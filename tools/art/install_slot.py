"""Installs a reviewed candidate into its art slot (Claude, 2026-10-26, placeholder factory contract;
03-spec-format.md sections 3.5 and 4.5).

    python tools/art/install_slot.py <slot_id> <candidate.png> --batch <batch_id> [--dry-run] [--no-godot]

Refuses, and changes nothing, when:
  - a CODEX_IN_PROGRESS lock sits in the batch folder (docs/art/slot-candidates/<batch>/), the slot's candidate
    folder there, or the slot's asset folder;
  - the candidate fails tools/art/validate_slot.py;
  - the batch's review.json does not hold Preston's "yes" for this slot. Nothing installs without his yes.
Otherwise it backs up the file it replaces to docs/art/slot-backups/<date>/, copies the candidate to the slot's file,
records its SHA-256 in docs/design/placeholder-factory-2026-10-26/installed.json, sets the slot's status to
"installed" in its slot file (keeping that file's line ends), then runs `godot --headless --import` and exports
slots.json again (skip both with --no-godot). review.json is {"slots": {"<slot_id>": {"answer": "yes"}}} (or
{"<slot_id>": "yes"}); answers are yes, redo or keep.
"""
import argparse
import datetime
import hashlib
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import slot_registry as reg  # noqa: E402
import validate_slot  # noqa: E402

CANDIDATES = reg.ROOT / "docs" / "art" / "slot-candidates"
BACKUPS = reg.ROOT / "docs" / "art" / "slot-backups"
INSTALLED = reg.DOC / "installed.json"
LOCK = "CODEX_IN_PROGRESS"


def answer(batch_dir: Path, slot_id: str) -> str:
    p = batch_dir / "review.json"
    if not p.is_file():
        return ""
    doc = json.loads(p.read_text(encoding="utf-8"))
    a = doc.get("slots", {}).get(slot_id, doc.get(slot_id, ""))
    if isinstance(a, dict):
        a = a.get("answer", "")
    return str(a).strip().lower()


def set_status(slot_id: str, status: str) -> Path:
    """Rewrites `"status": "..."` inside the slot's row in whichever slot file holds it, line ends kept."""
    for f in sorted(reg.SLOT_DIR.glob("*.gd")):
        raw = f.read_bytes()
        text = raw.decode("utf-8")
        start = text.find('\t"%s": {' % slot_id)
        if start < 0:
            continue
        end = text.find("\n\t},", start)
        row = text[start:end]
        new_row, n = re.subn(r'"status": "[a-z_]+"', '"status": "%s"' % status, row, count=1)
        if n != 1:
            raise RuntimeError(f"{f.name}: no status field in {slot_id}'s row")
        f.write_bytes((text[:start] + new_row + text[end:]).encode("utf-8"))
        return f
    raise RuntimeError(f"no slot file holds {slot_id}")


def main() -> int:
    ap = argparse.ArgumentParser(description="Install a reviewed candidate into its art slot.")
    ap.add_argument("slot_id")
    ap.add_argument("candidate")
    ap.add_argument("--batch", required=True)
    ap.add_argument("--dry-run", action="store_true", help="check everything, change nothing")
    ap.add_argument("--no-godot", action="store_true", help="skip the import and the slots.json export")
    a = ap.parse_args()
    try:
        s = reg.spec(a.slot_id)
    except (reg.StaleRegistry, KeyError) as e:
        print(f"refused: {e}")
        return 2
    cand = Path(a.candidate)
    target = reg.res_path(s["file"])
    batch_dir = CANDIDATES / a.batch
    for lock_dir in (batch_dir, batch_dir / a.slot_id, target.parent):
        if (lock_dir / LOCK).exists():
            print(f"refused: {LOCK} lock in {lock_dir}")
            return 3
    if not cand.is_file():
        print(f"refused: no candidate at {cand}")
        return 2
    report = validate_slot.run(a.slot_id, cand)
    if not report["pass"]:
        failed = [f"{r['id']} {r['detail']}" for r in report["results"] if r["result"] == "FAIL"]
        print("refused: the candidate fails " + "; ".join(failed))
        return 4
    said = answer(batch_dir, a.slot_id)
    if said != "yes":
        print(f"refused: {batch_dir / 'review.json'} holds '{said or 'nothing'}' for {a.slot_id}; it installs only on Preston's yes")
        return 5
    digest = hashlib.sha256(cand.read_bytes()).hexdigest()
    if a.dry_run:
        print(f"dry run: would install {cand} -> {target} (sha256 {digest[:12]}), status installed")
        return 0
    if target.is_file():
        day = BACKUPS / datetime.date.today().isoformat()
        day.mkdir(parents=True, exist_ok=True)
        shutil.copy2(target, day / f"{a.slot_id}.png")
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(cand, target)
    record = json.loads(INSTALLED.read_text(encoding="utf-8")) if INSTALLED.is_file() else {"slots": {}}
    record.setdefault("slots", {})[a.slot_id] = {"sha256": digest, "file": s["file"], "batch": a.batch,
                                                 "date": datetime.date.today().isoformat()}
    INSTALLED.write_text(json.dumps(record, indent=1, sort_keys=True) + "\n", encoding="utf-8")
    holder = set_status(a.slot_id, "installed")
    print(f"installed {a.slot_id}: {cand} -> {s['file']} (sha256 {digest[:12]}); status set in {holder.name}")
    if a.no_godot:
        print(f"skipped the import and the export; run them before the next tool: godot --headless --import, then {reg.EXPORT_HINT}")
        return 0
    g = reg.godot()
    if not g:
        print("Godot not found (set GODOT); run the import and the slots.json export by hand")
        return 0
    subprocess.run([g, "--headless", "--import", "--path", str(reg.ROOT)], check=False)
    subprocess.run([g, "--headless", "--path", str(reg.ROOT), "--script", "res://tools/art/render_slot_refs.gd", "--", "--export-only"], check=False)
    print("imported and exported slots.json; run python tools/debug/run_checks.py art_slots --jobs 1")
    return 0


if __name__ == "__main__":
    sys.exit(main())
