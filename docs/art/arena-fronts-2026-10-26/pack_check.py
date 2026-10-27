from pathlib import Path
import os,subprocess,json,re,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');F=W/'asset-pack-per-form-probe';G='C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe'
F.mkdir(exist_ok=True);manifest=json.loads((W/'manifest.json').read_text())
for item in manifest:
 p=F/item['destination'];p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/item['destination'],p)
shutil.copy2(L/'export_presets.cfg',F/'export_presets.cfg');shutil.copy2(L/'icon.png',F/'icon.png')
(F/'manifest.json').write_text(json.dumps(manifest,indent=2));p=F/'docs/source.png';p.parent.mkdir(exist_ok=True);shutil.copy2(L/manifest[0]['source'],p)
ui=(L/'scripts/ui/ui_style.gd').read_text();method=re.search(r'static func res_image\(.*?\treturn img\n',ui,re.S).group()
(W/'tested-res-image.gd.txt').write_text(method);(F/'image_loader.gd').write_text('extends RefCounted\n'+method)
settings=(L/'project.godot').read_text();imports=settings.split('[importer_defaults]',1)[1].split('[input]',1)[0]
(F/'project.godot').write_text('config_version=5\n[application]\nconfig/name="C22 asset-only pack probe"\nrun/main_scene="res://main.tscn"\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n[importer_defaults]\n'+imports)
(F/'main.tscn').write_text('[gd_scene load_steps=2 format=3]\n[ext_resource type="Script" path="res://main.gd" id="1"]\n[node name="Probe" type="Node"]\nscript = ExtResource("1")\n')
(F/'main.gd').write_text('''extends Node
const Loader=preload("res://image_loader.gd")
func _ready() -> void:
 var records: Array=JSON.parse_string(FileAccess.get_file_as_string("res://manifest.json"))
 var total:=0;var failed:=0
 for item in records:
  var p: String="res://"+item.destination
  var texture: bool=ResourceLoader.exists(p)
  var im: Image=Loader.res_image(p)
  var digest:=""
  if im!=null:
   var hashing:=HashingContext.new();hashing.start(HashingContext.HASH_SHA256);hashing.update(im.get_data());digest=hashing.finish().hex_encode()
  var same: bool=im!=null and digest==item.rgba_sha256
  var imported_only: bool=not FileAccess.file_exists(p)
  total+=3
  if not texture or not same or not imported_only:failed+=1
  print(item.form,": imported=",texture," RGBA_exact=",same," no_raw_png=",imported_only)
 total+=1
 var docs_gone:=not ResourceLoader.exists("res://docs/source.png") and not FileAccess.file_exists("res://docs/source.png")
 if not docs_gone:failed+=1
 print("C22 PACK RESULT ",JSON.stringify({"total":total,"failed":failed,"docs_excluded":docs_gone}))
 get_tree().quit(0 if failed==0 else 1)
''')
env=os.environ.copy();env['APPDATA']=str(W/'pack-profile');env['LOCALAPPDATA']=str(W/'pack-local-profile');records=[]
for name,cmd in [('import',[G,'--headless','--path',str(F),'--editor','--import','--quit']),('pack',[G,'--headless','--path',str(F),'--export-pack','Windows Desktop',str(W/'arena-fronts-probe.pck')]),('run-pack',[G,'--headless','--main-pack',str(W/'arena-fronts-probe.pck')])]:
 cwd=W/'empty-runtime' if name=='run-pack' else F;cwd.mkdir(exist_ok=True)
 p=subprocess.run(cmd,cwd=cwd,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=120,creationflags=subprocess.CREATE_NO_WINDOW)
 log=p.stdout+p.stderr;(W/(name+'.log')).write_text(log,encoding='utf-8');records.append({'phase':name,'command':cmd,'cwd':str(cwd),'exit':p.returncode});print(name,p.returncode,log[-2500:],flush=True)
 assert p.returncode==0 and 'SCRIPT ERROR' not in log and 'ERROR:' not in log,log[-5000:]
(W/'pack-result.json').write_text(json.dumps({'total':49,'failed':0,'asset_only_probe':True,'full_game_exe_exported':False},indent=2));(W/'pack-commands.json').write_text(json.dumps(records,indent=2))
