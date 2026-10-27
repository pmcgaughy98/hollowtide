from pathlib import Path
import os,json,subprocess
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');G='C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe'
results=[]
for hero in range(3):
 name='hero'+str(hero);profile=W/(name+'-profile');env=os.environ.copy();env['APPDATA']=str(profile);env['LOCALAPPDATA']=str(W/(name+'-local-profile'))
 cmd=[G,'--path',str(L),'--rendering-method','gl_compatibility','--audio-driver','Dummy','--fixed-fps','30','--script','res://tools/debug/opening_flow_check.gd','--','hero='+str(hero),'partner='+str(hero%2)]
 if hero==2:cmd.append('reduced')
 p=subprocess.run(cmd,cwd=L,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=120,creationflags=subprocess.CREATE_NO_WINDOW)
 log=p.stdout+p.stderr;(W/(name+'.log')).write_text(log,encoding='utf-8')
 (W/(name+'-command.json')).write_text(json.dumps({'command':cmd,'APPDATA':env['APPDATA'],'LOCALAPPDATA':env['LOCALAPPDATA'],'exit':p.returncode},indent=2))
 report=next(profile.rglob('opening-flow-check/checks.json'));out=W/name;out.mkdir(exist_ok=True)
 import shutil
 for item in report.parent.iterdir():
  if item.is_file():shutil.copy2(item,out/item.name)
 data=json.loads(report.read_text());assert p.returncode==0 and not data['failures'], log[-6000:]
 assert not any(t in log for t in ('SCRIPT ERROR','ERROR:','ObjectDB instances were leaked')),log[-6000:]
 results.append({'case':name,'checks':len(data['checks']),'failures':data['failures']})
 print(name,len(data['checks']),'native flow checks, clean',flush=True)
(W/'real-flow-result.json').write_text(json.dumps(results,indent=2))
