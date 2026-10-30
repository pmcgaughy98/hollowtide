from pathlib import Path
import sys,json,subprocess,os,re
import numpy as np
from PIL import Image,ImageDraw
sys.dont_write_bytecode=True
B=Path(__file__).parent;D=B/'title.backdrop.highbank';ROOT=B.parents[3];sys.path.insert(0,str(ROOT/'tools/art'));import slot_registry as reg
reg.load();a=np.array(Image.open(D/'prepared-from-raw.png').convert('RGBA'));before=a.copy();source=(ROOT/'scripts/town/tower_parts.gd').read_text(encoding='utf-8');hexes=re.findall(r'#[0-9a-fA-F]{6}',source.split('const PALETTE := [',1)[1].split(']',1)[0]);towercol=np.array([[int(v[i:i+2],16) for i in (1,3,5)] for v in hexes]);foreground=np.any(np.all(a[:50,312:,:3,None]==towercol.T[None,None,:,:],axis=2),axis=2)
# Calm wordmark sky and the title's actual pre-shade treatment, excluding Tower pixels.
for y in range(50):
 left=[30,48,46] if y<26 else [38,61,58];right=[25,39,38] if y<26 else [30,48,46]
 colours,counts=np.unique(before[y,90:312,:3],axis=0,return_counts=True);sky_colours=colours[np.argsort(-counts)[:2]];sky=np.any(np.all(before[y,:312,:3,None]==sky_colours.T[None,:,:],axis=1),axis=1);sky[80:312]=True;a[y,:312,:3][sky]=left;a[y,312:,:3][~foreground[y]]=right
for y in (50,51):
 rgb=a[y,90:,:3];keep=np.any(np.all(rgb[:,:,None]==towercol.T[None,:,:],axis=1),axis=1);rgb[~keep]=[51,82,78]
# The generated glass centre is (334,32). Re-register the painted lamp by (-1,+1), retaining its artwork.
patch=a[28:37,330:340].copy();ispart=np.any(np.all(patch[:,:,:3,None]==towercol.T[None,None,:,:],axis=2),axis=2)
for yy,xx in zip(*np.nonzero(ispart)):a[28+yy,330+xx,:3]=[30,48,46]
for yy,xx in zip(*np.nonzero(ispart)):a[29+yy,329+xx]=patch[yy,xx]
a[27:30,333,:3]=[163,122,50]
# Sequential cluster cleanup preserves the registered lamp and uses only adjacent existing colours.
protected=np.zeros(a.shape[:2],bool);protected[26:39,329:340]=True;repaired=0
for y in range(216):
 for x in range(384):
  if protected[y,x]:continue
  near=[(ny,nx) for ny,nx in ((y-1,x),(y,x-1),(y+1,x),(y,x+1)) if 0<=ny<216 and 0<=nx<384]
  if any(np.array_equal(a[y,x,:3],a[ny,nx,:3]) for ny,nx in near):continue
  def score(pos):
   ny,nx=pos;v=a[ny,nx,:3];n=sum(0<=ay<216 and 0<=ax<384 and np.array_equal(a[ay,ax,:3],v) for ay,ax in ((ny-1,nx),(ny,nx-1),(ny+1,nx),(ny,nx+1)))
   return(n,-int(((v.astype(int)-a[y,x,:3].astype(int))**2).sum()))
  ny,nx=max(near,key=score);a[y,x,:3]=a[ny,nx,:3];repaired+=1
a[:,:,3]=255;Image.fromarray(a).save(D/'native_input.png')
for tool,args in [('prepare_slot.py',['title.backdrop.highbank',D/'native_input.png',D/'prepared.png']),('validate_slot.py',['title.backdrop.highbank',D/'prepared.png'])]:
 p=subprocess.run([sys.executable,'-B',str(ROOT/'tools/art'/tool),*map(str,args)],env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'),capture_output=True,text=True);(D/(tool+'.log')).write_text(p.stdout+p.stderr,encoding='utf-8');print(tool,p.returncode)
 if p.returncode not in (0,1):raise RuntimeError(p.stdout+p.stderr)
receipt={'authorization':'Preston Yes, use Python pixel cleanup','raw_untouched':True,'size':[384,216],'sequential_colour_joins':repaired,'changed_rgb_pixels':int(np.any(before[:,:,:3]!=a[:,:,:3],axis=2).sum()),'sky':'two calm source-palette bands behind wordmark; right side pre-shaded using title canopy treatment; Tower colours retained','lamp_registration':{'from':[334,32],'to':[333,33],'delta':[-1,1]},'door_anchor':[333,160],'alpha_opaque':True,'all_changes_native_only':True};(D/'cleanup.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8')
# Preview only: apply current shader's source formulas, without modifying the asset or claiming a game capture.
pixels=a[:,:,:3].astype(float);canopy=np.array([.07,.10,.10])*255;pixels[:50,:312]=pixels[:50,:312]*.62+canopy*.38
seam=np.abs(pixels[:50,311]-pixels[:50,312]);max_seam=float(seam.max())
x=(np.arange(384)+.5)/384;y=(np.arange(216)+.5)/216
smooth=lambda lo,hi,v:np.clip((v-lo)/(hi-lo),0,1)**2*(3-2*np.clip((v-lo)/(hi-lo),0,1))
alpha=(1-smooth(.15,.58,x))[None,:]*smooth(.28,.62,y)[:,None]*.88;wash=np.array([.055,.092,.068])*255;pixels=pixels*(1-alpha[:,:,None])+wash*alpha[:,:,None];pixels=np.clip(np.rint(pixels),0,255).astype(np.uint8)
Image.fromarray(a).resize((1152,648),Image.Resampling.NEAREST).save(B/'native-preview-3x.png');Image.fromarray(pixels).resize((1152,648),Image.Resampling.NEAREST).save(B/'shading-preview-3x.png')
board=Image.fromarray(a).convert('RGB').resize((1152,648),Image.Resampling.NEAREST);draw=ImageDraw.Draw(board);draw.rectangle((90*3,0,295*3,52*3),outline=(180,220,255),width=2);draw.text((274,10),'WORDMARK SPACE (guide only)',fill='white');draw.rectangle((21*3,108*3,128*3,199*3),outline=(180,220,255),width=2);draw.text((65,330),'MENU SPACE',fill='white')
for name,(xx,yy) in {'lamp':(333,33),'door':(333,160),'shade end':(312,50)}.items():
 draw.ellipse((xx*3-5,yy*3-5,xx*3+5,yy*3+5),outline=(255,180,100),width=2);draw.text((xx*3-70,yy*3-18),name,fill='white')
board.save(B/'layout-guides-3x.png')
luma=lambda v:float(np.dot(v,[.299,.587,.114]));lamp=luma(a[33,333,:3]);door=luma(a[160,333,:3]);wall=float(np.dot(a[157:164,339:345,:3].mean(axis=(0,1)),[.299,.587,.114]));semantic={'lamp_anchor':[333,33],'lamp_anchor_luma':lamp,'door_anchor':[333,160],'door_anchor_luma':door,'adjacent_wall_luma':wall,'shade_end':[312,50],'shade_seam_max_channel_delta_after_canopy':max_seam,'wordmark_sky_unique_colours':len(np.unique(a[:52,90:296,:3].reshape(-1,3),axis=0)),'house_order_visual':['home','shop','storage','scrolls'],'in_game_verified':False,'preview':'Current canopy and legibility-wash formulas, static calculation only'};assert max_seam<2,max_seam;assert lamp>100 and door<wall;assert semantic['wordmark_sky_unique_colours']<=3;B.joinpath('semantic-checks.json').write_text(json.dumps(semantic,indent=2)+'\n',encoding='utf-8');print(json.dumps(semantic,indent=2))
