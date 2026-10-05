from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import numpy as np,json,hashlib
from collections import deque
P=Path(r"C:/Users/pmcga/dev/hollowtide");W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an");D=W/"coalcrest-tail-root-repair"
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def comps(occ):
 remain=set((int(x),int(y)) for y,x in np.argwhere(occ));ret=[]
 while remain:
  v=next(iter(remain));todo=[v];seen={v};remain.remove(v)
  while todo:
   x,y=todo.pop()
   for xx,yy in [(x-1,y),(x+1,y),(x,y-1),(x,y+1)]:
    v=(xx,yy)
    if v in remain:remain.remove(v);seen.add(v);todo.append(v)
  ret.append(seen)
 return sorted(ret,key=len,reverse=True)
baseline=json.loads((D/"baseline.json").read_text())
changed=[rel for rel,h in baseline.items() if not (P/rel).exists() or sha(P/rel)!=h]
assert not changed,("concurrent runtime changes",changed)
checks=[]
for view in ["front","back"]:
 old=np.array(Image.open(D/("coalcrest-"+view+"-previous.png")).convert("RGBA"))
 original=np.array(Image.open(W/"kithflare-tail-review"/("coalcrest-"+view+"-before.png")).convert("RGBA"))
 im=Image.open(D/("coalcrest-"+view+"-organic-root.png")).convert("RGBA");a=np.array(im);occ=a[:,:,3]>0
 assert a.shape==(160,160,4) and set(np.unique(a[:,:,3]))=={0,255}
 assert np.array_equal(a[:88],old[:88])
 parts=comps(occ);oldparts=comps(old[:,:,3]>0)
 # A real disconnected rogue cluster cannot pass as a valid attached tail.
 assert len(parts)<=len(oldparts),(view,"detached clusters",[len(c) for c in parts])
 assert (35,91) in parts[0] and (86,90) in parts[0]
 bulb=np.array(Image.open(W/"kithflare-tail-review/original-coalcrest-lantern.png").convert("RGBA"));b=bulb[:,:,3]>0
 assert np.array_equal(a[78:109,19:50][b],bulb[b])
 if view=="front":
  fin=original[:103,45:112,3]>0
  assert np.array_equal(a[:103,45:112][fin],original[:103,45:112][fin])
  assert np.array_equal(a[130:153,60:118],original[130:153,60:118])
  assert np.array_equal(a[129,60:71],original[129,60:71])
  assert np.array_equal(a[129,94:118],original[129,94:118])
  stem=np.zeros((160,160),bool);stem[121:130,72:94]=True;stem[122:129,104:154]=True
  assert not occ[stem].any()
  tailpath=[(60,105),(56,110),(52,116),(46,124),(40,130),(28,128),(15,115)]
 else:
  assert np.array_equal(a[126:143,71:129],original[126:143,71:129])
  # Old horizontal top shelf must no longer protrude into the open inner curl.
  assert not occ[119:123,43:49].any()
  top=[int(np.flatnonzero(occ[110:143,x])[0]+110) for x in range(41,57)]
  assert all(0<=a-b<=2 for a,b in zip(top,top[1:])),("rear root contour step",top)
  bottom=[int(np.flatnonzero(occ[110:145,x])[-1]+110) for x in range(50,71)]
  assert all(0<=a-b<=1 for a,b in zip(bottom,bottom[1:])),("rear underside protrusion",bottom)
  tailpath=[(68,115),(62,124),(52,131),(40,134),(28,128),(16,114)]
 widths=[]
 for x,y in tailpath:
  assert occ[y,x],(view,"missing intended tail center",x,y)
  # A centered 3x3 occupied core catches the thin or cut connection missed earlier.
  assert occ[y-1:y+2,x-1:x+2].all(),(view,"tail core narrowing",x,y)
  widths.append({"x":x,"y":y,"solid_3x3_core":True})
 mask=np.any(a!=old,axis=2);Image.fromarray(mask.astype("uint8")*255).save(D/("coalcrest-"+view+"-final-mask.png"))
 checks.append({"view":view,"canvas":[160,160],"binary_alpha":True,"four_connected_components":[len(c) for c in parts],"old_component_sizes":[len(c) for c in oldparts],"lamp_and_body_same_main_component":True,"lamp_rgba_exact":True,"fin_rgba_exact":view=="front","genuine_foot_regions_exact":True,"old_stem_or_rear_shelf_absent":True,"intended_tail_core_checks":widths,"changed_pixels_from_previous":int(mask.sum()),"bbox":im.getbbox(),"sha256":sha(D/("coalcrest-"+view+"-organic-root.png"))})
ledger=json.loads((W/"kithflare-tail-review/source-ledger.json").read_text())
assert all(sha(P/e["source"])==e["sha256"] for e in ledger)
sheet=Image.new("RGB",(370,190),(60,68,69));dr=ImageDraw.Draw(sheet)
for col,view in enumerate(["front","back"]):
 im=Image.open(D/("coalcrest-"+view+"-organic-root.png"))
 sheet.paste(im,(col*180+8,20),im);dr.text((col*180+8,5),"COALCREST "+view.upper(),fill="white")
sheet.resize((1110,570),Image.Resampling.NEAREST).save(D/"coalcrest-final-review.png")
comparison=Image.new("RGB",(390,440),(60,68,69));dr=ImageDraw.Draw(comparison)
for row,view in enumerate(["front","back"]):
 for col,suf in enumerate(["previous","organic-root"]):
  im=Image.open(D/("coalcrest-"+view+"-"+suf+".png")).crop((20,90,110,145))
  comparison.paste(im.resize((180,110),Image.Resampling.NEAREST),(col*195+5,row*220+35))
  dr.text((col*195+5,row*220+12),view.upper()+" "+("BEFORE" if col==0 else "REPAIRED"),fill="white")
comparison.resize((1170,1320),Image.Resampling.NEAREST).save(D/"root-before-after-detail.png")
(D/"pixel-checks.json").write_text(json.dumps({"checks":checks,"source_art_exact":True,"protected_runtime_files":len(baseline),"passed":True},indent=2))
print(json.dumps({"passed":True,"checks":checks,"source_art_exact":True,"protected_runtime_files":len(baseline)}))
