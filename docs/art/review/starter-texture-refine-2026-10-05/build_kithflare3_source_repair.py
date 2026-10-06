from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib
W=Path(__file__).parent; P=Path("C:/Users/pmcga/dev/hollowtide");a=json.loads((W/"source-audit.json").read_text());stage=a["lines"]["kithflare"][2]
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
(W/"candidates").mkdir(exist_ok=True)
record={"method":"Literal preserved full-size source nearest-neighbor sampled at existing219x219. Current original alpha and transparent RGB restored. No AI generation or painted pixels.","stage":"110_kithflare3","paid_calls":0,"views":{}}
sheet=Image.new("RGB",(900,1040),(80,87,90));draw=ImageDraw.Draw(sheet);font=ImageFont.truetype("C:/Windows/Fonts/arial.ttf",25)
for j,side in enumerate(["front","back"]):
 src=Image.open(W/"inputs"/("kithflare3_full_size_"+side+".png")).convert("RGBA");cur=Image.open(W/"inputs"/("110_kithflare3_"+side+".png")).convert("RGBA");candidate=src.resize(cur.size,Image.Resampling.NEAREST)
 assert candidate.getchannel("A").tobytes()==cur.getchannel("A").tobytes(),"Source alpha drift"
 for y in range(cur.height):
  for x in range(cur.width):
   c=cur.getpixel((x,y));n=candidate.getpixel((x,y));candidate.putpixel((x,y),c if c[3]==0 else (*n[:3],c[3]))
 assert sha(P/stage["views"][side]["project_path"])==stage["views"][side]["sha256"],"Shared source changed"
 out=W/"candidates"/("kithflare3_"+side+"_source_grid.png");candidate.save(out)
 b=list(cur.get_flattened_data());c=list(candidate.get_flattened_data())
 assert all(x[3]==y[3] and (x[3]>0 or x==y) for x,y in zip(b,c))
 record["views"][side]={"source_current_path":stage["views"][side]["project_path"],"source_current_sha256":stage["views"][side]["sha256"],"literal_donor":"inputs/kithflare3_full_size_"+side+".png","donor_sha256":sha(W/"inputs"/("kithflare3_full_size_"+side+".png")),"candidate_filename":out.name,"candidate_sha256":sha(out),"canvas":candidate.size,"bbox":candidate.getchannel("A").getbbox(),"alpha_and_transparent_rgb_exact":True,"changed_rgb_pixels":sum(x!=y for x,y in zip(b,c)),"color_count_before":len(set(x[:3] for x in b if x[3])),"color_count_after":len(set(x[:3] for x in c if x[3]))}
 for k,(im,label) in enumerate([(cur,"Current "+side),(candidate,"Source repair "+side)]):
  draw.text((k*450+10,j*520+8),label,font=font,fill="white")
  disp=im.resize((438,438),Image.Resampling.NEAREST);sheet.paste(disp,(k*450+6,j*520+65),disp)
sheet.save(W/"review"/"kithflare3_source_repair_before_after_2x.png")
(W/"kithflare3-source-repair.json").write_text(json.dumps(record,indent=2)+"\n");print(json.dumps(record))
