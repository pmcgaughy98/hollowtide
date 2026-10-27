from pathlib import Path
from PIL import Image,ImageDraw
import hashlib,json,shutil,subprocess,sys
import numpy as np
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');A=Path('assets/sprites/arena/muskin')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
front=np.array(Image.open(W/'originals'/A/'s.png').convert('RGBA'));back=np.array(Image.open(W/'originals'/A/'n.png').convert('RGBA'))
palette=np.unique(front[front[:,:,3]>0][:,:3],axis=0).astype(np.int32)
assert len(palette)<=30
mask=back[:,:,3]>0;rgb=back[mask,:3].astype(np.int32)
d=(rgb[:,None,:]-palette[None,:,:])**2
back[mask,:3]=palette[(d[:,:,0]*2+d[:,:,1]*4+d[:,:,2]*3).argmin(axis=1)]
fixed=W/'prepared'/A/'n.png';fixed.parent.mkdir(parents=True,exist_ok=True);Image.fromarray(back).save(fixed)
commands=[]
for phase in ('baseline','updated'):
 root=W/('rebuild-'+phase)
 shutil.copytree(W/'originals'/A,root/A,dirs_exist_ok=True)
 walk=Path('docs/creatures/arena-starters-2026-10-07/walk');(root/walk).mkdir(parents=True,exist_ok=True)
 for p in (W/'originals'/walk).glob('muskin*'):shutil.copy2(p,root/walk/p.name)
 for rel in ('tools/arena/build_dungeon_set.py','tools/arena/downscale.py','scripts/arena/arena_prototype.gd'):
  dest=root/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,dest)
  archived=W/'build-dependencies'/rel;archived.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,archived)
 if phase=='updated':shutil.copy2(fixed,root/A/'n.png')
 for opts in ([],['--set=town','--scale=1.5']):
  cmd=[sys.executable,str(root/'tools/arena/build_dungeon_set.py'),'muskin']+opts
  p=subprocess.run(cmd,cwd=root,capture_output=True,text=True);commands.append({'phase':phase,'command':cmd,'stdout':p.stdout,'stderr':p.stderr,'exit':p.returncode});assert p.returncode==0,p.stderr
# Rebuilds differ only where the north source was changed. Preserve other installed finishes.
delta=[];baseline_differences=[]
for kind in ('town','dungeon'):
 for p in (W/'rebuild-updated'/A/kind).glob('*.png'):
  rel=p.relative_to(W/'rebuild-updated');old=W/'rebuild-baseline'/rel
  if sha(old)!=sha(W/'originals'/rel):baseline_differences.append(rel.as_posix())
  if sha(p)!=sha(old):delta.append(rel.as_posix())
assert set(delta)=={(A/'town/n.png').as_posix(),(A/'dungeon/n.png').as_posix()},delta
for rel in delta:
 a=np.array(Image.open(W/'rebuild-updated'/rel).convert('RGBA')).astype(np.int32)
 # Preserve the installed black sel-out finish after resampling, without peeling.
 m=a[:,:,3]>0;pad=np.pad(m,1);edge=m&~(pad[:-2,1:-1]&pad[2:,1:-1]&pad[1:-1,:-2]&pad[1:-1,2:])
 luma=a[:,:,0]*.3+a[:,:,1]*.59+a[:,:,2]*.11
 dark=palette[(palette[:,0]*.3+palette[:,1]*.59+palette[:,2]*.11).argmin()]
 a[edge&(luma>=(float(dark[0]*.3+dark[1]*.59+dark[2]*.11)+12)),:3]=dark
 dest=W/'prepared'/rel;dest.parent.mkdir(parents=True,exist_ok=True);Image.fromarray(a.astype(np.uint8)).save(dest)
owned={p.relative_to(W/'prepared').as_posix():sha(p) for p in (W/'prepared').rglob('*.png')};assert len(owned)==3
metrics=[]
for rel in owned:
 old=np.array(Image.open(W/'originals'/rel).convert('RGBA'));new=np.array(Image.open(W/'prepared'/rel).convert('RGBA'))
 assert old.shape==new.shape and np.array_equal(old[:,:,3],new[:,:,3]),rel
 colours=np.unique(new[new[:,:,3]>0][:,:3],axis=0)
 assert len(colours)<=30 and all(any(np.array_equal(c,p) for p in palette) for c in colours)
 metrics.append({'path':rel,'before_colours':len(np.unique(old[old[:,:,3]>0][:,:3],axis=0)),'after_colours':len(colours),'size':list(Image.open(W/'prepared'/rel).size),'alpha_exact':True,'changed_rgb_pixels':int(np.any(old[:,:,:3]!=new[:,:,:3],axis=2).sum())})
(W/'installed-files.json').write_text(json.dumps(owned,indent=2));(W/'build-commands.json').write_text(json.dumps(commands,indent=2));(W/'build-result.json').write_text(json.dumps({'metrics':metrics,'rebuilt_delta':delta,'baseline_rebuild_differs_from_installed':baseline_differences,'front_palette_rgb':palette.tolist()},indent=2))
grid=Image.new('RGB',(768,800),(29,32,37));dr=ImageDraw.Draw(grid)
for k,(rel,h) in enumerate(owned.items()):
 for side,folder in enumerate(('originals','prepared')):
  im=Image.open(W/folder/rel).convert('RGBA');im=im.resize((im.width*3,im.height*3),Image.Resampling.NEAREST);x=side*384+(384-im.width)//2;y=(35,450,600)[k]
  grid.paste(im,(x,y),im);dr.text((side*384+10,y-18),rel.split('/muskin/')[-1]+' '+('before' if side==0 else 'after'),fill='white')
grid.save(W/'before-after.png')
print(json.dumps(metrics,indent=2));print('Baseline rebuild differs from installed:',len(baseline_differences),'PNG files; all unselected installed bytes retained.')
