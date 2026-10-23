# Runs Hollowtide's headless checks and prints one table of results (Claude, 2026-10-21, upgrade sweep).
#
#   python tools/debug/run_checks.py                  every check except arena_* and the long pilot chain
#   python tools/debug/run_checks.py stone town       only checks whose names contain "stone" or "town"
#   python tools/debug/run_checks.py pilot arena_tank a word that starts a check's name runs it even without --long or --arena
#   python tools/debug/run_checks.py --arena --long   also the arena checks and pilot_chain_check
#   python tools/debug/run_checks.py --md docs/team/sweep-2026-10-20/after-checks.md
#   python tools/debug/run_checks.py --godot /opt/godot --import   on Linux CI: name the Godot binary, import once first
#
# Why this exists: the checks count time in frames and were written for --fixed-fps 30 (their headers say so).
# Run without it, headless Godot draws about 145 frames a second, every wait ends four or five times early,
# and checks report broken stairs or empty teams that are not there. This runner always passes --fixed-fps 30.
# Each check also gets its own empty APPDATA folder, so no check can touch Preston's real save.
#
# Running the checks DOES change files in the repo. move_table_check rewrites docs/creatures/move-table-2026-10-09.md,
# pilot_chain_check rewrites docs/design/pilot-chain-2026-10-11.log, 37 other non-arena checks (and 34 arena ones)
# name a res://docs/ folder for stills or JSON, and galeshear_wings, opening_launch and relay_yard write to
# D:/dev/hollowtide-* folders.
# Check git status after a run and put back what you did not mean to change.
#
# Most checks exit 0 even when a line fails, so the result is read from what the check prints, not its exit code.
# The failure words below come from the checks themselves (grep of tools/debug/*_check.gd, 2026-10-21):
# "-> FAIL", "label: FAIL", "FAIL  what", "N FAILED", "-> WRONG", "(WRONG)", "WRONG: ...", "RESULT: N problems",
# "RESULT: problems", "N evolution problems", "RESULT n checks / N failures", and "label: false" from the two
# checks whose verdict is a bare true or false. Classes:
#   PASS     the check has ok/FAIL/WRONG/RESULT lines (or a non-zero quit) and none of them failed
#   RAN      it ran clean, but its script never judges anything; it only prints values for a person to read
#   FAIL     a failure line, a script error, an engine error not on the noise list, or a non-zero exit
#   WINDOW   a check that needs a drawn frame, run headless; a printed failure still makes it FAIL
#   TIMEOUT  it did not finish in time; RETIRED  it says it is retired (exit 2); BROKEN  a parse or compile error
# The runner itself exits 1 if any check FAILs, BREAKs or TIMEs OUT, and 2 if nothing was selected or Godot is missing.
# It ends with one table sorted by result (failures first) and an "exit N" line saying why (Claude, 2026-10-22, T0).

import argparse
import concurrent.futures
import functools
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEBUG = ROOT / "tools" / "debug"
DEFAULT_GODOT = r"C:\Users\pmcga\Games\Tools\Godot_v4.7.2\Godot_v4.7.2-stable_win64.exe"

# Checks that only make sense with a window: they wait for a drawn frame or stop at a screenshot.
# Headless they hang or error at the capture, so the runner reports them as WINDOW instead of FAIL,
# gives them only WINDOW_HEADLESS_SECS, and still reports any failure they printed before stopping.
# With --window they are judged like any other check.
WINDOW_ONLY = {
    "galeshear_wings_check", "listener_palette_check", "opening_launch_check", "relay_yard_check",
    "riverfront_quay_check", "world_navigation_check",
}
WINDOW_HEADLESS_SECS = 60
# Tools that live with the checks but need arguments; not run.
SKIP = {"back_idle_check": "a tool that needs an argument"}
# Long autopilot runs get more time than the default (or --timeout, if that is longer).
LONG = {"pilot_chain_check": 1500, "dungeon_boss_check": 600, "dungeon_chain_check": 600, "dungeon_evolve_check": 600, "lv1_run_check": 600}
# Excluded unless asked for: by flag, or by a word that starts the check's name ("arena", "pilot").
EXCLUDED = {"arena": lambda n: n.startswith("arena_"), "long": lambda n: n == "pilot_chain_check"}
IMPORT_SECS = 1200

FAIL_LINE = re.compile(
    r"\bWRONG\b"                                                    # '-> WRONG', '(WRONG)', 'WRONG: seed 3 ...'
    r"|\bFAIL(?:ED)?\b"                                             # '-> FAIL', 'label: FAIL', 'FAIL  what', '2 FAILED'
    r"|\b[1-9]\d*\s+(?:\w+\s+)?(?:failed|failures|problems?)\b"    # '(2 failed)', '/ 1 failures', '3 problems', '2 evolution problems'
    r"|RESULT:\s*problems\b"                                        # soul_prologue_check
)
# Only for checks whose source prints a bare bool as the verdict (BOOL_VERDICT_SRC); in other checks
# a line ending in ': false' is a value printed for reading (dungeon_battle, dungeon_recruit).
BOOL_FAIL_LINE = re.compile(r":\s*false\s*$")
BROKEN_LINE = re.compile(r"Parse Error|Failed to load script|Compile Error|Failed to compile")

# Read from the check's source (comments removed, plus the check it extends).
ASSERT_SRC = re.compile(
    r'"[^"\n]*\b(?:FAIL|FAILED|WRONG|PASS|RESULT)\b'        # a verdict word inside a string
    r'|"[^"\n]*%d\s+(?:\w+\s+)?(?:problems|failures)\b'     # '%d evolution problems' (roster_check)
    r'|quit\(\s*(?:[1-9]|[^)\n]*\bif\b)')                   # quit(1), quit(1 if fails else 0)
BOOL_VERDICT_SRC = re.compile(r'print\(\s*\w+\s*,\s*":\s*"\s*,\s*\w+(?:\[\w+\])?\s*\)')   # print(label, ": ", passed)
EXTENDS_SRC = re.compile(r'^extends\s+"res://(tools/debug/[^"]+\.gd)"', re.M)

# Godot's own error blocks: a head line, then indented 'at:' and backtrace lines.
ENGINE_HEAD = re.compile(r"^(SCRIPT ERROR|SCRIPT WARNING|USER ERROR|USER WARNING|ERROR|WARNING): (.*)")
ENGINE_TAIL = re.compile(r"^\s+(?:at: |GDScript backtrace|\[\d+\] )")
IN_CHECK_CODE = re.compile(r"\(res://tools/debug/")
# A screenshot taken headless: the check's own capture code gets a null image. Only exempt when the
# error's 'at:' is in tools/debug; the same null in game code (missing art, say) counts as an error.
CAPTURE_SCRIPT = re.compile(r"Cannot call method '(?:save_png|get_size|get_image|get_texture)' on a null value")
CAPTURE_ENGINE = re.compile(r'Parameter "t" is null')   # texture_2d_get in the dummy renderer, just before the above
# Engine ERROR lines that are known noise. Every other ERROR counts against the check, so a new kind gets
# noticed; that includes 'Resource file not found', 'Failed loading resource', 'previously freed' and
# 'Lambda capture ... was freed'. Add to this list only after reading where a new error comes from.
ENGINE_NOISE = (
    re.compile(r'Condition "!actions\.custom_samplers\.has'),   # the outline shaders (creature_finish.gd and friends), every check
    re.compile(r"ObjectDB instances were leaked at exit"),        # leak report at quit
    re.compile(r"resources still in use at exit"),               # leak report at quit
)


def _strip_comment(line: str) -> str:
    quote = ""
    i = 0
    while i < len(line):
        c = line[i]
        if quote:
            if c == "\\":
                i += 1
            elif c == quote:
                quote = ""
        elif c in "\"'":
            quote = c
        elif c == "#":
            return line[:i]
        i += 1
    return line


def _source(path: Path, seen: frozenset = frozenset()) -> str:
    if path in seen or not path.is_file():
        return ""
    code = "\n".join(_strip_comment(l) for l in path.read_text(encoding="utf-8", errors="replace").splitlines())
    m = EXTENDS_SRC.search(code)
    return code + ("\n" + _source(ROOT / m.group(1), seen | {path}) if m else "")


@functools.lru_cache(maxsize=None)
def traits(name: str) -> dict:
    """What the check's script can say: does it judge anything, and is its verdict a bare true/false?"""
    code = _source(DEBUG / f"{name}.gd")
    if not code:
        return {"asserts": True, "bool_verdict": False}   # no source to read: never hide a result as RAN
    return {"asserts": bool(ASSERT_SRC.search(code)), "bool_verdict": bool(BOOL_VERDICT_SRC.search(code))}


def _blocks(lines: list) -> tuple:
    """Split the log into printed lines and Godot error blocks (kind, message, 'at:' line, first backtrace frame)."""
    printed, blocks, in_block = [], [], False
    for l in lines:
        if not l.strip():
            continue   # blank lines (a log written with doubled line ends has one after every line) end nothing
        head = ENGINE_HEAD.match(l)
        if head:
            blocks.append({"kind": head.group(1), "msg": head.group(2).strip(), "at": "", "frame": ""})
            in_block = True
        elif in_block and ENGINE_TAIL.match(l):
            s, b = l.strip(), blocks[-1]
            if s.startswith("at: ") and not b["at"]:
                b["at"] = s
            elif s.startswith("[") and not b["frame"]:
                b["frame"] = s
        else:
            printed.append(l)
            in_block = False
    return printed, blocks


def classify(name: str, out: str, code: int, timed_out: bool, window: bool = False) -> dict:
    lines = out.splitlines()
    t = traits(name)
    printed, blocks = _blocks(lines)
    fails = [l.strip() for l in printed if FAIL_LINE.search(l) or (t["bool_verdict"] and BOOL_FAIL_LINE.search(l))]
    real_errors, capture_errors, stuck_at = [], 0, ""
    for b in blocks:
        where = b["at"] or b["frame"]
        if b["kind"] == "SCRIPT ERROR":
            if CAPTURE_SCRIPT.search(b["msg"]) and IN_CHECK_CODE.search(b["at"]):
                capture_errors += 1
                if "_initialize (" in b["at"]:
                    stuck_at = b["at"]   # the check's main coroutine ended here, so its quit() never runs
            else:
                real_errors.append(f"SCRIPT ERROR: {b['msg']} {where}")
        elif b["kind"] in ("ERROR", "USER ERROR"):
            if any(p.search(b["msg"]) for p in ENGINE_NOISE):
                continue
            if CAPTURE_ENGINE.search(b["msg"]) and "texture_2d_get" in b["at"] and IN_CHECK_CODE.search(b["frame"]):
                continue   # counted once, through the SCRIPT ERROR that follows it
            real_errors.append(f"ERROR: {b['msg']} {where}")
    broken = [l.strip() for l in lines if BROKEN_LINE.search(l)]
    last = next((l.strip() for l in reversed(printed) if l.strip()), "no output")
    needs_window = name in WINDOW_ONLY and not window
    if broken:
        cls, first = "BROKEN", broken[0]
    elif needs_window and fails:
        cls, first = "FAIL", fails[0]
    elif needs_window:
        cls, first = "WINDOW", f"needs a window; last line: {last}"
    elif timed_out:
        stuck = [f"stopped at a headless screenshot ({stuck_at}); guard it or use --window"] if stuck_at else []
        cls, first = "TIMEOUT", (fails or real_errors or stuck or [f"last line: {last}"])[0]
    elif code == 2 and "RETIRED" in out:
        cls, first = "RETIRED", "retired on purpose"
    elif fails or real_errors:
        cls, first = "FAIL", (fails or real_errors)[0]
    elif code != 0:
        cls, first = "FAIL", f"exit {code}; last line: {last}"
    elif not t["asserts"]:
        cls, first = "RAN", "prints values but judges nothing" + (f"; {capture_errors} screenshots skipped headless" if capture_errors else "")
    else:
        cls, first = "PASS", (f"{capture_errors} screenshots skipped headless" if capture_errors else "")
    return {"class": cls, "fails": len(fails), "errors": len(real_errors), "captures": capture_errors, "first": first}


def run_one(godot: str, name: str, timeout: int, window: bool, logs: Path) -> dict:
    appdata = Path(tempfile.mkdtemp(prefix=f"ht_{name}_"))
    env = dict(os.environ, APPDATA=str(appdata), XDG_DATA_HOME=str(appdata))
    cmd = [godot] + ([] if window else ["--headless"]) + [
        "--fixed-fps", "30", "--path", str(ROOT), "--script", f"res://tools/debug/{name}.gd"]
    start = time.time()
    timed_out = False
    try:
        # One pipe for both streams, so prints and errors stay in the order Godot wrote them.
        proc = subprocess.run(cmd, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=timeout)
        out = proc.stdout.decode("utf-8", "replace")
        code = proc.returncode
    except subprocess.TimeoutExpired as e:
        out = (e.stdout or b"").decode("utf-8", "replace")
        code, timed_out = 124, True
    secs = time.time() - start
    (logs / f"{name}.log").write_bytes(out.encode("utf-8"))   # bytes, so Windows line ends are not doubled
    shutil.rmtree(appdata, ignore_errors=True)
    return {"name": name, "secs": secs, "exit": code, **classify(name, out, code, timed_out, window)}


def find_godot(given: str) -> str:
    """The Godot binary: --godot, then GODOT, then Preston's copy on Windows. Empty if none is usable."""
    godot = given or os.environ.get("GODOT", "") or (DEFAULT_GODOT if os.name == "nt" else "")
    if not godot:
        return ""
    return godot if (Path(godot).is_file() or shutil.which(godot)) else ""


def import_project(godot: str, logs: Path) -> bool:
    """A fresh clone has no .godot/ folder, so textures and scripts are not imported yet. Do that once."""
    appdata = Path(tempfile.mkdtemp(prefix="ht_import_"))
    env = dict(os.environ, APPDATA=str(appdata), XDG_DATA_HOME=str(appdata))
    print(f"importing the project (up to {IMPORT_SECS} s)", flush=True)
    try:
        proc = subprocess.run([godot, "--headless", "--import", "--path", str(ROOT)], env=env,
                              stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=IMPORT_SECS)
        out, code = proc.stdout.decode("utf-8", "replace"), proc.returncode
    except subprocess.TimeoutExpired as e:
        out, code = (e.stdout or b"").decode("utf-8", "replace"), 124
    (logs / "_import.log").write_bytes(out.encode("utf-8"))
    shutil.rmtree(appdata, ignore_errors=True)
    if code != 0:
        print(f"import failed (exit {code}); see {logs / '_import.log'}", flush=True)
    return code == 0


def select(all_names: list, words: list, arena: bool, long: bool) -> list:
    def excluded(n: str) -> bool:
        return (EXCLUDED["arena"](n) and not arena) or (EXCLUDED["long"](n) and not long)
    if not words:
        return [n for n in all_names if not excluded(n)]
    # A word that starts the name ('pilot', 'arena_tank') is an explicit request and beats the exclusions;
    # a word inside the name ('vfx', 'chain') still leaves arena_* and pilot_chain out unless their flag is set.
    return [n for n in all_names
            if any(n.startswith(w) for w in words) or (any(w in n for w in words) and not excluded(n))]


def main() -> int:
    ap = argparse.ArgumentParser(description="Run Hollowtide's headless checks at --fixed-fps 30.")
    ap.add_argument("only", nargs="*", help="run only checks whose names contain one of these words")
    ap.add_argument("--godot", default="", help="the Godot binary (default: GODOT, then Preston's Windows copy)")
    ap.add_argument("--jobs", type=int, default=4, help="checks run side by side (default 4)")
    ap.add_argument("--timeout", type=int, default=300, help="seconds per check (default 300; long checks get more)")
    ap.add_argument("--arena", action="store_true", help="include the arena_* checks")
    ap.add_argument("--long", action="store_true", help="include pilot_chain_check (twenty minutes or more)")
    ap.add_argument("--window", action="store_true", help="run with a window, so screenshot checks can finish")
    ap.add_argument("--import", dest="do_import", action="store_true", help="run 'godot --headless --import' once first (fresh clones, CI)")
    ap.add_argument("--logs", default="", help="folder for the logs (default: a new temp folder)")
    ap.add_argument("--md", default="", help="also write the table to this markdown file")
    a = ap.parse_args()

    godot = find_godot(a.godot)
    if not godot:
        where = a.godot or os.environ.get("GODOT", "") or (DEFAULT_GODOT if os.name == "nt" else "")
        if where:
            print(f"Godot not found at {where}. Pass --godot <path> or set GODOT.", file=sys.stderr)
        else:
            print("No Godot binary given. Off Windows, pass --godot <path> or set GODOT (Godot 4.7.2).", file=sys.stderr)
        return 2

    all_names = sorted(p.stem for p in DEBUG.glob("*_check.gd"))
    names = select(all_names, a.only, a.arena, a.long)
    for w in a.only:
        if not any(w in n for n in all_names):
            print(f"no check name contains '{w}'", flush=True)
    skipped = [n for n in names if n in SKIP]
    names = [n for n in names if n not in SKIP]
    if not names:
        print("No checks selected" + (f" by {' '.join(a.only)}" if a.only else "") +
              ". arena_* need --arena or a word like 'arena', pilot_chain needs --long or 'pilot'.", file=sys.stderr)
        return 2
    logs = Path(a.logs) if a.logs else Path(tempfile.mkdtemp(prefix="ht_checks_"))
    logs.mkdir(parents=True, exist_ok=True)
    if a.do_import and not import_project(godot, logs):
        return 1
    print(f"{len(names)} checks, {a.jobs} at a time, logs in {logs}", flush=True)

    def budget(n: str) -> int:
        if n in WINDOW_ONLY and not a.window:
            return WINDOW_HEADLESS_SECS
        return max(LONG.get(n, 0), a.timeout)

    results = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=a.jobs) as pool:
        jobs = {pool.submit(run_one, godot, n, budget(n), a.window, logs): n for n in names}
        for f in concurrent.futures.as_completed(jobs):
            r = f.result()
            results.append(r)
            print(f"  {r['class']:8s} {r['name']:32s} {r['secs']:6.1f}s  {r['first'][:110]}", flush=True)

    order = ["BROKEN", "FAIL", "TIMEOUT", "WINDOW", "RAN", "RETIRED", "PASS"]
    results.sort(key=lambda r: (order.index(r["class"]), r["name"]))
    # The whole run once more as one table, failures first, for the integrator (Claude, 2026-10-22, T0):
    # the lines above arrive in finishing order, this one is sorted by result.
    print(f"\n{'RESULT':8s} {'CHECK':32s} {'SECS':>6s}  {'EXIT':>4s}  FIRST PROBLEM OR NOTE")
    for r in results:
        print(f"{r['class']:8s} {r['name']:32s} {r['secs']:6.1f}  {r['exit']:4d}  {r['first'][:100]}")
    for n in skipped:
        print(f"{'SKIPPED':8s} {n:32s} {'':6s}  {'':4s}  {SKIP[n]}")
    counts = {}
    for r in results:
        counts[r["class"]] = counts.get(r["class"], 0) + 1
    summary = ", ".join(f"{k} {v}" for k, v in counts.items()) + (f", SKIPPED {len(skipped)}" if skipped else "")
    print("\n" + summary)
    if counts.get("RAN"):
        print("RAN: those checks have no ok/FAIL/WRONG/RESULT line; read their logs to judge them.")

    if a.md:
        rows = ["| Check | Result | Secs | Exit | Fail lines | Errors | First problem or note |", "|---|---|---|---|---|---|---|"]
        for r in results:
            note = r["first"].replace("|", "/")[:160]
            rows.append(f"| {r['name']} | {r['class']} | {r['secs']:.0f} | {r['exit']} | {r['fails']} | {r['errors']} | {note} |")
        for n in skipped:
            rows.append(f"| {n} | SKIPPED | | | | | {SKIP[n]} |")
        legend = ("RAN means the check ran clean but its script judges nothing. Errors counts script errors and "
                  "engine errors not on the runner's noise list. This run may have rewritten files under docs/.")
        md = Path(a.md)
        md.parent.mkdir(parents=True, exist_ok=True)
        md.write_bytes((f"Totals: {summary}\n\n{legend}\n\n" + "\n".join(rows) + "\n").encode("utf-8"))
    bad = sum(counts.get(k, 0) for k in ("BROKEN", "FAIL", "TIMEOUT"))
    print(f"exit {1 if bad else 0}: " + (f"{bad} check{'' if bad == 1 else 's'} failed, broke or timed out" if bad else "nothing failed"))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
