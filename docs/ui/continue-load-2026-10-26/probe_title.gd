extends "res://scripts/creature_opening.gd"
var force_failure := false
var requests := 0
func _load_continue(path: String) -> PackedScene:
	requests+=1
	var cover: Node=get_tree().root.get_node_or_null(UI.FADE_NAME)
	get_tree().set_meta("continue_probe",{"path":path,"local_alpha":_fade.color.a,"shared_alpha":cover.get_node("Rect").color.a if cover!=null else -1.0,"requests":requests,"time":Time.get_ticks_usec(),"saved_hash":FileAccess.get_sha256(TeamState.save_path),"suspended":TeamState.has_suspended()})
	if force_failure:
		await get_tree().process_frame
		await get_tree().process_frame
		return null
	return await super._load_continue(path)
