from pathlib import Path
W=Path(__file__).parent;p=W/'prepared/tools/trailer/record_pitch_v4.gd';t=p.read_text(encoding='utf-8')
old='\tif shore != Vector2i(-1, -1):\n\t\tvar k := 0'
new='''	if shore != Vector2i(-1, -1):
		# Private camera setup: leave the party two floor rows above the first water edge, clear of the HUD.
		for lift in [2,1]:
			var candidate := shore+Vector2i(0,-lift)
			if dg._floor_at(candidate) and dg._floor_at(candidate+Vector2i(1,0)) and dg._floor_at(candidate+Vector2i(2,0)) and dg._floor_at(candidate+Vector2i(3,0)):
				shore=candidate
				break
		var k := 0'''
assert old in t;t=t.replace(old,new,1)
t=t.replace('\t\tdg._reveal()','\t\tdg._reveal()\n\t\tdg.cam_focus=dg.ents[0]["node"].position+Vector2(0,24)   # existing cinematic camera hook, capture framing only',1)
t=t.replace('\t\tawait dg.act_move(dir)\n\t\tawait _frames(12)','\t\tawait dg.act_move(dir)\n\t\tdg.cam_focus=dg.ents[0]["node"].position+Vector2(0,24)\n\t\tawait _frames(12)',1)
old='\t_checked("Warden stand-off returns to town",_scene()=="hub_town.tscn")'
new='\tawait _frames(6)   # change_scene_to_node adds its destination at the end of the transition frame\n'+old
assert old in t;t=t.replace(old,new,1)
p.write_text(t,encoding='utf-8')
print('Capture-only shoreline placement and deferred return-scene check corrected.')
