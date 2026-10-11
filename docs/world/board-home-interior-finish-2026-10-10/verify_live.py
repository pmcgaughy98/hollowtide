from pathlib import Path
import subprocess,sys
W=Path(__file__).parent
for name in ['finish_check','room_spots_check','hub_town_check','job_board_check','capture']:
    p=subprocess.run([sys.executable,str(W/'run.py'),name,'--live'])
    if p.returncode: raise SystemExit(p.returncode)
