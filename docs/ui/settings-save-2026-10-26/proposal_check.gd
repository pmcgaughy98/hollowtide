extends SceneTree
const W := "D:/dev/hollowtide-settings-save-20261026"
const UI := preload("res://scripts/ui/ui_style.gd")
var fails := 0
var total := 0
func _initialize() -> void: _run.call_deferred()
func check(label: String, ok: bool) -> void:
	total+=1
	if not ok:fails+=1
	print("PROPOSAL_CHECK ",label," -> ","ok" if ok else "FAIL")
func _run() -> void:
	var cfg:=ConfigFile.new();cfg.set_value("menu","reduce_motion",true);cfg.set_value("menu","courier","Female");cfg.save(UI.PREFS_PATH)
	var old_hash:=FileAccess.get_sha256(UI.PREFS_PATH)
	var next:=ConfigFile.new();next.set_value("menu","reduce_motion",false);next.set_value("menu","courier","Female")
	var interrupted=load(W+"/proposal/ui_style_interrupted.gd")
	check("controlled interruption reports failure",not interrupted.write_prefs(next,UI.PREFS_PATH))
	check("interruption after backup keeps prior final exact",FileAccess.get_sha256(UI.PREFS_PATH)==old_hash and FileAccess.get_sha256(UI.PREFS_PATH+".bak")==old_hash)
	UI.reload_prefs()
	check("existing shared reader sees prior settings after interruption",UI.reduce_motion())
	var candidate=load(W+"/proposal/ui_style.gd")
	check("full proposal successfully replaces prior final",candidate.write_prefs(next,UI.PREFS_PATH))
	UI.reload_prefs()
	check("shared reader sees new setting after replacement",not UI.reduce_motion())
	check("proposal retains prior backup and consumes temp",FileAccess.get_sha256(UI.PREFS_PATH+".bak")==old_hash and not FileAccess.file_exists(UI.PREFS_PATH+".tmp"))
	var main_hash:=FileAccess.get_sha256(UI.PREFS_PATH)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(UI.PREFS_PATH+".bak"));DirAccess.make_dir_absolute(ProjectSettings.globalize_path(UI.PREFS_PATH+".bak"))
	var block=FileAccess.open(UI.PREFS_PATH+".bak/block",FileAccess.WRITE);block.store_string("private fixture");block.close()
	check("backup-copy failure is returned",not candidate.write_prefs(cfg,UI.PREFS_PATH))
	check("failed backup leaves current final exact",FileAccess.get_sha256(UI.PREFS_PATH)==main_hash)
	print("PAUSE PROPOSAL: ",total-fails,"/",total,"; staging only, not installed")
	quit(0 if fails==0 else 1)
