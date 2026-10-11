from pathlib import Path
W=Path(__file__).parent;C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def edit(r,changes):
    raw=(W/'originals'/r).read_bytes();s=raw.decode().replace('\r\n','\n')
    for a,b in changes:assert s.count(a)==1,(r,a);s=s.replace(a,b)
    (C/r).write_bytes(s.replace('\n','\r\n').encode() if b'\r\n' in raw else s.encode())
edit('scripts/arena/creature_finish.gd',[
('finish.set_shader_parameter("sparkwick_palette", is_sparkwick(path))','finish.set_shader_parameter("sparkwick_palette", is_sparkwick(path))\n\t\tfinish.set_shader_parameter("skimlet_leg_fix", "/arena/skimlet/" in path or dialogue_form(path, "skimlet") or (path.is_empty() and form == "skimlet"))'),
('for form in ["mirekit", "whinet", "gruntle"]:','for form in ["mirekit", "whinet", "gruntle", "skimlet", "ozbender", "valvekin", "wayling", "swaphoard", "pouchbill", "inkhoot", "cairnshell", "crawdukes"]:'),
('static func portrait_target(path: String) -> bool:','static func new_creature(form: String) -> bool:\n\treturn form in ["skimlet", "ozbender", "valvekin", "wayling", "swaphoard", "pouchbill", "inkhoot", "cairnshell", "crawdukes"]\n\nstatic func portrait_target(path: String) -> bool:')])
edit('scripts/arena/sel_out.gdshaderinc',[
('uniform float detail_ink = SEL_OUT_DETAIL_DEFAULT;','uniform float detail_ink = SEL_OUT_DETAIL_DEFAULT;\n// Skimlet-only pale pinpoints on thin leg edges; its eyes/body highlights stay intact.\nuniform bool skimlet_leg_fix = false;'),
('\t// Internal selective outlines:', '''\tif (skimlet_leg_fix && c.a > 0.5) {
\t\tvec3 rgb = floor(c.rgb * 255.0 + 0.5);
\t\tbool pale_dot = all(equal(rgb, vec3(255.0))) || all(equal(rgb, vec3(225.0, 241.0, 247.0)));
\t\tif (pale_dot) {
\t\t\tfloat support = n.a+s.a+e.a+w.a;
\t\t\tsupport += sample_art(TEXTURE, UV+TEXTURE_PIXEL_SIZE).a + sample_art(TEXTURE, UV-TEXTURE_PIXEL_SIZE).a;
\t\t\tsupport += sample_art(TEXTURE, UV+TEXTURE_PIXEL_SIZE*vec2(1.0,-1.0)).a + sample_art(TEXTURE, UV+TEXTURE_PIXEL_SIZE*vec2(-1.0,1.0)).a;
\t\t\tif (support < 6.5) c.rgb = vec3(72.0, 54.0, 37.0) / 255.0;
\t\t}
\t}

\t// Internal selective outlines:''')])
edit('scripts/ui/party_screen.gd',[
('var _sparkwick_art: Node2D','var _sparkwick_art: Node2D\nvar _new_creature_art: Node2D'),
('add_child(_sparkwick_art)','add_child(_sparkwick_art)\n\t_new_creature_art = preload("res://scripts/ui/creature_detail_canvas.gd").new()\n\tadd_child(_new_creature_art)'),
('card["face"] = load(face) if ResourceLoader.exists(face) else null','card["face"] = load(face) if ResourceLoader.exists(face) else (UI.dialogue_portrait(String(form[0])) if preload("res://scripts/arena/creature_finish.gd").new_creature(String(form[0])) else null)'),
('func _draw() -> void:\n','func _draw() -> void:\n\t_new_creature_art.clear()\n'),
('\t\t\telse:\n\t\t\t\tdraw_texture_rect(cards[k]["face"], r.grow(-1.0), false, tint)','\t\t\telif preload("res://scripts/arena/creature_finish.gd").new_creature(String(cards[k]["form"])):\n\t\t\t\t_new_creature_art.paint(cards[k]["face"], r.grow(-2.0), Rect2(Vector2.ZERO, cards[k]["face"].get_size()), tint)\n\t\t\telse:\n\t\t\t\tdraw_texture_rect(cards[k]["face"], r.grow(-1.0), false, tint)'),
('\t\tdraw_texture_rect_region(tex, dest, Rect2(used), Color(0.6, 0.6, 0.6) if c["hp"] == 0 else Color.WHITE)','\t\tif preload("res://scripts/arena/creature_finish.gd").new_creature(String(c["form"])):\n\t\t\t_new_creature_art.paint(tex, dest, Rect2(used), Color(0.6, 0.6, 0.6) if c["hp"] == 0 else Color.WHITE)\n\t\telse:\n\t\t\tdraw_texture_rect_region(tex, dest, Rect2(used), Color(0.6, 0.6, 0.6) if c["hp"] == 0 else Color.WHITE)')])
print('Staged nine-form detail finish, Skimlet thin-edge dot correction and targeted Team art hook.')
