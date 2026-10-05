from pathlib import Path
from PIL import Image,ImageFilter,ImageDraw
import numpy as np,json,hashlib
D=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/coalcrest-fin-review")
original=np.array(Image.open(D/"front-before.png").convert("RGBA"))
before=np.array(Image.open(D/"fin-final-touchup.png").convert("RGBA"))
small=np.array(Image.open(D/"fin-only-mask.png").convert("L"))>127
mask=np.zeros(before.shape[:2],bool);mask[:48,54:118]=small
old_opaque=original[:,:,3]>0;opaque=before[:,:,3]>0
old_inner=np.array(Image.fromarray(old_opaque.astype("uint8")*255).filter(ImageFilter.MinFilter(3)))>0
new_inner=np.array(Image.fromarray(opaque.astype("uint8")*255).filter(ImageFilter.MinFilter(3)))>0
source_inner=np.array(Image.fromarray(old_opaque.astype("uint8")*255).filter(ImageFilter.MinFilter(5)))>0
source_inner[:18]=False;source_inner[46:]=False;source_inner[:,:54]=False;source_inner[:,102:]=False
source_inner &= (original[:,:,0]>=original[:,:,1])&(original[:,:,1]>=original[:,:,2])
ys,xs=np.nonzero(source_inner)
out=before.copy()
# The original clipped border has become an internal seam after extending the sail.
seam=old_opaque&~old_inner&new_inner&mask
for y,x in np.argwhere(seam):
    vector=np.array([96.-x,65.-y]);vector=vector/np.linalg.norm(vector)
    wanted=np.array([x,y])+vector*2
    scores=(xs-wanted[0])**2+(ys-wanted[1])**2
    i=scores.argmin();out[y,x]=original[ys[i],xs[i]]
# Use the sail's own dark contour palette for a continuous one-native-pixel upper rim.
edge=opaque&~new_inner&mask
source_edge=old_opaque&~old_inner
selection=source_edge.copy();selection[:30]=False;selection[60:]=False;selection[:,:52]=False;selection[:,100:]=False
colors=original[selection,:3]
colors=colors[(colors[:,0]<95)&(colors[:,0]>20)&(colors[:,0]>=colors[:,1])&(colors[:,1]>=colors[:,2])]
unique,counts=np.unique(colors,axis=0,return_counts=True)
outline=unique[counts.argmax()]
out[edge,:3]=outline;out[edge,3]=255
Image.fromarray(out).save(D/"fin-contour-cleaned.png")
canvas=Image.new("RGB",(320,176),(66,72,74))
for i,(a,label) in enumerate([(before,"BEFORE"),(out,"REAR SEAM / TOP RIM CLEANUP")]):
    im=Image.fromarray(a);canvas.paste(im,(i*160,8),im);ImageDraw.Draw(canvas).text((i*160+3,163),label,fill="white")
canvas.resize((960,528),Image.Resampling.NEAREST).save(D/"fin-contour-comparison.png")
changed=np.any(out!=original,axis=2)
audit={"changed_from_previous_finish":int(np.any(out!=before,axis=2).sum()),"old_border_seam_pixels_retextured":int(seam.sum()),"upper_rim_pixels":int(edge.sum()),"outline_native_rgb":outline.tolist(),"changed_outside_fin_mask":int(changed[~mask].sum()),"outer_silhouette_exact":bool(np.all((out[:,:,3]>0)==opaque)),"bounds":Image.fromarray(out).getbbox(),"sha256":hashlib.sha256((D/"fin-contour-cleaned.png").read_bytes()).hexdigest(),"user_request":"Clean the back black line and top black outline","original_visible_pixels_retextured_inside_requested_fin_region":int(changed[old_opaque].sum())}
assert audit["changed_outside_fin_mask"]==0 and audit["outer_silhouette_exact"]
(D/"fin-contour-audit.json").write_text(json.dumps(audit,indent=2));print(json.dumps(audit))
