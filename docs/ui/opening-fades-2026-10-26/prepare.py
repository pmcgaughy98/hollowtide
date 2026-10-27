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
for rel in ('scripts/storm_open.gd','scripts/soul_prologue.gd','scripts/creature_prologue.gd','scripts/ui/ui_style.gd','docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-26.md'):
    p=W/'originals'/rel;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,p)
def write(rel,s):
    raw=(L/rel).read_bytes();nl=b'\r\n' if b'\r\n' in raw else b'\n';p=W/'prepared'/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(s.encode().replace(b'\n',nl))
rel='scripts/storm_open.gd';s=(L/rel).read_text(encoding='utf-8')
s=s.replace('tw.tween_property(self, "white", 1.0, 1.0).set_delay(0.3)','tw.tween_property(self, "white", 0.4 if reduce_motion else 1.0, 1.0).set_delay(0.3)',1)
needle='\tleaving = true\n\tvar scene: Node = load(NEXT).instantiate()';assert s.count(needle)==1
s=s.replace(needle,'''\tleaving = true
\tvar tree := get_tree()
\tvar covered := is_inside_tree() and tree.current_scene == self
\tif covered:
\t\tif white > 0.0:
\t\t\tfor frame in 2: await tree.process_frame
\t\tawait UI.fade_out(tree, 1.0 / 3.0)
\tvar scene: Node = load(NEXT).instantiate()''',1)
s=s.replace('if is_inside_tree() and get_tree().current_scene == self:\n\t\tget_tree().change_scene_to_node(scene)','if covered:\n\t\tscene.set_meta("opening_black", true)\n\t\ttree.change_scene_to_node(scene)',1)
write(rel,s)
rel='scripts/soul_prologue.gd';s=(L/rel).read_text(encoding='utf-8')
s=s.replace('var _auto_wait := 0.0','var _auto_wait := 0.0\nvar _opening_fade := false',1)
needle='\t_start_line()\n\n\nfunc _current()';assert s.count(needle)==1
s=s.replace(needle,'''\t_start_line()
\tif has_meta("opening_black"):
\t\t_opening_fade = true
\t\t_reveal_opening.call_deferred()


func _reveal_opening() -> void:
\tvar tree := get_tree()
\tfor frame in 2: await tree.process_frame
\tif not is_inside_tree(): return
\tawait UI.fade_in(tree, 1.0 / 3.0)
\t_opening_fade = false


func _current()''',1)
needle='\tawait get_tree().create_timer(0.7).timeout\n\tstage = "done"';assert s.count(needle)==1
s=s.replace(needle,'''\tvar tree := get_tree()
\tvar covered := is_inside_tree() and tree.current_scene == self
\tif covered:
\t\tfor frame in 2: await tree.process_frame
\t\tawait UI.fade_out(tree, 1.0 / 3.0)
\telse:
\t\tawait tree.create_timer(0.7).timeout   # preserve the non-scene check handoff
\tstage = "done"''',1)
s=s.replace('if is_inside_tree() and get_tree().current_scene == self:\n\t\tget_tree().change_scene_to_node(next)','''if covered:
\t\t# The flood scene already builds under its own opaque veil, then lifts it after the first draw.
\t\t# Give that veil the black without stacking a second reveal over it.
\t\tUI.fade_in(tree, 0.0)
\t\ttree.change_scene_to_node(next)''',1)
s=s.replace('if auto or stage in ["fly", "done"]: return','if auto or _opening_fade or stage in ["fly", "done"]: return',1)
write(rel,s)
print('Prepared two owned opening scripts; protected',len(base),'existing files.')
