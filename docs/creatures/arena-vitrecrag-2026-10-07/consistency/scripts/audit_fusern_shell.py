"""Read-only Fusern shell-material comparison against preserved original art.

Usage (candidate and installed roots use the same interface):
  python audit_fusern_shell.py --before-audit /path/to/source-audit \
    --image-root /path/to/candidate-or-project --output /path/to/shell-review
Reads original PNGs under <before-audit>/originals and the exact form/kind/facing/
frame/path topology in before-metrics.json. It writes JSON/CSV/Markdown proof,
fixed original ROI masks and before/after contact sheets into --output only.
No redraw, recolour, resize of source files, engine process, or paid service.

The fixed diagnostic ROI is the upper52% of the ORIGINAL painted bounding box,
excluding its external4-neighbour silhouette edge. This is a comparable upper-
dome ROI, NOT a semantic segmentation of the whole shell or every brick. It
excludes eyes/legs and most lower gray armor. Dark L<=60 pixels are measured as
joint-or-shadow, not claimed to be an exact count of mortar topology. Contacts
use nearest-neighbour enlargement of the saved pixels only. Shape/alpha guards
flag any candidate departure from the original; the ROI never adapts to a redraw.
"""
from pathlib import Path
import argparse,json,csv,collections,hashlib,sys
import numpy as np
from PIL import Image,ImageDraw
FACINGS=['s','se','e','ne','n','nw','w','sw'];GOOD=['s','se','w','sw'];PALE=['e','ne','n','nw']

def lum(rgb):return rgb[...,0]*.299+rgb[...,1]*.587+rgb[...,2]*.114

def frame(root,r):
    im=Image.open(root/r['path']).convert('RGBA')
    if r['kind']=='walk_full':
        cw=im.height//2;i=r['frame'];im=im.crop(((i%4)*cw,(i//4)*cw,(i%4+1)*cw,(i//4+1)*cw))
    return im

def mask(original):
    a=np.array(original.convert('RGBA'));on=a[:,:,3]>0;y,x=np.nonzero(on);x0,y0,x1,y1=int(x.min()),int(y.min()),int(x.max()+1),int(y.max()+1);cut=y0+int(round((y1-y0)*.52));yy,xx=np.indices(on.shape);pad=np.pad(on,1);edge=on&~(pad[:-2,1:-1]&pad[2:,1:-1]&pad[1:-1,:-2]&pad[1:-1,2:]);roi=on&(yy<cut)&~edge
    return roi,[x0,y0,x1,cut]

def measure(im,roi):
    a=np.array(im.convert('RGBA'));on=a[:,:,3]>0;rgb=a[:,:,:3].astype(float);L=lum(rgb);mx=rgb.max(2);mn=rgb.min(2);sat=np.divide(mx-mn,mx,out=np.zeros_like(mx),where=mx>0);warm=(rgb[:,:,0]>rgb[:,:,1]*1.3)&(rgb[:,:,1]>rgb[:,:,2]*1.15)&(sat>.35);brick=roi&warm;br=roi&warm&(L>=130);pale=roi&warm&(L>=165);dark=roi&(L<=60);cols=collections.Counter(map(tuple,a[:,:,:3][roi]));dominant=cols.most_common(1)[0];difs=[]
    for dy,dx in ((0,1),(1,0)):
        pa=roi[:roi.shape[0]-dy or None,:roi.shape[1]-dx or None];pb=roi[dy:,dx:];la=L[:L.shape[0]-dy or None,:L.shape[1]-dx or None];lb=L[dy:,dx:];m=pa&pb;difs.extend(abs(la[m]-lb[m]).tolist())
    return {'whole_mean_brightness':round(float(L[on].mean()),4),'dome_roi_pixels':int(roi.sum()),'dome_mean_brightness':round(float(L[roi].mean()),4),'warm_brick_pixels':int(brick.sum()),'warm_brick_mean_brightness':round(float(L[brick].mean()),4) if brick.any() else None,'warm_brick_saturation_pct':round(float(sat[brick].mean()*100),4) if brick.any() else None,'bright_orange_L130_roi_pct':round(float(br.sum()/roi.sum()*100),4),'pale_orange_L165_roi_pct':round(float(pale.sum()/roi.sum()*100),4),'dark_joint_or_shadow_L60_roi_pct':round(float(dark.sum()/roi.sum()*100),4),'dominant_rgb':list(map(int,dominant[0])),'dominant_rgb_roi_pct':round(float(dominant[1]/roi.sum()*100),4),'local_adjacent_luminance_difference':round(float(np.mean(difs)),4),'roi_colour_count':len(cols)}

def tile(im,label,metrics,scale,size):
    im=im.convert('RGBA');w,h=size;bg=Image.new('RGBA',size,(45,55,58,255));d=ImageDraw.Draw(bg)
    for y in range(42,h,12):
        for x in range(0,w,12):
            if (x//12+y//12)%2==0:d.rectangle((x,y,x+11,y+11),fill=(55,66,69,255))
    d.text((5,4),label,fill='white');d.text((5,18),f"dome {metrics['dome_mean_brightness']:.1f}; bright {metrics['bright_orange_L130_roi_pct']:.1f}%",fill='white');d.text((5,30),f"dark joint/shadow {metrics['dark_joint_or_shadow_L60_roi_pct']:.1f}%",fill='white');shown=im.resize((im.width*scale,im.height*scale),Image.Resampling.NEAREST);bg.alpha_composite(shown,((w-shown.width)//2,44+(h-44-shown.height)//2));return bg

def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--before-audit',type=Path,required=True);ap.add_argument('--image-root',type=Path,required=True);ap.add_argument('--output',type=Path,required=True);args=ap.parse_args();audit=args.before_audit.resolve();original=audit/'originals';current=args.image_root.resolve();out=args.output.resolve();out.mkdir(parents=True,exist_ok=True);md=out/'roi-masks';md.mkdir(exist_ok=True);contacts=out/'contacts';contacts.mkdir(exist_ok=True)
    if out==current or out==original:raise ValueError('Evidence output must differ from image and original roots.')
    records=[r for r in json.loads((audit/'before-metrics.json').read_text(encoding='utf-8-sig')) if r['form']=='fusern'];rows=[];checks=[];missing=[];ims={};metricindex={}
    for r in records:
        p=current/r['path']
        if not p.exists():missing.append({k:r[k] for k in ('kind','facing','frame','path')});continue
        old=frame(original,r);new=frame(current,r);oa=np.array(old);na=np.array(new);roi,box=mask(old);samecanvas=oa.shape==na.shape;alphaexact=samecanvas and np.array_equal(oa[:,:,3],na[:,:,3]);check={k:r[k] for k in ('kind','facing','frame','path')};check.update({'canvas_exact':samecanvas,'alpha_bytes_exact':bool(alphaexact),'fixed_original_roi':box});checks.append(check)
        if not samecanvas:raise ValueError(f"Canvas changed: {r['kind']} {r['facing']} {r['frame']}")
        b=measure(old,roi);a=measure(new,roi);row={k:r[k] for k in ('form','kind','facing','frame','path')};row.update({'dome_bbox_original':box,'before':b,'after':a,'alpha_bytes_exact':bool(alphaexact)});rows.append(row);key=(r['kind'],r['facing'],r['frame']);ims[key]=(old,new);metricindex[key]=(b,a)
        if r['kind'] in ('base','full','walk_full'):
            fr='' if r['frame'] is None else f"-f{r['frame']}";Image.fromarray((roi*255).astype('uint8')).save(md/f"{r['kind']}-{r['facing']}{fr}.png")
    fullrows=[r for r in rows if r['kind']=='full'];required=[r for r in records if r['kind'] in ('base','full','walk_full')];missing_required=[r for r in missing if r['kind'] in ('base','full','walk_full')];summary={'method':__doc__,'original_root':str(original),'image_root':str(current),'records_evaluated':len(rows),'source_rows_required':len(required),'missing_paths':missing,'missing_required_source_rows':missing_required,'all_full_alpha_exact':all(r['alpha_bytes_exact'] for r in checks if r['kind'] in ('base','full','walk_full')) and not missing_required,'small_alpha_changes':[r for r in checks if r['kind'] in ('small','walk_small') and not r['alpha_bytes_exact']],'records':rows}
    (out/'fusern-shell-before-after.json').write_text(json.dumps(summary,indent=2),encoding='utf8')
    flat=[]
    for r in rows:
        f={k:r[k] for k in ('form','kind','facing','frame','path','alpha_bytes_exact')};f['dome_bbox_original']=json.dumps(r['dome_bbox_original'])
        for state in ('before','after'):
            for k,v in r[state].items():f[k+'_'+state]=json.dumps(v) if isinstance(v,list) else v
        flat.append(f)
    with (out/'fusern-shell-before-after.csv').open('w',encoding='utf8',newline='') as fp:
        wr=csv.DictWriter(fp,fieldnames=list(flat[0]));wr.writeheader();wr.writerows(flat)
    # Good original dark-brick references and pale original facings are reviewed separately.
    for group,fs in (('dark-brick-references',GOOD),('pale-original-facings',PALE)):
        examples=[ims['full',f,None][state] for state in (0,1) for f in fs];size=(max(i.width for i in examples)*2+12,max(i.height for i in examples)*2+56);sheet=Image.new('RGBA',(size[0]*4,size[1]*2))
        for row,label in enumerate(('Before','Current')):
            for col,f in enumerate(fs):sheet.alpha_composite(tile(ims['full',f,None][row],f'{label} {f}',metricindex['full',f,None][row],2,size),(col*size[0],row*size[1]))
        sheet.convert('RGB').save(contacts/f'fusern-{group}-before-current-full2x.png')
    # Complete labelled facing+base3x3 grids, current beside original in separate files.
    keys=[('base','base',None)]+[('full',f,None) for f in FACINGS];size=(max(im.width for k in keys for im in ims[k])*2+12,max(im.height for k in keys for im in ims[k])*2+56)
    for state,label in ((0,'before'),(1,'current')):
        sheet=Image.new('RGBA',(size[0]*3,size[1]*3))
        for j,k in enumerate(keys):sheet.alpha_composite(tile(ims[k][state],'BASE' if k[0]=='base' else k[1],metricindex[k][state],2,size),((j%3)*size[0],(j//3)*size[1]))
        sheet.convert('RGB').save(contacts/f'fusern-base-and8facings-{label}-full2x.png')
    for f in ('s','se','e','ne','n'):
        keys=[('walk_full',f,i) for i in range(8)]
        if any(k not in ims for k in keys):continue
        size=(max(im.width for k in keys for im in ims[k])*2+12,max(im.height for k in keys for im in ims[k])*2+56);sheet=Image.new('RGBA',(size[0]*8,size[1]*2))
        for state,label in ((0,'Before'),(1,'Current')):
            for col,k in enumerate(keys):sheet.alpha_composite(tile(ims[k][state],f'{label} {f} f{k[2]}',metricindex[k][state],2,size),(col*size[0],state*size[1]))
        sheet.convert('RGB').save(contacts/f'fusern-walk-{f}-before-current-full2x.png')
    cols=['Facing','Dome mean before→current','Bright orange% before→current','Pale orange% before→current','Dark joint/shadow% before→current'];table=['| '+' | '.join(cols)+' |','| '+' | '.join(['---']*len(cols))+' |']
    base=next(r for r in rows if r['kind']=='base')
    for r in [base]+fullrows:
        b,a=r['before'],r['after'];vs=[r['facing'],f"{b['dome_mean_brightness']:.2f} → {a['dome_mean_brightness']:.2f}",f"{b['bright_orange_L130_roi_pct']:.2f} → {a['bright_orange_L130_roi_pct']:.2f}",f"{b['pale_orange_L165_roi_pct']:.2f} → {a['pale_orange_L165_roi_pct']:.2f}",f"{b['dark_joint_or_shadow_L60_roi_pct']:.2f} → {a['dark_joint_or_shadow_L60_roi_pct']:.2f}"];table.append('| '+' | '.join(vs)+' |')
    text='# Fusern fixed upper-dome material comparison\n\nThis is the upper52% of the original painted bbox, excluding its silhouette edge. It is a comparable upper-dome diagnostic, **not semantic segmentation of the whole shell**. The mask remains fixed to the original, and alpha/canvas differences are reported. Bright warm orange uses L>=130; pale warm orange L>=165; dark joint-or-shadow uses L<=60. Warm RGB must satisfy R>1.3G, G>1.15B and HSV saturation>.35. Dark-pixel share and adjacent contrast do not prove that missing mortar geometry has been redrawn.\n\n'+'\n'.join(table)+f"\n\nEvaluated {len(rows)} frame/view records; original-source alpha exact: {summary['all_full_alpha_exact']}; missing required sources: {len(missing_required)}. All CSV/JSON data are calculated from the saved pixels under the declared current image root. This tool never edits source art, invokes generation, or calls the engine. Contacts expose dark original s/se/w/sw references and pale original e/ne/n/nw separately.\n"
    (out/'README.md').write_text(text,encoding='utf8');print(json.dumps({'output':str(out),'records_evaluated':len(rows),'source_rows_required':len(required),'missing_required_sources':len(missing_required),'all_full_alpha_exact':summary['all_full_alpha_exact']},indent=2));return 0 if summary['all_full_alpha_exact'] else 2
if __name__=='__main__':sys.exit(main())
