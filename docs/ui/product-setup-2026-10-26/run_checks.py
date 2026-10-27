from pathlib import Path
import subprocess,os,json,time,sys
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');G='C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe';mode=sys.argv[1]
env=os.environ.copy();env['APPDATA']=str(W/(mode+'-profile'));env['LOCALAPPDATA']=str(W/(mode+'-local-profile'))
target=L
if mode=='editor':
 import shutil
 target=W/'hook-unit-existing-hook';target.mkdir(exist_ok=True)
 for rel in ('addons/godot_ai/export/mcp_export_plugin.gd',):
  dest=target/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,dest)
 (target/'dummy.gd').write_text('extends Node\n')
 helper=target/'addons/godot_ai/runtime/game_helper.gd';helper.parent.mkdir(parents=True,exist_ok=True);helper.write_text('extends Node\n')
 (target/'project.godot').write_text('config_version=5\n[application]\nconfig/name="Hollowtide hook unit"\n[autoload]\n_mcp_game_helper="*res://addons/godot_ai/runtime/game_helper.gd"\nPlayerParty="*res://dummy.gd"\nDialogueManager="*res://dummy.gd"\nInputPrefs="*res://dummy.gd"\n')
cmd=[G,'--path',str(target),'--audio-driver','Dummy','--fixed-fps','30']
if mode=='editor':cmd+=['--headless','--editor','--script',str(W/'editor_check.gd')]
else:cmd+=['--rendering-method','gl_compatibility','--script',str(W/'native_check.gd')]
if mode=='native':
 marker=W/'window-ready.json'
 if marker.exists():marker.unlink()
 with open(W/(mode+'.log'),'w',encoding='utf-8') as log:
  p=subprocess.Popen(cmd,cwd=L,env=env,stdout=log,stderr=log,creationflags=subprocess.CREATE_NO_WINDOW)
  for i in range(600):
   if marker.exists():break
   if p.poll() is not None:break
   time.sleep(.05)
  assert marker.exists(),(W/(mode+'.log')).read_text()
  code=p.wait(timeout=60)
 output=(W/(mode+'.log')).read_text()
else:
 p=subprocess.run(cmd,cwd=L,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=90,creationflags=subprocess.CREATE_NO_WINDOW);code=p.returncode;output=p.stdout+p.stderr;(W/(mode+'.log')).write_text(output,encoding='utf-8')
(W/(mode+'-command.json')).write_text(json.dumps({'command':cmd,'APPDATA':env['APPDATA'],'LOCALAPPDATA':env['LOCALAPPDATA'],'exit':code},indent=2));print(output[-5000:]);assert code==0
assert 'SCRIPT ERROR' not in output
errors=[line for line in output.splitlines() if line.startswith('ERROR:')]
if mode=='editor':assert all('RID allocations' in line and 'were leaked at exit' in line for line in errors)
else:assert not errors
assert json.loads((W/(mode+'-result.json')).read_text())['failed']==0
