extends SceneTree
const W := "D:/dev/hollowtide-pilot-waking-20261010/"
var out := W+"review/after/"
var count := 0
var bad := 0
func _initialize() -> void: run.call_deferred()
func frames(n: int) -> void:
	for k in n: await process_frame
func check(ok: bool, message: String) -> void:
	count+=1
	if not ok: bad+=1
	print("PASS " if ok else "FAIL ",message)
func key(code: Key) -> void:
	for down in [true,false]:
		var e:=InputEventKey.new();e.keycode=code;e.physical_keycode=code;e.pressed=down
		Input.parse_input_event(e);await frames(3)
func click(b: Control) -> void:
	for down in [true,false]:
		var e:=InputEventMouseButton.new();e.position=b.get_global_rect().get_center();e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down
		Input.parse_input_event(e);await frames(3)
func shot(name: String) -> void:
	await frames(6);await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out+name+".png")
func run() -> void:
	root.size=Vector2i(1152,648)
	if ProjectSettings.globalize_path("res://").to_lower().begins_with("c:/"):out=W+"review/live/"
	DirAccess.make_dir_recursive_absolute(out)
	# All three soul identities, and both permitted partners, retain the old choice contract.
	for h in 3:
		var pro:Node=load("res://scenes/creature_prologue.tscn").instantiate()
		pro.hero=h;pro.partner=(h+1)%3;pro.chosen_by_soul=true;pro.reduce_motion=true
		root.add_child(pro);await frames(8)
		check(pro.cards.size()==0 and pro.prose.text.contains(pro.SENSES[h]),"soul identity %s keeps its body sensation and hides identity picker"%pro.FORMS[h])
		check(pro.prose.text.contains("river") and pro.prose.text.contains("rising Hollow") and pro.prose.text.contains("human"),"collapse, rising Hollow and retained human memory are present")
		var frozen:float=pro.bank.clock
		await frames(15)
		check(pro.bank.clock==frozen,"Reduce Motion freezes river glints")
		for p in 3:
			if p==h:continue
			pro.phase=1;pro.refresh();await frames(3)
			check(pro.cards.size()==2 and pro.partner_sprite.visible,"trainee still offers the two other partner forms")
			pro.choose(p)
			check(pro.partner==p and pro.partner_sprite.texture.resource_path.contains(pro.FORMS[p]),"chosen trainee sprite matches %s"%pro.FORMS[p])
			check(pro.prose.text.contains("Wayline trainee") and pro.prose.text.contains("mail") and pro.prose.text.contains("Something told me"),"trainee recovers mail and follows the quiet call")
			for phase in 3:
				pro.phase=phase;pro.refresh();await frames(3)
				var wrapped:String=pro.dialogue._wrapped(pro.prose.text,878)
				check(wrapped.split("\n").size()<=3,"dialogue fits phase %d, hero %d partner %d: %d lines"%[phase,h,p,wrapped.split("\n").size()])
				check(pro.panel.size.x==948 and pro.panel.position.x==102,"phase %d choice panel stays aligned at its designed width"%phase)
				check(pro.dialogue.portrait.material is ShaderMaterial and pro.leader_sprite.material is ShaderMaterial,"framed portraits and actors retain creature finish")
			pro.phase=2;pro.refresh()
			check(pro.prose.text.contains("No one runs a route alone") and pro.prose.text.contains("turning me away") and pro.prose.text.contains("guide") and pro.prose.text.contains("Highbank"),"both partners have a reason to go to Highbank")
		if h==1:
			for phase in 3:
				pro.phase=phase;pro.refresh();await shot("wake-%d"%phase)
			await RenderingServer.frame_post_draw
			pro.bank.get_viewport().get_texture().get_image().save_png(out+"riverbank-native.png")
		pro.queue_free();await frames(8)
	# Real mouse/keyboard input: legacy identity selection, partner selection, Back and town entry.
	change_scene_to_file("res://scenes/creature_prologue.tscn");await frames(8)
	var pro:Node=current_scene
	root.grab_focus();await frames(3)
	check(pro.bank.clock>0.0,"normal-motion river glints animate")
	check(pro.leader_sprite.position.y*3 < pro.title.position.y-12 and pro.partner_sprite.position.y*3 < pro.title.position.y-12,"creature feet clear the heading")
	await click(pro.cards[2]);check(pro.hero==2,"legacy identity mouse selection works")
	await key(KEY_ENTER);check(pro.phase==1,"Enter advances to trainee")
	await click(pro.cards[0]);check(pro.partner==0,"real partner mouse selection works")
	await key(KEY_ENTER);check(pro.phase==2,"Enter advances to mutual agreement")
	await key(KEY_ESCAPE);check(pro.phase==1 and pro.partner==0,"Back retains chosen companion")
	await key(KEY_ENTER);await key(KEY_ENTER);await frames(30)
	check(current_scene.get_script().resource_path.ends_with("hub_town.gd") and current_scene.party==[[2,0],[0,0]],"real confirmation reaches Highbank with the chosen team")
	await shot("highbank-arrival")
	for n in root.get_children():n.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	await frames(12)
	print("WAKING ",count-bad,"/",count," PASS")
	quit(0 if bad==0 else 1)
