from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert not (W/'protected-before.json').exists()
base={p.relative_to(L).as_posix():sha(p) for f in ('scripts','scenes','data','dialogue','tools') for p in (L/f).rglob('*') if p.is_file() and '__pycache__' not in p.parts};base['project.godot']=sha(L/'project.godot')
(W/'protected-before.json').write_text(json.dumps(base,indent=2))
for rel in ('scripts/main_menu.gd','scripts/opening_flow.gd','scripts/creature_opening.gd','scripts/town/team_state.gd','scripts/town/hub_town.gd','scripts/dungeon/dungeon.gd','scripts/ui/ui_style.gd','docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-26.md'):
 dest=W/'originals'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,dest)
rel='scripts/main_menu.gd';s=(L/rel).read_text()
s=s.replace('var _route_scene: PackedScene','var _route_requested := false\nvar _route_scene: PackedScene',1)
s=s.replace('\t# The first route loads in the background while the menu shows.\n\t_request_route()','\t# The legacy courier route is requested only when its New Game page opens.',1)
s=s.replace('func _request_route() -> void:\n\t_route_request_error', '''func _request_route() -> void:
\tif _route_requested: return
\t_route_requested = true
\tif _begin_button != null: _begin_button.disabled = true
\t_route_request_error''',1)
s=s.replace('\tif _ask_new_game(): return\n\t_sound(CONFIRM_SOUND)','\tif _ask_new_game(): return\n\t_request_route()\n\t_sound(CONFIRM_SOUND)',1)
s=s.replace('func _poll_route() -> void:\n\tif _route_scene','func _poll_route() -> void:\n\tif not _route_requested: return\n\tif _route_scene',1)
a=s.index('func _on_continue()');b=s.index('func _select_courier(',a)
s=s[:a]+'''func _on_continue() -> void:
\tif _leaving or ("_boot_done" in self and not get("_boot_done")): return
\t# Feedback first. No destination read or construction can hold the visible title still.
\t_leaving = true
\t_sound(CONFIRM_SOUND)
\t_fade.mouse_filter = Control.MOUSE_FILTER_STOP
\t_cursor.hide()
\tfor control in _focus_controls:
\t\tcontrol.mouse_filter = Control.MOUSE_FILTER_IGNORE
\t\tcontrol.focus_mode = Control.FOCUS_NONE
\tvar tween := create_tween().set_parallel()
\ttween.tween_property(_fade, "color:a", 1.0, 0.25 if _reduce_motion else 0.7)
\ttween.tween_property(_music, "volume_db", -80.0, 0.25 if _reduce_motion else 0.85)
\tawait tween.finished
\tif not TeamState.load_save():
\t\t_continue_failed(true)
\t\treturn
\t# Preserve the suspend record until a destination has loaded and the scene change succeeds.
\tvar run: Dictionary = TeamState.data.get("suspend", {}).duplicate(true) if TeamState.has_suspended() else {}
\tvar path := "res://scenes/hub_town.tscn" if run.is_empty() else "res://scenes/dungeon.tscn"
\tvar tree := get_tree()
\t# Highbank's existing card/build/reveal owns this cover after the scene swap.
\tUI._fade_rect(tree, 1.0)
\tawait tree.process_frame
\tvar packed: PackedScene = await _load_continue(path)
\tif packed == null:
\t\t_continue_failed()
\t\treturn
\tvar town := packed.instantiate()
\tif town == null:
\t\t_continue_failed()
\t\treturn
\tTeamState.give_to(town)
\tif not run.is_empty():
\t\ttown.set("dungeon", String(run.get("dungeon", "first")))
\t\ttown.set("floor_n", int(run.get("floor_n", 1)))
\t\ttown.set("floor_seed", int(run.get("floor_seed", 0)))
\t\ttown.set("replay", bool(run.get("replay", false)))
\t\ttown.set("return_to_town", true)
\t\ttown.set("resume", run)
\t_save_preferences()
\tvar error := tree.change_scene_to_node(town)
\tif error != OK:
\t\ttown.free()
\t\t_continue_failed()
\t\treturn
\tif not run.is_empty():
\t\tTeamState.take_suspended()
\t\t# The dungeon builds under its own opaque floor card and lifts it itself.
\t\tUI.fade_in(tree, 0.0)


func _load_continue(path: String) -> PackedScene:
\tif ResourceLoader.load_threaded_request(path) != OK: return null
\twhile is_inside_tree():
\t\tmatch ResourceLoader.load_threaded_get_status(path):
\t\t\tResourceLoader.THREAD_LOAD_LOADED:
\t\t\t\treturn ResourceLoader.load_threaded_get(path) as PackedScene
\t\t\tResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
\t\t\t\treturn null
\t\tawait get_tree().process_frame
\treturn null


func _continue_failed(invalid_save := false) -> void:
\t_leaving = false
\t_fade.color.a = 0.0
\t_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
\t_music.volume_db = music_db
\tif invalid_save and _continue_button != null: _continue_button.disabled = true
\tfor control in _focus_controls:
\t\tcontrol.mouse_filter = Control.MOUSE_FILTER_STOP
\t\tcontrol.focus_mode = Control.FOCUS_ALL
\tvar first: Control = _buttons.filter(func(b: Button) -> bool: return not b.disabled)[0]
\t_quiet_focus = true
\t_show_page("main", first)
\tset_deferred("_quiet_focus", false)
\t_sound(CANCEL_SOUND)
\tUI.fade_in(get_tree())
\tUI.toast(get_tree(), "Could not continue. Please try again.")


'''+s[b:]
p=W/'prepared'/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s,encoding='utf-8');print('Prepared main_menu.gd only;',len(base),'protected files.')
