from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert not (W/'protected-before.json').exists()
paths=set()
for folder in ('scripts','scenes','data','dialogue','tools'):
    paths.update(p for p in (L/folder).rglob('*') if p.is_file() and '__pycache__' not in p.parts)
paths.update(L/p for p in ('project.godot','docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-26.md'))
base={p.relative_to(L).as_posix():sha(p) for p in sorted(paths)}
(W/'protected-before.json').write_text(json.dumps(base,indent=2))
for rel in ('scripts/soul_prologue.gd','scripts/ui/ui_style.gd','docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-26.md'):
    p=W/'originals'/rel;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,p)
rel='scripts/soul_prologue.gd';s=(L/rel).read_text(encoding='utf-8')
s=s.replace('var _opening_fade := false','var _opening_fade := false\nvar _backdrop: SubViewport\nvar _background_area := Rect2(Vector2.ZERO, LOW)\nvar _previous_aspect: Window.ContentScaleAspect',1)
s=s.replace('get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP','_previous_aspect = get_tree().root.content_scale_aspect\n\tget_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND',1)
s=s.replace('\tvar vp := SubViewport.new()\n\tvp.size = LOW','\tvar vp := SubViewport.new()\n\t_backdrop = vp\n\tvp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST\n\tvp.size = LOW',1)
s=s.replace('\tlayer.add_child(_ui)\n','\tlayer.add_child(_ui)\n\tget_viewport().size_changed.connect(_fit_backdrop)\n\t_fit_backdrop()\n',1)
at=s.index('func _reveal_opening()')
s=s[:at]+'''func _fit_backdrop() -> void:
\tvar size := get_viewport().get_visible_rect().size
\t_backdrop.size = Vector2i(ceili(size.x / 3.0), ceili(size.y / 3.0))
\t# Keep the authored composition centred on whole art pixels; the gradient fills the extra space.
\t_void.position = ((Vector2(_backdrop.size) - Vector2(LOW)) * 0.5).floor()
\t_ui.position = _void.position * 3.0
\t_background_area = Rect2(-_void.position, Vector2(_backdrop.size))
\t_void.queue_redraw()


func _exit_tree() -> void:
\tvar view := get_viewport()
\tif view.size_changed.is_connected(_fit_backdrop): view.size_changed.disconnect(_fit_backdrop)
\tget_tree().root.content_scale_aspect = _previous_aspect


''' +s[at:]
s=s.replace('for y in LOW.y:\n\t\tvar k := float(y) / LOW.y\n\t\tc.draw_rect(Rect2(0, y, LOW.x, 1),','for y in range(floori(_background_area.position.y), ceili(_background_area.end.y)):\n\t\tvar k := (float(y) - _background_area.position.y) / _background_area.size.y\n\t\tc.draw_rect(Rect2(_background_area.position.x, y, _background_area.size.x, 1),',1)
s=s.replace('Vector2(x0, -2), Vector2(x0 + w, -2)','Vector2(x0, _background_area.position.y - 2), Vector2(x0 + w, _background_area.position.y - 2)',1)
needle='\t\t\tc.draw_colored_polygon(poly, Color(1.0, 0.92, 0.72, 0.05 * _speak))\n\t\tc.draw_rect(Rect2(0, 0, LOW.x, 3), Color(1.0, 0.94, 0.78, 0.35 * _speak))';assert s.count(needle)==1
s=s.replace(needle,'''\t\t\tvar top := Color(1.0, 0.92, 0.72, 0.05 * _speak)
\t\t\tvar end := Color(top, 0.0)
\t\t\tc.draw_polygon(poly, PackedColorArray([top, top, end, end]))''',1)
s=s.replace('c.draw_rect(Rect2(Vector2.ZERO, LOW), Color(1, 1, 1, minf(1.0, _flash)))','c.draw_rect(_background_area, Color(1, 1, 1, minf(1.0, _flash)))',1)
raw=(L/rel).read_bytes();nl=b'\r\n' if b'\r\n' in raw else b'\n';p=W/'prepared'/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(s.encode().replace(b'\n',nl))
print('Prepared C9 in one owned script; protected',len(base),'current files.')
