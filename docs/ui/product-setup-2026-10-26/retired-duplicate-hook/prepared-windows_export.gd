@tool
extends EditorExportPlugin
## The source project keeps its debugger helper. Only this preset's in-memory export settings omit it.
const FEATURE := "hollowtide_windows"
const HELPER := "autoload/_mcp_game_helper"
var _removed := false
var _helper_value: Variant
var _helper_order := 0
func _get_name() -> String:return "HollowtideWindows"
func _export_begin(features: PackedStringArray, _debug: bool, _path: String, _flags: int) -> void:
	if not features.has(FEATURE) or not ProjectSettings.has_setting(HELPER):return
	_helper_value = ProjectSettings.get_setting(HELPER)
	_helper_order = ProjectSettings.get_order(HELPER)
	ProjectSettings.set_setting(HELPER, null)
	_removed = true
func _export_end() -> void:
	if not _removed:return
	ProjectSettings.set_setting(HELPER, _helper_value)
	ProjectSettings.set_order(HELPER, _helper_order)
	_helper_value = null
	_removed = false
