from pathlib import Path
import os,subprocess
W=Path(__file__).parent
env=os.environ.copy();env['APPDATA']=str(W/'live-profile')
args=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path','C:/Users/pmcga/dev/hollowtide','--rendering-method','gl_compatibility','--fixed-fps','30','--verbose','--script',str(W/'quit_title.gd')]
with (W/'quit_verbose.log').open('w') as f:code=subprocess.run(args,env=env,stdout=f,stderr=subprocess.STDOUT,timeout=60).returncode
print('Verbose title Quit exit',code)
