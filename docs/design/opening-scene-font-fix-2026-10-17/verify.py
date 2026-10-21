from pathlib import Path
import os,subprocess,json,sys
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide')
jobs=[('summer-scenes','C:/Users/pmcga/AppData/Local/SummerEngine/current/Summer.exe',['--rendering-method','gl_compatibility','--fixed-fps','30','--resolution','1152x648','--script',str(W/'verify_scenes.gd')]),('ui-fit','C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe',['--headless','--script','res://tools/debug/ui_fit_check.gd'])]
records=[]
for name,exe,args in jobs:
    env=os.environ.copy();env['APPDATA']=str(W/(name+'-profile'));env['LOCALAPPDATA']=env['APPDATA'];env['HT_OPENING_DIAG_OUT']=str(W/'captures')
    cmd=[exe,'--path',str(R),'--audio-driver','Dummy']+args
    p=subprocess.run(cmd,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=90,creationflags=subprocess.CREATE_NO_WINDOW)
    log=p.stdout+p.stderr;(W/(name+'.log')).write_text(log,encoding='utf-8');records.append({'name':name,'command':cmd,'exit':p.returncode,'APPDATA':env['APPDATA']})
    print(name,log[-7500:],flush=True)
    expected='OPENING FIX: 10/10' if name=='summer-scenes' else 'ui fit: all ok'
    assert p.returncode==0 and expected in log and not any(t in log for t in ['SCRIPT ERROR','Parse Error','FAIL']),name
(W/'verification-commands.json').write_text(json.dumps(records,indent=2),encoding='utf-8')
