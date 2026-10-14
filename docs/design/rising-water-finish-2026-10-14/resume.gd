extends SceneTree
const TeamState := preload("res://scripts/town/team_state.gd")
const Water := preload("res://scripts/dungeon/rising_water_art.gd")
const WORK := "D:/dev/hollowtide-rising-water-20261014/"
var checks: Array = []
var failed := 0
var out: String
func _initialize() -> void: run.call_deferred()
func frames(n: int) -> void:
	for k in n: await process_frame
func ok(label: String, good: bool) -> void:
	checks.append({"check":label,"ok":good})
	if not good:failed+=1
	print(label," -> ","ok" if good else "FAIL")
func run() -> void:
	out=WORK+("live/" if OS.get_cmdline_user_args().has("live") else "stage/")
	DirAccess.make_dir_recursive_absolute(out);root.size=Vector2i(1152,648)
	TeamState.save_path=out+"water-resume.save"
	ok("Native painted atlases available",Water._ready_art())
	for name in ["ripples","shoreline"]:
		var tex: Texture2D=load(Water.DIR+name+".png")
		var source:=Image.load_from_file(WORK+"art/"+name+".png")
		ok("Native "+name+" atlas RGBA exact",tex.get_image().get_data()==source.get_data())
	TeamState.start([[0,0],[1,0]])
	var dg: Node2D=load("res://scenes/dungeon.tscn").instantiate()
	dg.dungeon="hollow";dg.floor_seed=1;dg.poll_input=false
	TeamState.give_to(dg);root.add_child(dg);current_scene=dg;await frames(5)
	for t in range(1,10):dg.turn=t;dg._end_turn()
	ok("Turn nine still dry",dg.water_rows==0)
	dg.turn=10;dg._end_turn()
	ok("Turn ten floods exactly the first row",dg.water_rows==1 and dg.wet(Vector2i(31,dg.water_base-1)))
	dg.turn=20;dg._end_turn()
	var record: Dictionary=dg.suspend_record()
	var unchanged:=var_to_bytes(record)
	await frames(8)
	ok("Rendering changes no suspend fields",unchanged==var_to_bytes(dg.suspend_record()))
	ok("Suspend writes isolated save",dg.suspend())
	var kept: Dictionary=TeamState._read().get("data",{}).get("suspend",{})
	ok("Disk retains exact water rows and run fields",kept==record and int(kept.get("water_rows",0))==2)
	var expected_base: int=dg.water_base
	var expected_max: int=dg.water_max
	# Use the real campaign title's Continue callback and one-use suspend path.
	var title: Node=load("res://scenes/creature_opening.tscn").instantiate()
	change_scene_to_node(title);await frames(12)
	var guard:=0
	while "_boot_done" in title and not title.get("_boot_done") and guard<600:
		await frames(1);guard+=1
	ok("Actual title is ready for Continue",not ("_boot_done" in title) or title.get("_boot_done"))
	TeamState.data={};title._on_continue();guard=0
	while (current_scene==null or current_scene==title) and guard<600:
		await frames(1);guard+=1
	var resumed:=current_scene
	var correct: bool=resumed!=null and resumed.scene_file_path=="res://scenes/dungeon.tscn"
	ok("Actual Continue opens dungeon scene",correct)
	if correct:
		resumed.poll_input=false;await frames(5)
		ok("Resumed valley, seed and water height exact",resumed.dungeon=="hollow" and resumed.floor_n==1 and resumed.floor_seed==1 and resumed.water_rows==2 and resumed.water_base==expected_base and resumed.water_max==expected_max)
		ok("Resumed clock and lantern exact",resumed.turn==record.turn and resumed.light==record.light)
		ok("Resume still starts above water with stairs dry",resumed.ents[0].pos==resumed.data.start and not resumed.wet(resumed.data.start) and not resumed.wet(resumed.data.stairs))
		ok("One-use suspend consumed in memory and on disk",not TeamState.has_suspended() and not TeamState._read().get("data",{}).has("suspend"))
		resumed.turn=21;resumed._end_turn()
		ok("No extra rise between beats after resume",resumed.water_rows==2)
		resumed.turn=30;resumed._end_turn()
		ok("Next scheduled rise reaches original ceiling",resumed.water_rows==expected_max and not resumed.wet(resumed.data.stairs) and not resumed.wet(resumed.data.start))
		resumed.queue_free();await frames(4)
	TeamState.erase_save();TeamState.save_path=TeamState.SAVE_PATH
	var music:=root.get_node_or_null("HollowtideMusic")
	if music!=null:music.queue_free()
	await frames(4)
	FileAccess.open(out+"resume-checks.json",FileAccess.WRITE).store_string(JSON.stringify({"passed":checks.size()-failed,"total":checks.size(),"checks":checks},"  "))
	print("WATER RESUME: %d/%d" % [checks.size()-failed,checks.size()]);quit(0 if failed==0 else 1)
