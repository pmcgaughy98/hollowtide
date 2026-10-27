from pathlib import Path
import os,subprocess,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
env=os.environ.copy();env['APPDATA']=str(W/'native-profile');env['LOCALAPPDATA']=str(W/'native-local-profile');(W/'native-profile').mkdir(exist_ok=True)
cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(L),'--rendering-method','gl_compatibility','--audio-driver','Dummy','--fixed-fps','30','--script',str(W/'native_check.gd')]
p=subprocess.run(cmd,cwd=L,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=90,creationflags=subprocess.CREATE_NO_WINDOW)
log=p.stdout+p.stderr;(W/'native.log').write_text(log);(W/'native-command.json').write_text(json.dumps({'command':cmd,'APPDATA':env['APPDATA'],'LOCALAPPDATA':env['LOCALAPPDATA'],'exit':p.returncode},indent=2));print(log[-4500:]);assert p.returncode==0
assert json.loads((W/'native-result.json').read_text())['failed']==0 and 'ERROR:' not in log and 'SCRIPT ERROR' not in log
