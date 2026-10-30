from pathlib import Path
from PIL import Image,ImageDraw
import json,hashlib,subprocess,sys,os
import numpy as np
B=Path(__file__).parent;D=B/'town.building.hall.key';L=B.parents[3]
contract=json.loads((D/'design-contract-pending.json').read_text(encoding='utf-8'));pal=np.array(contract['palette_rgb_from_approved_design'],dtype=np.int32)
raw=Image.open(D/'raw.png').convert('RGBA');bounds=raw.getchannel('A').point(lambda v:255 if v>=128 else 0).getbbox();assert bounds
content=raw.crop(bounds);factor=min(214/content.width,359/content.height);size=(max(1,int(content.width*factor)),max(1,int(content.height*factor)))
small=content.convert('RGBa').resize(size,Image.Resampling.BOX).convert('RGBA');a=np.array(small);a[:,:,3]=np.where(a[:,:,3]>=128,255,0);a[a[:,:,3]==0,:3]=0
native=Image.new('RGBA',(216,360));native.alpha_composite(Image.fromarray(a),(108-size[0]//2,360-size[1]));a=np.array(native);m=a[:,:,3]>0
pixels=a[m,:3].astype(np.int32)
for i in range(0,len(pixels),32768):
 chunk=pixels[i:i+32768];pixels[i:i+32768]=pal[((chunk[:,None,:]-pal[None,:,:])**2).sum(2).argmin(1)]
colors,counts=np.unique(pixels,axis=0,return_counts=True)
# Keep the courier-teal and brass accents while selecting the provisional32-color design subset.
essential=[[11,14,17],[45,158,159],[18,131,127],[0,49,58],[242,210,122],[163,122,50]]
chosen=[]
for c in essential+[colors[i].tolist() for i in np.argsort(-counts)]:
 if c not in chosen:chosen.append(c)
 if len(chosen)==32:break
chosen=np.array(chosen,dtype=np.int32)
for i in range(0,len(pixels),32768):
 chunk=pixels[i:i+32768];pixels[i:i+32768]=chosen[((chunk[:,None,:]-chosen[None,:,:])**2).sum(2).argmin(1)]
a[m,:3]=pixels.astype(np.uint8);before=a.copy();removed=0
for iteration in range(12):
 opaque=a[:,:,3]>0;key=(a[:,:,0].astype(int)<<16)|(a[:,:,1].astype(int)<<8)|a[:,:,2].astype(int);key=np.where(opaque,key,-1);p=np.pad(key,1,constant_values=-2);same=np.zeros(key.shape,bool)
 for dy,dx in ((0,1),(2,1),(1,0),(1,2)):same|=p[dy:dy+360,dx:dx+216]==key
 ys,xs=np.nonzero(opaque&~same)
 if len(ys)/max(1,opaque.sum())<.006:break
 for y,x in zip(ys,xs):
  neighbors=[a[yy,xx,:3].copy() for yy,xx in ((y-1,x),(y+1,x),(y,x-1),(y,x+1)) if 0<=yy<360 and 0<=xx<216 and a[yy,xx,3]>0]
  if not neighbors:a[y,x]=0;removed+=1;continue
  colors2,counts2=np.unique(np.array(neighbors),axis=0,return_counts=True);dist=((colors2.astype(int)-a[y,x,:3].astype(int))**2).sum(1)
  best=sorted(range(len(colors2)),key=lambda k:(-counts2[k],dist[k]))[0];a[y,x,:3]=colors2[best]
Image.fromarray(a).save(D/'key-native.png')
colors=np.unique(a[a[:,:,3]>0,:3],axis=0);ys,xs=np.nonzero(a[:,:,3]>0)
manual={'status':'DESIGN-ONLY native measurements; not official slot validation','size':[216,360],'binary_alpha':bool(np.isin(a[:,:,3],[0,255]).all()),'opaque_pixels':int((a[:,:,3]>0).sum()),'color_count':len(colors),'provisional_color_ceiling':32,'design_palette_subset':all(any(np.array_equal(c,p) for p in pal) for c in colors),'clear_top_and_sides':bool(not a[0,:,3].any() and not a[:,0,3].any() and not a[:,-1,3].any()),'lowest_opaque_row':int(ys.max()),'source_raw_size':list(raw.size),'source_crop':list(bounds),'source_content_fit':list(size),'adjacent_color_cleanup_pixels':int(np.any(before[:,:,:3]!=a[:,:,:3],axis=2).sum()),'isolated_alpha_specks_removed':removed,'raw_sha256':hashlib.sha256((D/'raw.png').read_bytes()).hexdigest(),'native_sha256':hashlib.sha256((D/'key-native.png').read_bytes()).hexdigest()}
assert manual['binary_alpha'] and manual['color_count']<=32 and manual['design_palette_subset'] and manual['clear_top_and_sides'] and manual['lowest_opaque_row']==359
(D/'design-native-measurements.json').write_text(json.dumps(manual,indent=2),encoding='utf-8')
# Attempt exactly the requested tools. Unknown slots are honestly retained as REFUSED, never faked as PASS.
env=os.environ.copy();env['PYTHONDONTWRITEBYTECODE']='1';attempts=[]
for tool,args in [('prepare_slot.py',['town.building.hall.key',str(D/'raw.png'),str(D/'prepared.png')]),('validate_slot.py',['town.building.hall.key',str(D/'key-native.png')])]:
 cmd=[sys.executable,'-B',str(L/'tools/art'/tool)]+args
 r=subprocess.run(cmd,cwd=L,env=env,capture_output=True,text=True);(D/(tool+'.log')).write_text(r.stdout+r.stderr,encoding='utf-8');attempts.append({'tool':tool,'command':cmd,'exit':r.returncode,'stdout':r.stdout,'stderr':r.stderr})
(D/'official-slot-attempts.json').write_text(json.dumps(attempts,indent=2),encoding='utf-8')
# A design-only board, explicitly not the contract review_sheet.py product.
board=Image.new('RGB',(760,790),(29,32,37));dr=ImageDraw.Draw(board)
dr.text((12,10),'NEW TOWER STYLE KEY - design reference only, official slot export pending',fill='white')
for col,name,label in ((0,'reference-key-216x360.png','Approved clean blockout'),(1,'key-native.png','Painted candidate, native216x360')):
 im=Image.open(D/name).convert('RGBA').resize((432,720),Image.Resampling.NEAREST)
 # Native1x fits both columns; lower panels show2x crops for material review.
 im=Image.open(D/name).convert('RGBA');board.paste(im,(col*370+76,48),im);dr.text((col*370+12,30),label,fill='white')
 crop=Image.open(D/name).convert('RGBA').crop((24,180,192,350)).resize((336,340),Image.Resampling.NEAREST);board.paste(crop,(col*370+12,430),crop)
dr.text((12,410),'Lower/material detail2x. No install or official check-pass claim.',fill=(240,207,132))
board.save(B/'design-review.png')
print(json.dumps(manual,indent=2));print('Official tools:',[(x['tool'],x['exit']) for x in attempts])
