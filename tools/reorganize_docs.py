"""Sort the loose files at the top of docs/ into topic folders (Preston,
2026-09-30: "too many duplicates, files everywhere, takes me a long time to
find things").

Moves each file with `git mv` (so history follows it) and rewrites every
reference to it: `docs/<name>` paths anywhere in the repository, CLAUDE.md,
AGENTS.md and Claude's memory, plus relative Markdown links between docs.
Run once from the project folder; a second run finds nothing to move.

  python tools/reorganize_docs.py           # do it
  python tools/reorganize_docs.py --check   # only count broken links
"""
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DOCS = ROOT / "docs"
MEMORY = Path.home() / ".claude/projects/C--Users-pmcga-dev-hollowtide/memory"

FOLDERS = {
    "team": "How the assistants work together: roles, plans, handoffs, setup.",
    "world": "The world, the route, the story and the people in it.",
    "creatures": "The roster, each creature line, sprites and back views.",
    "battle": "Battle rules, moves, attack animation and camera.",
    "audio": "Music prompts and sound design.",
    "forges": "Opal Forge prompts, records, and the Gemini skill exports.",
    "art": "Art direction, palettes, rigs and review images.",
    "research": "Gemini and Grok research tasks and what was adopted.",
}

MOVES = {
    "team": ["agent-role-charter-2026-09-27.md", "claude-work-plan.md", "claude-next-shift-handoff.md",
             "what-actually-constrains-this.md", "production-reality-and-the-64px-decision.md",
             "runtime-verification.md", "godot-mcp-setup.md", "asset-location-index.md",
             "codex-style-consistency-brief-2026-09-29.md", "codex-title-card-brief-2026-09-30.md"],
    "world": ["world-bible.md", "region-atlas-draft.md", "far-bank-slice-draft.md", "first-route-art-pass-brief.md",
              "first-route-playguide.md", "opening-chapter-production-path.md", "overworld-perspective-brief.md",
              "character-cast-draft.md"],
    "creatures": ["creature-roster-draft.md", "reshape-proposal.md", "river-listener-line.md",
                  "personal-stone-line-proposal.md", "creature-scale-research-adoption.md", "creature-scale-proposals.csv",
                  "ember-creature-physiology-and-action-brief-2026-09-27.md", "vitrecrag-redraw-job.md",
                  "vitrecrag-back-conformance.md", "vitrecrag-back-imagegen-brief.md",
                  "cinderhide-sprite-quality-research-adoption.md", "sprite-production-board.md",
                  "ludo-vitrecrag-back-foot-fix-2026-09-30.md"],
    "battle": ["battle-rules.md", "battle-animation-direction-2026-09-27.md", "battle-camera-brief.md",
               "attack-sheet-protocol.md", "move-structure-decisions-2026-09-28.md", "ember-move-set.md",
               "river-listener-moves-draft.md", "defensive-move-rules-draft.md", "game-feel.md",
               "move-effect-sources.json"],
    "audio": ["music-prompts.md", "audio-research-takeaways-2026-09-29.md", "game-sound-direction-2026-09-30.md",
              "ironvent-sound-prompts-2026-09-30.md", "vitrecrag-sound-prompts-2026-09-29.md"],
    "forges": ["opal-back-view-app-v4.md", "opal-effect-sheet-prompt-v1.md", "opal-evolution-forge-prompt-v1.md",
               "opal-sprite-forge-prompt-v1-backup.md", "opal-sprite-forge-prompt-v2.md",
               "opal-sprite-forge-prompt-v3-back-view.md", "opal-sprite-forge-prompt-v3.md",
               "opal-sprite-forge-prompt-v4.md", "opal-sprite-forge-prompt-v6.md", "forge-hub-2026-09-30.md",
               "forge-live-status-2026-09-27.md", "forge-production-standard.md",
               "forge-rig-readiness-pending-2026-09-27.md", "forge-update-2026-09-29.md",
               "attack-forge-creature-prompts-2026-09-27.md", "ironvent-furnace-roar-cutin-forge-prompt-2026-09-30.md",
               "ironvent-furnace-roar-impact-forge-prompt-2026-09-28.md",
               "oxbowarchon-kingstone-rail-cutin-forge-prompt-2026-09-29.md", "vitrecrag-back-forge-prompt-2026-09-28.md",
               "vitrecrag-molten-glass-cutin-forge-prompt-2026-09-28.md",
               "vitrecrag-molten-glass-meltdown-forge-prompt-2026-09-28.md",
               "new-courier-character-forge-prompt-2026-09-30.md", "preostmar-line-attack-forge-prompts-2026-09-29.md",
               "ember-forge-prompt-pack.md", "idle-forge-prompt-pack.md", "sprite-generation.md",
               "walk-cycle-forge-workflow.md", "world-asset-forge-prompts-2026-09-30.md",
               "world-asset-forge-spec-2026-09-30.md"],
    "art": ["art-direction.md", "animation-rig-strategy.md", "cinderhide-cutout-rig-pilot.md",
            "creature-cutout-rigs-2026-09-27.md", "idle-animation-workflow.md", "vitrecrag-glass-style-review.png",
            "vitrecrag-plate-style-review.png"],
    "research": ["gemini-attack-animation-research-task.md", "gemini-combat-animation-research-adoption.md",
                 "gemini-cutout-rig-research-adoption.md", "gemini-cutout-rig-research-task.md",
                 "gemini-deep-research-queue.md", "gemini-ember-creature-animation-research-task.md",
                 "gemini-prompt-code-drawn-pixel-vfx-2026-09-29.md", "gemini-prompt-game-audio-layering-2026-09-29.md",
                 "gemini-prompt-signature-moves-2026-09-28.md", "gemini-research-2026-09-27-adoption.md",
                 "vfx-research-takeaways-2026-09-29.md"],
}
# Generated by Godot importing the CSV as translations; inert once docs/ is not imported.
GENERATED = ["creature-scale-proposals.csv.import", "creature-scale-proposals.battle.translation",
             "creature-scale-proposals.height.translation", "creature-scale-proposals.idle.translation",
             "creature-scale-proposals.mass.translation", "creature-scale-proposals.name.translation",
             "creature-scale-proposals.source.translation", "vitrecrag-glass-style-review.png.import",
             "vitrecrag-plate-style-review.png.import"]

TEXT = {".md", ".gd", ".py", ".json", ".tres", ".tscn", ".txt", ".cfg", ".toml", ".gdshader", ".csv"}
LINK = re.compile(r"(\]\()([^)\s]+)(\))|(^\[[^\]]+\]:\s*)(\S+)", re.M)


def git(*args: str) -> str:
    return subprocess.run(["git", *args], cwd=ROOT, capture_output=True, text=True, check=True).stdout


def text_files() -> list:
    files = [ROOT / p for p in git("ls-files").splitlines()]
    files += [ROOT / p for p in git("ls-files", "--others", "--exclude-standard").splitlines()]
    extra = [ROOT / "CLAUDE.md", ROOT / "AGENTS.md"] + (list(MEMORY.glob("*.md")) if MEMORY.exists() else [])
    seen, out = set(), []
    for f in files + extra:
        if f in seen or not f.is_file() or f.suffix not in TEXT:
            continue
        if any(part in ("Codex", "crystal-creatures-concept", "archive", ".godot") for part in f.parts):
            continue
        seen.add(f)
        out.append(f)
    return out


def broken_links(files: list) -> int:
    n = 0
    for f in files:
        if f.suffix != ".md":
            continue
        for m in LINK.finditer(f.read_text(encoding="utf-8", errors="ignore")):
            target = (m.group(2) or m.group(5) or "").split("#")[0]
            if not target or re.match(r"^[a-z]+:", target) or target.startswith("/"):
                continue
            if not (f.parent / target.replace("%20", " ")).exists():
                n += 1
    return n


def main() -> None:
    files = text_files()
    before = broken_links(files)
    if "--check" in sys.argv:
        print("broken relative links:", before)
        return
    moved = {}  # old Path -> new Path
    for folder, names in MOVES.items():
        (DOCS / folder).mkdir(exist_ok=True)
        for name in names:
            old, new = DOCS / name, DOCS / folder / name
            if old.exists():
                git("mv", str(old.relative_to(ROOT)), str(new.relative_to(ROOT)))
                moved[old] = new
    for name in GENERATED:
        p = DOCS / name
        if p.exists():
            tracked = git("ls-files", str(p.relative_to(ROOT))).strip()
            git("rm", "-q", str(p.relative_to(ROOT))) if tracked else p.unlink()
    files = [moved.get(f, f) for f in files]
    by_old_name = {old.name: new for old, new in moved.items()}
    inverse = {new: old for old, new in moved.items()}
    changed = 0
    for f in files:
        src = f.read_text(encoding="utf-8", errors="ignore")
        out = src
        # 1. Repository paths: docs/<name> -> docs/<folder>/<name> (also docs\<name>).
        for name, new in by_old_name.items():
            rel = new.relative_to(ROOT).as_posix()
            out = re.sub(r"(?<![\w/.-])docs[/\\]" + re.escape(name), rel, out)
        # 2. Relative Markdown links, resolved from where this file used to be.
        if f.suffix == ".md":
            old_dir = inverse.get(f, f).parent

            def fix(m: re.Match) -> str:
                prefix, target, suffix = (m.group(1), m.group(2), m.group(3)) if m.group(1) else (m.group(4), m.group(5), "")
                path, _, anchor = target.partition("#")
                if not path or re.match(r"^[a-z]+:", path) or path.startswith("/") or path.startswith("docs/"):
                    return m.group(0)
                resolved = (old_dir / path.replace("%20", " ")).resolve()
                resolved = moved.get(resolved, resolved)
                if not resolved.exists():
                    return m.group(0)
                rel = Path(os.path.relpath(resolved, f.parent)).as_posix().replace(" ", "%20")
                return prefix + rel + ("#" + anchor if anchor else "") + suffix
            out = LINK.sub(fix, out)
        if out != src:
            f.write_text(out, encoding="utf-8")
            changed += 1
    after = broken_links(files)
    print(f"moved {len(moved)} files, updated references in {changed} files")
    print(f"broken relative links: {before} before, {after} after")


if __name__ == "__main__":
    main()
