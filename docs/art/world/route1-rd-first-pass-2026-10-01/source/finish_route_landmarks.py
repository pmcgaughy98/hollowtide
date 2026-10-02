from PIL import Image,ImageDraw
from pathlib import Path
import json
P=Path(__file__).parent;O=P/'props';O.mkdir(exist_ok=True)
report={}
for name in ['marker','post','height','reeds','dispatcher']:
 im=Image.open(P/(name+'_original.png')).convert('RGBA');d=ImageDraw.Draw(im)
 if name=='marker':
  d.rectangle((6,7,18,14),fill=(50,59,59,255))
  for x in [8,12,16]: d.point((x,10),fill=(220,205,161,255))
 if name=='post':
  d.rectangle((11,17,19,19),fill=(40,43,37,255))
  d.line((11,20,19,20),fill=(133,113,76,255))
  d.rectangle((13,25,16,28),fill=(43,49,43,255))
  d.line((13,24,16,24),fill=(140,124,85,255))
 if name=='height':
  padded=Image.new('RGBA',(16,64));padded.paste(im,(0,3));im=padded
 im.save(O/(name+'.png'));report[name]={'size':im.size,'bbox':im.getbbox(),'finish':'Explicit three-dot sign' if name=='marker' else ('Dry slot and empty return recess' if name=='post' else ('Transparent padding, original pixels retained' if name=='height' else 'Original generation unchanged'))}
(O/'landmark_preparation.json').write_text(json.dumps(report,indent=2));print(json.dumps(report))
card=Image.new('RGBA',(320,96),(93,120,94,255));d=ImageDraw.Draw(card)
for n,name in enumerate(report):
 im=Image.open(O/(name+'.png'));card.alpha_composite(im,(n*64+8,8));d.text((n*64+3,76),name,fill='white')
card.resize((960,288),Image.Resampling.NEAREST).convert('RGB').save(O/'landmarks_review.png')
