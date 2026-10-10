from pathlib import Path
from PIL import Image
import hashlib,json
W=Path(__file__).parent
source=W/'sources/storage_original.png'
img=Image.open(source).convert('RGBA')
# Asset preparation only: remove transparent padding, uniform nearest scaling, transparent canvas.
# Never paint, recolour, paste architectural parts or replace source pixels.
body=img.getchannel('A').point(lambda a:255 if a>=8 else 0).getbbox()
# Sub-8-alpha empty-canvas wisps are padding, not the building. Keep two source pixels of room.
bbox=(max(0,body[0]-2),max(0,body[1]-2),min(img.width,body[2]+2),min(img.height,body[3]+2));crop=img.crop(bbox)
width=134;height=round(crop.height*width/crop.width)
scaled=crop.resize((width,height),Image.Resampling.NEAREST)
native=Image.new('RGBA',(144,120))
offset=(8,119-height);native.paste(scaled,offset)
dest=W/'candidate/assets/sprites/world/storage_2026_10_10/storage_native.png'
native.save(dest)
(W/'asset-preparation.json').write_text(json.dumps({'method':'built-in imagegen; transparent padding crop, uniform nearest resize, transparent canvas','source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'source_size':img.size,'crop_bbox':bbox,'padding_bbox_threshold':8,'source_padding':2,'alpha_within_crop_preserved':True,'native_size':native.size,'scaled_size':scaled.size,'offset':offset,'source_preserved':True,'architectural_compositing':False},indent=2))
print('Native',native.size,'art',scaled.size,'offset',offset,'door tile x48..72')
