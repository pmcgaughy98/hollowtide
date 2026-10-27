from pathlib import Path
import os,sys,json,subprocess
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');phase=sys.argv[1]
env=os.environ.copy();env['APPDATA']=str(W/(phase+'-profile'));env['LOCALAPPDATA']=str(W/(phase+'-local-profile'))
if phase=='official':cmd=[sys.executable,str(L/'tools/debug/run_checks.py'),'storm_open','opening_flow','--jobs','1','--logs',str(W/'runner'),'--md',str(W/'runner-result.md')]
else:cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(L),'--rendering-method','gl_compatibility','--audio-driver','Dummy','--fixed-fps','30','--script',str(W/'native_check.gd'),'--',phase]
p=subprocess.run(cmd,cwd=L,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=120,creationflags=subprocess.CREATE_NO_WINDOW)
log=p.stdout+p.stderr;(W/(phase+'.log')).write_text(log,encoding='utf-8');(W/(phase+'-command.json')).write_text(json.dumps({'command':cmd,'APPDATA':env['APPDATA'],'LOCALAPPDATA':env['LOCALAPPDATA'],'exit':p.returncode},indent=2));print(log[-6000:]);assert p.returncode==0
if phase!='official':assert not any(x in log for x in ('SCRIPT ERROR','ERROR:','ObjectDB instances were leaked')) and json.loads((W/(phase+'-result.json')).read_text())['failed']==0
