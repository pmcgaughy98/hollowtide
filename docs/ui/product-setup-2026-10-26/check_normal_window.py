from pathlib import Path
import subprocess,os,time,json
from check_window import capture
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');G='C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe'
env=os.environ.copy();env['APPDATA']=str(W/'normal-profile');env['LOCALAPPDATA']=str(W/'normal-local-profile')
cmd=[G,'--path',str(L),'--rendering-method','gl_compatibility','--audio-driver','Dummy','--fixed-fps','30']
with open(W/'normal-window.log','w',encoding='utf-8') as log:
 p=subprocess.Popen(cmd,cwd=L,env=env,stdout=log,stderr=log,creationflags=subprocess.CREATE_NO_WINDOW)
 try:
  time.sleep(4);capture(p.pid)
 finally:
  p.terminate();p.wait(timeout=15)
(W/'normal-window-command.json').write_text(json.dumps({'command':cmd,'APPDATA':env['APPDATA'],'LOCALAPPDATA':env['LOCALAPPDATA'],'shutdown':'own test process terminated after read-only icon capture'},indent=2))
print((W/'window-icon-result.json').read_text())
