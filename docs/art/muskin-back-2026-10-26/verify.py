from pathlib import Path
from PIL import Image
import hashlib,json
import numpy as np
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
owned=json.loads((W/'installed-files.json').read_text());before=json.loads((W/'muskin-before.json').read_text());protected=json.loads((W/'protected-before.json').read_text())
for rel,h in owned.items():assert sha(L/rel)==h,rel
for rel,h in before.items():
 if rel not in owned:assert sha(L/rel)==h,rel+' unexpectedly changed'
palette=np.unique(np.array(Image.open(L/'assets/sprites/arena/muskin/s.png').convert('RGBA')).reshape(-1,4),axis=0);palette=palette[palette[:,3]>0,:3]
manifest=[]
for rel,h in owned.items():
 old=np.array(Image.open(W/'originals'/rel).convert('RGBA'));new=np.array(Image.open(L/rel).convert('RGBA'));assert old.shape==new.shape and np.array_equal(old[:,:,3],new[:,:,3])
 colours=np.unique(new[new[:,:,3]>0][:,:3],axis=0);assert len(colours)<=30 and all(any(np.array_equal(c,p) for p in palette) for c in colours)
 manifest.append({'path':rel,'old_sha256':sha(W/'originals'/rel),'sha256':h,'dimensions':list(Image.open(L/rel).size),'colours':len(colours),'alpha_exact':True,'front_palette_subset':True})
concurrent=[]
for rel,h in protected.items():
 if not (L/rel).exists() or sha(L/rel)!=h:
  concurrent.append(rel)
  if (L/rel).is_file():
   p=W/'concurrent-at-finish'/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes((L/rel).read_bytes())
for rel in ('scripts/dungeon/dungeon.gd','scripts/arena/arena_prototype.gd','scripts/town/scene_kit.gd','scripts/town/team_state.gd','tools/arena/build_dungeon_set.py','tools/arena/downscale.py','project.godot','export_presets.cfg'):assert sha(L/rel)==protected[rel],rel
n=json.loads((W/'native-result.json').read_text());assert n['failed']==0
result={'installed_pngs':3,'other_muskin_files_preserved':len(before)-3,'all_source_walks_preserved':True,'native_checks':n['total'],'native_failures':n['failed'],'source_code_settings_changed_by_this_slice':0,'concurrent_paths_preserved':concurrent,'metrics':manifest}
(W/'manifest.json').write_text(json.dumps(manifest,indent=2));(W/'verification.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
