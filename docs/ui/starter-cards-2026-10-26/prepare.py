from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert not (W/'protected-before.json').exists()
base={p.relative_to(L).as_posix():sha(p) for folder in ('scripts','scenes','data','dialogue','tools') for p in (L/folder).rglob('*') if p.is_file() and '__pycache__' not in p.parts}
base['project.godot']=sha(L/'project.godot')
(W/'protected-before.json').write_text(json.dumps(base,indent=2))
for rel in ('scripts/soul_prologue.gd','tools/debug/opening_flow_check.gd','scripts/ui/ui_style.gd','docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-26.md'):
 p=W/'originals'/rel;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,p)
s=(L/'scripts/soul_prologue.gd').read_text(encoding='utf-8')
s=s.replace('var stage := "talk"        # talk, choose, after, fly, done','var stage := "talk"        # talk, choose, confirm, after, fly, done')
s=s.replace('var _blip: AudioStreamPlayer','var _presence: AudioStreamPlayer\nvar _choice_wait := 0.0\nvar _accept_released := true\nvar _answer := 1   # Yes / No: a fresh choice starts on No')
a=s.index('\t_blip = AudioStreamPlayer.new()');b=s.index('\tvar rng :=',a)
s=s[:a]+'''\t_presence = AudioStreamPlayer.new()
\t_presence.stream = preload("res://assets/audio/sfx/dungeon/presence_swell.wav")
\t_presence.volume_db = -14.0
\t_presence.bus = &"UI"
\tadd_child(_presence)
'''+s[b:]
s=s.replace('if stage in ["talk", "choose"]:', 'if stage == "confirm": return ["%s?" % NAMES[pick], ""]\n\tif stage in ["talk", "choose"]:',1)
s=s.replace('\t_t += delta','''\t_t += delta
\t_choice_wait = maxf(0.0, _choice_wait - delta)
\tif not _accept_down(): _accept_released = true''',1)
s=s.replace('if stage == "choose":\n\t\thome', 'if stage in ["choose", "confirm"]:\n\t\thome',1)
s=s.replace('\t\t\telse:\n\t\t\t\tadvance()','\t\t\telse:\n\t\t\t\tif stage == "confirm": _answer = 0\n\t\t\t\tadvance()',1)
s=s.replace('\t\t\t\t\tstage = "choose"   # the last line is shown over the choice','\t\t\t\t\tstage = "choose"   # the last line is shown over the choice\n\t\t\t\t\t_choice_wait = 0.4\n\t\t\t\t\t_accept_released = false',1)
a=s.index('\t\t"choose":\n');b=s.index('\n\nfunc _fly()',a)
s=s[:a]+'''\t\t"choose":
\t\t\tif not _choice_ready(): return
\t\t\tstage = "confirm"
\t\t\t_answer = 1
\t\t\t_accept_released = false
\t\t\tUI.tick("open")
\t\t"confirm":
\t\t\tif not _choice_ready(): return
\t\t\t_accept_released = false
\t\t\tif _answer == 1:
\t\t\t\t_back_to_cards()
\t\t\t\treturn
\t\t\tchosen = pick
\t\t\tstage = "after"
\t\t\tline = 0
\t\t\tUI.tick("confirm")
\t\t\t_presence.play()
\t\t\t_start_line()


func _accept_down() -> bool:
\tfor action in UI.INPUT_ADVANCE:
\t\tif Input.is_action_pressed(action): return true
\treturn Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)


func _choice_ready() -> bool:
\treturn _choice_wait <= 0.0 and _accept_released


func _back_to_cards() -> void:
\tstage = "choose"
\t_accept_released = false
\tUI.tick("cancel")


func _move_pick(step: int) -> void:
\tpick = posmod(pick + step, 3)
\tUI.tick("cursor")


func _move_answer() -> void:
\t_answer = 1 - _answer
\tUI.tick("cursor")
'''+s[b:]
a=s.index('func _input(');b=s.index('\n\n# ---------------------------------------------------------------- drawing',a)
s=s[:a]+'''func _input(event: InputEvent) -> void:
\t# UI.pressed ignores centre events; feed them to its shared edge tracker too.
\tif event is InputEventJoypadMotion: UI._motion_edge(event)
\tif not _accept_down(): _accept_released = true
\tif auto or _opening_fade or stage in ["fly", "done"]: return
\tif stage == "confirm" and UI.pressed(event, "cancel"):
\t\t_back_to_cards()
\telif stage in ["choose", "confirm"] and UI.pressed(event, "move_left"):
\t\tif stage == "choose": _move_pick(-1)
\t\telse: _move_answer()
\telif stage in ["choose", "confirm"] and UI.pressed(event, "move_right"):
\t\tif stage == "choose": _move_pick(1)
\t\telse: _move_answer()
\telse:
\t\tvar next := false
\t\tfor action in UI.INPUT_ADVANCE:
\t\t\tif UI.pressed(event, action): next = true
\t\tif not next: return
\t\tif stage in ["choose", "confirm"]:
\t\t\tadvance()
\t\telif _accept_released:
\t\t\t_accept_released = false
\t\t\tadvance()   # one event, even when J/A belongs to multiple advance actions
\tget_viewport().set_input_as_handled()


func _card_rect(k: int) -> Rect2:
\treturn Rect2(66 + k * 348, 176 - (12 if k == pick else 0), 324, 312)


func _answer_rect(k: int) -> Rect2:
\treturn Rect2(676 + k * 144, 524, 124, 48)


func _on_click(event: InputEvent) -> void:
\tif auto or _opening_fade or not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT): return
\tif stage == "confirm":
\t\tif not _choice_ready(): return
\t\tfor k in 2:
\t\t\tif _answer_rect(k).has_point(event.position):
\t\t\t\t_answer = k
\t\t\t\tadvance()
\t\t\t\treturn
\t\treturn
\tif stage == "choose":
\t\tif not _choice_ready(): return
\t\tfor k in 3:
\t\t\tif _card_rect(k).has_point(event.position):
\t\t\t\tif k == pick: advance()
\t\t\t\telse:
\t\t\t\t\tpick = k
\t\t\t\t\tUI.tick("cursor")
\t\t\t\t\t_accept_released = false
\t\t\t\treturn
\t\treturn
\tif _accept_released:
\t\t_accept_released = false
\t\tadvance()
'''+s[b:]
a=s.index('func _draw_ui()');b=s.index('\n\nvar _shared_scale',a)
s=s[:a]+'''func _draw_ui() -> void:
\tvar c := _ui
\tif stage in ["choose", "confirm", "after", "fly"]:
\t\tfor k in 3: _draw_card(k)
\tvar box := Rect2(140, 498, 872, 122)
\tif stage in ["choose", "confirm"]:
\t\t# Choices stay fully visible, independent of the shared story typewriter's last page.
\t\tUI.panel(c, box, 0.95)
\t\tUI.nameplate(c, box.position + Vector2(24, -22), "???")
\t\tUI.say(c, box.position + Vector2(30, 56), _text(), "story", UI.TEXT)
\t\tvar hint := "%s / %s  choose      %s  review" % [UI.binding_text("move_left"), UI.binding_text("move_right"), UI.binding_text("confirm")]
\t\tif stage == "confirm":
\t\t\tfor k in 2:
\t\t\t\tvar answer := _answer_rect(k)
\t\t\t\tUI.panel(c, answer, 1.0, k == _answer)
\t\t\t\tUI.say(c, answer.position + Vector2(0, 32), "Yes" if k == 0 else "No", "button", UI.EDGE_LIGHT if k == _answer else UI.TEXT, answer.size.x, HORIZONTAL_ALIGNMENT_CENTER)
\t\t\thint = "%s / %s  choose      %s  confirm      %s  back" % [UI.binding_text("move_left"), UI.binding_text("move_right"), UI.binding_text("confirm"), UI.binding_text("cancel")]
\t\tUI.say(c, box.position + Vector2(30, 104), hint, "label", UI.TEXT, box.size.x - 60, HORIZONTAL_ALIGNMENT_RIGHT)
\telif stage in ["talk", "after"]:
\t\tUI.dialogue(c, box, "???", _text(), null, _t)
'''+s[b:]
s=s.replace('## The largest half-step scale at which every starter fits its card, shared by all three.','## One whole-pixel scale for the existing full-body showcase family, shared by all three.')
s=s.replace('146.0 / box.size.y, 246.0 / box.size.x','156.0 / box.size.y, 256.0 / box.size.x')
s=s.replace('floorf(clampf(fit, 0.5, 2.0) * 2.0) / 2.0','maxf(1.0, floorf(fit))')
s=s.replace('k == pick and stage == "choose"','k == pick and stage in ["choose", "confirm"]')
s=s.replace('1.0 if stage == "choose" or k == chosen','1.0 if stage in ["choose", "confirm"] or k == chosen')
s=s.replace('\tc.draw_style_box(UI.frame("portrait"), stage_r)','''\tc.draw_style_box(UI.frame("portrait"), stage_r)
\t# Main-essence colours from the dungeon's existing essence palette.
\tvar tint: Color = [Color(1, 0.55, 0.25), Color(0.5, 0.9, 0.4), Color(0.35, 0.75, 1)][k]
\tc.draw_rect(stage_r.grow(-8), Color(tint, 0.12 * fade))''',1)
s=s.replace('stage_r.size.y - size.y - 18','(stage_r.size.y - size.y) * 0.5')
s=s.replace('Vector2(28, 238), NAMES[k], "name"','Vector2(28, 248), NAMES[k], "title"')
s=s.replace('(UI.EDGE_LIGHT if on else UI.TEXT) * Color(1, 1, 1, fade))','(UI.EDGE_LIGHT if on else UI.TEXT) * Color(1, 1, 1, fade), r.size.x - 56)',1)
s=s.replace('r.position.y + 214, 28, 28','r.position.y + 32, 24, 24')
s=s.replace('Vector2(28, 262)','Vector2(28, 278)')
p=W/'prepared/scripts/soul_prologue.gd';p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s,encoding='utf-8')
# The existing driver must actually exercise the new contracts and retain Claude's partner gate.
s=(L/'tools/debug/opening_flow_check.gd').read_text(encoding='utf-8')
s=s.replace('\telse:\n\t\tawait key(KEY_ENTER)\n\tif not verify("Storm enters', '\telse:\n\t\tawait key(KEY_ENTER)\n\t\tverify("First Storm press only arms skip", current_scene == storm and storm._skip_armed)\n\t\tawait key(KEY_ENTER)\n\tif not verify("Storm enters',1)
s=s.replace('\tawait key(KEY_ENTER)\n\tverify("Soul confirms selected starter"', '''\tawait frames(14)   # cards ignore the reading press for 0.4 s
\tawait key(KEY_ENTER)
\tverify("Starter asks before committing and defaults to No", soul.stage == "confirm" and soul.chosen == -1 and soul._answer == 1)
\tawait key(KEY_LEFT)
\tawait key(KEY_ENTER)
\tverify("Soul confirms selected starter"''',1)
p=W/'prepared/tools/debug/opening_flow_check.gd';p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s,encoding='utf-8')
print('Prepared two owned files; snapshotted',len(base),'protected files.')
