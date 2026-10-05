from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib
D=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/coalcrest-fin-review")
a=np.array(Image.open(D/"front-before.png").convert("RGBA"))
shape=np.array(Image.open(D/"coalcrest-front-fin-finished.png").convert("RGBA"))
small=np.array(Image.open(D/"fin-only-mask.png").convert("L"))>127
mask=np.zeros(a.shape[:2],bool);mask[:48,54:118]=small
extra=(shape[:,:,3]>0)&(a[:,:,3]==0)&mask
anchor=np.array([96.,65.])
variants=[]
for index in [0,1]:
    candidate=a.copy()
    for y,x in np.argwhere(extra):
        vec=np.array([float(x),float(y)])-anchor
        sy=16.+max(0.,16.-y)*(.5 if index==0 else 0.)
        t=(sy-anchor[1])/vec[1]
        sample=anchor+vec*t
        sx=int(round(sample[0]));syi=int(round(sample[1]))
        if vec[0] > 0:
            # The right rim must sample the sail, never the separate head fragment.
            row=a[syi,54:102]
            xs=np.flatnonzero((row[:,3]>0)&(row[:,0]>=row[:,1])&(row[:,1]>=row[:,2]))+54
            sx=int(xs[np.argmin(abs(xs-sx))])
        else:
            for step in range(25):
                if a[syi,sx,3]>0:break
                pos=anchor+vec*max(.35,t-step*.02);sx,syi=int(round(pos[0])),int(round(pos[1]))
        assert a[syi,sx,3]>0,(x,y,sx,syi)
        candidate[y,x]=a[syi,sx]
    variants.append(Image.fromarray(candidate))
variants[0].save(D/"fin-matched-native.png")
canvas=Image.new("RGB",(480,176),(66,72,74))
for i,(im,label) in enumerate([(Image.fromarray(a),"ORIGINAL"),(variants[0],"CONTINUED ORIGINAL RIBS"),(variants[1],"RIM PROJECTION")]):
    canvas.paste(im,(i*160,8),im);ImageDraw.Draw(canvas).text((i*160+3,163),label,fill="white")
canvas.resize((1440,528),Image.Resampling.NEAREST).save(D/"fin-matched-options.png")
out=np.array(variants[0]);changed=np.any(out!=a,axis=2)
audit={"dimensions":variants[0].size,"changed_pixels":int(changed.sum()),"changed_outside_mask":int(changed[~mask].sum()),"existing_visible_pixels_changed":int(changed[a[:,:,3]>0].sum()),"new_visible_pixels":int(extra.sum()),"generated_outline_preserved":bool(np.all(out[:,:,3][a[:,:,3]==0]==shape[:,:,3][a[:,:,3]==0])),"top_clearance":variants[0].getbbox()[1],"material_source":"Original sail only; radial continuation from anchor (96,65), reflected source rim y16 with 0.5 depth factor; nearest native sampling","sha256":hashlib.sha256((D/"fin-matched-native.png").read_bytes()).hexdigest()}
assert audit["changed_outside_mask"]==0 and audit["existing_visible_pixels_changed"]==0 and audit["generated_outline_preserved"]
(D/"fin-matched-audit.json").write_text(json.dumps(audit,indent=2));print(json.dumps(audit))
