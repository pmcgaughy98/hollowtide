extends SceneTree
const OUT="D:/dev/hollowtide-creature-town-menu-20261009/"
var checks:Array[Dictionary]=[]
var failures:Array[String]=[]
func _initialize() -> void:call_deferred("run")
func check(label:String,ok:bool) -> void:
	checks.append({"check":label,"passed":ok})
	if not ok:failures.append(label)
	print(label,": ",ok)
func frames(n:int) -> void:
	for i in n:await process_frame
func capture(name:String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+name+".png")
func run() -> void:
	root.size=Vector2i(1152,648)
	var menu:Node2D=load("res://scenes/creature_opening.tscn").instantiate()
	root.add_child(menu);current_scene=menu
	await frames(3)
	check("Boot shown",not menu._boot_done)
	menu._finish_boot()
	await frames(150)
	check("Boot reaches title",menu._boot_done and menu._page=="main")
	check("Two finished creatures replace human menu actor",menu.companions.size()==2 and not menu.has_node("CourierMenuIdle"))
	menu._on_options();await frames(2)
	check("Options still open",menu._page=="options")
	menu._close_panel();await frames(2)
	check("Retro village backdrop installed",menu.get_node("CreatureVillage").texture.resource_path.ends_with("creature_village_2026_10_09.png"))
	check("Menu fits the village composition",menu._main_panel.position.x==44 and menu._main_panel.get_rect().end.y<648)
	menu._buttons[0].grab_focus();await frames(2);await capture("title")
	menu._on_options();await frames(2);await capture("options");menu._close_panel();await frames(2)
	menu._on_new_game()
	await frames(70)
	var story:Node2D=current_scene
	check("New Game opens awakening",story.get_script().resource_path.ends_with("creature_prologue.gd"))
	await capture("awakening")
	for hero in 3:
		story.phase=0;story.choose(hero)
		check("Hero %d can be selected"%hero,story.hero==hero)
		story.advance()
		check("Companion differs from hero %d"%hero,story.partner!=hero and story.cards.size()==2)
		for partner in 3:
			if hero==partner:continue
			story.choose(partner)
			story.advance()
			check("Pair %d/%d confirmation"%[hero,partner],story.phase==2 and story.hero==hero and story.partner==partner)
			story.previous()
		story.previous()
		check("Can revise creature identity",story.phase==0)
	story.choose(1);story.advance();story.choose(2)
	await frames(3);await capture("companion")
	story.advance()
	await frames(3);await capture("together")
	story.advance()
	await frames(100)
	var dungeon:Node2D=current_scene
	dungeon.poll_input=false
	check("Chosen creature leads dungeon",dungeon.party==[[1,0],[2,0]] and dungeon.ents[0].line==1)
	check("Claude's current turn-based combat retained",not dungeon.real_time_battles)
	check("Party sprites carry finish",dungeon.ents[0].sprite.material!=null and dungeon.ents[1].sprite.material!=null)
	await capture("dungeon")
	var painter=load("res://scripts/dungeon/floor_painter.gd")
	var tile_art:Image=load("res://assets/tilesets/hollow_bank_2026_10_09/terrain_24.png").get_image()
	var colors:Dictionary={}
	var opaque:=true
	for y in tile_art.get_height():
		for x in tile_art.get_width():
			var c:=tile_art.get_pixel(x,y)
			opaque=opaque and c.a>0.99
			colors[c.to_rgba32()]=true
	check("16 nonblank opaque native tiles",tile_art.get_size()==Vector2i(96,96) and opaque and colors.size()>100)
	var tileset:TileSet=load("res://assets/tilesets/hollow_bank_2026_10_09/terrain_24.tres")
	check("Editor tileset exposes 16 native cells",tileset.tile_size==Vector2i(24,24) and tileset.get_source(0).get_tiles_count()==16)
	var before:PackedByteArray=dungeon.data.tiles.duplicate()
	var a:Image=painter.paint(dungeon.data,24,4242)
	var b:Image=painter.paint(dungeon.data,24,4242)
	check("Terrain render deterministic",a.get_data()==b.get_data())
	check("Terrain leaves gameplay topology exact",before==dungeon.data.tiles)
	check("Native 24px floor size",a.get_width()==dungeon.data.w*24 and a.get_height()==dungeon.data.h*24)
	a.save_png(OUT+"floor-after.png")
	var old:Image=painter.paint_procedural(dungeon.data,24,4242)
	old.save_png(OUT+"floor-before.png")
	check("Visible floor upgrade",a.get_data()!=old.get_data())
	var fallback:Image=painter.paint(dungeon.data,16,4242)
	check("16px procedural fallback retained",fallback.get_width()==dungeon.data.w*16)
	dungeon.queue_free();await frames(4)
	var f:=FileAccess.open(OUT+"checks.json",FileAccess.WRITE)
	f.store_string(JSON.stringify({"checks":checks,"failures":failures},"  "));f.close()
	print("RESULT ",checks.size()," checks / ",failures.size()," failures")
	quit(0 if failures.is_empty() else 1)
