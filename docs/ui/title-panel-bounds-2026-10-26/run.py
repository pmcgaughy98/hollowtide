from pathlib import Path
import json,os,subprocess,sys
W=Path(__file__).parent
stage=sys.argv[1]
assert stage in ('before','after','legacy','ui_fit')
env=os.environ.copy();env['APPDATA']=str(W/(stage+'-profile'));env['LOCALAPPDATA']=str(W/(stage+'-local-profile'));env['HT_TITLE_STAGE']=stage
cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path','C:/Users/pmcga/dev/hollowtide','--rendering-method','gl_compatibility','--audio-driver','Dummy','--fixed-fps','30','--script',str(W/('ui_fit_private.gd' if stage=='ui_fit' else 'native_check.gd'))]
p=subprocess.run(cmd,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=100,creationflags=subprocess.CREATE_NO_WINDOW)
log=p.stdout+p.stderr
(W/(stage+'.log')).write_text(log,encoding='utf-8');(W/(stage+'-command.json')).write_text(json.dumps({'command':cmd,'APPDATA':env['APPDATA'],'LOCALAPPDATA':env['LOCALAPPDATA'],'exit':p.returncode},indent=2),encoding='utf-8')
print(log[-10000:])
assert p.returncode==0
assert not any(s in log for s in ('SCRIPT ERROR','ERROR:'))
if stage in ('after','ui_fit'): assert 'ObjectDB instances were leaked' not in log
if stage!='before':assert 'FAIL' not in log
