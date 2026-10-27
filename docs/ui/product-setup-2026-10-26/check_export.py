from pathlib import Path
import os,subprocess,json,shutil,hashlib
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');G='C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe';F=W/'export-probe-existing-hook'
F.mkdir(exist_ok=True)
for rel in ('export_presets.cfg','icon.png','addons/godot_ai/export/mcp_export_plugin.gd'):
 dest=F/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,dest)
(F/'project.godot').write_text('''config_version=5
[application]
config/name="Hollowtide export hook probe"
run/main_scene="res://main.tscn"
config/icon="res://icon.png"
[autoload]
_mcp_game_helper="*res://addons/godot_ai/runtime/game_helper.gd"
[editor_plugins]
enabled=PackedStringArray("res://addons/godot_ai/plugin.cfg")
[rendering]
renderer/rendering_method="gl_compatibility"
''')
(F/'main.tscn').write_text('[gd_scene load_steps=2 format=3]\n[ext_resource type="Script" path="res://main.gd" id="1"]\n[node name="Probe" type="Node"]\nscript = ExtResource("1")\n')
(F/'main.gd').write_text('''extends Node
func _ready() -> void:
 var checks:={
  "custom_feature":OS.has_feature("hollowtide_windows"),
  "autoload_setting_removed":not ProjectSettings.has_setting("autoload/_mcp_game_helper"),
  "autoload_node_absent":get_tree().root.get_node_or_null("_mcp_game_helper")==null,
  "debug_helper_file_excluded":not ResourceLoader.exists("res://addons/godot_ai/runtime/game_helper.gd"),
  "tools_excluded":not FileAccess.file_exists("res://tools/export_probe.json"),
  "lab_excluded":not ResourceLoader.exists("res://scenes/_lab/probe.tscn"),
  "export_plugin_excluded":not ResourceLoader.exists("res://addons/godot_ai/export/mcp_export_plugin.gd"),
  "docs_resource_kept":ResourceLoader.exists("res://docs/creatures/keep.png"),
  "archived_docs_code_excluded":["gd","tscn","tres","gdshader"].all(func(ext):return not ResourceLoader.exists("res://docs/archived."+ext)),
  "icon_kept":ResourceLoader.exists("res://icon.png")}
 print("PACK PROBE ",JSON.stringify(checks))
 get_tree().quit(0 if checks.values().all(func(v):return v) else 1)
''')
for rel,contents in {'addons/godot_ai/runtime/game_helper.gd':'extends Node\n','tools/export_probe.json':'{"excluded":true}\n','scenes/_lab/probe.tscn':'[gd_scene format=3]\n[node name="Excluded" type="Node"]\n'}.items():
 dest=F/rel;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_text(contents)
dest=F/'docs/creatures/keep.png';dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/'icon.png',dest)
for ext,content in {'gd':'extends Node\n','tscn':'[gd_scene format=3]\n[node name="Archive" type="Node"]\n','tres':'[gd_resource type="Gradient" format=3]\n[resource]\n','gdshader':'shader_type canvas_item;\n'}.items():(F/('docs/archived.'+ext)).write_text(content)
(F/'addons/godot_ai/plugin.cfg').write_text('[plugin]\nname="Export hook probe"\ndescription="Probe"\nauthor="Hollowtide"\nversion="1.0"\nscript="plugin.gd"\n')
(F/'addons/godot_ai/plugin.gd').write_text('@tool\nextends EditorPlugin\nvar hook: EditorExportPlugin\nfunc _enter_tree() -> void:\n hook=preload("res://addons/godot_ai/export/mcp_export_plugin.gd").new()\n add_export_plugin(hook)\nfunc _exit_tree() -> void:\n remove_export_plugin(hook)\n hook=null\n')
env=os.environ.copy();env['APPDATA']=str(W/'export-profile');env['LOCALAPPDATA']=str(W/'export-local-profile')
records=[]
for name,cmd in [('import',[G,'--headless','--path',str(F),'--editor','--import','--quit']),('pack',[G,'--headless','--path',str(F),'--export-pack','Windows Desktop',str(W/'export-probe.pck')]),('run-pack',[G,'--headless','--main-pack',str(W/'export-probe.pck')])]:
 run_dir=W/'packed-runtime' if name=='run-pack' else F;run_dir.mkdir(exist_ok=True)
 p=subprocess.run(cmd,cwd=run_dir,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=90,creationflags=subprocess.CREATE_NO_WINDOW)
 log=p.stdout+p.stderr;(W/(name+'.log')).write_text(log,encoding='utf-8');records.append({'phase':name,'cmd':cmd,'exit':p.returncode});print(name,p.returncode,log[-1600:],flush=True)
 assert p.returncode==0,log[-5000:]
 assert 'SCRIPT ERROR' not in log,log[-5000:]
(W/'export-probe-commands.json').write_text(json.dumps(records,indent=2));(W/'export-probe-result.json').write_text(json.dumps({'pack_assertions':10,'passed':True,'template_install':'not performed','actual_game_exe':'not exported'},indent=2))
