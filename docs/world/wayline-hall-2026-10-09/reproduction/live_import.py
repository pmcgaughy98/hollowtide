from pathlib import Path
import os,subprocess
W=Path(__file__).parent
env=os.environ.copy();env['APPDATA']=str(W/'live-import-profile')
(W/'live-import-profile').mkdir(exist_ok=True)
args=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path','C:/Users/pmcga/dev/hollowtide','--headless','--editor','--import','--quit']
with (W/'live_import.log').open('w') as f:
    p=subprocess.Popen(args,env=env,stdout=f,stderr=subprocess.STDOUT,creationflags=subprocess.CREATE_NO_WINDOW)
    try:code=p.wait(timeout=900)
    except subprocess.TimeoutExpired:p.kill();p.wait();raise
print('Live Godot import exit',code);raise SystemExit(code)
