from pathlib import Path
import sys,json,hashlib
import numpy as np
from PIL import Image,ImageOps
root=Path(__file__).parent
stage=Path('D:/dev/hollowtide-world-refinement-20261008/project')
sys.path.insert(0,str(stage/'tools/arena'))
from downscale import resample
faces=['s','se','e','ne','n','nw','w','sw']
palette=set()
for f in faces:
    a=np.asarray(Image.open(root/f'originals/assets/sprites/arena/galeshear/{f}.png').convert('RGBA'))
    palette.update(map(tuple,a[a[:,:,3]>0][:,:3]))
rows=[]
def inspect(p,label):
    im=Image.open(p).convert('RGBA');a=np.asarray(im); box=im.getbbox()
    assert box and box[0]>0 and box[1]>0 and box[2]<im.width and box[3]<im.height,label+' touches edge'
    assert set(np.unique(a[:,:,3]))<={0,255},label+' soft alpha'
    assert set(map(tuple,a[a[:,:,3]>0][:,:3]))<=palette,label+' palette drift'
    rows.append({'path':label,'dimensions':im.size,'bounds':box,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
    return im
for f in faces:
    full=inspect(stage/f'assets/sprites/arena/galeshear/{f}.png',f+' full')
    small=inspect(stage/f'assets/sprites/arena/galeshear/small/{f}.png',f+' game')
    assert np.array_equal(np.asarray(resample(full,3/1.1)),np.asarray(small)),f+' still pipeline'
for f in ['s','se','e','ne','n']:
    p=stage/f'docs/creatures/arena-starters-2026-10-07/walk/galeshear_{f}_sheet.png'
    sheet=Image.open(p).convert('RGBA')
    assert sheet.size==(768,384)
    distinct=set()
    for i in range(8):
        full=sheet.crop(((i%4)*192,(i//4)*192,(i%4+1)*192,(i//4+1)*192))
        small=inspect(stage/f'assets/sprites/arena/galeshear/small/walk_{f}_f{i}.png',f+str(i)+' game')
        assert np.array_equal(np.asarray(resample(full,3/1.1)),np.asarray(small)),f+' walking pipeline'
        distinct.add(small.tobytes())
    assert len(distinct)==8,f+' distinct steps lost'
for f,source in {'nw':'ne','w':'e','sw':'se'}.items():
    for i in range(8):
        original=Image.open(stage/f'assets/sprites/arena/galeshear/small/walk_{source}_f{i}.png').convert('RGBA')
        mirrored=inspect(stage/f'assets/sprites/arena/galeshear/small/walk_{f}_f{i}.png',f+str(i)+' mirror')
        assert np.array_equal(np.asarray(ImageOps.mirror(original)),np.asarray(mirrored)),f+' mirror mismatch'
for entry in json.loads((root/'originals.json').read_text()):
    assert hashlib.sha256((root/'originals'/entry['path']).read_bytes()).hexdigest()==entry['sha256'],'Original changed'
report={'palette_colors':len(palette),'audited_images':len(rows),'still_pipeline_checks':8,'walking_pipeline_checks':40,'exact_walk_mirrors':24,'distinct_frames_per_authored_facing':8,'images':rows}
(root/'asset-audit.json').write_text(json.dumps(report,indent=2))
print(json.dumps({k:v for k,v in report.items() if k!='images'}))
