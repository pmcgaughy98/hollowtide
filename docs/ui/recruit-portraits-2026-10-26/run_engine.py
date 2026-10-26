from pathlib import Path
import json, os, subprocess, sys
W=Path(__file__).parent
mode=sys.argv[1]
assert mode in ('import','native','faces')
env=os.environ.copy()
env['APPDATA']=str(W/'private-profile')
env['LOCALAPPDATA']=str(W/'private-local-profile')
cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path','C:/Users/pmcga/dev/hollowtide','--audio-driver','Dummy','--fixed-fps','30']
if mode=='import': cmd+=['--headless','--editor','--import','--quit']
elif mode=='native': cmd+=['--rendering-method','gl_compatibility','--script',str(W/'native_check.gd')]
else: cmd+=['--headless','--script','res://tools/debug/face_crop_check.gd']
p=subprocess.run(cmd,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=180,creationflags=subprocess.CREATE_NO_WINDOW)
log=p.stdout+p.stderr
(W/(mode+'.log')).write_text(log,encoding='utf-8')
(W/(mode+'-command.json')).write_text(json.dumps({'command':cmd,'APPDATA':env['APPDATA'],'LOCALAPPDATA':env['LOCALAPPDATA'],'exit':p.returncode},indent=2),encoding='utf-8')
print(log[-6000:])
assert p.returncode==0
if mode!='import':
    assert not any(x in log for x in ('SCRIPT ERROR','ERROR:','FAIL','ObjectDB instances leaked'))
    assert ('RECRUIT PORTRAITS: 32/32' in log) if mode=='native' else ('face crops: all ok' in log)
else:
    print('Import diagnostics:',sum(x in log for x in ('SCRIPT ERROR','ERROR:')))
