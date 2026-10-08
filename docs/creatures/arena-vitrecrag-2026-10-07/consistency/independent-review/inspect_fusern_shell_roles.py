"""Read-only Fusern source color-role contacts; only review PNG/JSON outputs are written."""
from pathlib import Path
import hashlib,json
import numpy as np
from PIL import Image,ImageDraw
P=Path('C:/Users/pmcga/dev/hollowtide');O=Path(__file__).resolve().parent;S=O.parent/'source-audit/originals'
colors=[(231,113,39),(252,161,82),(218,116,60)]
faces=['e','ne','n','nw'];cropbox=(20,20,105,82);scale=4;cw=360;rh=275
sheet=Image.new('RGB',(cw*4,rh*4),(23,31,28));d=ImageDraw.Draw(sheet);records={}
for row,f in enumerate(faces):
 rel=Path('assets/sprites/arena/fusern')/(f+'.png');p=S/rel;a=np.array(Image.open(p).convert('RGBA'));panels=[]
 for col in range(4):
  aa=a.copy()
  if col:
   mask=(aa[:,:,3]>0)&np.all(aa[:,:,:3]==colors[col-1],axis=2)
   aa[aa[:,:,3]>0,:3]=(aa[aa[:,:,3]>0,:3].astype(float)*.30).astype(np.uint8);aa[mask,:3]=[255,70,190]
   title=f'{f} highlighted {colors[col-1]}'
  else:title=f'{f} ORIGINAL'
  im=Image.fromarray(aa).crop(cropbox);large=im.resize((im.width*scale,im.height*scale),Image.Resampling.NEAREST)
  x=col*cw+8;y=row*rh+22;sheet.paste(large,(x,y),large);d.text((x,row*rh+4),title,fill='white')
 on=a[:,:,3]>0;yy,xx=np.mgrid[:a.shape[0],:a.shape[1]];mask=on&(yy<66)&(yy>=24)&(xx>=26)&(xx<103)
 c,k=np.unique(a[mask,:3],axis=0,return_counts=True);order=k.argsort()[::-1]
 records[f]={'path':str(rel).replace('\\','/'),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'shell_roi_review_only_xyxy':[26,24,103,66],'dominant_roi_rgb_counts':[{'rgb':list(map(int,c[i])),'count':int(k[i])} for i in order[:15]]}
sheet.save(O/'fusern_pale_shell_color_classes4x.png')
(O/'fusern_shell_color_roles.json').write_text(json.dumps({'note':'Review-only RGB class identification; ROI is not an approved application mask. Geometry/support untouched.','frames':records},indent=2)+'\n')
print('Prepared color-class contact and read-only ROI counts.')
