from pathlib import Path
import os,subprocess,json
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide')
env=os.environ.copy();env['APPDATA']=str(W/'profile');env['LOCALAPPDATA']=env['APPDATA']
exe='C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe'
results=[]
for name in ['opening_flow','creature_opening']:
    cmd=[exe,'--headless','--path',str(R),'--audio-driver','Dummy','--check-only','--script','res://scripts/'+name+'.gd']
    p=subprocess.run(cmd,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=60,creationflags=subprocess.CREATE_NO_WINDOW)
    (W/(name+'-godot-parse.log')).write_text(p.stdout+p.stderr,encoding='utf-8');results.append({'name':name,'exit':p.returncode,'command':cmd})
    print(name,p.returncode,p.stdout+p.stderr,flush=True)
(W/'commands.json').write_text(json.dumps(results,indent=2),encoding='utf-8')
