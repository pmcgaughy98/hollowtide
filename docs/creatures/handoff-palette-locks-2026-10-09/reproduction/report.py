from pathlib import Path
import json,importlib.util,hashlib,shutil
import numpy as np
from PIL import Image,ImageDraw
W=Path(__file__).parent;P=W/'candidate';O=W/'originals';C=Path('D:/dev/hollowtide-world-refinement-20261008/project');FORMS=['dustkite','waywhistle','highsignal','riftfin','scourmaw'];FACINGS='s se e ne n nw w sw'.split();DOC=Path('docs/creatures/arena-starters-2026-10-07')
spec=importlib.util.spec_from_file_location('norm',P/'tools/arena/normalize_arena_palette.py');norm=importlib.util.module_from_spec(spec);spec.loader.exec_module(norm)
owned=json.loads((W/'owned.json').read_text());result={'files':[],'forms':{},'failures':[],'alpha_exact':0,'canvas_exact':0,'transparent_rgba_exact':0,'palette_exact':0}
for r in owned:
    a=np.array(Image.open(O/r).convert('RGBA'));b=np.array(Image.open(P/r).convert('RGBA'));form=next(n for n in FORMS if '/'+n+'/' in r or Path(r).name.startswith(n+'_'))
    base=np.array(Image.open(O/DOC/'forms'/f'{form}_arena_front_take1.png').convert('RGBA'));palette=set(map(tuple,base[base[...,3]>0,:3]));on=b[...,3]>0
    checks={'canvas':a.shape==b.shape,'alpha':np.array_equal(a[...,3],b[...,3]),'transparent_rgba':np.array_equal(a[a[...,3]==0],b[a[...,3]==0]),'palette':set(map(tuple,b[on,:3]))<=palette}
    for key,ok in checks.items():
        if not ok:result['failures'].append([r,key])
    result['canvas_exact']+=int(checks['canvas']);result['alpha_exact']+=int(checks['alpha']);result['transparent_rgba_exact']+=int(checks['transparent_rgba']);result['palette_exact']+=int(checks['palette'])
    result['files'].append({'path':r,'sha256':hashlib.sha256((P/r).read_bytes()).hexdigest(),'rgb_pixels_changed':int(np.any(a[...,:3]!=b[...,:3],axis=-1).sum())})
board=Image.new('RGB',(8*148,5*2*164),(24,29,32));draw=ImageDraw.Draw(board)
for row,n in enumerate(FORMS):
    rowmetrics={}
    for size in ['full','small','dungeon']:
        sets={}
        for label,root in [('before',O),('after',P)]:
            vals={}
            for f in FACINGS:
                r=Path('assets/sprites/arena')/n/(Path() if size=='full' else Path(size))/(f+'.png')
                vals[f]=norm.metrics(np.array(Image.open(root/r).convert('RGBA')))
            sets[label]={'facings':vals,'brightness_spread':max(m['brightness'] for m in vals.values())-min(m['brightness'] for m in vals.values())}
        rowmetrics[size]=sets
    result['forms'][n]=rowmetrics
    for side,root in enumerate([O,P]):
        for col,f in enumerate(FACINGS):
            im=Image.open(root/'assets/sprites/arena'/n/'small'/(f+'.png')).convert('RGBA');im=im.resize((im.width*3,im.height*3),Image.Resampling.NEAREST)
            x=col*148+(148-im.width)//2;y=(row*2+side)*164+19+(140-im.height)//2
            board.paste(im,(x,y),im);draw.text((col*148+3,(row*2+side)*164+3),(n+' BEFORE' if side==0 else n+' AFTER') if col==0 else f,fill='white')
board.save(W/'game-size-before-after.png')
(W/'structural-and-palette-checks.json').write_text(json.dumps(result,indent=2))
assert not result['failures'],result['failures'][:20]
print(json.dumps({k:v for k,v in result.items() if k not in ['files','forms']},indent=2))
print([(n,round(v['full']['before']['brightness_spread'],2),round(v['full']['after']['brightness_spread'],2)) for n,v in result['forms'].items()])
