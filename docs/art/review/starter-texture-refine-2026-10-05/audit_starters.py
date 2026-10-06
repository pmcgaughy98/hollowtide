from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import re,json,hashlib,shutil,collections
P=Path("C:/Users/pmcga/dev/hollowtide"); W=Path(__file__).parent
names={"kithflare":["103_kithflare","109_kithflare2","110_kithflare3"],"tallowroot":["1701_tallowroot","1702_tallowroot2","1703_tallowroot3"],"rimefin":["001_rimefin","502_riftfin","503_scourmaw"]}
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
(W/"inputs").mkdir(exist_ok=True);(W/"review").mkdir(exist_ok=True)
record={"date":"2026-10-05","status":"read-only active starter audit, no generated edits or project changes","requested_essences":{"kithflare":["Ember","Electric"],"tallowroot":["Bloom","Stone"],"rimefin":["Hollow","Tide"]},"lines":{}}
font=ImageFont.truetype("C:/Windows/Fonts/arial.ttf",17)
for line,ids in names.items():
 entries=[]; sheet=Image.new("RGB",(1920,425),(80,87,90)); draw=ImageDraw.Draw(sheet)
 for stage,id_ in enumerate(ids,1):
  resource=P/"data/creatures"/(id_+".tres");text=resource.read_text(encoding="utf-8")
  shutil.copy2(resource,W/"inputs"/resource.name)
  ext={m.group(2):m.group(1) for m in re.finditer(r'\[ext_resource[^\n]*path="([^"]+)"[^\n]*id="([^"]+)"[^\n]*\]',text)}
  scalar=lambda key,default:re.search(r"^"+key+r"\s*=\s*(.+)$",text,re.M).group(1) if re.search(r"^"+key+r"\s*=\s*(.+)$",text,re.M) else default
  entry={"resource":"data/creatures/"+resource.name,"resource_sha256":sha(resource),"name":scalar("creature_name",'""'),"essence":int(scalar("essence","0")),"has_second_essence":scalar("has_second_essence","false"),"second_essence":int(scalar("second_essence","0")),"battle_size":float(scalar("battle_size","1.0")),"evolves_into":scalar("evolves_into","none"),"views":{}}
  for side,prop in [("front","sprite"),("back","back_sprite")]:
   match=re.search("^"+prop+r'\s*=\s*ExtResource\("([^"]+)"\)',text,re.M);assert match,(id_,prop,"not a direct current texture")
   rel=ext[match.group(1)].removeprefix("res://");src=P/rel;dest=W/"inputs"/(id_+"_"+side+".png");shutil.copy2(src,dest)
   im=Image.open(dest).convert("RGBA");alpha=im.getchannel("A");bbox=alpha.getbbox();rgba=list(im.getdata()); visible=[p[:3] for p in rgba if p[3]>0]; hist=collections.Counter(visible)
   edge=[]
   for y in range(im.height):
    for x in range(im.width):
     rgb=im.getpixel((x,y))
     if rgb[3] and any(nx<0 or ny<0 or nx>=im.width or ny>=im.height or im.getpixel((nx,ny))[3]==0 for nx,ny in [(x-1,y),(x+1,y),(x,y-1),(x,y+1)]):edge.append(rgb[:3])
   info={"project_path":rel,"input_filename":dest.name,"sha256":sha(src),"canvas":im.size,"bbox":bbox,"clear_margins":[bbox[0],bbox[1],im.width-bbox[2],im.height-bbox[3]],"visible_pixels":len(visible),"opaque_pixels":sum(p[3]==255 for p in rgba),"semi_transparent_pixels":sum(0<p[3]<255 for p in rgba),"visible_rgb_colors":len(hist),"visible_exact_magenta_pixels":hist[(255,0,255)],"visible_near_white_pixels":sum(n for rgb,n in hist.items() if min(rgb)>225),"bright_edge_pixels":sum(min(rgb)>210 for rgb in edge),"top_colors":[{"rgb":rgb,"pixels":n} for rgb,n in hist.most_common(12)]}
   entry["views"][side]=info
   col=(stage-1)*2+(side=="back"); cellx=col*320;draw.text((cellx+12,8),line.title()+" "+str(stage)+" "+side,font=font,fill="white")
   draw.text((cellx+12,31),str(im.size)+" / "+str(len(hist))+" colors",font=font,fill="white")
   display=im.resize((im.width*2,im.height*2),Image.Resampling.NEAREST);sheet.paste(display,(cellx+(320-display.width)//2,65),display)
   matte=Image.new("RGBA",im.size,(80,87,90,255));matte.alpha_composite(im);matte.convert("RGB").resize((im.width*4,im.height*4),Image.Resampling.NEAREST).save(W/"review"/(id_+"_"+side+"_4x.png"))
  entries.append(entry)
 record["lines"][line]=entries;sheet.save(W/"review"/(line+"_all_stages_2x.png"))
(W/"source-audit.json").write_text(json.dumps(record,indent=2)+"\n",encoding="utf-8")
print(json.dumps({line:[{"resource":e["resource"],"essences":[e["essence"],e["second_essence"]],"views":{s:{k:v for k,v in d.items() if k in ["canvas","visible_rgb_colors","semi_transparent_pixels","bright_edge_pixels","clear_margins"]} for s,d in e["views"].items()}} for e in entries] for line,entries in record["lines"].items()}))
