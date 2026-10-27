extends Node
func _ready() -> void:
 var checks:={
  "custom_feature":OS.has_feature("hollowtide_windows"),
  "autoload_setting_removed":not ProjectSettings.has_setting("autoload/_mcp_game_helper"),
  "autoload_node_absent":get_tree().root.get_node_or_null("_mcp_game_helper")==null,
  "debug_helper_file_excluded":not ResourceLoader.exists("res://addons/godot_ai/runtime/game_helper.gd"),
  "tools_excluded":not FileAccess.file_exists("res://tools/export_probe.json"),
  "lab_excluded":not ResourceLoader.exists("res://scenes/_lab/probe.tscn"),
  "export_plugin_excluded":not ResourceLoader.exists("res://addons/godot_ai/export/mcp_export_plugin.gd"),
  "docs_resource_kept":ResourceLoader.exists("res://docs/creatures/keep.png"),
  "archived_docs_code_excluded":["gd","tscn","tres","gdshader"].all(func(ext):return not ResourceLoader.exists("res://docs/archived."+ext)),
  "icon_kept":ResourceLoader.exists("res://icon.png")}
 print("PACK PROBE ",JSON.stringify(checks))
 get_tree().quit(0 if checks.values().all(func(v):return v) else 1)
