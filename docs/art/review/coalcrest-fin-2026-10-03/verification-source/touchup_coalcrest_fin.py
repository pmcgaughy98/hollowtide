from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import numpy as np,json,hashlib
D=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/coalcrest-fin-review")
a=np.array(Image.open(D/"front-before.png").convert("RGBA"))
shape=np.array(Image.open(D/"fin-matched-native.png").convert("RGBA"))
small=np.array(Image.open(D/"fin-only-mask.png").convert("L"))>127
mask=np.zeros(a.shape[:2],bool);mask[:48,54:118]=small
extra=(shape[:,:,3]>0)&(a[:,:,3]==0)&mask
target_inner=np.array(Image.fromarray((shape[:,:,3]>0).astype("uint8")*255).filter(ImageFilter.MinFilter(3)))>0
source_inner=np.array(Image.fromarray((a[:,:,3]>0).astype("uint8")*255).filter(ImageFilter.MinFilter(5)))>0
source_inner[:18]=False;source_inner[46:]=False;source_inner[:,:54]=False;source_inner[:,102:]=False
source_inner &= (a[:,:,0]>=a[:,:,1])&(a[:,:,1]>=a[:,:,2])
ys,xs=np.nonzero(source_inner)
candidate=shape.copy();anchor=np.array([96.,65.]);touched=0
for y,x in np.argwhere(extra&target_inner):
    vec=np.array([float(x),float(y)])-anchor
    sy=16.+max(0.,16.-y)*.5
    sample=anchor+vec*((sy-anchor[1])/vec[1])
    distances=(xs-sample[0])**2+(ys-sample[1])**2
    i=distances.argmin()
    color=a[ys[i],xs[i]]
    if not np.array_equal(candidate[y,x],color):touched+=1
    candidate[y,x]=color
out=Image.fromarray(candidate);out.save(D/"fin-final-touchup.png")
canvas=Image.new("RGB",(320,176),(66,72,74))
for i,(im,label) in enumerate([(Image.fromarray(shape),"BEFORE TOUCHUP"),(out,"FIN TEXTURE TOUCHUP")]):
    canvas.paste(im,(i*160,8),im);ImageDraw.Draw(canvas).text((i*160+3,163),label,fill="white")
canvas.resize((960,528),Image.Resampling.NEAREST).save(D/"fin-touchup-comparison.png")
changed=np.any(candidate!=a,axis=2)
audit={"touched_new_pixels":touched,"changed_from_original":int(changed.sum()),"existing_visible_pixels_changed":int(changed[a[:,:,3]>0].sum()),"changed_outside_mask":int(changed[~mask].sum()),"approved_outline_exact":bool(np.all(candidate[:,:,3]==shape[:,:,3])),"top_clearance":out.getbbox()[1],"sha256":hashlib.sha256((D/"fin-final-touchup.png").read_bytes()).hexdigest(),"method":"Original membrane/rib material, nearest native samples from 2px inside authored sail; outer outline kept exact"}
assert audit["existing_visible_pixels_changed"]==0 and audit["changed_outside_mask"]==0 and audit["approved_outline_exact"]
(D/"fin-final-touchup-audit.json").write_text(json.dumps(audit,indent=2));print(json.dumps(audit))
