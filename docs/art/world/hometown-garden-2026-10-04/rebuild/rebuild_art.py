from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib
A=Path(__file__).resolve().parent.parent
O=A/"rebuild/output";O.mkdir(exist_ok=True)
def padded(i):
 out=Image.new("RGBA",(i.width+4,i.height+4));out.alpha_composite(i,(2,2));return out
src=Image.open(A/"generation/timber-bed-source.png").convert("RGBA");a=np.array(src);yy,xx=np.mgrid[:64,:64]
palette=np.unique(a[a[:,:,3]>0,:3],axis=0)
def native(c):return palette[np.argmin(((palette.astype(int)-np.array(c))**2).sum(1))]
mask=(xx>=11)&(xx<=52)&(yy>=13)&(yy<=47)&(a[:,:,3]>0)&(a[:,:,0]<42)&(a[:,:,1]<25)
out=a.copy();out[mask,:3]=native([58,32,23]);out[mask&(((xx//3+yy//2*5)%13)==0),:3]=native([77,41,26])
padded(Image.fromarray(out).crop(src.getbbox())).save(O/"timber_bed.png")
src=Image.open(A/"generation/cuttings-row-source.png").convert("RGBA")
padded(src.crop(src.getbbox())).save(O/"cuttings_row.png")
atlas=Image.open(A/"sources/route1_ground_atlas_polished.png").convert("RGBA");soil=np.array(atlas.crop((176,0,192,16)))
mask=Image.new("L",(1024,768));draw=ImageDraw.Draw(mask)
draw.rounded_rectangle((352,488,536,600),radius=12,fill=255);draw.rounded_rectangle((431,584,457,632),radius=8,fill=255)
draw.line([(520,584),(558,578)],fill=255,width=26);draw.ellipse((507,571,533,597),fill=255);draw.ellipse((545,565,571,591),fill=255)
for b in [(377,518,431,568),(457,518,511,568)]:draw.rectangle((b[0],b[1],b[2]-1,b[3]-1),fill=0)
draw.rounded_rectangle((524,488,561,600),radius=12,fill=255)
yy,xx=np.mgrid[:768,:1024];rgba=soil[yy%16,xx%16].copy();rgba[:,:,3]=np.array(mask);Image.fromarray(rgba).save(O/"garden_lanes.png")
src=np.array(Image.open(A/"generation/garden-neighbor-source.png").convert("RGBA"))
generated=np.array(Image.open(A/"generation/garden-neighbor-hat-outpaint.png").convert("RGBA"))
out=np.zeros((76,48,4),dtype=np.uint8);out[12:]=src;yy,xx=np.mgrid[:76,:48]
candidate=(yy<12)&(xx>=14)&(xx<=33)&(generated[:,:,3]>0)&(generated[:,:,0]<225)&(generated[:,:,2]<155)&(generated[:,:,0]>=generated[:,:,1])&(generated[:,:,1]>=generated[:,:,2])
hat_palette=np.unique(src[:17][src[:17,:,3]>0,:3],axis=0);keep=np.zeros(candidate.shape,dtype=bool)
front=[(11,int(x)) for x in np.nonzero(candidate[11]&(src[0,:,3]>0))[0]]
while front:
 y,x=front.pop()
 if keep[y,x] or not candidate[y,x]:continue
 keep[y,x]=True
 for dy,dx in [(1,0),(-1,0),(0,1),(0,-1)]:
  ny,nx=y+dy,x+dx
  if 0<=ny<12 and 0<=nx<48:front.append((ny,nx))
out[keep]=generated[keep]
for y,x in np.argwhere(keep):
 c=out[y,x,:3];out[y,x,:3]=hat_palette[np.argmin(((hat_palette.astype(int)-c.astype(int))**2).sum(1))]
assert np.array_equal(out[12:],src)
i=Image.fromarray(out);i=i.crop(i.getbbox());size=(round(i.width*30/i.height),30)
padded(i.resize(size,Image.Resampling.NEAREST)).save(O/"garden_neighbor.png")
checks=[]
for name in ["timber_bed","cuttings_row","garden_lanes","garden_neighbor"]:
 rebuilt=O/(name+".png");expected=A/"prepared"/(name+".png")
 checks.append({"file":name+".png","byte_exact":rebuilt.read_bytes()==expected.read_bytes(),"sha256":hashlib.sha256(rebuilt.read_bytes()).hexdigest()})
(A/"rebuild-check.json").write_text(json.dumps({"checks":checks,"passed":all(x["byte_exact"] for x in checks)},indent=2),encoding="utf-8")
assert all(x["byte_exact"] for x in checks),checks
print(json.dumps(checks))
