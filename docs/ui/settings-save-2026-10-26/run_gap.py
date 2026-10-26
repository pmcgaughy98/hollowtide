from pathlib import Path
import json,os,subprocess
W=Path(__file__).parent
env=os.environ.copy();env['APPDATA']=str(W/'pause-gap-profile');env['LOCALAPPDATA']=str(W/'pause-gap-local-profile')
cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--headless','--path','C:/Users/pmcga/dev/hollowtide','--audio-driver','Dummy','--fixed-fps','30','--script',str(W/'pause_gap.gd')]
p=subprocess.run(cmd,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=30,creationflags=subprocess.CREATE_NO_WINDOW)
log=p.stdout+p.stderr
(W/'pause-gap.log').write_text(log,encoding='utf-8');(W/'pause-gap-command.json').write_text(json.dumps({'command':cmd,'APPDATA':env['APPDATA'],'LOCALAPPDATA':env['LOCALAPPDATA'],'exit':p.returncode},indent=2),encoding='utf-8')
print(log);assert p.returncode==0 and 'reproduced;' in log and 'SCRIPT ERROR' not in log
