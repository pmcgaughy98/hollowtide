from pathlib import Path
import os,subprocess
W=Path(__file__).parent
env=os.environ.copy();env['APPDATA']=str(W/'live-import-profile')
args=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path','C:/Users/pmcga/dev/hollowtide','--headless','--script',str(W/'live_smoke.gd')]
with (W/'live_smoke.log').open('w') as f:
    p=subprocess.Popen(args,env=env,stdout=f,stderr=subprocess.STDOUT,creationflags=subprocess.CREATE_NO_WINDOW)
    try:code=p.wait(timeout=120)
    except subprocess.TimeoutExpired:p.kill();p.wait();raise
print('Installed Home smoke exit',code);raise SystemExit(code)
