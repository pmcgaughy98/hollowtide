from pathlib import Path
from PIL import Image, ImageDraw
import hashlib,json,numpy as np
D=Path(__file__).resolve().parent
O=D/'prepared';R=D/'review'/'closeups';O.mkdir(exist_ok=True);R.mkdir(parents=True,exist_ok=True)
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def image_array(p):return np.array(Image.open(p).convert('RGBA'))
def matte(a):
 im=Image.fromarray(a,'RGBA');bg=Image.new('RGBA',im.size,(63,71,72,255));bg.alpha_composite(im);return bg.convert('RGB')
spec=json.loads((D/'request/coalcrest-outline-closeups-spec.json').read_text())
atlas=Image.open(D/'request/coalcrest-outline-closeups-256.png').convert('RGBA');gen=Image.open(D/'generated/coalcrest-closeups-rd.png').convert('RGBA')
assert atlas.size==(256,256) and gen.size==(128,128),'Unexpected atlas dimensions; refuse unverified registration'
g=np.array(gen);background=np.all(g[:,:,:3]==g[0,0,:3],axis=2)
# These gray background colors have no warm creature-material contrast.
gi=g[:,:,:3].astype(int);background|=(gi.max(axis=2)-gi.min(axis=2)<=12)&(gi.min(axis=2)>=95)&(gi[:,:,1]>=gi[:,:,0])&(gi[:,:,2]>=gi[:,:,0])
foot_boxes={'coalcrest_front':[(59,134,77,142),(99,132,119,140)],'coalcrest_back':[(99,132,125,140),(84,131,90,134)]}
source_files={'coalcrest_front':D/'inputs/coalcrest_front.png','coalcrest_back':D/'inputs/coalcrest_back_active_v3.png'}
expected={'coalcrest_front':'6cbd82720f1c9673e51fea21cc6261fc2798bc80e4c0d3e0a433a224202f669f','coalcrest_back':'e2cde80eb484a38d0322c225a83d8584a37fb96c1ebfc6c1db83d373966020a1'}
report={'status':'W-only native candidate reviewed at1x/2x/4x; not installed or engine-verified','generated_dimensions':list(gen.size),'approved_atlas_dimensions':list(atlas.size),'atlas_uniform_scale':0.5,'effective_panel_native_magnification':1,'generated_sha256':digest(D/'generated/coalcrest-closeups-rd.png'),'approved_atlas_sha256':digest(D/'request/coalcrest-outline-closeups-256.png'),'method':'Exact native sampling at half approved atlas origins; no RGB resizing/averaging/painting. Only original acceptance-mask RGB copied when generated alpha is nonzero and sample is not gray backdrop. Original active-source alpha and all outside-mask pixels retained.','rear_head_preservation':'Latest active resource selects original occluded-leg v3. Uploaded rear has unused painted head; baseline restored from frozen active v3, body/tail/feet unchanged. Tail foreground, hind leg hidden, only existing tiny far-foot peek eligible.','assets':{}}
upload=image_array(D/'inputs/coalcrest_back.png');active=image_array(source_files['coalcrest_back']);hd=np.any(upload!=active,axis=2);hy,hx=np.where(hd);report['uploaded_vs_active_rear']={'uploaded_sha256':digest(D/'inputs/coalcrest_back.png'),'active_sha256':digest(source_files['coalcrest_back']),'changed_rgba_pixels':int(hd.sum()),'head_difference_bbox':[int(hx.min()),int(hy.min()),int(hx.max()+1),int(hy.max()+1)],'body_tail_foot_changes_y70plus':int(hd[70:].sum())};assert not hd[70:].any()
for name,srcpath in source_files.items():
 assert digest(srcpath)==expected[name],f'Changed frozen source {name}'
 src=image_array(srcpath);out=src.copy();maskpath=D/'request'/f'{name}-acceptance-mask.png';mask=np.array(Image.open(maskpath).convert('L'))>0;assert mask.shape==(160,160)
 assert not np.any(mask&(src[:,:,3]==0)),'Mask includes source-transparent pixels'
 feet=np.zeros((160,160),bool)
 for x0,y0,x1,y1 in foot_boxes[name]:feet[y0:y1,x0:x1]=True
 selected=np.zeros((160,160),bool);rows=[]
 for panel in spec['panels']:
  if panel['source']!=name:continue
  x0,y0,x1,y1=panel['source_crop'];ax,ay=panel['atlas_origin'];assert ax%2==0 and ay%2==0 and panel['magnification']==2;ax//=2;ay//=2;nw,nh=panel['native_size'];assert (x1-x0,y1-y0)==(nw,nh)
  region=mask[y0:y1,x0:x1]&((feet if panel['kind']=='feet' else ~feet)[y0:y1,x0:x1]);sample=g[ay:ay+nh,ax:ax+nw];bg=background[ay:ay+nh,ax:ax+nw];eligible=region&(sample[:,:,3]>0)&~bg
  dst=out[y0:y1,x0:x1];dst[eligible,:3]=sample[eligible,:3];selected[y0:y1,x0:x1]|=eligible
  rows.append({'name':panel['name'],'source_crop':panel['source_crop'],'actual_output_origin':[ax,ay],'native_cell_factor':1,'approved_mask_pixels_in_panel':int(region.sum()),'gray_or_transparent_samples_rejected':int((region&~eligible).sum()),'eligible_rgb_samples':int(eligible.sum())})
 diff=np.any(out!=src,axis=2);assert not np.any(diff&~mask);assert np.array_equal(out[:,:,3],src[:,:,3]);assert np.array_equal(out[src[:,:,3]==0],src[src[:,:,3]==0]);assert not diff[:70].any()
 candidate=O/f'{name}_closeup_native.png';Image.fromarray(out,'RGBA').save(candidate);Image.fromarray((selected*255).astype('uint8'),'L').save(R/f'{name}-accepted-generated-samples.png')
 Image.fromarray((diff*255).astype('uint8'),'L').save(R/f'{name}-actual-rgb-diff-mask.png')
 for z in [1,2,4]:
  pair=Image.new('RGB',(320*z+24,160*z+32),(63,71,72));dr=ImageDraw.Draw(pair);pair.paste(matte(src).resize((160*z,160*z),Image.Resampling.NEAREST),(0,32));pair.paste(matte(out).resize((160*z,160*z),Image.Resampling.NEAREST),(160*z+24,32));dr.text((8,8),'ACTIVE SOURCE',fill='white');dr.text((160*z+32,8),'MASKED NATIVE CANDIDATE',fill='white');pair.save(R/f'{name}-native-candidate-comparison-{z}x.png')
 source_colors={tuple(c) for c in src[src[:,:,3]>0,:3]};candidate_colors={tuple(c) for c in out[out[:,:,3]>0,:3]}
 report['assets'][name]={'source':str(srcpath),'source_sha256':digest(srcpath),'mask':str(maskpath),'mask_sha256':digest(maskpath),'candidate':str(candidate),'candidate_sha256':digest(candidate),'approved_mask_pixels':int(mask.sum()),'eligible_generated_samples':int(selected.sum()),'changed_rgb_pixels':int(diff.sum()),'outside_mask_rgba_changes':int((diff&~mask).sum()),'source_alpha_unchanged':bool(np.array_equal(out[:,:,3],src[:,:,3])),'transparent_rgba_unchanged':bool(np.array_equal(out[src[:,:,3]==0],src[src[:,:,3]==0])),'head_and_upper_body_unchanged':bool(not diff[:70].any()),'additional_visible_rgb_colors':[[int(v) for v in c] for c in sorted(candidate_colors-source_colors)],'panels':rows}
report['visual_assessment']={'recommendation':'Useful modest material refinement for root native battle review; strongest improvement in front toe divisions and near-foot rim. Rear foot changes subtle. Tail rim slightly more even and dark.','limitations':'Exact sourcealpha retains original tiny toe shapes and original tail geometry; rear foot is still small as intended. No complete silhouette redraw or broad material change.','protected_anatomy':'Foreground tail covers hind leg; only original tiny far-foot peek remains. Activev3 head preserved, unused painted head not promoted.','observed_rejections':'Original gray background samples retained as sourcepixels instead of copied; no gray contaminates masked sprite.'}
(R/'native-acceptance-diagnostic.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
