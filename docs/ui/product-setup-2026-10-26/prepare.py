from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert not (W/'protected-before.json').exists()
base={p.relative_to(L).as_posix():sha(p) for f in ('scripts','scenes','data','dialogue','tools') for p in (L/f).rglob('*') if p.is_file() and '__pycache__' not in p.parts}
for rel in ('project.godot','.gitignore','icon.svg'):base[rel]=sha(L/rel)
(W/'protected-before.json').write_text(json.dumps(base,indent=2))
for rel in ('project.godot','.gitignore','icon.svg','scripts/ui/hollowtide_wordmark.gd','docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-26.md'):
 dest=W/'originals'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,dest)
s=(L/'project.godot').read_text();s=s.replace('config/icon="res://icon.svg"','config/icon="res://icon.png"\nboot_splash/show_image=false\nboot_splash/bg_color=Color(0, 0, 0, 1)',1)
p=W/'prepared/project.godot';p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s,encoding='utf-8')
(W/'prepared/.gitignore').write_text((L/'.gitignore').read_text().rstrip()+'\n\n# Local Windows export output.\n/builds/\n',encoding='utf-8')
shutil.copy2(W/'build_app_icon.gd',W/'prepared/build_app_icon.gd')
print('Prepared guarded config changes; snapshotted',len(base),'protected files.')
