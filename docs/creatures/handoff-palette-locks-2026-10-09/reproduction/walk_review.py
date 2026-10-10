from pathlib import Path
import json,importlib.util
import numpy as np
from PIL import Image,ImageDraw
W=Path(__file__).parent;P=W/'candidate';O=W/'originals';FORMS=['dustkite','waywhistle','highsignal','riftfin','scourmaw'];FACINGS='s se e ne n nw w sw'.split()
spec=importlib.util.spec_from_file_location('norm',P/'tools/arena/normalize_arena_palette.py');norm=importlib.util.module_from_spec(spec);spec.loader.exec_module(norm)
summary={};review=[]
for n in FORMS:
    summary[n]={}
    for size in ['small','dungeon']:
        summary[n][size]={}
        for label,root in [('before',O),('after',P)]:
            vals=[norm.metrics(np.array(Image.open(root/'assets/sprites/arena'/n/size/f'walk_{f}_f{i}.png').convert('RGBA'))) for f in FACINGS for i in range(8)]
            summary[n][size][label]={'brightness_spread':max(v['brightness'] for v in vals)-min(v['brightness'] for v in vals),'saturation_spread':max(v['saturation_pct'] for v in vals)-min(v['saturation_pct'] for v in vals)}
for frame in range(8):
    canvas=Image.new('RGB',(5*170,2*190),(25,30,32));draw=ImageDraw.Draw(canvas)
    for i,n in enumerate(FORMS):
        for row,size in enumerate(['small','dungeon']):
            im=Image.open(P/'assets/sprites/arena'/n/size/f'walk_se_f{frame}.png').convert('RGBA');im=im.resize((im.width*3,im.height*3),Image.Resampling.NEAREST)
            canvas.paste(im,(i*170+(170-im.width)//2,row*190+25+(155-im.height)//2),im);draw.text((i*170+3,row*190+3),n+' '+size,fill='white')
    review.append(canvas)
palette=review[0].quantize(colors=256)
review=[im.quantize(palette=palette,dither=Image.Dither.NONE) for im in review]
review[0].save(W/'prepared-walk-review.gif',save_all=True,append_images=review[1:],duration=140,loop=0,disposal=2)
(W/'walk-spreads.json').write_text(json.dumps(summary,indent=2));print('Both sizes reviewed through all eight SE poses; spread measurements saved')
