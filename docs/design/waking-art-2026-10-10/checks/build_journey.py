from pathlib import Path
import shutil
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
W=Path(__file__).parent
L=Path('C:/Users/pmcga/dev/hollowtide')
raw=Path('C:/Users/pmcga/.codex/generated_images/01a11b73-6d5a-78a3-819c-fd3b9ced7188')
(W/'sources').mkdir(exist_ok=True)
for name,src in [('waking-source.png','exec-15ef5037-970b-4026-afb8-b4d2f81ed407.png'),('entrance-source.png','exec-eea69258-6227-4ed5-8690-5954fc25263b.png')]:shutil.copy2(raw/src,W/'sources'/name)
prep=(W/'prepare_art.gd').read_text().replace('exec-15ef5037-970b-4026-afb8-b4d2f81ed407.png','exec-eea69258-6227-4ed5-8690-5954fc25263b.png').replace('waking_native.png','entrance_native.png')
(W/'prepare_entrance.gd').write_text(prep)
bank=C/'scripts/ui/waking_bank.gd'
s=bank.read_text().replace('var companion_visible := false','var companion_visible := false\nvar show_actor_shadows := true')
s=s.replace('\tdraw_ellipse_shadow(Vector2(168,84))\n\tif companion_visible:', '\tif show_actor_shadows:draw_ellipse_shadow(Vector2(168,84))\n\tif show_actor_shadows and companion_visible:')
bank.write_text(s)
pro=C/'scripts/creature_prologue.gd'
s=pro.read_text().replace('confirm.text="Reach Highbank together"','confirm.text="Step onto the riverbank"')
s=s.replace('\t# Claude, 2026-10-09 (Preston: "prologue to town to hollow and back"): the day starts in Highbank,\n\t# and the Mouth of the Hollow there starts the run. The team record carries the choice.','\t# Preston, 2026-10-10: explore this bank and its close-up entrance immediately after choice.\n\t# Highbank remains the next story stop; the existing team record carries the choice.')
s=s.replace('load("res://scenes/hub_town.tscn").instantiate()','load("res://scenes/waking_riverbank.tscn").instantiate()\n\tdungeon.reduce_motion=reduce_motion')
s=s.replace('Highbank could not open.','Riverbank could not open.')
pro.write_text(s)
# Only the already-cleared first dungeon routes through the new Hollow approach.
town=C/'scripts/town/hub_town.gd'
backup=W/'originals/scripts/town/hub_town.gd';backup.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/'scripts/town/hub_town.gd',backup)
s=town.read_text()
needle='\tif is_inside_tree() and get_tree().current_scene == self:\n\t\tget_tree().change_scene_to_node(dg)'
replacement='\tif is_inside_tree() and get_tree().current_scene == self:\n\t\tif dg.dungeon == "hollow":\n\t\t\tdg.free()\n\t\t\tvar approach:Node2D=load("res://scenes/waking_riverbank.tscn").instantiate()\n\t\t\tTeamState.give_to(approach)\n\t\t\tapproach.returning=true\n\t\t\tget_tree().change_scene_to_node(approach)\n\t\telse:\n\t\t\tget_tree().change_scene_to_node(dg)'
assert s.count(needle)==1
town.write_text(s.replace(needle,replacement))
for scene,entrance in [('waking_riverbank',False),('hollow_entrance',True)]:
 (C/'scenes'/f'{scene}.tscn').write_text('[gd_scene load_steps=2 format=3]\n\n[ext_resource type="Script" path="res://scripts/riverbank_journey.gd" id="1"]\n\n[node name="'+('HollowEntrance' if entrance else 'WakingRiverbank')+'" type="Node2D"]\nscript = ExtResource("1")\nentrance = '+str(entrance).lower()+'\n')
print('Prepared source archives, entrance resize fixture, route hooks and two scene wrappers.')
