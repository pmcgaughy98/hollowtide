from pathlib import Path
from PIL import Image
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');SRC='docs/creatures/arena-starters-2026-10-07/forms';DST='assets/sprites/arena'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert not (W/'protected-before.json').exists()
base={p.relative_to(L).as_posix():sha(p) for d in ('scripts','scenes','data','dialogue','tools') for p in (L/d).rglob('*') if p.is_file() and '__pycache__' not in p.parts}
for rel in ('project.godot','export_presets.cfg','.gitignore'):base[rel]=sha(L/rel)
(W/'protected-before.json').write_text(json.dumps(base,indent=2))
for rel in ('scripts/town/board_scene.gd','scripts/ui/ui_style.gd','export_presets.cfg','docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-26.md'):
 dest=W/'originals'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,dest)
original_assets={p.relative_to(L).as_posix():sha(p) for p in (L/SRC).iterdir() if p.is_file()};(W/'original-forms-hashes.json').write_text(json.dumps(original_assets,indent=2))
manifest=[]
for p in sorted((L/SRC).glob('*_arena_front_chosen.png')):
 form=p.name.removesuffix('_arena_front_chosen.png')
 dest=W/'prepared'/DST/form/'front_chosen.png';dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest)
 im=Image.open(p).convert('RGBA');assert im.getbbox() is not None
 manifest.append({'form':form,'source':p.relative_to(L).as_posix(),'destination':f'{DST}/{form}/front_chosen.png','sha256':sha(p),'size':list(im.size),'rgba_sha256':hashlib.sha256(im.tobytes()).hexdigest(),'bytes':p.stat().st_size})
assert len(manifest)==16
(W/'manifest.json').write_text(json.dumps(manifest,indent=2))
rel='scripts/town/board_scene.gd';s=(L/rel).read_text()
old=f'res://{SRC}/%s_arena_front_chosen.png';new=f'res://{DST}/%s/front_chosen.png';assert s.count(old)==1
s=s.replace(old,new)
s=s.replace("# The docs/ path stays until Codex's C22 moves the art into assets/ (Claude, 2026-10-24, pass 4 T11). Read",'# Runtime fronts live in assets; original research takes stay in docs. Read')
dest=W/'prepared'/rel;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_text(s,encoding='utf-8')
# With the only runtime docs reference repointed, package exclusions can leave the whole docs tree out.
rel='export_presets.cfg';s=(L/rel).read_text();old='docs/*.gd,docs/*.tscn,docs/*.tres,docs/*.gdshader';assert old in s;s=s.replace(old,'docs/*')
dest=W/'prepared'/rel;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_text(s,encoding='utf-8')
print('Prepared16 byte-identical runtime fronts, one fallback path/comment and docs exclusion.')
