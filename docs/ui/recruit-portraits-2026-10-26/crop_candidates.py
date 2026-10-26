from pathlib import Path
import importlib.util, json, shutil
from PIL import Image, ImageDraw

W = Path(__file__).parent
L = Path('C:/Users/pmcga/dev/hollowtide')
spec = importlib.util.spec_from_file_location('portrait_builder', L/'tools/arena/build_portraits.py')
b = importlib.util.module_from_spec(spec)
spec.loader.exec_module(b)
b.ART = L/'assets/sprites/arena'
cuts = {'skimlet': (0.29, 0.16, 0.44), 'ozbender': (0.19, 0.28, 0.44), 'valvekin': (0.23, 0.39, 0.60)}
b.HEAD.update(cuts)
sheet = Image.new('RGBA', (900, 278), '#242b25')
d = ImageDraw.Draw(sheet)
facts = {}
for i, form in enumerate(cuts):
    p = b.portrait(form)
    dest = W/'prepared/assets/sprites/arena'/form/'portrait.png'
    p.save(dest)
    src = Image.open(b.ART/form/'sw.png').convert('RGBA')
    x0,y0,x1,y1 = src.getbbox(); width,height=x1-x0,y1-y0
    cx,top,side=cuts[form]; span=side*max(width,height)
    box=tuple(round(v) for v in (x0+cx*width-span/2,y0+top*height,x0+cx*width+span/2,y0+top*height+span))
    assert p.size == (48,48) and p.getbbox() is not None
    assert set(p.getdata()).issubset(set(src.getdata()))
    tile=Image.new('RGBA',(48,48),'#d7c7a5'); tile.alpha_composite(p)
    sheet.alpha_composite(tile,(i*300+12,24))
    sheet.alpha_composite(tile.resize((192,192),Image.Resampling.NEAREST),(i*300+88,24))
    d.text((i*300+12,8),form,fill='white')
    d.text((i*300+12,230),'48px actual; 4x review',fill='white')
    facts[form]={'facing':'sw','HEAD':cuts[form],'source_box':box,'colours':len({v for v in p.getdata() if v[3]>0}), 'opaque_pixels':sum(v[3]>0 for v in p.getdata())}
sheet.convert('RGB').save(W/'portraits-review.png')
(W/'crop-facts.json').write_text(json.dumps(facts,indent=2),encoding='utf-8')
builder=(L/'tools/arena/build_portraits.py').read_bytes()
for before,after in [
    (b'    "oxbowarchon":',b'    "ozbender": (0.19, 0.28, 0.44),\n    "oxbowarchon":'),
    (b'    "sparkjab":',b'    "skimlet": (0.29, 0.16, 0.44),\n    "sparkjab":'),
    (b'    "warden":',b'    "valvekin": (0.23, 0.39, 0.60),\n    "warden":')]:
    assert builder.count(before)==1
    builder=builder.replace(before,after)
dest=W/'prepared/tools/arena/build_portraits.py';dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(builder)
print(json.dumps(facts,indent=2))
