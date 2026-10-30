"""Pass 9 dungeon lane: CR LF counts of the lane's edited files, now and at HEAD, so an edit never mixes line ends.
python -I eol_check.py (run from the repo root)"""
import subprocess

FILES = ["tools/debug/arena_protector_check.gd", "tools/debug/job_board_check.gd", "tools/debug/hollow_check.gd",
         "tools/debug/pilot_chain_check.gd", "scripts/town/jobs.gd", "scripts/dungeon/dungeon.gd",
         "scripts/arena/arena_prototype.gd", "tools/debug/dual_essence_check.gd", "docs/creatures/hollow-wilds-2026-10-10.md"]
for f in FILES:
    now = open(f, "rb").read()
    head = subprocess.run(["git", "show", "HEAD:" + f], capture_output=True).stdout
    print(f"{f}: now {now.count(b'\r\n')} CRLF of {now.count(b'\n')} lines; HEAD {head.count(b'\r\n')} of {head.count(b'\n')}")
