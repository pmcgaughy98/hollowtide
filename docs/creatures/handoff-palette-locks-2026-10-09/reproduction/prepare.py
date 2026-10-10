from pathlib import Path
import hashlib,json,shutil,importlib.util
import numpy as np
from PIL import Image,ImageDraw
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project');O=W/'originals';P=W/'candidate'
FORMS=['dustkite','waywhistle','highsignal','riftfin','scourmaw'];FACINGS='s se e ne n nw w sw'.split();DOC=Path('docs/creatures/arena-starters-2026-10-07')
REFS={n:DOC/'forms'/f'{n}_arena_front_take1.png' for n in FORMS}
def cp(src,dst):dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst)
hashes={};owned=[]
for n in FORMS:
    rels=[Path(f'assets/sprites/arena/{n}/{f}.png') for f in FACINGS]
    rels += [DOC/'walk'/f'{n}_{f}_sheet.png' for f in 's se e ne n'.split()]
    rels += list(p.relative_to(L) for folder in ['small','dungeon'] for p in (L/'assets/sprites/arena'/n/folder).glob('*.png'))
    for r in rels:
        assert (L/r).exists(),str(r)
        cp(L/r,O/r);cp(L/r,P/r);hashes[r.as_posix()]=hashlib.sha256((L/r).read_bytes()).hexdigest();owned.append(r.as_posix())
    r=REFS[n];cp(L/r,O/r);hashes[r.as_posix()]=hashlib.sha256((L/r).read_bytes()).hexdigest()
for folder in ['scripts','scenes','data','tools']:
    for src in (L/folder).rglob('*'):
        if not src.is_file() or src.suffix=='.pyc' or '__pycache__' in src.parts:continue
        dst=C/src.relative_to(L)
        if not dst.is_file() or src.read_bytes()!=dst.read_bytes():cp(src,dst)
for r in ['tools/arena/normalize_arena_palette.py','tools/arena/build_small.py','tools/arena/build_dungeon_set.py','tools/arena/downscale.py','scripts/arena/arena_prototype.gd']:
    cp(L/r,P/r);hashes[r]=hashlib.sha256((L/r).read_bytes()).hexdigest()
(W/'baseline.json').write_text(json.dumps(hashes,indent=2));(W/'owned.json').write_text(json.dumps(owned,indent=2))
spec=importlib.util.spec_from_file_location('norm',L/'tools/arena/normalize_arena_palette.py');mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
board=Image.new('RGB',(9*150,5*166),(25,30,32));draw=ImageDraw.Draw(board);audit={}
for row,n in enumerate(FORMS):
    audit[n]={'reference':REFS[n].as_posix(),'facings':{}}
    for col,f in enumerate(['reference']+FACINGS):
        path=L/(REFS[n] if f=='reference' else Path(f'assets/sprites/arena/{n}/{f}.png'))
        im=Image.open(path).convert('RGBA');a=np.array(im);m=mod.metrics(a);audit[n]['reference_metrics' if f=='reference' else 'facings'].update(m if f=='reference' else {f:m}) if f!='reference' else None
        if f=='reference':audit[n]['reference_metrics']=m
        im.thumbnail((140,140),Image.Resampling.NEAREST);board.paste(im,(col*150+(150-im.width)//2,row*166+20+(140-im.height)//2),im)
        draw.text((col*150+4,row*166+2),n if f=='reference' else f,fill='white')
(W/'source-audit.json').write_text(json.dumps(audit,indent=2));board.save(W/'approved-reference-and-current-facings.png')
print('Five current approved models and cleaned sources backed up:',len(owned),'owned PNGs')
