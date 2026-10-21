from pathlib import Path
import os,subprocess
W=Path(__file__).parent;env=os.environ.copy();env['APPDATA']=str(W/'base-profile');env['LOCALAPPDATA']=env['APPDATA']
for name in ['main_menu','main_menu_art_preview']:
    p=subprocess.run(['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--headless','--path','C:/Users/pmcga/dev/hollowtide','--audio-driver','Dummy','--check-only','--script','res://scripts/'+name+'.gd'],env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=45,creationflags=subprocess.CREATE_NO_WINDOW)
    (W/(name+'-parse.log')).write_text(p.stdout+p.stderr,encoding='utf-8');print(name,p.stdout+p.stderr,flush=True)
