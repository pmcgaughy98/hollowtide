from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert not (W/'protected-before.json').exists()
paths=set()
for folder in ('scripts','scenes','data','dialogue','tools'):
    paths.update(p for p in (L/folder).rglob('*') if p.is_file() and '__pycache__' not in p.parts)
for folder in ('assets/fonts','assets/sprites/ui','assets/sprites/menu'):
    paths.update(p for p in (L/folder).rglob('*') if p.is_file())
paths.update(L/p for p in ('project.godot','docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-22.md'))
base={p.relative_to(L).as_posix():sha(p) for p in sorted(paths)}
(W/'protected-before.json').write_text(json.dumps(base,indent=2),encoding='utf-8')
for rel in ('scripts/main_menu.gd','scripts/creature_opening.gd','scripts/soul_prologue.gd','scripts/ui/ui_style.gd','tools/debug/ui_fit_check.gd','docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-22.md'):
    p=W/'originals'/rel;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,p)
def edit(rel,changes):
    raw=(L/rel).read_bytes();nl=b'\r\n' if b'\r\n' in raw else b'\n';s=raw.decode().replace('\r\n','\n')
    for a,b in changes:
        assert s.count(a)==1,(rel,a[:100]);s=s.replace(a,b)
    out=W/'prepared'/rel;out.parent.mkdir(parents=True,exist_ok=True);out.write_bytes(s.encode().replace(b'\n',nl))
edit('scripts/main_menu.gd',[
('var role := "title" if size >= 30 else "body"','var role := "title" if size >= 28 else ("label" if size <= 15 else "body")'),
('\tb.add_theme_font_override("font", UI.font("button"))\n\tb.add_theme_font_size_override("font_size", UI.type_size("button"))\n\tfor state in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color"]:\n\t\tb.add_theme_color_override(state, TEXT)\n',''),
('\tb.add_theme_stylebox_override("focus", focus)\n\tb.focus_entered.connect(_on_focus)','\tb.add_theme_stylebox_override("focus", focus)\n\tUI.style_button(b)\n\tb.focus_entered.connect(_on_focus)')])
creature=(L/'scripts/creature_opening.gd').read_text(encoding='utf-8')
button=creature[creature.index('func _button(text:String) -> Button:'):creature.index('func _build_menu() -> void:')]
flat=creature[creature.index('\t\tb.add_theme_font_size_override("font_size",32)'):creature.index('\tvar rule := ColorRect.new()')]
edit('scripts/creature_opening.gd',[
('const MENU_FACE = preload("res://assets/fonts/Vollkorn-Variable.ttf")\nconst COPY_FACE = preload("res://assets/fonts/AlegreyaSansSC-Regular.ttf")\nconst HINT_FACE = preload("res://assets/fonts/Silkscreen-Regular.ttf")\n',''),
('l.add_theme_font_override("font",MENU_FACE if size>=28 else COPY_FACE)','if size==23:   # the Help section labels use the shared compact role\n\t\tl.add_theme_font_override("font",UI.font("label"))\n\t\tl.add_theme_font_size_override("font_size",UI.type_size("label"))'),
(button,''),(flat,''),
('_launch_hint.add_theme_font_override("font",HINT_FACE)\n\t_launch_hint.add_theme_font_size_override("font_size",14)','_launch_hint.add_theme_font_override("font",UI.font("label"))\n\t_launch_hint.add_theme_font_size_override("font_size",UI.type_size("label"))'),
('\t_input_hint.add_theme_font_override("font",HINT_FACE)\n',''),
('# Keep the original NewGame/Options/Quit identities; display Quit last. By the last button\'s index, not a\n\t# fixed one, since Continue is listed first when a save exists (Claude, 2026-10-12).','# Keep button identities, with How to play immediately before Quit. Use the last button\'s index\n\t# since Continue is listed first when a save exists (Claude, 2026-10-12).')])
edit('scripts/soul_prologue.gd',[
('\t\tif int(shown) / 3 != before / 3 and int(shown) < full:\n\t\t\t_blip.play()\n',''),
('\t\tvar before := int(shown)\n',''),
('\t\t"talk", "after":\n\t\t\tif shown < _text().length():','\t\t"talk", "after":\n\t\t\t# Finish the current shared dialogue page before moving to the next story line.\n\t\t\tif not UI.line_done(_text()):\n\t\t\t\tUI.finish_line()\n\t\t\t\tshown = _text().length()\n\t\t\t\treturn\n\t\t\tif shown < _text().length():'),
('c.draw_string(UI.HEAD, at + Vector2(10, -16), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1.0, 0.95, 0.8, minf(1.0, _question)))','UI.say(c, at + Vector2(10, -16), "?", "label", Color(1.0, 0.95, 0.8, minf(1.0, _question)))'),
('\t\t# The presence has no face: a name tab and no portrait, the way an unseen voice speaks in\n\t\t# Explorers of Sky.\n\t\tUI.panel(c, box, 0.95)\n\t\tUI.nameplate(c, box.position + Vector2(24, -22), "???", 26)\n\t\tvar text := _text().substr(0, int(shown)) if stage != "choose" else _text()\n\t\tc.draw_multiline_string(UI.HEAD, box.position + Vector2(30, 50), text, HORIZONTAL_ALIGNMENT_LEFT, box.size.x - 80, 21, 3, UI.TEXT)',
 '\t\t# An unseen voice uses the same story role and two-row pages as the waking dialogue.\n\t\tUI.dialogue(c, box, "???", _text(), null, _t)'),
('\t\tif stage == "choose":\n\t\t\tUI.text(c, box.position + Vector2(0, 108), "A / D  choose      J  this shape", 15, Color(UI.MUTED, 0.6 + 0.4 * sin(_t * 4.0)), box.size.x - 30, HORIZONTAL_ALIGNMENT_RIGHT)\n\t\telif shown >= _text().length():\n\t\t\tUI.next_arrow(c, box.end - Vector2(48, 36), _t)',
 '\t\tif stage == "choose":\n\t\t\tUI.finish_line()   # the short choice prompt stays fully visible\n\t\t\tUI.say(c, box.position + Vector2(0, 108), "A / D  choose      J  this shape", "label", Color(UI.MUTED, 0.6 + 0.4 * sin(_t * 4.0)), box.size.x - 30, HORIZONTAL_ALIGNMENT_RIGHT)'),
('UI.text(c, r.position + Vector2(28, 238), NAMES[k], 24,','UI.say(c, r.position + Vector2(28, 238), NAMES[k], "name",'),
('c.draw_multiline_string(UI.HEAD, r.position + Vector2(28, 262), FEEL[k], HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 56, 15, 2,','c.draw_multiline_string(UI.font("body"), r.position + Vector2(28, 262), FEEL[k], HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 56, UI.type_size("body"), 2,')])
print('Preserved',len(base),'current files and prepared three owned scripts with shared type/frame roles.')
