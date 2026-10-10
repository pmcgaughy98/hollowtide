from pathlib import Path
from PIL import Image
import json,hashlib
W=Path(__file__).parent
source=W/'sources/shrine_original.png'
img=Image.open(source).convert('RGBA')
body=img.getchannel('A').point(lambda a:255 if a>=8 else 0).getbbox()
bbox=(max(0,body[0]-2),max(0,body[1]-2),min(img.width,body[2]+2),min(img.height,body[3]+2))
crop=img.crop(bbox)
ratio=min(136/crop.width,114/crop.height)
size=(round(crop.width*ratio),round(crop.height*ratio))
offset=((144-size[0])//2,(120-size[1])//2)
native=Image.new('RGBA',(144,120));native.paste(crop.resize(size,Image.Resampling.NEAREST),offset)
native.save(W/'candidate/assets/sprites/world/growth_shrine_2026_10_10/shrine_native.png')
(W/'asset-preparation.json').write_text(json.dumps({'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'source_size':img.size,'crop':bbox,'scaled_size':size,'offset':offset,'native_size':native.size,'method':'built-in imagegen; transparent safety padding crop and uniform nearest resize only; source and retained alpha unchanged'},indent=2))
print(size,offset,bbox)
