from pathlib import Path
from PIL import Image
import json,hashlib
W=Path(__file__).parent
source=W/'sources/scroll_original.png';img=Image.open(source).convert('RGBA')
body=img.getchannel('A').point(lambda a:255 if a>=8 else 0).getbbox()
bbox=(max(0,body[0]-2),max(0,body[1]-2),min(img.width,body[2]+2),min(img.height,body[3]+2))
crop=img.crop(bbox)
width=132;size=(width,round(crop.height*width/crop.width));offset=(4,0)
native=Image.new('RGBA',(144,120));native.paste(crop.resize(size,Image.Resampling.NEAREST),offset)
native.save(W/'candidate/assets/sprites/world/scroll_keeper_2026_10_10/scroll_native.png')
(W/'asset-preparation.json').write_text(json.dumps({'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'source_size':img.size,'crop':bbox,'scaled_size':size,'offset':offset,'native_size':native.size,'method':'built-in imagegen; transparent safety padding crop and uniform nearest resize only; source and retained alpha unchanged'},indent=2))
print('Native size',size,'offset',offset,'bbox',bbox)
