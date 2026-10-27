extends SceneTree
const W := "D:/dev/hollowtide-product-setup-20261026"
var checks: Array=[]
func _initialize() -> void:_run.call_deferred()
func check(label: String, good: bool) -> void:
	checks.append({"check":label,"passed":good});print(label,": ","PASS" if good else "FAIL")
func _run() -> void:
	# --editor starts its filesystem asynchronously; do not quit in the middle of that first scan.
	for frame in 30:await process_frame
	var fs:=EditorInterface.get_resource_filesystem()
	while fs!=null and fs.is_scanning():await process_frame
	for frame in 10:await process_frame
	var source_hash:=FileAccess.get_sha256("res://project.godot")
	var key: String="autoload/_mcp_game_helper";var value: Variant=ProjectSettings.get_setting(key);var order:=ProjectSettings.get_order(key)
	var hook: RefCounted=load("res://addons/godot_ai/export/mcp_export_plugin.gd").new()
	check("Helper retained in source editor settings",value=="*res://addons/godot_ai/runtime/game_helper.gd")
	hook._export_begin(PackedStringArray(["hollowtide_windows"]),false,"test.exe",0)
	check("Target export removes helper setting",not ProjectSettings.has_setting(key))
	check("Export-only settings snapshot saves",ProjectSettings.save_custom(W+"/export-settings.godot")==OK)
	var exported:=ConfigFile.new();exported.load(W+"/export-settings.godot")
	check("Serialized export settings omit autoload",not exported.has_section_key("autoload","_mcp_game_helper"))
	check("Other autoloads retained",exported.has_section_key("autoload","InputPrefs") and exported.has_section_key("autoload","DialogueManager") and exported.has_section_key("autoload","PlayerParty"))
	hook._export_end()
	check("Export end restores exact helper value",ProjectSettings.get_setting(key)==value)
	hook._export_begin(PackedStringArray(["hollowtide_windows"]),true,"test.exe",0)
	check("Debug export of filtered preset omits helper too",not ProjectSettings.has_setting(key));hook._export_end()
	hook._export_begin(PackedStringArray(["unrelated"]),false,"test.exe",0)
	check("Existing addon also strips helper in other exports",not ProjectSettings.has_setting(key));hook._export_end()
	ProjectSettings.set_setting(key,null);hook._export_begin(PackedStringArray(["hollowtide_windows"]),false,"test.exe",0);hook._export_end()
	check("Absent helper is not invented",not ProjectSettings.has_setting(key));ProjectSettings.set_setting(key,value);ProjectSettings.set_order(key,order)
	check("Source project file never rewritten by hook",FileAccess.get_sha256("res://project.godot")==source_hash)
	hook=null
	var result:={"total":checks.size(),"checks":checks,"failed":checks.filter(func(c):return not c.passed).size()}
	var f:=FileAccess.open(W+"/editor-result.json",FileAccess.WRITE);f.store_string(JSON.stringify(result,"  "));f.close()
	for frame in 10:await process_frame
	quit(0 if result.failed==0 else 1)
