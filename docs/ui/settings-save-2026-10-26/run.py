from pathlib import Path
import json,os,subprocess,sys
W=Path(__file__).parent
phase=sys.argv[1];assert phase in ('before','after','restart','failures')
profile='baseline' if phase=='before' else 'installed'
env=os.environ.copy();env['APPDATA']=str(W/(profile+'-profile'));env['LOCALAPPDATA']=str(W/(profile+'-local-profile'));env['HT_SETTINGS_PHASE']=phase
cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path','C:/Users/pmcga/dev/hollowtide','--rendering-method','gl_compatibility','--audio-driver','Dummy','--fixed-fps','30','--script',str(W/'settings_check.gd')]
p=subprocess.run(cmd,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=90,creationflags=subprocess.CREATE_NO_WINDOW)
log=p.stdout+p.stderr
(W/(phase+'.log')).write_text(log,encoding='utf-8');(W/(phase+'-command.json')).write_text(json.dumps({'command':cmd,'APPDATA':env['APPDATA'],'LOCALAPPDATA':env['LOCALAPPDATA'],'exit':p.returncode},indent=2),encoding='utf-8')
print(log[-7000:]);assert p.returncode==0
assert 'SCRIPT ERROR' not in log and 'ObjectDB instances were leaked' not in log
if phase not in ('before','failures'):assert 'ERROR:' not in log
if phase!='before':assert json.loads((W/(phase+'-result.json')).read_text())['failed']==0
