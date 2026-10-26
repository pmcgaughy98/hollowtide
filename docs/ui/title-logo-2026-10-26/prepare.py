from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert not (W/'protected-before.json').exists()
paths=set()
for folder in ('scripts','scenes','data','dialogue','tools'):
    paths.update(p for p in (L/folder).rglob('*') if p.is_file() and '__pycache__' not in p.parts)
paths.update(L/p for p in ('project.godot','docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-22.md'))
base={p.relative_to(L).as_posix():sha(p) for p in sorted(paths)}
(W/'protected-before.json').write_text(json.dumps(base,indent=2))
for rel in ('scripts/opening_flow.gd','scripts/creature_opening.gd','scripts/main_menu.gd','docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-22.md'):
    dest=W/'originals'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,dest)
rel='scripts/opening_flow.gd';s=(L/rel).read_text(encoding='utf-8')
a=s.index('\t# Start the approved walk-in as the menu is revealed.');b=s.index('\nfunc _input(',a)
s=s[:a]+'''\t# Clear the launch card before the menu wordmark appears: never crossfade two logos.
\tvar reveal: Array[CanvasItem] = [_wordmark, _main_panel]
\tvar hint := _ui.get_node_or_null("InputHint") as CanvasItem
\tif hint != null: reveal.append(hint)
\tfor item in reveal: item.modulate.a = 0.0
\t_quiet_focus = true
\tif not _reduce_motion:
\t\tawait create_tween().tween_property(_boot, "modulate:a", 0.0, 0.5).finished
\t_boot.modulate.a = 0.0
\t_boot.hide()
\t_time = 0.0
\t_wordmark.show()
\t_main_panel.show()
\t_main_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tif not _reduce_motion:
\t\tvar reveal_tween := create_tween().set_parallel()
\t\tfor item in reveal: reveal_tween.tween_property(item, "modulate:a", 1.0, 0.25)
\t\tawait reveal_tween.finished
\tfor item in reveal: item.modulate.a = 1.0
\t_boot_done = true
\t_main_panel.mouse_filter = Control.MOUSE_FILTER_STOP
\t_show_page("main", _buttons[0])
\t# _show_page grabs focus deferred; loading a title should be silent.
\tset_deferred("_quiet_focus", false)

''' +s[b:]
raw=(L/rel).read_bytes();nl=b'\r\n' if b'\r\n' in raw else b'\n'
dest=W/'prepared'/rel;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(s.encode().replace(b'\n',nl))
print('Fresh baseline:',len(base),'files. Prepared one opening_flow method.')
