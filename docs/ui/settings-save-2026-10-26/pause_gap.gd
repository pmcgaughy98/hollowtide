extends SceneTree
const UI := preload("res://scripts/ui/ui_style.gd")
func _initialize() -> void: _run.call_deferred()
func _run() -> void:
	# Reproduce the state between the current shared helper's two renames, in this private profile only.
	var c:=ConfigFile.new();c.set_value("menu","reduce_motion",true);c.set_value("menu","courier","Female");c.save(UI.PREFS_PATH)
	var main:=ProjectSettings.globalize_path(UI.PREFS_PATH)
	var err:=DirAccess.rename_absolute(main,main+".bak")
	UI.reload_prefs()
	var backup:=ConfigFile.new();backup.load(UI.PREFS_PATH+".bak")
	var reproduced: bool=err==OK and not FileAccess.file_exists(UI.PREFS_PATH) and bool(backup.get_value("menu","reduce_motion",false)) and not UI.reduce_motion()
	print("PAUSE GAP DIAGNOSTIC: ","reproduced; valid backup exists but shared reader uses defaults" if reproduced else "not reproduced")
	quit(0 if reproduced else 1)
