from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib
W=Path(__file__).resolve().parent;D=W/"room-coalcrest-detail-2026-10-05"
a=np.array(Image.open(D/"inputs/room.png").convert("RGBA"));b=np.array(Image.open(D/"generated/room-rd.png").convert("RGBA"))
assert a.shape==b.shape==(256,256,4)
mask=np.array(Image.open(D/"request/room-acceptance-mask.png").convert("L"))>0
accepted=mask&(a[:,:,3]>0)&(b[:,:,3]>0)
final=a.copy();final[accepted,:3]=b[accepted,:3]
cloth=np.array(Image.open(D/"review/room-original-cloth-plane-mask.png").convert("L"))>0
assert int(cloth.sum())==501
final[cloth,:3]=a[cloth,:3]
assert np.array_equal(final[cloth],a[cloth])
assert np.array_equal(final[~mask],a[~mask]) and np.array_equal(final[:,:,3],a[:,:,3])
Image.fromarray(final).save(D/"prepared/room_detail_registered_source.png")
bg=final.copy();layers=[];records=[]
groups=[("home_stove_front",177,(35,112,59,177),[(35,112,59,159),(35,160,59,177)]),("home_coat_front",176,(184,116,220,176),[(184,116,220,166),(200,166,218,176)]),("home_threshold_front",233,(26,211,231,233),[(26,211,106,233),(154,211,231,233)])]
for name,foot,bounds,rects in groups:
 m=np.zeros((256,256),dtype=bool)
 for x0,y0,x1,y1 in rects:m[y0:y1,x0:x1]=True
 m&=final[:,:,3]>0
 fore=np.zeros_like(final);fore[m]=final[m]
 for y,x in np.argwhere(m):bg[y,x]=final[y,124+(x%24)]
 x0,y0,x1,y1=bounds;out=Image.new("RGBA",(x1-x0+4,y1-y0+4))
 out.paste(Image.fromarray(fore).crop(bounds),(2,2));out.save(D/"prepared"/(name+".png"));layers.append(fore)
 records.append({"asset":name,"bounds":bounds,"size":out.size,"origin":[x0-2,y0-2],"y_sort_foot":foot,"exact_source_RGBA":bool(np.array_equal(fore[m],final[m]))})
Image.fromarray(bg).save(D/"prepared/home_room.png")
combined=Image.fromarray(bg)
for layer in layers:combined.alpha_composite(Image.fromarray(layer))
assert np.array_equal(np.array(combined),final)
combined.save(D/"render/room-detail-recomposed.png")
panel=Image.new("RGBA",(1024,560),(63,63,63,255));draw=ImageDraw.Draw(panel)
for x,v,label in [(0,a,"Installed sharper room / empty table"),(512,final,"Focused material detail / candidate")]:
 panel.alpha_composite(Image.fromarray(v).resize((512,512),Image.Resampling.NEAREST),(x,36));draw.text((x+12,10),label,fill="white")
panel.save(D/"render/room-detail-comparison.png")
crops=[("bed-quilt",(32,52,124,128)),("stove-woodpile",(28,104,80,184)),("cupboard-coat",(176,108,228,192)),("shelf-worktable",(148,24,228,112))]
for name,bounds in crops:
 size=((bounds[2]-bounds[0])*3,(bounds[3]-bounds[1])*3)
 p=Image.new("RGBA",(size[0]*2+12,size[1]),(63,63,63,255))
 for x,v in [(0,a),(size[0]+12,final)]:p.alpha_composite(Image.fromarray(v).crop(bounds).resize(size,Image.Resampling.NEAREST),(x,0))
 p.save(D/"render"/("room-"+name+"-detail-comparison.png"))
info={"canvas":[256,256],"original_alpha_and_transparent_RGB_exact":True,"outside_accepted_mask_RGBA_exact":True,"accepted_mask_pixels":int(mask.sum()),"eligible_generated_pixels":int(accepted.sum()),"changed_RGB_pixels":int(np.any(final[:,:,:3]!=a[:,:,:3],axis=2).sum()),"foregrounds":records,"full_opacity_foreground_reconstruction_exact":True,"table_clear_mask_restricted_material":True,"original_pale_cloth_restored_pixels":501,"native_resampling":False}
(D/"room-native-preparation.json").write_text(json.dumps(info,indent=2)+"\n",encoding="utf-8")
print(json.dumps(info))
