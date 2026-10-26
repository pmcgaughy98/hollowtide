from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent
L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert not (W/'protected-before.json').exists()
paths=set()
for folder in ('scripts','scenes','data','dialogue','tools'):
    paths.update(p for p in (L/folder).rglob('*') if p.is_file() and '__pycache__' not in p.parts)
for folder in ('assets/fonts','assets/sprites/ui','assets/sprites/menu'):
    paths.update(p for p in (L/folder).rglob('*') if p.is_file())
paths.update(L/p for p in ('project.godot','docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-22.md'))
baseline={p.relative_to(L).as_posix():sha(p) for p in sorted(paths)}
(W/'protected-before.json').write_text(json.dumps(baseline,indent=2),encoding='utf-8')
for rel in ('scripts/creature_opening.gd','scripts/main_menu.gd','tools/debug/ui_fit_check.gd','docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-22.md'):
    dest=W/'originals'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,dest)
print(f'Preserved {len(baseline)} current files and fresh originals.')
