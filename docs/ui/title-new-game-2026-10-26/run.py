from pathlib import Path
import json,os,subprocess,sys
W=Path(__file__).parent;phase=sys.argv[1];assert phase in ('native','ui_fit')
env=os.environ.copy();env['APPDATA']=str(W/(phase+'-profile'));env['LOCALAPPDATA']=str(W/(phase+'-local-profile'))
cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path','C:/Users/pmcga/dev/hollowtide','--rendering-method','gl_compatibility','--audio-driver','Dummy','--fixed-fps','30','--script',str(W/('ui_fit_private.gd' if phase=='ui_fit' else 'native_check.gd'))]
p=subprocess.run(cmd,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=100,creationflags=subprocess.CREATE_NO_WINDOW)
log=p.stdout+p.stderr;(W/(phase+'.log')).write_text(log,encoding='utf-8');(W/(phase+'-command.json')).write_text(json.dumps({'command':cmd,'APPDATA':env['APPDATA'],'LOCALAPPDATA':env['LOCALAPPDATA'],'exit':p.returncode},indent=2),encoding='utf-8')
print(log[-9000:]);assert p.returncode==0
assert not any(s in log for s in ('SCRIPT ERROR','ERROR:','ObjectDB instances were leaked'))
if phase=='native':assert json.loads((W/'native-result.json').read_text())['failed']==0
else:assert 'ui fit: all ok' in log
