from pathlib import Path
import json,hashlib,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
owned=json.loads((W/'installed-files.json').read_text());manifest=json.loads((W/'manifest.json').read_text())
for rel,h in owned.items():assert sha(L/rel)==h,rel
(W/'shared-layout-manifest.json').write_text(json.dumps(manifest,indent=2))
for item in manifest:
 old=item['destination'];new='assets/sprites/arena/'+item['form']+'/front_chosen.png';assert not (L/new).exists()
 dest=L/new;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/old,dest);assert sha(dest)==item['sha256'];(L/old).unlink()
 old_prepared=W/'prepared'/old
 if old_prepared.exists():old_prepared.unlink()
 p=W/'prepared'/new;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(dest,p)
 owned.pop(old);owned[new]=sha(dest);item['destination']=new
try:(L/'assets/sprites/arena/fronts_2026_10_07').rmdir()
except OSError:pass
rel='scripts/town/board_scene.gd';s=(L/rel).read_text().replace('res://assets/sprites/arena/fronts_2026_10_07/%s_arena_front_chosen.png','res://assets/sprites/arena/%s/front_chosen.png')
(L/rel).write_text(s,encoding='utf-8');(W/'prepared'/rel).write_text(s,encoding='utf-8');owned[rel]=sha(L/rel)
(W/'installed-files.json').write_text(json.dumps(owned,indent=2));(W/'manifest.json').write_text(json.dumps(manifest,indent=2));print('Placed16 exact images inside existing per-form maintenance roots.')
