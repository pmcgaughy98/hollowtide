from pathlib import Path
import subprocess,sys
W=Path(__file__).parent
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
q=C/'assets/sprites/world/home_interior_2026_10_10/home_native.png'
hold=W/'fallback-hold-home.png'
assert q.resolve().is_relative_to(C.resolve()) and not hold.exists()
q.rename(hold)
board=C/'assets/sprites/world/job_board_selout_2026_10_10/board_native.png'
board_hold=W/'fallback-hold-board.png'
assert board.resolve().is_relative_to(C.resolve()) and not board_hold.exists()
board.rename(board_hold)
try:
    p=subprocess.run([sys.executable,str(W/'run.py'),'home_fallback'])
finally:
    assert not q.exists()
    hold.rename(q)
    board_hold.rename(board)
raise SystemExit(p.returncode)
