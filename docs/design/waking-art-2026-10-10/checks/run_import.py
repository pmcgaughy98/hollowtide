from pathlib import Path
import subprocess,os
W=Path(__file__).parent
env=os.environ.copy();env['APPDATA']=str(W/'live-profile')
args=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path','C:/Users/pmcga/dev/hollowtide','--headless','--editor','--rendering-method','gl_compatibility','--import','--quit']
with (W/'live-editor-import.log').open('w',encoding='utf-8') as f:r=subprocess.run(args,env=env,stdout=f,stderr=subprocess.STDOUT,timeout=240,creationflags=subprocess.CREATE_NO_WINDOW)
print('Editor import exit',r.returncode);print((W/'live-editor-import.log').read_text(encoding='utf-8',errors='replace')[-2000:])
