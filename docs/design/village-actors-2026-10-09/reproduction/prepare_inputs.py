from pathlib import Path
from PIL import Image
import urllib.request,json
W=Path(__file__).parent
manifest={}
for form in ['punchybun','cinderhide']:
    r=json.loads((W/(form+'-reframed.json')).read_text())
    raw=W/(form+'-reframed.png')
    urllib.request.urlretrieve(r['result']['output_urls'][0],raw)
    im=Image.open(raw).convert('RGBA');box=im.getchannel('A').getbbox()
    assert box and box[0]>0 and box[1]>0 and box[2]<im.width and box[3]<im.height,(form,'Source clipping',box)
    body=im.crop(box)
    factor=min(58/body.width,56/body.height)
    size=(round(body.width*factor),round(body.height*factor))
    body=body.resize(size,Image.Resampling.NEAREST)
    canvas=Image.new('RGBA',(80,80));at=((80-size[0])//2,70-size[1]);canvas.alpha_composite(body,at)
    canvas.save(W/(form+'-input80.png'))
    manifest[form]={'source_size':list(im.size),'source_used':list(box),'prepared_size':list(size),'prepared_at':list(at),'native_canvas':[80,80],'nearest_only':True}
(W/'input-preparation.json').write_text(json.dumps(manifest,indent=2))
print(json.dumps(manifest,indent=2))
