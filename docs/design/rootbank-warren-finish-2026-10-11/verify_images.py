from pathlib import Path
from PIL import Image
import json,ast
W=Path(__file__).parent
report=[]
for f in [1,2,3,4]:
    before=json.loads((W/f'before/floor{f}-data.json').read_text())
    after=json.loads((W/f'after/floor{f}-data.json').read_text())
    assert before==after, 'Layout changed'
    tiles=ast.literal_eval(before['tiles'])
    stats={'floor':f,'layout_exact':True}
    for kind in ['raw','native']:
        a=Image.open(W/f'before/floor{f}-{kind}.png').convert('RGBA')
        b=Image.open(W/f'after/floor{f}-{kind}.png').convert('RGBA')
        assert a.size==b.size
        changed=outside=0
        for y in range(a.height):
            for x in range(a.width):
                p=b.getpixel((x,y));assert p[3]==255
                if p!=a.getpixel((x,y)):
                    changed+=1
                    if tiles[(y//24)*before['w']+x//24]!=0:outside+=1
        assert changed>0 and outside==0, (f,kind,changed,outside)
        stats[kind]={'changed_wall_pixels':changed,'changed_floor_pixels':outside,'opaque':True}
    report.append(stats)
(W/'image-verification.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report,indent=2))
