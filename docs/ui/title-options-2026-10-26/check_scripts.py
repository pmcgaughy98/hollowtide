from pathlib import Path
import json,os,subprocess
W=Path(__file__).parent;env=os.environ.copy();env['APPDATA']=str(W/'parse-profile');env['LOCALAPPDATA']=str(W/'parse-local-profile')
out=[]
for rel in ('scripts/ui/title_settings.gd','scripts/main_menu.gd','scripts/creature_opening.gd'):
    cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--headless','--path','C:/Users/pmcga/dev/hollowtide','--check-only','--script','res://'+rel]
    p=subprocess.run(cmd,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=30,creationflags=subprocess.CREATE_NO_WINDOW)
    log=p.stdout+p.stderr;(W/('parse-'+Path(rel).stem+'.log')).write_text(log,encoding='utf-8');out.append({'script':rel,'command':cmd,'exit':p.returncode})
    print(rel,':',p.returncode,log[-1000:] if p.returncode or 'ERROR' in log else 'parse clean')
    assert p.returncode==0 and 'SCRIPT ERROR' not in log and 'ERROR:' not in log
(W/'parse-commands.json').write_text(json.dumps(out,indent=2))
