from pathlib import Path
import os,subprocess,json,sys
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');phase=sys.argv[1]
env=os.environ.copy();env['APPDATA']=str(W/(phase+'-profile'));env['LOCALAPPDATA']=str(W/(phase+'-local-profile'))
if phase=='official':cmd=[sys.executable,str(L/'tools/debug/run_checks.py'),'board_scene','--jobs','1','--logs',str(W/'runner'),'--md',str(W/'runner-result.md')]
else:
 for kind,path in [('before',W/'originals/scripts/town/board_scene.gd'),('after',L/'scripts/town/board_scene.gd')]:
  s=path.read_text().replace('res://assets/sprites/arena/%s/town/','res://_c22_no_directional_sets/%s/town/').replace('res://assets/sprites/arena/%s/dungeon/','res://_c22_no_directional_sets/%s/dungeon/')
  (W/('forced_'+kind+'.gd')).write_text(s,encoding='utf-8')
 cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(L),'--rendering-method','gl_compatibility','--audio-driver','Dummy','--fixed-fps','30','--script',str(W/'native_check.gd')]
p=subprocess.run(cmd,cwd=L,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=120,creationflags=subprocess.CREATE_NO_WINDOW)
log=p.stdout+p.stderr;(W/(phase+'.log')).write_text(log,encoding='utf-8');(W/(phase+'-command.json')).write_text(json.dumps({'command':cmd,'APPDATA':env['APPDATA'],'LOCALAPPDATA':env['LOCALAPPDATA'],'exit':p.returncode},indent=2));print(log[-5000:]);assert p.returncode==0
if phase=='native':assert json.loads((W/'native-result.json').read_text())['failed']==0 and not any(t in log for t in ('SCRIPT ERROR','ERROR:'))
