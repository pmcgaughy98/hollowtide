from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib
W=Path(__file__).resolve().parent
D=W/"home-interior-linework-2026-10-04"
original=Image.open(D/"before/room-original-source.png").convert("RGBA")
generated=Image.open(D/"generated/room-linework-rd.png").convert("RGBA")
replacement=Image.open(D/"generated/table-replacement-rd.png").convert("RGBA")
assert original.size==generated.size==replacement.size==(256,256)
a=np.array(original);b=np.array(generated);c=np.array(replacement);final=b.copy()
vis=a[:,:,3]>0;genvis=b[:,:,3]>0
final[~vis]=a[~vis];final[vis&~genvis]=a[vis&~genvis];final[:,:,3]=a[:,:,3]
sharp=final.copy()
mask=np.array(Image.open(D/"request/table-clear-mask.png").convert("L"))>0
assert int(mask.sum())==512
assert (c[:,:,3][mask]>0).all()
final[mask,:3]=c[mask,:3]
assert np.array_equal(final[~mask],sharp[~mask])
assert np.array_equal(final[:,:,3],a[:,:,3])
assert np.array_equal(final[~vis],a[~vis])
source=Image.fromarray(final);source.save(D/"prepared/room_cleared_registered_source.png")
bg=final.copy()
groups=[
 ("home_stove_front",177,(35,112,59,177),[(35,112,59,159),(35,160,59,177)]),
 ("home_coat_front",176,(184,116,220,176),[(184,116,220,166),(200,166,218,176)]),
 ("home_threshold_front",233,(26,211,231,233),[(26,211,106,233),(154,211,231,233)])
]
layers=[];records=[]
for name,foot,bounds,rects in groups:
 m=np.zeros((256,256),dtype=bool)
 for x0,y0,x1,y1 in rects:m[y0:y1,x0:x1]=True
 m&=final[:,:,3]>0
 fore=np.zeros_like(final);fore[m]=final[m]
 for y,x in np.argwhere(m):bg[y,x]=final[y,124+(x%24)]
 x0,y0,x1,y1=bounds
 cropped=Image.fromarray(fore).crop(bounds)
 out=Image.new("RGBA",(x1-x0+4,y1-y0+4));out.paste(cropped,(2,2))
 out.save(D/"prepared"/(name+".png"));layers.append(fore)
 records.append({"asset":name,"fixed_original_bounds":bounds,"native_size":out.size,"draw_origin":[x0-2,y0-2],"y_sort_foot":foot,"rectangles":rects,"source_visible_RGBA_exact":bool(np.array_equal(fore[m],final[m]))})
Image.fromarray(bg).save(D/"prepared/home_room.png")
combined=Image.fromarray(bg)
for layer in layers:combined.alpha_composite(Image.fromarray(layer))
assert np.array_equal(np.array(combined),final),"source reconstruction mismatch"
combined.save(D/"render/cleared-room-recomposed.png")
combined.resize((768,768),Image.Resampling.NEAREST).save(D/"render/cleared-room-recomposed-x3.png")
panel=Image.new("RGBA",(1024,572),(56,56,56,255));d=ImageDraw.Draw(panel)
for x,im,label in [(0,original,"Original room"),(512,source,"Sharper room / empty worktable")]:
 panel.paste(im.resize((512,512),Image.Resampling.NEAREST),(x,42));d.text((x+14,12),label,fill="white")
panel.save(D/"render/final-room-comparison.png")
info={"native_size":[256,256],"original_alpha_exact":True,"transparent_RGB_original_exact":True,"original_bounds_retained":source.getbbox(),"generated_RGB_visible_pixels_retained":int((vis&genvis).sum()),"original_visible_edge_pixels_restored":int((vis&~genvis).sum()),"generated_outside_silhouette_pixels_excluded":int((~vis&genvis).sum()),"changed_visible_RGB":int((np.any(final[:,:,:3]!=a[:,:,:3],axis=2)&vis).sum()),"table_replacement":{"raw_source":"generated/table-replacement-rd.png","accepted_mask":"request/table-clear-mask.png","half_open_bounds":[159,70,191,86],"mask_pixels":512,"changed_pixels":int(np.any(final!=sharp,axis=2).sum()),"outside_mask_RGBA_exact":True,"first_inpainting_rejected":"generated/clear_table-rd.png","first_inpainting_pixels_installed":0},"full_opacity_RGBA_reconstruction_exact":True,"native_resampling":False,"foregrounds":records}
(D/"native-preparation.json").write_text(json.dumps(info,indent=2)+"\n",encoding="utf-8")
approval={"date":"2026-10-05","request":"Approve uploading the sharper full-room image for one replacement $0.18 edit that removes only the map and cup. This is an additional charge beyond the five approved edits.","human_answer":"Approve replacement ($0.18)","input":"prepared/room_registered_source.png","input_sha256":hashlib.sha256((D/"prepared/room_registered_source.png").read_bytes()).hexdigest(),"tool":"image_edit","destination":"Retro Diffusion","max_requests":1,"approved_cost_usd":0.18,"status":"completed","receipt":"generated/table-replacement-receipt.json"}
(D/"request/table-retry-approval.json").write_text(json.dumps(approval,indent=2)+"\n",encoding="utf-8")
spec=json.loads((D/"request/table-retry-spec.json").read_text(encoding="utf-8"));spec.update(status="completed",approval="table-retry-approval.json",receipt="../generated/table-replacement-receipt.json",installed_pixels_from_first_result=0)
(D/"request/table-retry-spec.json").write_text(json.dumps(spec,indent=2)+"\n",encoding="utf-8")
print(json.dumps(info))
