@tool
extends EditorPlugin
var hook: EditorExportPlugin
func _enter_tree() -> void:
 hook=preload("res://addons/godot_ai/export/mcp_export_plugin.gd").new()
 add_export_plugin(hook)
func _exit_tree() -> void:
 remove_export_plugin(hook)
 hook=null
