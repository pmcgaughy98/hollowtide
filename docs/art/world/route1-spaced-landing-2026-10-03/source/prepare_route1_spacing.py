from pathlib import Path
import hashlib,json,re,shutil
W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an");P=Path(r"C:/Users/pmcga/dev/hollowtide");D=W/"route1-spaced-landing-review"
rels=["scripts/first_route_prototype.gd","scripts/route1_landing_loop.gd","scripts/route1_crossing.gd","scripts/route1_landscape.gd","scenes/first_route_prototype.tscn","docs/AI_COLLABORATION.md"]
guard={}
for rel in rels:
    src=P/rel;dest=D/"before"/rel;dest.parent.mkdir(parents=True,exist_ok=True)
    assert not dest.exists();shutil.copy2(src,dest);guard[rel]=hashlib.sha256(src.read_bytes()).hexdigest()
(D/"before-manifest.json").write_text(json.dumps(guard,indent=2))
protected=[f for root in ["assets","data"] for f in (P/root).rglob("*") if f.is_file() and f.suffix not in [".import"]]
protected += [P/x for x in ["scripts/player.gd","scripts/player_party.gd","scripts/battle_screen.gd","scripts/creature_data.gd","scripts/party_member.gd","scripts/world_journey.gd","scripts/main_menu.gd","scripts/route1_terrain_relief.gd","project.godot"]]
(D/"protected-before.json").write_text(json.dumps({f.relative_to(P).as_posix():hashlib.sha256(f.read_bytes()).hexdigest() for f in protected},indent=2))
C=D/"candidate";C.mkdir()
t=(P/rels[0]).read_text()
for old,new in [('"post": Vector2(392, 240)','"post": Vector2(398, 530)'),('"river": Vector2(432, 296)','"river": Vector2(416, 592)'),('"levee_entrance": Vector2(216, 264)','"levee_entrance": Vector2(64, 200)'),('"landing_notice": Vector2(320, 316)','"landing_notice": Vector2(320, 456)')]:
    assert t.count(old)==1;t=t.replace(old,new)
old='The bank trail reaches the relay post and height marker, then winds under the cottonwoods back to the bridge road. The crest is higher ground. Worn rope grooves mark the older crossing; the cuts on the height post have no dates.'
new='The bank trail passes the height post, then follows lower ground south to the relay and old tieoffs. A second worn track returns to the bridge road. The crest is higher ground. Worn rope grooves mark the older crossing; the cuts on the height post have no dates.'
assert t.count(old)==1;t=t.replace(old,new)
old='\t\telif player.position.y >= 248 or player.position.x >= 200:'
new='\t\telif player.position.y >= 480:\n\t\t\t_area_label.text = "ROUTE 1 / OLD LANDING"\n'+old
assert t.count(old)==1;t=t.replace(old,new)
(C/"first_route_prototype.gd").write_text(t)
t=(P/rels[2]).read_text()
for old,new in [('MARK, Vector2(216, 248)','MARK, Vector2(64, 186)'),('Vector2(235, 235)','Vector2(84, 168)')]:
    assert t.count(old)==1;t=t.replace(old,new)
(C/"route1_crossing.gd").write_text(t)
t=(P/rels[3]).read_text()
old='Vector2(433, 600)';assert t.count(old)==1;t=t.replace(old,'Vector2(435, 618)')
old='\tVector2(322, 55), Vector2(246, 178), Vector2(266, 203),'
assert t.count(old)==1;t=t.replace(old,old+'\n\tVector2(226, 342), Vector2(303, 334), Vector2(242, 394),')
(C/"route1_landscape.gd").write_text(t)
t=(P/rels[4]).read_text()
for name,old,new in [('RelayPost','Vector2(392, 240)','Vector2(398, 530)'),('RiverCall','Vector2(432, 286)','Vector2(416, 582)'),('CinderhideEncounter','Vector2(320, 164)','Vector2(258, 352)'),('FerryTieoffFull','Vector2(442, 273)','Vector2(438, 558)'),('FerryTieoffShort','Vector2(414, 272)','Vector2(414, 556)')]:
    pattern=r'(\[node name="'+name+r'"[^\n]*\]\n)(.*?)(?=\n\[node|\Z)'
    found=list(re.finditer(pattern,t,re.S));assert len(found)==1,name
    b=found[0].group(0);assert b.count(old)==1,name
    t=t[:found[0].start()]+b.replace(old,new)+t[found[0].end():]
(C/"first_route_prototype.tscn").write_text(t)
t=(P/rels[1]).read_text()
t=t.replace('var _canopy_opacity := 1.0','var _canopy_opacity := 1.0\nvar _landing_tree: Sprite2D\nvar _landing_material: ShaderMaterial\nvar _landing_opacity := 1.0\nvar _landing_old_material: Material')
old='func _ready() -> void:'
new='''func _enter_tree() -> void:
\t# Cached route scenes re-enter without a second _ready call.
\tif is_instance_valid(_tree) and _canopy_material:
\t\t_tree.material = _canopy_material
\tif is_instance_valid(_landing_tree) and _landing_material:
\t\t_landing_tree.material = _landing_material

const SOUTH_LOOP = preload("res://assets/sprites/world/route1_spaced_landing_2026_10_03/landing_south_loop.png")

'''+old
assert t.count(old)==1;t=t.replace(old,new)
old='\t_tree.material=_canopy_material'
new=old+'''\n\t_canopy_material.set_shader_parameter("canopy_opacity", 1.0)
\t_landing_tree=route.get_node("RouteDecor/CottonwoodMeadow07")
\t_landing_old_material=_landing_tree.material
\t_landing_material=ShaderMaterial.new()
\t_landing_material.shader=CANOPY
\t_landing_material.set_shader_parameter("canopy_opacity", 1.0)
\t_landing_tree.material=_landing_material'''
assert t.count(old)==1;t=t.replace(old,new)
old='\tadd_child(surface)'
new=old+'''\n\tvar south:=Sprite2D.new()
\tsouth.name="SouthernLandingLoop"
\tsouth.texture=SOUTH_LOOP
\tsouth.centered=false
\tsouth.position=Vector2(244,336)
\tsouth.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
\tsouth.material=route.get_node("Terrain").material
\tadd_child(south)'''
assert t.count(old)==1;t=t.replace(old,new)
t=t.replace('notice.position=Vector2(320,302)','notice.position=Vector2(320,442)')
t=t.replace('label.position=Vector2(278,270)','label.position=Vector2(280,480)')
old='\t_canopy_material.set_shader_parameter("canopy_opacity",_canopy_opacity)'
new=old+'''\n\tvar landing_head:=_landing_tree.to_local(_player.global_position+Vector2(0,-16))
\tvar landing_behind:=_player.global_position.y<_landing_tree.global_position.y-2 and _landing_tree.get_rect().has_point(landing_head)
\t_landing_opacity=move_toward(_landing_opacity,0.35 if landing_behind else 1.0,delta*3.0)
\t_landing_material.set_shader_parameter("canopy_opacity",_landing_opacity)'''
assert t.count(old)==1;t=t.replace(old,new)
t += '\n\tif is_instance_valid(_landing_tree):\n\t\t_landing_tree.material=_landing_old_material\n'
(C/"route1_landing_loop.gd").write_text(t)
print("Saved exact baseline and five focused route layout candidates.")
