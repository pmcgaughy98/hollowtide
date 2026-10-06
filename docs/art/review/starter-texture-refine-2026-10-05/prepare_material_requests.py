from pathlib import Path
from PIL import Image,ImageDraw,ImageFont,ImageFilter
import json,hashlib,shutil
W=Path(__file__).parent;P=Path("C:/Users/pmcga/dev/hollowtide")
audit=json.loads((W/"source-audit.json").read_text());byid={e["resource"].split("/")[-1].removesuffix(".tres"):e for entries in audit["lines"].values() for e in entries}
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
req=W/"request";req.mkdir(exist_ok=True)
plans=[
("kithflare2-materials","Kithflare Stage II warm copper skin and organic amber lantern glass inside its existing wire cage",[
("109_kithflare2","front",(36,31,100,95),"amber",(48,38,83,88)),
("109_kithflare2","back",(46,25,110,89),"amber",(58,35,95,85)),
("109_kithflare2","front",(98,99,162,163),"warm",None),
("109_kithflare2","back",(100,90,164,154),"warm",None)]),
("tallowroot1-2-husks","Tallowroot Stage I seed husk and Stage II layered husk armor, both views",[
("1701_tallowroot","front",(42,57,106,121),"wood",None),
("1701_tallowroot","back",(41,54,105,118),"wood",None),
("1702_tallowroot2","front",(115,48,179,112),"wood",None),
("1702_tallowroot2","back",(70,65,134,129),"wood",None)]),
("tallowroot3-armor-leaves","Tallowroot Stage III layered husk armor in both views and Stage II/III rear leaves",[
("1703_tallowroot3","front",(86,115,150,179),"wood",None),
("1703_tallowroot3","back",(79,72,143,136),"wood",None),
("1702_tallowroot2","back",(45,17,109,81),"leaf",None),
("1703_tallowroot3","back",(79,18,143,82),"leaf",None)]),
("rimefin-riftfin-scales","Rimefin Stage I blue river skin and Riftfin armored scale clusters, both views",[
("001_rimefin","front",(31,57,95,121),"blue",None),
("001_rimefin","back",(36,56,100,120),"blue",None),
("502_riftfin","front",(41,95,105,159),"blue",None),
("502_riftfin","back",(95,79,159,143),"blue",None)]),
("scourmaw-scales-fins","Scourmaw dark river-blue scale material and gray-blue fin plates in both views",[
("503_scourmaw","front",(63,119,127,183),"blue",None),
("503_scourmaw","back",(95,106,159,170),"blue",None),
("503_scourmaw","front",(113,36,177,100),"bone",None),
("503_scourmaw","back",(122,36,186,100),"bone",None)])
]
def material(rgb,kind):
 r,g,b=rgb[:3]
 if kind in ("wood","warm","amber"):return 50<r<(190 if kind=="warm" else 211) and 25<g<181 and r-g>8 and g-b>6
 if kind=="leaf":return 45<g<190 and g-r>9 and g-b>20
 if kind=="blue":return 20<r<180 and 40<g<200 and 45<b<211 and min(g,b)>r+6
 if kind=="bone":return 60<r<220 and 80<g<226 and 80<b<226 and g>=r and b>r-3
 return False
batch={"date":"2026-10-05","status":"prepared_for_specific_user_upload_and_charge_approval","destination":"Retro Diffusion image_edit","paid_edits_submitted":0,"proposed_edit_count":6,"proposed_total_usd":1.08,"requests":[],"KithflareIII_source_grid_repair":"already installed separately, zero charge"}
oldreq=W.parent/"kithflare-lantern-detail-2026-10-05/request"
for filename in ["kithflare-lantern-closeups-source.png","kithflare-lantern-exact-prompt.txt","kithflare-lantern-target-brief.json"]:
 shutil.copy2(oldreq/filename,req/filename)
batch["requests"].append({"name":"kithflare1-lanterns","input_file":"request/kithflare-lantern-closeups-source.png","input_sha256":sha(req/"kithflare-lantern-closeups-source.png"),"prompt_file":"request/kithflare-lantern-exact-prompt.txt","scope":"Original two-lantern request retained unchanged; duplicate approval must never cause a duplicate paid call","estimated_usd":0.18})
font=ImageFont.truetype("C:/Windows/Fonts/arial.ttf",14);overview=Image.new("RGB",(1536,660),(60,67,70));od=ImageDraw.Draw(overview)
for index,(name,subject,tiles) in enumerate(plans):
 atlas=Image.new("RGBA",(256,256),(0,0,0,0));masked=Image.new("RGB",(256,256),(80,87,90));manifest=[]
 for i,(id_,side,box,kind,restriction) in enumerate(tiles):
  inf=byid[id_]["views"][side];assert sha(P/inf["project_path"])==inf["sha256"],("Source art changed",id_,side)
  im=Image.open(W/"inputs"/inf["input_filename"]).convert("RGBA");eroded=im.getchannel("A").filter(ImageFilter.MinFilter(5))
  mask=Image.new("L",im.size,0)
  for y in range(box[1],box[3]):
   for x in range(box[0],box[2]):
    if restriction and not(restriction[0]<=x<restriction[2] and restriction[1]<=y<restriction[3]):continue
    if id_=="001_rimefin" and kind=="blue" and im.getpixel((x,y))[0]>=100:continue
    if eroded.getpixel((x,y))==255 and material(im.getpixel((x,y)),kind):mask.putpixel((x,y),255)
  count=sum(p>0 for p in mask.get_flattened_data());assert count>=20,(name,id_,side,"Empty/undersized material scope",count)
  maskname=name+"_tile"+str(i+1)+"_acceptance.png";mask.save(req/maskname)
  crop=im.crop(box);pos=((i%2)*128,(i//2)*128);display=crop.resize((128,128),Image.Resampling.NEAREST);atlas.paste(display,pos)
  matte=Image.new("RGBA",crop.size,(80,87,90,255));matte.alpha_composite(crop);viz=matte.convert("RGB")
  local=mask.crop(box)
  for y in range(64):
   for x in range(64):
    if local.getpixel((x,y))>0:
     r,g,b=viz.getpixel((x,y));viz.putpixel((x,y),(min(255,(r+80)//2),min(255,(g+255)//2),min(255,(b+200)//2)))
  masked.paste(viz.resize((128,128),Image.Resampling.NEAREST),pos)
  manifest.append({"tile":i+1,"id":id_,"view":side,"source_path":inf["project_path"],"source_sha256":inf["sha256"],"frozen_source":inf["input_filename"],"source_crop":box,"material":kind,"atlas_origin":pos,"source_to_input_scale":2,"acceptance_mask_file":"request/"+maskname,"accepted_native_rgb_pixels":count,"alpha_pose_edge_core_other_pixels_protected":True})
 prompt="Refine the existing "+subject+" shown in this exact four-tile pixel-art atlas. Reading order is top-left, top-right, bottom-left, bottom-right. Preserve exact source pixel registration, silhouettes, anatomy, pose, contours, palette roles and transparency in every tile. The atlas is literal nearest-neighbor 2x source crops, not a new composition. Strengthen authored pixel clusters with a few coherent highlights and dark material grooves. Match front/back material texture and lighting. Keep Stage I simpler, Stage II stronger, Stage III denser; do not flatten everything into the same texture. "
 if "tallowroot" in name:prompt+="Keep the approved organic seed husks, layered natural armor and leaf shapes. Crisp warm muted ochre-brown husk grain or veins in existing leaves only. No new stones, species changes, armor pieces, vines, flowers, limbs, claws or decoration. "
 if name=="kithflare2-materials":prompt+="Keep burnished tan/copper skin and recognizable yellow lightning markings. Lantern stays a wire-caged organic ember. Keep cage, glowing core and attachments; only local amber shell and skin texture. No manufactured design replacement, extra ribs, new sparks or tail movement. "
 if name.startswith("rimefin") or name.startswith("scourmaw"):prompt+="Keep Missouri River catfish identity, blue/slate skin, existing armored scale rows and cool gray-blue bony plates. Keep barbels, mouths, teeth, eyes, existing pale body bands and fin shapes untouched. No new frost, spines, scales outside existing material, shark traits, limbs or armor. "
 prompt+="Avoid blur, antialiasing, gradient airbrush, background/matte colors, white fringe, rotation, shifting tiles, enlarging details or rearranging anatomy. Only the existing materials need careful pixel-art detail."
 ap=req/(name+"-source.png");atlas.save(ap);pp=req/(name+"-prompt.txt");pp.write_text(prompt+"\n",encoding="utf-8");mp=req/(name+"-tiles.json");mp.write_text(json.dumps(manifest,indent=2)+"\n")
 batch["requests"].append({"name":name,"input_file":"request/"+ap.name,"input_sha256":sha(ap),"prompt_file":"request/"+pp.name,"tile_manifest":"request/"+mp.name,"estimated_usd":0.18,"accepted_native_rgb_pixels":sum(e["accepted_native_rgb_pixels"] for e in manifest)})
 for j,(im,label) in enumerate([(atlas,"source"),(masked,"accepted material")]):
  x=(index%3)*512+j*256;y=(index//3)*330;od.text((x+6,y+5),name[:30],font=font,fill="white");od.text((x+6,y+24),label,font=font,fill="white")
  if im.mode=="RGBA":
   base=Image.new("RGBA",im.size,(80,87,90,255));base.alpha_composite(im);im=base.convert("RGB")
  overview.paste(im,(x,y+55))
overview.save(W/"review"/"material-request-source-mask-preview.png")
(req/"batch-spec.json").write_text(json.dumps(batch,indent=2)+"\n",encoding="utf-8")
print(json.dumps({"requests":len(batch["requests"]),"proposed_total_usd":batch["proposed_total_usd"],"scopes":[{"name":r["name"],"pixels":r.get("accepted_native_rgb_pixels",465)} for r in batch["requests"]]}))
