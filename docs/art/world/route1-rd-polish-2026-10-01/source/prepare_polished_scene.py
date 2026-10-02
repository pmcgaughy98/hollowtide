from pathlib import Path
from PIL import Image
import re,json

ROOT=Path(__file__).resolve().parent
PROJECT=Path('C:/Users/pmcga/dev/hollowtide')
baseline=ROOT/'first_route_before_polish.tscn'
scene=baseline.read_text() if baseline.exists() else (PROJECT/'scenes/first_route_prototype.tscn').read_text()
source=scene
def block(name):
    pattern=r'(\[node name="'+re.escape(name)+r'"[^\n]*\]\n)(.*?)(?=\n\[node |\Z)'
    match=re.search(pattern,scene,re.S)
    assert match,name
    return pattern,match
def setprop(name,prop,value):
    global scene
    pattern,match=block(name);body=match.group(2)
    line=prop+' = '+value
    if re.search(r'^'+re.escape(prop)+r' = .*$',body,re.M):body=re.sub(r'^'+re.escape(prop)+r' = .*$',line,body,flags=re.M)
    else:body=body.rstrip()+'\n'+line+'\n'
    scene=scene[:match.start()]+match.group(1)+body+scene[match.end():]
def replace_resource(resource_id,path):
    global scene
    pattern=r'\[ext_resource type="[^"]+"[^\n]*id="'+re.escape(resource_id)+r'"\]'
    match=re.search(pattern,scene);assert match,resource_id
    kind='TileSet' if resource_id=='1_tiles' else 'Texture2D'
    scene=scene[:match.start()]+f'[ext_resource type="{kind}" path="{path}" id="{resource_id}"]'+scene[match.end():]
replace_resource('1_tiles','res://assets/tilesets/route1_rd_2026_10_01/route1_ground_polished.tres')
replace_resource('4_hp0rj','res://assets/sprites/world/route1_rd_2026_10_01/cottonwood_polished.png')
replace_resource('5_v4cb8','res://assets/sprites/world/route1_rd_2026_10_01/retaining_wall_polished.png')
replace_resource('7_cinder_sprite','res://assets/sprites/world/route1_rd_2026_10_01/cinderhide_field_idle.png')
scene=re.sub(r'tile_map_data = PackedByteArray\("[^"\n]+"\)', 'tile_map_data = PackedByteArray("'+(ROOT/'tile_map_data.txt').read_text()+'")',scene)
at=scene.index('\n[sub_resource')
scene=scene[:at]+'\n[ext_resource type="Script" path="res://scripts/route1_map_polish.gd" id="14_polish"]\n[ext_resource type="Texture2D" path="res://assets/sprites/world/route1_rd_2026_10_01/shrub_polished.png" id="15_shrub"]\n'+scene[at:]
setprop('FirstRoutePrototype','y_sort_enabled','true')
setprop('RouteDecor','y_sort_enabled','true')
setprop('Terrain','z_index','-10')
anchors={}
def anchor(name,file,keep_ground=None):
    pattern,match=block(name);body=match.group(2)
    pos=re.search(r'position = Vector2\(([^,]+), ([^)]+)\)',body);x,y=map(float,pos.groups())
    scale=re.search(r'scale = Vector2\(([^,]+), ([^)]+)\)',body);s=float(scale.group(2)) if scale else 1.0
    im=Image.open(file);foot=im.getbbox()[3]-im.height/2
    new_y=keep_ground if keep_ground is not None else y+foot*s
    setprop(name,'position',f'Vector2({x:g}, {new_y:g})')
    setprop(name,'offset',f'Vector2(0, {-foot:g})')
    anchors[name]={'foot_position':[x,new_y],'native_foot_offset':foot,'scale':s}
old_tree=Image.open(ROOT.parent/'props/cottonwood.png');old_foot=old_tree.getbbox()[3]-48
for name,x,y in [('CottonwoodNorth',90,47),('CottonwoodRidge',194,44),('CottonwoodEast',418,43),('CottonwoodSouth',412,319),('CottonwoodWest',126,309)]:
    anchor(name,ROOT/'cottonwood_original.png',y+old_foot)
anchor('WaylineOffice',ROOT.parent/'props/wayline_office.png')
for name in ['RetainingWallWest','RetainingWallEast']:anchor(name,ROOT/'wall_original.png',142)
for name,file in [('RiverHeightMarker','height.png'),('Dispatcher','dispatcher.png'),('Marker','marker.png'),('RelayPost','post.png')]:anchor(name,ROOT.parent/'props'/file)
setprop('CinderhideEncounter','position','Vector2(320, 164)')
setprop('InteractionRange','position','Vector2(0, -20)')
setprop('CinderhideEncounter','field_idle_texture','ExtResource("7_cinder_sprite")')
# Find this actor's child explicitly, since Sprite2D occurs once in this scene.
setprop('Sprite2D','texture','ExtResource("7_cinder_sprite")')
setprop('Sprite2D','scale','Vector2(0.55, 0.55)')
setprop('Sprite2D','position','Vector2(0, -17.6)')
setprop('Sprite2D','region_enabled','true')
setprop('Sprite2D','region_rect','Rect2(0, 0, 80, 80)')
setprop('Prompt','offset_top','-48.0');setprop('Prompt','offset_bottom','-34.0')
setprop('RiverCall','visible','false')
shrubs=[(140,59),(226,58),(366,62),(370,178),(260,319),(61,295),(44,245),(374,349)]
im=Image.open(ROOT/'shrub_original.png');offset=im.getbbox()[3]-im.height/2
for i,(x,y) in enumerate(shrubs):
    scene+=f'\n[node name="BankShrub{i+1}" type="Sprite2D" parent="RouteDecor"]\nposition = Vector2({x}, {y})\noffset = Vector2(0, {-offset})\ntexture = ExtResource("15_shrub")\n'
scene+='\n[node name="MapPolish" type="Node2D" parent="."]\nz_index = -8\nscript = ExtResource("14_polish")\n'
tree=Image.open(ROOT/'cottonwood_original.png');tree_offset=tree.getbbox()[3]-tree.height/2
for name,x,y in [('CottonwoodOfficeGrove',128,158),('CottonwoodBankBend',374,178)]:
    scene+=f'\n[node name="{name}" type="Sprite2D" parent="RouteDecor"]\nposition = Vector2({x}, {y})\noffset = Vector2(0, {-tree_offset})\ntexture = ExtResource("4_hp0rj")\n'
(ROOT/'first_route_polished.tscn').write_text(scene)
(ROOT/'foot_anchors.json').write_text(json.dumps(anchors,indent=2))
(ROOT/'first_route_before_polish.tscn').write_text(source)
print(json.dumps({'anchored_props':len(anchors),'shrubs':len(shrubs),'field_encounter_center_preserved':[320,144]}))
