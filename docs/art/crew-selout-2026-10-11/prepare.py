from pathlib import Path
import hashlib,json,shutil,sys
import numpy as np
from PIL import Image,ImageDraw,ImageFont
W=Path(__file__).parent
C=Path('C:/Users/pmcga/dev/hollowtide')
NAMES=['grubbit','muskin','slipjaw','stillwade','wickglow','rinsepaw','cairnshell','crawdukes']
FACINGS=['s','se','e','ne','n','nw','w','sw']
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def luma(rgb):return rgb[...,0]*.3+rgb[...,1]*.59+rgb[...,2]*.11
def outline(a,dark):
    b=a.copy();solid=a[...,3]>0;p=np.pad(solid,1)
    edge=solid&~(p[:-2,1:-1]&p[2:,1:-1]&p[1:-1,:-2]&p[1:-1,2:])
    mask=edge&(luma(a[...,:3].astype(float))>=float(luma(dark.astype(float)))+12.)
    b[mask,:3]=dark
    return b,mask
def sheet(name,kind,source,output):
    frames=[[Image.open(source/('assets/sprites/arena/'+name+'/'+kind+'/walk_'+fc+'_f'+str(k)+'.png')).convert('RGBA') for k in range(8)] for fc in FACINGS]
    cell=max(max(im.size) for row in frames for im in row)*2+8
    out=Image.new('RGB',(50+cell*8,30+(cell+16)*8),'#242b25');draw=ImageDraw.Draw(out)
    draw.text((8,6),name+' '+kind+' / eight frames per facing',fill='#e4ca8e')
    for y,(fc,row) in enumerate(zip(FACINGS,frames)):
        draw.text((5,42+y*(cell+16)),fc,fill='#e4ca8e')
        for k,im in enumerate(row):
            x=50+k*cell;yy=30+y*(cell+16)
            draw.rectangle((x,yy,x+cell-3,yy+cell-3),fill='#3f5140')
            scaled=im.resize((im.width*2,im.height*2),Image.Resampling.NEAREST)
            out.paste(scaled,(x+(cell-scaled.width)//2,yy+(cell-scaled.height)//2),scaled)
            draw.text((x+4,yy+cell),str(k),fill='#fff4e8')
    out.save(output)
def prepare():
    assert not (W/'manifest.json').exists(),'Snapshot exists; preserve it instead of replacing it.'
    paths=[]
    for name in NAMES:
        root=C/'assets/sprites/arena'/name
        expected={f'{fc}.png' for fc in FACINGS}
        expected|={f'{kind}/{fc}.png' for kind in ['town','dungeon'] for fc in FACINGS}
        expected|={f'{kind}/walk_{fc}_f{k}.png' for kind in ['town','dungeon'] for fc in FACINGS for k in range(8)}
        actual={p.relative_to(root).as_posix() for p in root.rglob('*.png')}
        assert actual==expected,(name,'inspect new/missing textures',actual^expected)
        paths.extend(sorted(root.rglob('*.png')))
        paths.append(C/f'docs/creatures/arena-starters-2026-10-07/forms/{name}_arena_front_chosen.png')
    records=[];form_stats={}
    for name in NAMES:
        still=np.array(Image.open(C/'assets/sprites/arena'/name/'s.png').convert('RGBA'))
        solid=still[...,3]>0;lum=luma(still[solid,:3].astype(float))
        dark=still[solid][lum==lum.min()][0,:3]
        form_stats[name]={'line_colour':dark.tolist(),'images':0,'changed_images':0,'changed_pixels':0}
        for path in [p for p in paths if '/'+name+'/' in p.as_posix() or p.name==name+'_arena_front_chosen.png']:
            rel=path.relative_to(C).as_posix();before=W/'originals'/rel;after=W/'prepared'/rel
            before.parent.mkdir(parents=True,exist_ok=True);after.parent.mkdir(parents=True,exist_ok=True)
            shutil.copy2(path,before)
            assert digest(path)==digest(before),'Concurrent source changed during snapshot: '+rel
            a=np.array(Image.open(before).convert('RGBA'));b,mask=outline(a,dark)
            changed=np.any(a!=b,axis=2)
            assert np.array_equal(a[...,3],b[...,3]) and not np.any(changed&~mask)
            assert np.array_equal(a[~mask],b[~mask])
            assert np.array_equal(b[mask,:3],np.broadcast_to(dark,b[mask,:3].shape))
            if changed.any():Image.fromarray(b).save(after)
            else:shutil.copy2(before,after)
            # Reapplying exactly this rule cannot thicken or keep darkening the line.
            twice,_=outline(b,dark);assert np.array_equal(b,twice)
            stat=form_stats[name];stat['images']+=1;stat['changed_images']+=bool(changed.any());stat['changed_pixels']+=int(changed.sum())
            records.append({'path':rel,'form':name,'before':digest(before),'after':digest(after),'size':list(Image.open(before).size),'changed_pixels':int(changed.sum())})
    (W/'manifest.json').write_text(json.dumps(records,indent=2),encoding='utf-8')
    (W/'stats.json').write_text(json.dumps(form_stats,indent=2),encoding='utf-8')
    review=W/'review';review.mkdir()
    for name in NAMES:
        for kind in ['town','dungeon']:
            sheet(name,kind,W/'prepared',review/f'{name}_{kind}_after.png')
            sheet(name,kind,W/'originals',review/f'{name}_{kind}_before.png')
    # Current full-size facings and idle fronts, before/after at nearest 2x.
    for chosen in [False,True]:
        cell=432;out=Image.new('RGB',(cell*4,cell*4),'#242b25');draw=ImageDraw.Draw(out)
        for k,name in enumerate(NAMES):
            rel=(f'docs/creatures/arena-starters-2026-10-07/forms/{name}_arena_front_chosen.png' if chosen else f'assets/sprites/arena/{name}/s.png')
            for n,source in enumerate(['originals','prepared']):
                im=Image.open(W/source/rel).convert('RGBA');im=im.resize((im.width*2,im.height*2),Image.Resampling.NEAREST)
                x=(k%2)*cell*2+n*cell;y=(k//2)*cell
                draw.text((x+8,y+8),name+' '+('BEFORE' if n==0 else 'AFTER'),fill='#e4ca8e')
                out.paste(im,(x+(cell-im.width)//2,y+24+(cell-24-im.height)//2),im)
        out.save(review/('idle_fronts_before_after.png' if chosen else 'facings_before_after.png'))
    print(json.dumps(form_stats,indent=2))
    print('Preserved',len(records),'current PNGs; alpha, dimensions, unselected RGBA and idempotence exact.')
if __name__=='__main__':prepare()
