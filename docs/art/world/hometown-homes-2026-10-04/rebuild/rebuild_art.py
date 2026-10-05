from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib
A=Path(__file__).resolve().parent.parent
O=A/"rebuild/output";O.mkdir(parents=True,exist_ok=True)
for source,name in [("neighbor-home","neighbor_home"),("garden-home","garden_home")]:
 i=Image.open(A/"generation"/(source+"-source.png")).convert("RGBA");b=i.getbbox()
 cropped=i.crop(b);out=Image.new("RGBA",(cropped.width+24,cropped.height+24));out.paste(cropped,(12,12))
 out.save(O/(name+".png"))
 assert out.crop((12,12,12+cropped.width,12+cropped.height)).tobytes()==cropped.tobytes()
source=Image.open(A/"generation/courtyard-home-room-source.png").convert("RGBA");a=np.array(source);bg=a.copy()
layers=[]
for name,rects in [
 ("home_stove_front",[(35,112,59,159),(35,160,59,177)]),
 ("home_coat_front",[(184,116,220,166),(200,166,218,176)]),
 ("home_threshold_front",[(26,211,106,233),(154,211,231,233)])
]:
 mask=np.zeros((256,256),dtype=bool)
 for x0,y0,x1,y1 in rects:mask[y0:y1,x0:x1]=True
 mask&=a[:,:,3]>0
 fore=np.zeros_like(a);fore[mask]=a[mask]
 for y,x in np.argwhere(mask):bg[y,x]=a[y,124+(x%24)]
 i=Image.fromarray(fore);b=i.getbbox();cropped=i.crop(b)
 out=Image.new("RGBA",(cropped.width+4,cropped.height+4));out.paste(cropped,(2,2));out.save(O/(name+".png"));layers.append(fore)
Image.fromarray(bg).save(O/"home_room.png")
combined=Image.fromarray(bg)
for fore in layers:combined.alpha_composite(Image.fromarray(fore))
assert np.array_equal(np.array(combined),a)
atlas=Image.open(A/"sources/route1_ground_atlas_polished.png").convert("RGBA")
tile=np.array(atlas.crop((176,0,192,16)))
mask=Image.new("L",(1024,768));draw=ImageDraw.Draw(mask)
draw.rounded_rectangle((224,247,242,281),radius=6,fill=255)
draw.line([(233,274),(224,290)],width=18,fill=255)
draw.ellipse((215,281,233,299),fill=255)
draw.rounded_rectangle((549,220,571,260),radius=6,fill=255)
yy,xx=np.mgrid[:768,:1024];out=tile[yy%16,xx%16].copy();out[:,:,3]=np.array(mask)
Image.fromarray(out).save(O/"home_approaches.png")
checks=[]
for name in ["neighbor_home","garden_home","home_room","home_stove_front","home_coat_front","home_threshold_front","home_approaches"]:
 rebuilt=O/(name+".png");expected=A/"prepared"/(name+".png")
 checks.append({"file":name+".png","byte_exact":rebuilt.read_bytes()==expected.read_bytes(),"sha256":hashlib.sha256(rebuilt.read_bytes()).hexdigest()})
result={"passed":all(x["byte_exact"] for x in checks),"original_room_composite_rgba_exact":True,"checks":checks}
(A/"rebuild-check.json").write_text(json.dumps(result,indent=2),encoding="utf-8")
assert result["passed"],checks
print(json.dumps(result))
