extends SceneTree
const U="D:/dev/hollowtide-flood-waking-20261010/"
const UI=preload("res://scripts/ui/ui_style.gd")
const Team=preload("res://scripts/town/team_state.gd")
var checks:=0
var fails:=0
func _initialize()->void:run.call_deferred()
func frames(n:int)->void:
	for k in n:await process_frame
func ok(what:String,yes:bool)->void:
	checks+=1
	if not yes:fails+=1
	print(what," -> ","ok" if yes else "FAIL")
func click(b:Button)->void:
	var at:=b.get_global_rect().get_center()
	var event:=InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_LEFT;event.position=at;event.pressed=true
	Input.parse_input_event(event);await frames(1)
	event=InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_LEFT;event.position=at;event.pressed=false
	Input.parse_input_event(event);await frames(3)
func beat(w:Node)->void:
	var phase:int=w.phase
	for press in 8:
		await click(w.confirm)
		if w.leaving or w.phase!=phase:return
	ok("Advance completes within eight page presses",false)
func shot(name:String)->void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(U+"review/"+name+".png")
func run()->void:
	DirAccess.make_dir_recursive_absolute(U+"review/");root.size=Vector2i(1152,648)
	for hero in 3:
		for partner in 3:
			if hero==partner:continue
			var w:Node=load("res://scenes/creature_prologue.tscn").instantiate();w.hero=hero;w.partner=partner;w.chosen_by_soul=true;w.reduce_motion=true
			root.add_child(w);await frames(5)
			ok("Soul identity %d/%d and no starter menu"%[hero,partner],w.hero==hero and w.cards.is_empty() and w.prose.text.contains("human") and w.prose.text.contains(w.SENSES[hero]))
			ok("Ruin and walkway remain submerged before choice",w.flood_cover.rise==0.0 and w.flood_cover.walk_stage==-1 and not w.flood_cover.is_processing())
			ok("Actors draw above the cover",w.leader_sprite.z_index==83 and w.partner_sprite.z_index==84 and not w.partner_sprite.visible)
			if hero==0 and partner==1:
				await click(w.confirm);ok("First press finishes the page without skipping a beat",w.phase==0 and UI._line.done)
				await shot("0-waking")
			await beat(w);await frames(3)
			ok("Partner choice has two alternatives and rising-water story",w.phase==1 and w.cards.size()==2 and w.prose.text.contains("trainee") and w.prose.text.contains("still rising"))
			# Choose the intended partner by its real button, then exercise Back and restore.
			for b in w.cards:
				if b.text.contains(w.NAMES[partner]):await click(b);break
			if hero==0 and partner==1:
				await click(w.back);ok("Back retains soul identity",w.phase==0 and w.hero==hero and w.cards.is_empty())
				await beat(w);await frames(2)
			await beat(w);await frames(3)
			ok("Agreement points to higher ground, with blocked Highbank road",w.phase==2 and w.partner==partner and w.prose.text.contains("road is flooded") and w.prose.text.contains("route alone") and not w.prose.text.contains("head for Highbank"))
			ok("Buttons and title use house pixel faces",w.title.get_theme_font("font")==UI.font("name") and w.confirm.get_theme_font("font")==UI.font("button"))
			if hero==0 and partner==1:
				UI.finish_line();await frames(2);await shot("2-higher-ground")
			await beat(w);await frames(18)
			var bank:Node=current_scene
			ok("Actual choice opens the waking riverbank",bank!=null and bank.scene_file_path=="res://scenes/waking_riverbank.tscn")
			ok("Identity/companion record survives the handoff",Team.data.party==[[hero,0],[partner,0]] and Team.data.metas.creature_player==w.FORMS[hero] and Team.data.metas.opening_companion==w.FORMS[partner])
			ok("Flood rise plays on first entry",bank.leaving and bank.view.get_child_count()>4)
			w.queue_free();bank.queue_free();load("res://scripts/audio/music.gd")._inst=null;await frames(8)
	print("WAKING CHECKS ",checks-fails,"/",checks);quit(1 if fails else 0)
