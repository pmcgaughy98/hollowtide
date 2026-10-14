from pathlib import Path
import os,subprocess,json,sys
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');F=R/'docs/trailer/v4/full'
env=os.environ.copy();env['APPDATA']=str(W/'installed-parse-profile');env['LOCALAPPDATA']=env['APPDATA']
cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--headless','--check-only','--path',str(R),'--rendering-method','gl_compatibility','--audio-driver','Dummy','--script','res://tools/trailer/record_pitch_v4.gd']
p=subprocess.run(cmd,capture_output=True,text=True,encoding='utf-8',errors='replace',env=env,timeout=60,creationflags=subprocess.CREATE_NO_WINDOW)
(F/'installed-parse.log').write_text(p.stdout+p.stderr,encoding='utf-8')
(F/'installed-parse-command.json').write_text(json.dumps({'command':cmd,'APPDATA':env['APPDATA'],'LOCALAPPDATA':env['LOCALAPPDATA'],'exit_code':p.returncode},indent=2),encoding='utf-8')
print(p.stdout+p.stderr);assert p.returncode==0 and 'ERROR' not in p.stdout+p.stderr and 'WARNING' not in p.stdout+p.stderr
