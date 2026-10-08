"""Repair Fusern's pale mortar and burnt-brick material without altering geometry.

Run the unchanged palette normalizer first, then this script with --project,
--source, --candidate and --baseline. An immutable baseline is reused on repeat
runs. Only E/NE/N/NW stills and E/NE/N source walk sheets receive color-role repair.
The existing named builder subsequently creates small sprites and mirrored walks.

The largest 8-connected component of the source's pale warm RGB classes isolates
the dome from eyes, legs and core. A conservative 3x3 binary opening separates
broad bright tile highlights from the thin existing pale mortar network. Those
roles map to literal approved-base dark mortar and burnt-rust colors. All outside
RGBA, alpha, canvas, silhouette support and feet remain exact to the baseline.

NW's broad tile island lacks some internal joints. A separate review proposal
copies actual accepted W mortar courses, their transition tones and tile shading
at identical canvas positions inside that island. This explicit interior RGB
texture restoration has no scaling, random noise, dither or new silhouette. --restore-nw-donor installs this explicitly reviewed RGB texture
proposal. Good S/SE/W/SW facings and all other forms remain byte exact. No paid
service is called, and no live project files are written.
"""
from pathlib import Path
from collections import deque
import argparse, hashlib, json
import numpy as np
from PIL import Image

PROTO=np.array([[252,161,82],[231,113,39],[218,116,60]],dtype=int)
COLORS={'mortar':(64,44,41),'brick':(164,74,50),'brick_highlight':(180,91,56),'broad_highlight':(191,96,53)}
FACINGS=['e','ne','n','nw']; WALKS=['e','ne','n']
DOC=Path('docs/creatures/arena-starters-2026-10-07'); ART=Path('assets/sprites/arena/fusern')

def lum(a): return np.asarray(a,float)@np.array([.299,.587,.114])
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p): return np.array(Image.open(p).convert('RGBA'))
def bbox(mask):
 ys,xs=np.nonzero(mask)
 return [int(xs.min()),int(ys.min()),int(xs.max()+1),int(ys.max()+1)] if len(xs) else None

def largest_component(mask,on):
 seen=np.zeros_like(mask); components=[]; h,w=mask.shape
 for y,x in zip(*np.nonzero(mask)):
  if seen[y,x]: continue
  seen[y,x]=1; q=deque([(y,x)]); coords=[]
  while q:
   yy,xx=q.popleft(); coords.append((yy,xx))
   for dy,dx in [(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)]:
    ny,nx=yy+dy,xx+dx
    if 0<=ny<h and 0<=nx<w and mask[ny,nx] and not seen[ny,nx]: seen[ny,nx]=1; q.append((ny,nx))
  components.append(coords)
 if not components: return np.zeros_like(mask)
 coords=max(components,key=len); out=np.zeros_like(mask); ys,xs=np.array(coords).T; out[ys,xs]=1
 ob=bbox(on); cy=float(ys.mean())
 assert len(coords)>150 and cy<ob[1]+(ob[3]-ob[1])*.65,(len(coords),cy,ob)
 return out

def shifted(mask,dy,dx):
 h,w=mask.shape; p=np.pad(mask,3)
 return p[3+dy:3+dy+h,3+dx:3+dx+w]

def repair(original,baseline,palette):
 assert original.shape==baseline.shape and np.array_equal(original[...,3],baseline[...,3])
 rgb=original[...,:3].astype(int)
 distances=np.abs(rgb[:,:,None,:]-PROTO[None,None,:,:]).max(axis=3)
 role=distances.argmin(axis=2); matches=distances.min(axis=2)<=2
 on=original[...,3]>0; shell=largest_component(matches&on,on); bright=shell&(role==0)
 eroded=np.ones_like(bright)
 for dy in [-1,0,1]:
  for dx in [-1,0,1]: eroded &= shifted(bright,dy,dx)
 broad=np.zeros_like(bright)
 for dy in [-1,0,1]:
  for dx in [-1,0,1]: broad |= shifted(eroded,dy,dx)
 broad &= bright; mortar=bright&~broad; brick=shell&(role==1); highlight=shell&(role==2)
 out=baseline.copy()
 for mask,name in [(mortar,'mortar'),(broad,'broad_highlight'),(brick,'brick'),(highlight,'brick_highlight')]: out[mask,:3]=COLORS[name]
 changed=np.any(out!=baseline,axis=2)
 assert not np.any(changed&~shell)
 assert np.array_equal(out[...,3],original[...,3]) and set(map(tuple,out[on,:3])).issubset(palette)
 info={'source_dome_bbox':bbox(shell),'source_dome_pixels':int(shell.sum()),'mortar_pixels':int(mortar.sum()),'broad_highlight_pixels':int(broad.sum()),'brick_pixels':int(brick.sum()),'brick_highlight_pixels':int(highlight.sum()),'changed_rgb_pixels':int(changed.sum()),'same_outside_rgba':bool(np.array_equal(out[~shell],baseline[~shell])),'same_alpha':True,'same_support':True,'same_canvas':True,'same_foot_row':bool(np.nonzero(on)[0].max()==np.nonzero(out[...,3]>0)[0].max()),'exact_base_palette':True,'source_shell_mean':float(lum(rgb[shell]).mean()),'baseline_shell_mean':float(lum(baseline[shell,:3]).mean()),'fixed_shell_mean':float(lum(out[shell,:3]).mean()),'existing_seam_placement_only':True,'missing_topology_preserved':True}
 return out,info,{'shell':shell,'mortar':mortar,'broad_highlight':broad,'brick':brick,'brick_highlight':highlight}

def nw_donor_proposal(original,current,masks,donor,palette):
 assert original.shape==current.shape==donor.shape
 allowed=masks['broad_highlight']; roof=np.zeros_like(allowed); roof[36:65,40:93]=True
 assert not np.any(allowed&~roof), 'NW reviewed broad island extends outside donor roof'
 assert np.all(donor[allowed,3]>0)
 out=current.copy(); out[allowed,:3]=donor[allowed,:3]
 changed=np.any(out!=current,axis=2)
 assert not np.any(changed&~allowed)
 assert np.array_equal(out[~allowed],current[~allowed]) and np.array_equal(out[...,3],original[...,3])
 assert set(map(tuple,out[out[...,3]>0,:3])).issubset(palette)
 colors,counts=np.unique(out[allowed,:3],axis=0,return_counts=True)
 info={'source_original_path':str(ART/'w.png'),'donor_original_sha':None,'accepted_palette_donor_path':str(ART/'w.png'),'accepted_palette_donor_sha':None,'mapping':'actual accepted W mortar courses, transition tones and tile shading at identical canvas coordinates; no scaling or translation','explicit_interior_rgb_texture_restoration':True,'allowed_broad_mask_bbox':bbox(allowed),'allowed_broad_mask_pixels':int(allowed.sum()),'donor_roof_bbox_inclusive':[40,36,92,64],'changed_interior_rgb_bbox':bbox(changed),'changed_interior_rgb_pixels':int(changed.sum()),'donor_rgb_populations':{str(tuple(map(int,c))):int(n) for c,n in zip(colors,counts)},'same_outside_broad_rgba':True,'same_alpha_support_canvas':True,'installed_into_canonical':False}
 return out,changed,info

def main():
 ap=argparse.ArgumentParser()
 for name in ['project','source','candidate','baseline']: ap.add_argument('--'+name,type=Path,required=True)
 ap.add_argument('--restore-nw-donor',action='store_true'); args=ap.parse_args()
 source=args.source; out=args.candidate; old=args.baseline; old.mkdir(parents=True,exist_ok=True)
 base=read(source/DOC/'forms/fusern.png'); palette=set(map(tuple,base[base[...,3]>0,:3]))
 assert set(COLORS.values()).issubset(palette)
 audit={'algorithm':'largest 8-connected pale roof; conservative 3x3 opening role discrimination; literal base burnt-rust and mortar; explicit actual accepted W mortar, transition and tile-shade texture inside NW broad island','source_palette':str(DOC/'forms/fusern.png'),'role_colors':COLORS,'facings':{},'walk':{},'unchanged_dark_facings':{},'mask_paths':[],'restore_nw_donor':args.restore_nw_donor}
 for f in ['s','se','w','sw']: audit['unchanged_dark_facings'][f]={'candidate_before':sha(out/ART/f'{f}.png')}
 def baseline(rel):
  p=old/rel; p.parent.mkdir(parents=True,exist_ok=True)
  if not p.exists(): p.write_bytes((out/rel).read_bytes())
  return read(p)
 mask_root=out/'fusern-brick-masks'; mask_root.mkdir(exist_ok=True)
 for f in FACINGS:
  rel=ART/f'{f}.png'; original=read(source/rel); before=baseline(rel); fixed,info,masks=repair(original,before,palette)
  if f=='nw':
   proposal,seams,donor_info=nw_donor_proposal(original,fixed,masks,read(out/ART/'w.png'),palette)
   proposal_path=out/'fusern_nw_donor_proposal.png'; Image.fromarray(proposal).save(proposal_path)
   mask_path=mask_root/'nw_donor_seam_proposal.png'; Image.fromarray(seams.astype(np.uint8)*255).save(mask_path)
   donor_info.update({'donor_original_sha':sha(source/ART/'w.png'),'accepted_palette_donor_sha':sha(out/ART/'w.png'),'proposal_path':str(proposal_path.relative_to(out)),'proposal_sha':sha(proposal_path),'mask_path':str(mask_path.relative_to(out))})
   if args.restore_nw_donor:
    fixed=proposal; donor_info['installed_into_canonical']=True; info['missing_topology_preserved']=False; info['existing_seam_placement_only']=False
    info['fixed_shell_mean']=float(lum(fixed[masks['shell'],:3]).mean())
    info['changed_rgb_pixels']=int(np.any(fixed!=before,axis=2).sum())
   info['nw_donor']=donor_info
  Image.fromarray(fixed).save(out/rel)
  info.update({'source_path':str(rel),'original_sha':sha(source/rel),'baseline_sha':sha(old/rel),'fixed_sha':sha(out/rel)})
  audit['facings'][f]=info
  for name,mask in masks.items():
   p=mask_root/f'{f}_{name}.png'; Image.fromarray(mask.astype(np.uint8)*255).save(p); audit['mask_paths'].append(str(p.relative_to(out)))
 for f in WALKS:
  rel=DOC/'walk'/f'fusern_{f}_sheet.png'; original=read(source/rel); before=baseline(rel); fixed=before.copy(); cell=original.shape[0]//2; records=[]
  assert original.shape[1]==cell*4
  for i in range(8):
   y=(i//4)*cell; x=(i%4)*cell; a=original[y:y+cell,x:x+cell]; b=before[y:y+cell,x:x+cell]; fr,info,masks=repair(a,b,palette); fixed[y:y+cell,x:x+cell]=fr; info['frame']=i; records.append(info)
   for name,mask in masks.items():
    p=mask_root/f'walk_{f}_f{i}_{name}.png'; Image.fromarray(mask.astype(np.uint8)*255).save(p); audit['mask_paths'].append(str(p.relative_to(out)))
  Image.fromarray(fixed).save(out/rel); audit['walk'][f]={'path':str(rel),'original_sha':sha(source/rel),'baseline_sha':sha(old/rel),'fixed_sha':sha(out/rel),'frames':records}
 for f,info in audit['unchanged_dark_facings'].items():
  info['candidate_after']=sha(out/ART/f'{f}.png'); info['byte_exact']=info['candidate_before']==info['candidate_after']; assert info['byte_exact']
 (out/'fusern-brick-audit.json').write_text(json.dumps(audit,indent=2)+'\n')
 print(json.dumps({f:{k:v for k,v in info.items() if k in ['source_dome_pixels','mortar_pixels','broad_highlight_pixels','fixed_shell_mean','baseline_shell_mean','same_outside_rgba','nw_donor']} for f,info in audit['facings'].items()},indent=2),flush=True)
 print('4 stills and 24 source walk frames repaired; outside RGB and all geometry exact.',flush=True)

if __name__=='__main__': main()
