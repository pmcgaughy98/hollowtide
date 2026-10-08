"""Report installed arena colours against preserved original PNGs without editing assets.

Usage from the project root after consistency normalization and build_small.py:
Explicit --forms limits all measurements, contacts and mirror checks to that selection.
  python tools/arena/report_consistency.py --project . \
    --before-audit /absolute/path/to/source-audit --output /absolute/path/to/review
The before-audit directory contains before-manifest.json, before-metrics.json and
originals/<project-relative PNG>. --before-manifest may point to the manifest instead.
Writes CSV/Markdown/JSON proof, 3x nearest-neighbour game contacts and walk preview
GIFs into --output only. It never calls generation, imports, or game code. Existing
alpha/support/foot rows of the full art are immutable except explicit audited
artifact removal or enclosed crater-hole filling; no general shape exemption is
accepted. Tiny sparks, barbels and spikes are measured, never deleted implicitly.
Saturation is mean HSV percent (0 to100).
"""
from pathlib import Path
import argparse, hashlib, json, csv, collections, sys
import numpy as np
from PIL import Image, ImageDraw, ImageOps

FORMS=['kithflare','sparkwick','stormwick','tallowroot','huskward','rampartroot','rimefin','riftfin','scourmaw']
FACINGS=['s','se','e','ne','n','nw','w','sw']
BASE_REL={n:(f'docs/creatures/arena-starters-2026-10-07/{n}_arena_front_take2_clear.png' if n in ('kithflare','tallowroot','rimefin') else f'docs/creatures/arena-starters-2026-10-07/forms/{n}.png') for n in FORMS}
FULL_MIRRORS={'kithflare':{'e':'w'},'rimefin':{'e':'w'},'sparkwick':{'e':'w'},'riftfin':{'nw':'ne'},'scourmaw':{'sw':'se'}}
WALK_MIRROR={'e':'w','se':'sw','ne':'nw','w':'e','sw':'se','nw':'ne'}

def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def lum(rgb): return rgb[...,0]*.299+rgb[...,1]*.587+rgb[...,2]*.114

def hsv(rgb):
    a=rgb.astype(float)/255; mx=a.max(axis=-1); mn=a.min(axis=-1); dif=mx-mn
    s=np.divide(dif,mx,out=np.zeros_like(dif),where=mx>0)
    h=np.zeros_like(mx); has=dif>0
    r=has&(mx==a[...,0]); g=has&~r&(mx==a[...,1]); b=has&~r&~g
    h[r]=((a[...,1]-a[...,2])[r]/dif[r])%6; h[g]=(a[...,2]-a[...,0])[g]/dif[g]+2; h[b]=(a[...,0]-a[...,1])[b]/dif[b]+4
    return h/6,s,mx

def geometry(a):
    on=a[:,:,3]>0
    if not on.any(): return {'canvas':[a.shape[1],a.shape[0]],'bbox':None,'foot_row':None,'painted_pixels':0}
    yy,xx=np.nonzero(on)
    return {'canvas':[a.shape[1],a.shape[0]],'bbox':[int(xx.min()),int(yy.min()),int(xx.max()+1),int(yy.max()+1)],'foot_row':int(yy.max()),'painted_pixels':int(on.sum())}

def measure(im):
    a=np.array(im.convert('RGBA')); rgb=a[:,:,:3]; al=a[:,:,3]; on=al>0
    rec=geometry(a)
    if not on.any(): return {**rec,'empty':True}
    yy,xx=np.nonzero(on); pad=np.pad(on,1); edge=on&~(pad[:-2,1:-1]&pad[2:,1:-1]&pad[1:-1,:-2]&pad[1:-1,2:]); interior=on&~edge
    L=lum(rgb); H,S,V=hsv(rgb); count=collections.Counter(map(tuple,rgb[on])); edge_count=collections.Counter(map(tuple,rgb[edge])); dark=edge&(L<40)
    codes=rgb[:,:,0].astype(int)*65536+rgb[:,:,1].astype(int)*256+rgb[:,:,2]; cp=np.pad(codes,1,constant_values=-1)
    lone=interior&(cp[:-2,1:-1]!=codes)&(cp[2:,1:-1]!=codes)&(cp[1:-1,:-2]!=codes)&(cp[1:-1,2:]!=codes)
    hues={str(i*30)+'-'+str((i+1)*30):round(float(((H[on]*12).astype(int)%12==i)[S[on]>.1].mean()*100),3) if (S[on]>.1).any() else 0 for i in range(12)}
    return {**rec,'opaque_pixels':int((al==255).sum()),'partial_alpha_pixels':int(((al>0)&(al<255)).sum()),'alpha_values':list(map(int,np.unique(al))),'mean_brightness':round(float(L[on].mean()),4),'mean_saturation':round(float(S[on].mean()*100),4),'colour_count':len(count),'brightness_p10':round(float(np.quantile(L[on],.1)),4),'brightness_p90':round(float(np.quantile(L[on],.9)),4),'contrast_p90_p10':round(float(np.quantile(L[on],.9)-np.quantile(L[on],.1)),4),'mean_interior_brightness':round(float(L[interior].mean()),4) if interior.any() else None,'edge_pixels':int(edge.sum()),'dark_edge_share_pct':round(float(dark.sum()/edge.sum()*100),3),'dark_edge_rgb_median':np.median(rgb[dark],axis=0).astype(int).tolist() if dark.any() else None,'top_edge_colours':[{'rgb':list(map(int,k)),'pixels':int(v)} for k,v in edge_count.most_common(6)],'interior_lone_colour_pct':round(float(lone.sum()/max(1,interior.sum())*100),4),'chromatic_hue_distribution_pct':hues}

def image_record(root,r):
    im=Image.open(root/r['path']).convert('RGBA')
    if r['kind']=='walk_full':
        cw=im.height//2; i=r['frame']; im=im.crop(((i%4)*cw,(i//4)*cw,(i%4+1)*cw,(i//4+1)*cw))
    return im

def dump_json(path,obj): path.write_text(json.dumps(obj,indent=2),encoding='utf8')
def dump_csv(path,rows,columns=None):
    columns=columns or list(rows[0])
    with path.open('w',encoding='utf8',newline='') as fp:
        wr=csv.DictWriter(fp,fieldnames=columns,extrasaction='ignore'); wr.writeheader(); wr.writerows(rows)

def md_table(cols,rows):
    return '\n'.join(['| '+' | '.join(cols)+' |','| '+' | '.join(['---']*len(cols))+' |']+['| '+' | '.join(str(r[c]) for c in cols)+' |' for r in rows])+'\n'

def tile(im,label,scale=3,size=None):
    im=im.convert('RGBA'); sz=(im.width*scale,im.height*scale); cellw,cellh=size or (sz[0]+12,sz[1]+28)
    bg=Image.new('RGBA',(cellw,cellh),(45,55,58,255)); d=ImageDraw.Draw(bg)
    for yy in range(20,cellh,12):
        for xx in range(0,cellw,12):
            if (xx//12+yy//12)%2==0:d.rectangle((xx,yy,xx+11,yy+11),fill=(55,66,69,255))
    d.text((5,4),label,fill='white'); bg.alpha_composite(im.resize(sz,Image.Resampling.NEAREST),((cellw-sz[0])//2,20+(cellh-20-sz[1])//2)); return bg

def spreads(records,kind):
    rs=[r for r in records if r['kind']==kind]
    return {'brightness_spread':round(max(r['mean_brightness'] for r in rs)-min(r['mean_brightness'] for r in rs),4),'saturation_spread':round(max(r['mean_saturation'] for r in rs)-min(r['mean_saturation'] for r in rs),4),'colour_min':min(r['colour_count'] for r in rs),'colour_max':max(r['colour_count'] for r in rs)} if rs else None

def main():
    global FORMS, BASE_REL, FULL_MIRRORS
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--project',type=Path,required=True)
    before=parser.add_mutually_exclusive_group(required=True); before.add_argument('--before-audit',type=Path); before.add_argument('--before-manifest',type=Path)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--geometry-repairs',type=Path,help='Audited explicit artifact pixels, never a general shape exemption')
    parser.add_argument('--palette-reference',type=Path,help='Explicit JSON mapping of form to preserved corrected-palette reference')
    parser.add_argument('--forms',nargs='+',default=FORMS,help='Only report explicitly selected forms; default is the original nine')
    args=parser.parse_args(); project=args.project.resolve(); audit=(args.before_audit or args.before_manifest.parent).resolve(); original=audit/'originals'; output=args.output.resolve()
    FORMS=list(args.forms)
    BASE_REL={n:(f'docs/creatures/arena-starters-2026-10-07/{n}_arena_front_take2_clear.png' if n in ('kithflare','tallowroot','rimefin') else f'docs/creatures/arena-starters-2026-10-07/forms/{n}.png') for n in FORMS}
    FULL_MIRRORS={n:pairs for n,pairs in FULL_MIRRORS.items() if n in FORMS}
    manifest_path=(args.before_manifest or audit/'before-manifest.json').resolve()
    manifest=json.loads(manifest_path.read_text(encoding='utf-8-sig')); before_records=json.loads((audit/'before-metrics.json').read_text(encoding='utf-8-sig'))
    output.mkdir(parents=True,exist_ok=True); contacts=output/'contacts'; contacts.mkdir(exist_ok=True); gifs=output/'walk-previews'; gifs.mkdir(exist_ok=True)
    if project==original or output==project or output==original: raise ValueError('Output and originals must be separate from project root.')
    repairs=json.loads(args.geometry_repairs.read_text(encoding='utf8')) if args.geometry_repairs else {'repairs':[]}
    repair_pixels={r['path']:{tuple(xy) for xy in r['sheet_pixels_xy']} for r in repairs['repairs']}
    repair_operations={r['path']:r.get('operation','remove_artifact') for r in repairs['repairs']}
    if len(repair_pixels)!=len(repairs['repairs']):raise ValueError('One exact repair declaration per source sheet is required.')
    if any(op not in ('remove_artifact','fill_enclosed_crater') for op in repair_operations.values()):raise ValueError('Unknown geometry operation; no generic alpha exemption.')
    def alpha_valid(old,new,rel,frame=None):
        if old.shape!=new.shape:return False
        changed={(int(x),int(y)) for y,x in zip(*np.nonzero(old[:,:,3]!=new[:,:,3]))}
        expected=repair_pixels.get(rel,set())
        if frame is not None:
            cell=old.shape[0];ox=(frame%4)*cell;oy=(frame//4)*cell
            expected={(x-ox,y-oy) for x,y in expected if ox<=x<ox+cell and oy<=y<oy+cell}
        operation=repair_operations.get(rel,'remove_artifact')
        if operation=='fill_enclosed_crater':
            # Verify additions only, at the complete explicitly audited coordinate set.
            # Independently prove each original transparent component is enclosed within
            # its frame; this cannot exempt silhouette expansion or open background.
            if changed!=expected or not all(old[y,x,3]==0 and new[y,x,3]==255 for x,y in expected):return False
            # A repaired sheet still contains untouched frames. Exact empty diffs
            # in those frames are valid; they receive no geometry exemption.
            if not expected:return True
            cell=old.shape[0] if frame is not None else old.shape[0]//2
            height,width=old.shape[:2];remaining=set(expected)
            while remaining:
                start=next(iter(remaining));stack=[start];component=set();seen={start}
                while stack:
                    x,y=stack.pop();component.add((x,y))
                    if x%cell in (0,cell-1) or y%cell in (0,cell-1):return False
                    for dy in (-1,0,1):
                        for dx in (-1,0,1):
                            if dx==0 and dy==0:continue
                            xx,yy=x+dx,y+dy
                            if 0<=xx<width and 0<=yy<height and old[yy,xx,3]==0 and (xx,yy) not in seen:
                                seen.add((xx,yy));stack.append((xx,yy))
                if not component.issubset(expected):return False
                remaining-=component
            return geometry(old)['bbox']==geometry(new)['bbox'] and geometry(old)['foot_row']==geometry(new)['foot_row']
        return changed==expected and all(old[y,x,3]>0 and new[y,x,3]==0 for x,y in expected)
    overrides=json.loads(args.palette_reference.read_text(encoding='utf8')) if args.palette_reference else {}
    basepal={}; bases=[]
    for n,rel in BASE_REL.items():
        a=np.array(Image.open(original/rel).convert('RGBA')); palette_image=np.array(Image.open(args.palette_reference.parent/overrides[n]).convert('RGBA')) if n in overrides else a
        basepal[n]={tuple(c) for c in palette_image[:,:,:3][palette_image[:,:,3]>0]}
        bases.append({'form':n,'path':rel,'before_sha256':sha(original/rel),'after_sha256':sha(project/rel),'source_unchanged':sha(original/rel)==sha(project/rel)})
    # Recover exact expected frames from the fixed original record topology.
    after_records=[]; palette_checks=[]; alpha_checks=[]; small_pipeline_checks=[]
    sys.path.insert(0,str(project/'tools/arena'));from downscale import shrink,resample
    import ast
    builder=ast.parse((project/'tools/arena/build_small.py').read_text(encoding='utf8'))
    scales=next(ast.literal_eval(node.value) for node in builder.body if isinstance(node,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='SCALE' for t in node.targets))
    def small_of(im,n):
        scale=scales.get(n,1.0)
        return shrink(im,3) if scale==1.0 else resample(im,3.0/scale)
    def expected_small(r):
        n=r['form'];f=r['facing']
        if r['kind']=='small':
            src=FULL_MIRRORS.get(n,{}).get(f,f)
            im=small_of(Image.open(project/f'assets/sprites/arena/{n}/{src}.png').convert('RGBA'),n)
            return np.array(ImageOps.mirror(im) if src!=f else im)
        walk=project/f'docs/creatures/arena-starters-2026-10-07/walk/{n}_{f}_sheet.png';flip=not walk.exists()
        if flip:walk=project/f'docs/creatures/arena-starters-2026-10-07/walk/{n}_{WALK_MIRROR[f]}_sheet.png'
        sheet=Image.open(walk).convert('RGBA');cw=sheet.height//2;i=r['frame'];im=sheet.crop(((i%4)*cw,(i//4)*cw,(i%4+1)*cw,(i//4+1)*cw))
        cell=Image.open(project/f'assets/sprites/arena/{n}/{f}.png').size
        if im.size!=cell:im=im.resize(cell,Image.Resampling.NEAREST)
        im=small_of(im,n)
        return np.array(ImageOps.mirror(im) if flip else im)
    for r in before_records:
        im=image_record(project,r); a=np.array(im); on=a[:,:,3]>0
        after={k:r[k] for k in ('form','kind','facing','frame','path')}; after.update(measure(im)); after_records.append(after)
        pipeline_exact=None
        if r['kind'] in ('small','walk_small'):
            expected=expected_small(r);pipeline_exact=bool(expected.shape==a.shape and np.array_equal(expected,a))
            small_pipeline_checks.append({'form':r['form'],'kind':r['kind'],'facing':r['facing'],'frame':r['frame'],'path':r['path'],'rgba_exact_existing_pipeline':pipeline_exact})
        old=np.array(image_record(original,r)); equal_canvas=old.shape==a.shape; alpha_equal=equal_canvas and np.array_equal(old[:,:,3],a[:,:,3]); support_equal=equal_canvas and np.array_equal(old[:,:,3]>0,on)
        rgb=a[:,:,:3].astype(int); magenta=on&(rgb[:,:,0]>160)&(rgb[:,:,2]>120)&(rgb[:,:,1]<100); cols=collections.Counter(map(tuple,a[:,:,:3][on])); unsupported=sum(v for c,v in cols.items() if c not in basepal[r['form']])
        if r['kind'] in ('full','walk_full','small','walk_small'):
            palette_checks.append({'form':r['form'],'kind':r['kind'],'facing':r['facing'],'frame':r['frame'],'path':r['path'],'out_of_selected_reference_palette_pixels':unsupported,'out_of_selected_reference_palette_pct':round(100*unsupported/max(1,on.sum()),4),'magenta_pixels':int(magenta.sum()),'half_alpha_pixels':int(((a[:,:,3]>0)&(a[:,:,3]<255)).sum()),'exact_palette_pass':unsupported==0})
            alpha_checks.append({'form':r['form'],'kind':r['kind'],'facing':r['facing'],'frame':r['frame'],'path':r['path'],'geometry_valid_with_audited_repairs':bool(equal_canvas and r['foot_row']==after['foot_row'] and (pipeline_exact if pipeline_exact is not None else alpha_valid(old,a,r['path'],r['frame'] if r['kind']=='walk_full' else None))),'canvas_exact':equal_canvas,'alpha_bytes_exact':bool(alpha_equal),'support_exact':bool(support_equal),'foot_row_exact':r['foot_row']==after['foot_row'],'bbox_exact':r['bbox']==after['bbox'],'before_geometry':{k:r[k] for k in ('canvas','bbox','foot_row','painted_pixels')},'after_geometry':geometry(a),'hard_alpha_pass':after['partial_alpha_pixels']==0})
    dump_json(output/'after-metrics.json',after_records)
    metric_cols=['form','kind','facing','frame','mean_brightness','mean_saturation','colour_count','contrast_p90_p10','partial_alpha_pixels','foot_row','painted_pixels','edge_pixels','dark_edge_share_pct','interior_lone_colour_pct','path']
    dump_csv(output/'after-metrics.csv',after_records,metric_cols); dump_json(output/'palette-and-alpha-checks.json',{'approved_bases':bases,'palette':palette_checks,'geometry':alpha_checks})
    file_checks=[]
    for r in manifest['files']:
        p=project/r['path']; q=original/r['path']; oldhash=sha(q); currenthash=sha(p) if p.exists() else None
        protected_png=('/small/' not in r['path'] and not r['path'].startswith('assets/sprites/arena/') and '/walk/' not in r['path'])
        full_or_walk=('/small/' not in r['path'] and r['path'].startswith('assets/sprites/arena/')) or '/walk/' in r['path']
        source_alpha_exact=None; source_canvas_exact=None; source_alpha_valid=None
        if full_or_walk and p.exists():
            olda=np.array(Image.open(q).convert('RGBA')); newa=np.array(Image.open(p).convert('RGBA')); source_canvas_exact=olda.shape==newa.shape; source_alpha_exact=source_canvas_exact and np.array_equal(olda[:,:,3],newa[:,:,3]); source_alpha_valid=alpha_valid(olda,newa,r['path'])
        file_checks.append({'path':r['path'],'original_snapshot_matches_manifest':oldhash==r['sha256'],'before_sha256':r['sha256'],'after_sha256':currenthash,'changed':currenthash!=r['sha256'],'immutable_source_png':protected_png,'immutable_source_pass':not protected_png or currenthash==r['sha256'],'full_facing_or_walk_sheet':full_or_walk,'whole_source_alpha_valid_with_audited_repairs':source_alpha_valid,'whole_source_canvas_exact':source_canvas_exact,'whole_source_alpha_exact':bool(source_alpha_exact) if source_alpha_exact is not None else None})
    code_checks=[]
    for r in manifest['protected_code_and_tools']:
        p=project/r['path']; currenthash=sha(p) if p.exists() else None; allowed=r['path']=='tools/arena/build_small.py' or r['path']==manifest.get('authorized_report_tool_exception')
        code_checks.append({'path':r['path'],'before_sha256':r['sha256'],'after_sha256':currenthash,'changed':currenthash!=r['sha256'],'authorized_exception':allowed,'guard_pass':allowed or currenthash==r['sha256']})
    dump_json(output/'original-files-and-protected-code-checks.json',{'images':file_checks,'existing_code_and_tools':code_checks})
    mirror_checks=[]
    for n,pairs in FULL_MIRRORS.items():
        for dst,src in pairs.items():
            for kind,prefix in (('full',''),('small','small/')):
                a=np.array(Image.open(project/f'assets/sprites/arena/{n}/{prefix}{dst}.png').convert('RGBA')); b=np.array(ImageOps.mirror(Image.open(project/f'assets/sprites/arena/{n}/{prefix}{src}.png').convert('RGBA')))
                mirror_checks.append({'form':n,'kind':kind,'facing':dst,'mirrors':src,'rgba_exact':bool(a.shape==b.shape and np.array_equal(a,b))})
    walks=project/'docs/creatures/arena-starters-2026-10-07/walk'
    walk_forms={r['form'] for r in before_records if r['kind']=='walk_small'}
    for n in FORMS:
        for f in FACINGS:
            if (walks/f'{n}_{f}_sheet.png').exists(): continue
            source=WALK_MIRROR.get(f)
            if not source or not (walks/f'{n}_{source}_sheet.png').exists(): continue
            for i in range(8):
                a=np.array(Image.open(project/f'assets/sprites/arena/{n}/small/walk_{f}_f{i}.png').convert('RGBA')); b=np.array(ImageOps.mirror(Image.open(project/f'assets/sprites/arena/{n}/small/walk_{source}_f{i}.png').convert('RGBA')))
                mirror_checks.append({'form':n,'kind':'walk_small','facing':f,'mirrors':source,'frame':i,'rgba_exact':bool(a.shape==b.shape and np.array_equal(a,b))})
    dump_json(output/'mirror-checks.json',mirror_checks)
    after_index={(r['form'],r['kind'],r['facing'],r['frame']):r for r in after_records}; before_index={(r['form'],r['kind'],r['facing'],r['frame']):r for r in before_records}
    rows=[]
    for n in FORMS:
        for f in FACINGS:
            row={'form':n,'facing':f}
            for kind in ('full','small'):
                br=before_index[n,kind,f,None]; ar=after_index[n,kind,f,None]
                for field in ('mean_brightness','mean_saturation','colour_count','dark_edge_share_pct','contrast_p90_p10'):
                    row[f'{kind}_{field}_before']=br[field]; row[f'{kind}_{field}_after']=ar[field]
            rows.append(row)
    dump_csv(output/'before-after-facings.csv',rows)
    text='# Arena facing colours: before / after\n\nBrightness uses .299R+.587G+.114B; saturation is mean HSV percent. All measurements exclude transparent pixels. Each row compares the exact original and installed facing.\n\n'
    for n in FORMS:
        text+=f'## {n.title()}\n\n'
        display=[]
        for row in [r for r in rows if r['form']==n]:
            display.append({'Facing':row['facing'],'Full brightness':f"{row['full_mean_brightness_before']:.2f} → {row['full_mean_brightness_after']:.2f}",'Full saturation%':f"{row['full_mean_saturation_before']:.2f} → {row['full_mean_saturation_after']:.2f}",'Full colours':f"{row['full_colour_count_before']} → {row['full_colour_count_after']}",'Small brightness':f"{row['small_mean_brightness_before']:.2f} → {row['small_mean_brightness_after']:.2f}",'Small saturation%':f"{row['small_mean_saturation_before']:.2f} → {row['small_mean_saturation_after']:.2f}",'Small colours':f"{row['small_colour_count_before']} → {row['small_colour_count_after']}"})
        text+=md_table(list(display[0]),display)+'\n'
    (output/'before-after-facings.md').write_text(text,encoding='utf8')
    spread_rows=[]; spread_detail=[]
    for n in FORMS:
        br=[r for r in before_records if r['form']==n]; ar=[r for r in after_records if r['form']==n]
        row={'Form':n.title()}
        for kind in ('full','small'):
            b=spreads(br,kind); a=spreads(ar,kind); row[kind.title()+' brightness spread']=f"{b['brightness_spread']:.2f} → {a['brightness_spread']:.2f}"; row[kind.title()+' saturation spread']=f"{b['saturation_spread']:.2f} → {a['saturation_spread']:.2f}"; row[kind.title()+' colour range']=f"{b['colour_min']}–{b['colour_max']} → {a['colour_min']}–{a['colour_max']}"; row[kind.title()+' brightness <8']=a['brightness_spread']<8
        spread_rows.append(row)
        for kind in ('base','full','small','walk_full','walk_small'):
            b=spreads(br,kind); a=spreads(ar,kind)
            if b: spread_detail.append({'form':n,'kind':kind,'before':b,'after':a})
    dump_json(output/'before-after-spreads.json',spread_detail); dump_csv(output/'before-after-spreads.csv',spread_rows)
    (output/'before-after-spreads.md').write_text('# Per-form spread, full and game-size art\n\n'+md_table(list(spread_rows[0]),spread_rows)+'\nThe pipeline majority downscale can change colour proportions, so full and small means are measured separately. Averages are diagnostics, not approval of anatomy or texture. Later approved evolutions remain deliberately darker.\n',encoding='utf8')
    walk_stats=[]
    for r in before_records:
        if r['kind'] not in ('walk_full','walk_small'): continue
        ar=after_index[r['form'],r['kind'],r['facing'],r['frame']]; row={k:r[k] for k in ('form','kind','facing','frame','path')}
        for field in ('mean_brightness','mean_saturation','colour_count','contrast_p90_p10','dark_edge_share_pct','foot_row','painted_pixels'):
            row[field+'_before']=r[field]; row[field+'_after']=ar[field]
        walk_stats.append(row)
    dump_csv(output/'before-after-walk-source-frames.csv',[r for r in walk_stats if r['kind']=='walk_full']); dump_csv(output/'before-after-walk-game-frames.csv',[r for r in walk_stats if r['kind']=='walk_small']); dump_json(output/'before-after-walk-frames.json',walk_stats)
    # The requested 9 facing sheets: original row over installed row, actual small pixels at3x.
    for n in FORMS:
        paths=[f'assets/sprites/arena/{n}/small/{f}.png' for f in FACINGS]; ims=[Image.open(root/p).convert('RGBA') for root in (original,project) for p in paths]; size=(max(i.width for i in ims)*3+12,max(i.height for i in ims)*3+28)
        sheet=Image.new('RGBA',(size[0]*8,size[1]*2))
        for r,label in enumerate(('Before','After')):
            for c,f in enumerate(FACINGS): sheet.alpha_composite(tile(ims[r*8+c],f'{label} {f}',3,size),(c*size[0],r*size[1]))
        sheet.convert('RGB').save(contacts/f'{n}-facings-before-after-game3x.png')
    for n in FORMS:
        source_facings=[f for f in FACINGS if (walks/f'{n}_{f}_sheet.png').exists()]
        for f in source_facings:
            paths=[f'assets/sprites/arena/{n}/small/walk_{f}_f{i}.png' for i in range(8)]; ims=[Image.open(root/p).convert('RGBA') for root in (original,project) for p in paths]; size=(max(i.width for i in ims)*3+12,max(i.height for i in ims)*3+28); sheet=Image.new('RGBA',(size[0]*8,size[1]*2)); animation=[]
            for i in range(8):
                before_tile=tile(ims[i],f'Before {f} f{i}',3,size); after_tile=tile(ims[i+8],f'After {f} f{i}',3,size); sheet.alpha_composite(before_tile,(i*size[0],0)); sheet.alpha_composite(after_tile,(i*size[0],size[1])); frame=Image.new('RGBA',(size[0]*2,size[1])); frame.alpha_composite(before_tile,(0,0)); frame.alpha_composite(after_tile,(size[0],0)); animation.append(frame.convert('RGB'))
            sheet.convert('RGB').save(contacts/f'{n}-walk-{f}-before-after-game3x.png'); animation[0].save(gifs/f'{n}-walk-{f}-before-after-game3x.gif',save_all=True,append_images=animation[1:],duration=140,loop=0,optimize=False,disposal=2)
    # All 9 approved family takes vs their south game sprites. It illustrates colour identity without equalizing stages.
    family_ims=[]
    for n in FORMS:
        family_ims.extend([Image.open(original/f'assets/sprites/arena/{n}/small/s.png').convert('RGBA'),Image.open(project/f'assets/sprites/arena/{n}/small/s.png').convert('RGBA')])
    size=(max(i.width for i in family_ims)*3+12,max(i.height for i in family_ims)*3+28); family=Image.new('RGBA',(size[0]*6,size[1]*((len(FORMS)+2)//3)))
    for line in range((len(FORMS)+2)//3):
        for stage in range(3):
            if line*3+stage>=len(FORMS):break
            n=FORMS[line*3+stage]
            for state,label in enumerate(('Before','After')): family.alpha_composite(tile(family_ims[(line*3+stage)*2+state],f'{n} {label}',3,size),((stage*2+state)*size[0],line*size[1]))
    family.convert('RGB').save(contacts/('all-nine-family-before-after-south-game3x.png' if len(FORMS)==9 else 'selected-family-before-after-south-game3x.png'))
    full_geometry=[c for c in alpha_checks if c['kind'] in ('full','walk_full')]; small_geometry=[c for c in alpha_checks if c['kind'] in ('small','walk_small')]
    full_geometry_pass=all(c['canvas_exact'] and c['alpha_bytes_exact'] and c['support_exact'] and c['foot_row_exact'] and c['bbox_exact'] for c in full_geometry)
    summary={'metric_records':len(after_records),'original_pngs':len(file_checks),'protected_code_and_tools':len(code_checks),'existing_code_guard_pass':all(c['guard_pass'] for c in code_checks),'approved_bases_unchanged':all(c['source_unchanged'] for c in bases),'original_snapshot_hashes_pass':all(c['original_snapshot_matches_manifest'] for c in file_checks),'immutable_source_pngs_pass':all(c['immutable_source_pass'] for c in file_checks),'full_and_walk_frame_geometry_exact':full_geometry_pass,'full_facing_and_whole_walk_sheet_alpha_exact':all(c['whole_source_canvas_exact'] and c['whole_source_alpha_exact'] for c in file_checks if c['full_facing_or_walk_sheet']),'small_canvases_and_foot_rows_exact':all(c['canvas_exact'] and c['foot_row_exact'] for c in small_geometry),'exact_selected_reference_palette_pass':all(c['exact_palette_pass'] for c in palette_checks),'hard_alpha_pass':all(c['half_alpha_pixels']==0 for c in palette_checks),'magenta_pixels_total':sum(c['magenta_pixels'] for c in palette_checks),'explicit_mirrors_exact':all(c['rgba_exact'] for c in mirror_checks),'mirror_checks':len(mirror_checks),'small_geometry_changes':[c for c in small_geometry if not(c['alpha_bytes_exact'] and c['bbox_exact'] and c['foot_row_exact'])],'full_spreads_under8':all(r['after']['brightness_spread']<8 for r in spread_detail if r['kind']=='full'),'small_spreads_under8':all(r['after']['brightness_spread']<8 for r in spread_detail if r['kind']=='small'),'changes':[r['path'] for r in file_checks if r['changed']],'engine_checked_by_this_tool':False,'gif_preview_frame_ms':140}
    dump_json(output/'existing-downscale-pipeline-checks.json',small_pipeline_checks)
    summary['palette_reference_overrides']=overrides
    summary['palette_reference_sha256']=sha(args.palette_reference) if args.palette_reference else None
    summary['game_pngs_exact_existing_pipeline']=all(r['rgba_exact_existing_pipeline'] for r in small_pipeline_checks)
    summary['game_pngs_pipeline_checked']=len(small_pipeline_checks)
    summary['full_and_walk_frame_geometry_valid']=all(c['geometry_valid_with_audited_repairs'] for c in full_geometry)
    summary['full_facing_and_whole_walk_sheet_alpha_valid']=all(c['whole_source_canvas_exact'] and c['whole_source_alpha_valid_with_audited_repairs'] for c in file_checks if c['full_facing_or_walk_sheet'])
    summary['audited_geometry_repairs']=repairs
    protected_assets=[]
    for r in manifest.get('protected_assets',[]):
        currenthash=sha(project/r['path']) if (project/r['path']).exists() else None
        protected_assets.append({'path':r['path'],'before_sha256':r['sha256'],'after_sha256':currenthash,'unchanged':currenthash==r['sha256']})
    dump_json(output/'protected-other-arena-assets.json',protected_assets)
    summary['other_arena_assets_unchanged']=all(r['unchanged'] for r in protected_assets)
    summary['other_arena_assets_checked']=len(protected_assets)
    summary['structural_and_palette_pass']=all(summary[k] for k in ('existing_code_guard_pass','approved_bases_unchanged','original_snapshot_hashes_pass','immutable_source_pngs_pass','full_and_walk_frame_geometry_valid','full_facing_and_whole_walk_sheet_alpha_valid','small_canvases_and_foot_rows_exact','exact_selected_reference_palette_pass','hard_alpha_pass','explicit_mirrors_exact','other_arena_assets_unchanged','game_pngs_exact_existing_pipeline')) and summary['magenta_pixels_total']==0
    dump_json(output/'consistency-check-summary.json',summary)
    report='# Installed arena consistency report\n\n'+('Structural/palette checks passed using explicit selected references and current per-form scale.' if summary['structural_and_palette_pass'] else 'One or more structural/palette checks failed; inspect the JSON proof before accepting this output.')+'\n\n'+md_table(['Check','Result'],[{'Check':k,'Result':str(summary[k])} for k in ('original_pngs','metric_records','protected_code_and_tools','existing_code_guard_pass','approved_bases_unchanged','full_and_walk_frame_geometry_exact','full_facing_and_whole_walk_sheet_alpha_exact','small_canvases_and_foot_rows_exact','exact_selected_reference_palette_pass','hard_alpha_pass','magenta_pixels_total','explicit_mirrors_exact','full_spreads_under8','small_spreads_under8')])+'\nAny explicitly audited artifact removals are validated pixel by pixel in the geometry-valid fields; exact-alpha fields still report false for those frames. The report reads the actual installed full/small PNGs, not candidate calculations. It does not run Godot; attach the separate native import/playback logs and captures. GIFs show the eight saved game frames at140ms per frame for inspection, and do not assert game playback timing. Small support/bbox changes caused by the corrected mirror/downscale pipeline are recorded individually in `consistency-check-summary.json`; they are not silently claimed to be exact original alpha. Intended spikes, sparks and barbels are preserved; only separately audited generated curl pixels are removed.\n\nSee `before-after-facings.md` and `.csv`, `before-after-spreads.md`/JSON/CSV, two walk-frame CSVs, selected facing contact sheets, source walk contact sheets/GIFs, the family contact and byte/hash proof.\n'
    (output/'REPORT.md').write_text(report,encoding='utf8')
    print(json.dumps({k:summary[k] for k in ('structural_and_palette_pass','full_and_walk_frame_geometry_exact','full_facing_and_whole_walk_sheet_alpha_exact','small_canvases_and_foot_rows_exact','exact_selected_reference_palette_pass','explicit_mirrors_exact','full_spreads_under8','small_spreads_under8','magenta_pixels_total','metric_records','original_pngs')},indent=2))
    return 0 if summary['structural_and_palette_pass'] else 2

if __name__=='__main__': sys.exit(main())

