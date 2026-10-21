from pathlib import Path
import os,subprocess,json
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');env=os.environ.copy();env['APPDATA']=str(W/'boot-profile');env['LOCALAPPDATA']=env['APPDATA'];results=[]
exe='C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe'
for name in ['opening_flow','creature_opening']:
    cmd=[exe,'--headless','--rendering-method','gl_compatibility','--path',str(R),'--audio-driver','Dummy','--quit-after','30','res://scenes/'+name+'.tscn']
    p=subprocess.run(cmd,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=45,creationflags=subprocess.CREATE_NO_WINDOW)
    (W/(name+'-boot.log')).write_text(p.stdout+p.stderr,encoding='utf-8');results.append({'name':name,'exit':p.returncode,'command':cmd});print(name,p.returncode,p.stdout+p.stderr,flush=True)
(W/'boot-commands.json').write_text(json.dumps(results,indent=2),encoding='utf-8')
