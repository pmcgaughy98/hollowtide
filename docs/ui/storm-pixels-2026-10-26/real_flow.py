from pathlib import Path
import os,json,subprocess,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');G='C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe'
s=(L/'tools/debug/opening_flow_check.gd').read_text()
old='\t\tawait capture("3-frozen")'
new='''\t\tawait capture("3-frozen")
\t\tverify("Soul pixel cluster descends in actual Storm", await until(func() -> bool: return is_instance_valid(storm) and storm.soul_glow > 0.99 and storm.soul_at.y > 30.0, 300))
\t\tawait capture("3b-descending-pixels")
\t\tverify("Soul cluster reaches original waking spot before bloom", await until(func() -> bool: return is_instance_valid(storm) and storm.soul_at.distance_to(storm.WAKE_AT) < 1.0 and storm.white == 0.0, 240))
\t\tawait capture("3c-landed-pixels")'''
assert s.count(old)==1;s=s.replace(old,new)
(W/'natural_flow_check.gd').write_text(s,encoding='utf-8')
s=s.replace('\t# Music survives scene changes; release it on test shutdown.', '\tif is_instance_valid(UI._blip): UI._blip.free()\n\t# Music survives scene changes; release it on test shutdown.')
s=s.replace('\tawait frames(3)\n\t# Dialogue Manager', '\tawait frames(6)\n\t# Dialogue Manager')
(W/'natural_flow_check.gd').write_text(s,encoding='utf-8')
results=[]
for name,hero,partner,reduced in [('normal',0,1,False),('reduced',2,0,True)]:
 profile=W/(name+'-profile');env=os.environ.copy();env['APPDATA']=str(profile);env['LOCALAPPDATA']=str(W/(name+'-local-profile'))
 cmd=[G,'--path',str(L),'--rendering-method','gl_compatibility','--audio-driver','Dummy','--fixed-fps','30','--verbose','--script',str(W/'natural_flow_check.gd'),'--','hero='+str(hero),'partner='+str(partner),'automatic-storm']
 if reduced:cmd.append('reduced')
 p=subprocess.run(cmd,cwd=L,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=120,creationflags=subprocess.CREATE_NO_WINDOW)
 log=p.stdout+p.stderr;(W/(name+'.log')).write_text(log,encoding='utf-8');(W/(name+'-command.json')).write_text(json.dumps({'command':cmd,'APPDATA':env['APPDATA'],'LOCALAPPDATA':env['LOCALAPPDATA'],'exit':p.returncode},indent=2))
 report=next(profile.rglob('opening-flow-check/checks.json'));out=W/name;out.mkdir(exist_ok=True)
 for item in report.parent.iterdir():
  if item.is_file():shutil.copy2(item,out/item.name)
 data=json.loads(report.read_text());assert p.returncode==0 and not data['failures'],log[-6000:]
 assert not any(t in log for t in ('SCRIPT ERROR','ERROR:','ObjectDB instances were leaked')),log[-6000:]
 results.append({'case':name,'checks':len(data['checks']),'failures':data['failures']});print(name,len(data['checks']),'native flow checks, clean',flush=True)
(W/'real-flow-result.json').write_text(json.dumps(results,indent=2))
