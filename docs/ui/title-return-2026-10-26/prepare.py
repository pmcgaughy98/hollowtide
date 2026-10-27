from pathlib import Path
import json,hashlib,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert not (W/'protected-before.json').exists()
base={p.relative_to(L).as_posix():sha(p) for f in ('scripts','scenes','data','dialogue','tools') for p in (L/f).rglob('*') if p.is_file() and '__pycache__' not in p.parts}
base['project.godot']=sha(L/'project.godot');(W/'protected-before.json').write_text(json.dumps(base,indent=2))
for rel in ('scripts/opening_flow.gd','scripts/main_menu.gd','scripts/creature_opening.gd','scripts/ui/ui_style.gd','scripts/ui/title_settings.gd','docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-26.md'):
 dest=W/'originals'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,dest)
rel='scripts/opening_flow.gd';s=(L/rel).read_text()
s=s.replace('var _boot: Control','''# A return to title in this process opens the menu directly. A fresh launch still shows the card.
static var _launch_seen := false
var _boot_hint: Label
var _boot: Control''',1)
s=s.replace('\t_build_boot()\n','\t_build_boot()\n\tif _launch_seen: _finish_boot(true)\n',1)
s=s.replace('var hint := _label("Enter / A / click to continue", 18)','var hint := _label(_launch_skip_text(), 18)\n\t_boot_hint = hint\n\thint.name = "LaunchHint"',1)
s=s.replace('func _finish_boot() -> void:', '''func _launch_skip_text() -> String:
\tvar keys := PackedStringArray()
\tfor action in UI.INPUT_ADVANCE:
\t\tvar binding := UI.binding_text(action)
\t\tif binding != "" and not keys.has(binding): keys.append(binding)
\treturn "%s / click  Skip" % " / ".join(keys)


func _finish_boot(instant := false) -> void:''',1)
s=s.replace('if not _reduce_motion:', 'if not _reduce_motion and not instant:')
s=s.replace('\t_boot.hide()','''\t_boot.hide()
\tfor child in _boot.get_children():
\t\tif child is Label:
\t\t\tchild.hide()
\t\t\tchild.modulate.a = 0.0''',1)
s=s.replace('\t_boot_done = true','\t_boot_done = true\n\t_launch_seen = true',1)
s=s.replace('\tif not _boot_done:\n\t\t_boot_clock', '\tif not _boot_done:\n\t\t_boot_hint.text = _launch_skip_text()\n\t\t_boot_clock',1)
p=W/'prepared'/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s,encoding='utf-8')
rel='scripts/creature_opening.gd';s=(L/rel).read_text()
old='\t\t_launch_hint.text={"keyboard":"Enter to continue","controller":"A to continue","mouse":"Click to continue"}[device]'
assert s.count(old)==1;s=s.replace(old,'\t\t_launch_hint.text=_launch_skip_text()',1)
p=W/'prepared'/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s,encoding='utf-8')
print('Prepared opening_flow and one creature hint line; protected',len(base),'current files.')
