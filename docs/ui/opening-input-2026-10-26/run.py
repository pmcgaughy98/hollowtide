from pathlib import Path
import json,os,subprocess,sys,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');phase=sys.argv[1];assert phase in ('native','flow','official')
env=os.environ.copy();env['APPDATA']=str(W/(phase+'-profile'));env['LOCALAPPDATA']=str(W/(phase+'-local-profile'))
if phase=='official':cmd=[sys.executable,str(L/'tools/debug/run_checks.py'),'opening_flow','soul_prologue','input_map','rebind','--jobs','1','--logs',str(W/'runner'),'--md',str(W/'runner-result.md')]
else:cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(L),'--rendering-method','gl_compatibility','--audio-driver','Dummy','--fixed-fps','30','--script',str(W/('native_check.gd' if phase=='native' else 'opening_flow_private.gd'))]
p=subprocess.run(cmd,cwd=L,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=180,creationflags=subprocess.CREATE_NO_WINDOW)
log=p.stdout+p.stderr;(W/(phase+'.log')).write_text(log,encoding='utf-8');(W/(phase+'-command.json')).write_text(json.dumps({'command':cmd,'APPDATA':env['APPDATA'],'LOCALAPPDATA':env['LOCALAPPDATA'],'exit':p.returncode},indent=2))
print(log[-10500:]);assert p.returncode==0
if phase=='native':
    assert not any(s in log for s in ('SCRIPT ERROR','ERROR:','ObjectDB instances were leaked'))
    assert json.loads((W/'native-result.json').read_text())['failed']==0
elif phase=='flow':
    assert 'SCRIPT ERROR' not in log and '0 failures' in log
    out=Path(env['APPDATA'])/'Godot/app_userdata/Hollowtide/opening-input-flow-check'
    result=json.loads((out/'checks.json').read_text());assert not result['failures']
    shutil.copytree(out,W/'flow-results',dirs_exist_ok=True)
