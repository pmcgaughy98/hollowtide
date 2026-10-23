from pathlib import Path
import subprocess,os,json
W=Path(__file__).parent;env=os.environ.copy();env['APPDATA']=str(W/'import-profile');env['LOCALAPPDATA']=env['APPDATA']
cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--headless','--editor','--path','C:/Users/pmcga/dev/hollowtide','--rendering-method','gl_compatibility','--audio-driver','Dummy','--import']
p=subprocess.run(cmd,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=180,creationflags=subprocess.CREATE_NO_WINDOW);log=p.stdout+p.stderr;(W/'import.log').write_text(log,encoding='utf-8');(W/'import-command.json').write_text(json.dumps({'command':cmd,'exit':p.returncode},indent=2),encoding='utf-8');print(log[-3500:]);assert p.returncode==0 and 'SCRIPT ERROR' not in log
