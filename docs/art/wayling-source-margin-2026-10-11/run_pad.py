from pathlib import Path
import os,subprocess
W=Path(__file__).parent
env=os.environ.copy();env['APPDATA']=str(W/'profile');env['LOCALAPPDATA']=str(W/'profile')
cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--headless','--path','D:/dev/hollowtide-world-refinement-20261008/project','--script',str(W/'pad.gd')]
with (W/'pad.log').open('w',encoding='utf-8') as f:
    result=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,env=env,creationflags=subprocess.CREATE_NO_WINDOW,timeout=30)
log=(W/'pad.log').read_text();print(log);assert result.returncode==0 and 'SCRIPT ERROR' not in log
