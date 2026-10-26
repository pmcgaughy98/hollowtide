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
    dest=W/'originals'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,dest)
rel='scripts/soul_prologue.gd';s=(L/rel).read_text(encoding='utf-8');assert s.count('\t_flash = 1.6')==1
s=s.replace('func _ready() -> void:\n','func _ready() -> void:\n\t# Honor the title handoff and the saved preference when opening this scene directly.\n\treduce_motion = reduce_motion or UI.reduce_motion()\n',1)
s=s.replace('\t_flash = 1.6','\t_flash = 0.4 if reduce_motion else 1.6',1)
raw=(L/rel).read_bytes();nl=b'\r\n' if b'\r\n' in raw else b'\n';dest=W/'prepared'/rel;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(s.encode().replace(b'\n',nl))
print('Prepared ACC-14, preserving',len(base),'current files.')
