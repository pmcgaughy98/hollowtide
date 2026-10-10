extends SceneTree
const OUT="D:/dev/hollowtide-handoff-palettes-20261009/"
const SPECS=[[9,0,"dustkite"],[9,1,"waywhistle"],[9,2,"highsignal"],[2,1,"riftfin"],[2,2,"scourmaw"]]
var checks:Array[Dictionary]=[]
var failed:Array[String]=[]
var actors:Array[Dictionary]=[]
var arena:Node2D
var dungeon:Node2D
func _initialize() -> void:call_deferred("run")
func check(s:String,ok:bool) -> void:
	checks.append({"check":s,"passed":ok})
	if not ok:failed.append(s)
	print(s,": ",ok)
func label(text:String,at:Vector2) -> void:
	var l:=Label.new();l.text=text;l.position=at;l.add_theme_font_size_override("font_size",20);root.add_child(l)
func frames(n:int) -> void:
	for i in n:await process_frame
func run() -> void:
	root.size=Vector2i(1152,648)
	var back:=ColorRect.new();back.color=Color("#3d493f");back.size=Vector2(1152,648);root.add_child(back)
	label("ARENA SIZE · shared Hollowtide Sprite finish",Vector2(22,16))
	label("DUNGEON SIZE · stage sizes retained",Vector2(22,337))
	arena=Node2D.new();arena.set_script(load("res://scripts/arena/arena_prototype.gd"))
	dungeon=Node2D.new();dungeon.set_script(load("res://scripts/dungeon/dungeon.gd"))
	arena._world=Node2D.new();arena._world.scale=Vector2(3,3);root.add_child(arena._world)
	dungeon._world=Node2D.new();dungeon._world.scale=Vector2(3,3);root.add_child(dungeon._world)
	for i in SPECS.size():
		var spec:Array=SPECS[i]
		var a:Dictionary=arena._make_fighter(spec[0],spec[1],Vector2(42+i*73,87),"se",false)
		var d:Dictionary=dungeon._make(spec[0],spec[1],0,Vector2i(0,0))
		d.node.position=Vector2(42+i*73,191)
		actors.append({"record":a,"owner":arena,"kind":"arena"})
		actors.append({"record":d,"owner":dungeon,"kind":"dungeon"})
		label(String(spec[2]).capitalize(),Vector2(75+i*219,280))
		label(String(spec[2]).capitalize(),Vector2(75+i*219,591))
		check(spec[2]+" wears finish in both constructors",a.sprite.material!=null and d.sprite.material!=null)
		check(spec[2]+" loads actual dungeon set",d.art.still.s.resource_path.contains("/dungeon/"))
	var count:=0;var worst:=0.0;var complete:=true
	for actor in actors:
		var f:Dictionary=actor.record
		for facing in arena.FACINGS:
			complete=complete and f.art.walk[facing].size()==8
			var textures:Array=[f.art.still[facing]]+Array(f.art.walk[facing])
			for tex in textures:
				if actor.kind=="arena":actor.owner._set_texture(f,tex)
				else:actor.owner._set_tex(f,tex)
				var bottom:float=f.sprite.position.y+f.sprite.offset.y-tex.get_height()*0.5+f.art.foot[tex]
				worst=maxf(worst,absf(bottom));count+=1
	check("Both loaders provide all 720 facing/walk textures",count==720 and complete)
	check("Every texture swap retains the planted feet row",worst<0.01)
	DirAccess.make_dir_recursive_absolute(OUT+"native-loop")
	for sample in 24:
		for actor in actors:
			var f:Dictionary=actor.record;var tex:Texture2D=f.art.walk.se[(sample/3)%8]
			if actor.kind=="arena":actor.owner._set_texture(f,tex)
			else:actor.owner._set_tex(f,tex)
		await frames(6);await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OUT+"native-loop/frame_%02d.png"%sample)
	for actor in actors:
		var f:Dictionary=actor.record
		if actor.kind=="arena":actor.owner._set_texture(f,f.art.still.se)
		else:actor.owner._set_tex(f,f.art.still.se)
	await frames(2);await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"native-palette-view.png")
	var file:=FileAccess.open(OUT+"native-checks.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failed,"textures":count,"worst_anchor_error":worst},"  "));file.close()
	arena._world.queue_free();dungeon._world.queue_free();arena.free();dungeon.free();await frames(3)
	quit(0 if failed.is_empty() else 1)
