from pathlib import Path
W=Path(__file__).parent;C=W/'candidate'
def edit(r,old,new):
 p=C/r;b=p.read_bytes();a=old.replace('\n','\r\n').encode();z=new.replace('\n','\r\n').encode()
 if a not in b:a=old.encode();z=new.encode()
 assert b.count(a)==1,(r,old);p.write_bytes(b.replace(a,z))
palette='''// Sparkwick's display palette: approved arena-front gold/tan/copper, not muddy grey-brown.
// Exact swatches only. Flame, pale belly, alpha and source art remain unchanged.
uniform bool sparkwick_palette = false;
vec4 sparkwick_colour(vec4 c) {
    if (!sparkwick_palette || c.a == 0.0) return c;
    vec3 rgb = floor(c.rgb * 255.0 + 0.5);
    vec3 out_rgb = rgb;
    // Older large idle -> the same warm material ramps as the approved arena take.
    if (all(equal(rgb, vec3(206,157,92))) || all(equal(rgb, vec3(207,157,92))) || all(equal(rgb, vec3(185,129,64))) || all(equal(rgb, vec3(186,129,64)))) out_rgb = vec3(215,156,76);
    else if (all(equal(rgb, vec3(174,141,96))) || all(equal(rgb, vec3(175,141,96))) || all(equal(rgb, vec3(171,125,84))) || all(equal(rgb, vec3(172,125,84)))) out_rgb = vec3(202,152,89);
    else if (all(equal(rgb, vec3(156,98,57))) || all(equal(rgb, vec3(157,98,57))) || all(equal(rgb, vec3(160,112,71))) || all(equal(rgb, vec3(161,112,71)))) out_rgb = vec3(156,103,58);
    else if (all(equal(rgb, vec3(121,94,73))) || all(equal(rgb, vec3(122,94,73))) || all(equal(rgb, vec3(123,81,51))) || all(equal(rgb, vec3(124,81,51)))) out_rgb = vec3(143,92,54);
    else if (all(equal(rgb, vec3(109,67,44))) || all(equal(rgb, vec3(110,67,44)))) out_rgb = vec3(105,64,39);
    // Turned/walking generations contain desaturated body paint, already locked to the
    // source palette. Remove those dull material swatches without repainting markings.
    else if (all(equal(rgb, vec3(180,139,91))) || all(equal(rgb, vec3(166,137,105))) || all(equal(rgb, vec3(166,121,85)))) out_rgb = vec3(202,152,89);
    return vec4(out_rgb / 255.0, c.a);
}
'''
p=C/'scripts/arena/sparkwick_palette.gdshaderinc';p.parent.mkdir(parents=True,exist_ok=True);p.write_text(palette)
edit('scripts/arena/sel_out.gdshaderinc','varying vec4 tint;','varying vec4 tint;\n#include "res://scripts/arena/sparkwick_palette.gdshaderinc"')
edit('scripts/arena/sel_out.gdshaderinc','vec4 c = texture(tex, uv);','vec4 c = sparkwick_colour(texture(tex, uv));')
edit('scripts/arena/creature_finish.gd','\tsprite.material = finish','''	sprite.material = finish
	# Textures arrive after construction in town/dungeon and change during walking.
	# Follow the active texture, so only this form receives its material correction.
	var refresh := func() -> void:
		var path := sprite.texture.resource_path if sprite.texture != null else ""
		finish.set_shader_parameter("sparkwick_palette", is_sparkwick(path))
	sprite.texture_changed.connect(refresh)
	refresh.call()


static func is_sparkwick(path: String) -> bool:
	return "/arena/sparkwick/" in path or "/sparkwick_palette_locked/" in path or "/sparkwick_idle_texture_" in path or "/109_kithflare2/" in path or path.ends_with("/kithflare2_front.png") or path.ends_with("/kithflare2_back.png")''')
canvas='''extends Node2D
## A creature-only draw layer. UI panels/text never pass through a creature material.
var draws: Array = []

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var finish := ShaderMaterial.new()
	finish.shader = preload("res://scripts/arena/creature_finish.gdshader")
	finish.set_shader_parameter("sparkwick_palette", true)
	material = finish

func _draw() -> void:
	for d in draws:
		draw_set_transform(d["at"], 0.0, d["scale"])
		draw_texture_rect_region(d["tex"], d["dest"], d["region"], d["colour"])
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
'''
p=C/'scripts/ui/sparkwick_canvas.gd';p.write_text(canvas)
edit('scripts/ui/party_screen.gd','var _sound: AudioStreamPlayer','var _sound: AudioStreamPlayer\nvar _sparkwick_art: Node2D')
edit('scripts/ui/party_screen.gd','\t_D = load(DUNGEON)','\t_sparkwick_art = preload("res://scripts/ui/sparkwick_canvas.gd").new()\n\tadd_child(_sparkwick_art)\n\t_D = load(DUNGEON)')
edit('scripts/ui/party_screen.gd','\tvar c: Dictionary = cards[sel]\n\t_draw_left(c)','\tvar c: Dictionary = cards[sel]\n\t_sparkwick_art.draws.clear()\n\t_draw_left(c)\n\t_sparkwick_art.queue_redraw()')
edit('scripts/ui/party_screen.gd','''		if cards[k]["face"] != null:
			draw_texture_rect(cards[k]["face"], r.grow(-1.0), false, Color.WHITE if k == sel else Color(1, 1, 1, 0.55))''','''		if cards[k]["face"] != null:
			var tint := Color.WHITE if k == sel else Color(1, 1, 1, 0.55)
			if cards[k]["form"] == "sparkwick":
				_sparkwick_art.draws.append({"at": Vector2.ZERO, "scale": Vector2.ONE, "tex": cards[k]["face"], "dest": r.grow(-1.0), "region": Rect2(Vector2.ZERO, cards[k]["face"].get_size()), "colour": tint})
			else:
				draw_texture_rect(cards[k]["face"], r.grow(-1.0), false, tint)''')
edit('scripts/ui/party_screen.gd','''		draw_texture_rect_region(CreatureIdle.frame_at(idle, _t), Rect2(-ib.size.x * 0.5, 0, ib.size.x, ib.size.y), Rect2(ib), Color(0.6, 0.6, 0.6) if c["hp"] == 0 else Color.WHITE)''','''		var tint := Color(0.6, 0.6, 0.6) if c["hp"] == 0 else Color.WHITE
		if c["form"] == "sparkwick":
			_sparkwick_art.draws.append({"at": foot + Vector2(0, -ib.size.y * k), "scale": Vector2(-k, k), "tex": CreatureIdle.frame_at(idle, _t), "dest": Rect2(-ib.size.x * 0.5, 0, ib.size.x, ib.size.y), "region": Rect2(ib), "colour": tint})
		else:
			draw_texture_rect_region(CreatureIdle.frame_at(idle, _t), Rect2(-ib.size.x * 0.5, 0, ib.size.x, ib.size.y), Rect2(ib), tint)''')
edit('scripts/ui/evolution_scene.gd','uniform float white = 0.0;','uniform float white = 0.0;\n#include "res://scripts/arena/sparkwick_palette.gdshaderinc"')
edit('scripts/ui/evolution_scene.gd','vec4 c = texture(TEXTURE, UV);','vec4 c = sparkwick_colour(texture(TEXTURE, UV));')
edit('scripts/ui/evolution_scene.gd','\tmat.shader = sh\n\ts.material = mat','\tmat.shader = sh\n\tmat.set_shader_parameter("sparkwick_palette", form == "sparkwick")\n\ts.material = mat')
print('Prepared palette/render-layer candidate; no PNG bytes changed.')
