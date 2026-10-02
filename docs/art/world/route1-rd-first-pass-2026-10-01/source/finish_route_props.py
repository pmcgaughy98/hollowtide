from PIL import Image,ImageDraw
from pathlib import Path
import numpy as np,json
P=Path(__file__).parent;O=P/'props';O.mkdir(exist_ok=True)
a=np.array(Image.open(P/'office_original.png').convert('RGBA'));b=np.array(Image.open(P/'office_outpaint.png').convert('RGBA'))
masked=a[:,:,3]>0
print('office original visible RGB mismatches',int(np.any(a[:,:,:3]!=b[16:96,:,:3],2)[masked].sum()),'alpha mismatches',int((a[:,:,3]!=b[16:96,:,3]).sum()))
# Outpainting decodes the transparent background as a matte. Keep the original
# building literally intact and use only the newly completed top strip.
finish=Image.new('RGBA',(96,96));top=Image.fromarray(b[:16].copy());t=np.array(top)
white=(t[:,:,:3].min(2)>200);t[white,3]=0
finish.paste(Image.fromarray(a),(0,16))
# The generated extension painted a checkerboard instead of completing the
# roof. Reject that strip. Cap the existing roof with its own dark outline.
f=np.array(finish)
f[15,a[0,:,3]>0,:3]=(45,52,52);f[15,a[0,:,3]>0,3]=255
finish=Image.fromarray(f);finish.save(O/'wayline_office.png')
Image.open(P/'tree_original.png').convert('RGBA').save(O/'cottonwood.png')
report={'office_original_body_rgb_changes':0,'office_original_body_alpha_changes':0,'office_canvas':[96,96],'office_bbox':finish.getbbox(),'method':'Outpainting added only a baked checkerboard and was rejected. Preserve every original pixel at y+16 and cap the roof with a one-pixel dark ridge from the existing roof outline.'}
(O/'prop_preparation.json').write_text(json.dumps(report,indent=2));print(json.dumps(report))
card=Image.new('RGBA',(240,192),(93,120,94,255));card.alpha_composite(finish,(8,16));card.alpha_composite(Image.open(O/'cottonwood.png'),(124,8));card.resize((720,576),Image.Resampling.NEAREST).convert('RGB').save(O/'props_review.png')
