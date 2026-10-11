from pathlib import Path
W=Path(__file__).parent;C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def edit(r,changes):
    raw=(W/'originals'/r).read_bytes();crlf=b'\r\n' in raw;s=raw.decode('utf-8').replace('\r\n','\n')
    for a,b in changes:assert s.count(a)==1,(r,a[:80]);s=s.replace(a,b)
    (C/r).write_bytes(s.replace('\n','\r\n').encode('utf-8') if crlf else s.encode('utf-8'))
edit('scripts/arena/creature_finish.gd',[
 ('static func apply(sprite: Sprite2D, details: bool = false)', 'static func apply(sprite: Sprite2D, details: bool = false, form: String = "")'),
 ('else crew_detail(path))','else crew_detail(path, form))'),
 ('static func crew_detail(path: String) -> float:\n\tfor form in ["mirekit", "whinet"]:\n\t\tif ("/arena/" + form + "/") in path or path.ends_with("/dialogue/" + form + ".png"):\n\t\t\treturn 0.65\n\treturn 0.0',
  '''static func dialogue_form(path: String, form: String) -> bool:
\t# Expression variants share their form's finish; rejected/source sheets do not opt in.
\tvar stem := path.get_file().get_basename()
\treturn path.get_base_dir().ends_with("/sprites/ui/dialogue") and (stem == form or stem.begins_with(form + "_"))

static func crew_detail(path: String, identity: String = "") -> float:
\tfor form in ["mirekit", "whinet", "gruntle"]:
\t\tif ("/arena/" + form + "/") in path or dialogue_form(path, form) or (path.is_empty() and identity == form):
\t\t\treturn 0.65
\treturn 0.0

static func portrait_target(path: String) -> bool:
\treturn crew_detail(path) > 0.0 or dialogue_form(path, "starward")''')])
edit('scripts/town/board_scene.gd',[
 ('preload("res://scripts/arena/creature_finish.gd").apply(sprite)','preload("res://scripts/arena/creature_finish.gd").apply(sprite, false, form)')])
edit('scripts/ui/ui_style.gd',[
 ('preload("res://scripts/arena/creature_finish.gd").crew_detail(tex.resource_path) > 0.0','preload("res://scripts/arena/creature_finish.gd").portrait_target(tex.resource_path)')])
edit('scripts/town/hub_town.gd',[
 ('layer.add_child(_hud)\n','layer.add_child(_hud)\n\tvar crew_portraits := preload("res://scripts/ui/crew_portrait_canvas.gd").new()\n\tcrew_portraits.name = "CrewPortraitFinish"\n\t_hud.add_child(crew_portraits)\n'),
 ('func _draw_hud() -> void:\n','func _draw_hud() -> void:\n\t_hud.get_node("CrewPortraitFinish").clear()\n')])
print('Added Gruntle and expression selectors, texture-less identity and Town portrait finish hook.')
