from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib
ROOT=Path(__file__).resolve().parent/"polish"
source=Path("C:/Users/pmcga/dev/hollowtide/assets/sprites/world/route1_rd_2026_10_01/cottonwood_polished.png")
orig=Image.open(source).convert("RGBA")
edited=Image.open(ROOT/"cottonwood_outpaint_transparent.png").convert("RGBA")
a=np.array(edited);assert a.shape==(96,96,4)
# The service outpaint changed inner pixels and added a checker matte.
# Preserve every original pixel; only generated side strips supply new foliage.
outer=np.zeros((96,96),dtype=bool);outer[:,:16]=True;outer[:,80:]=True
rgb=a[:,:,:3].astype(int)
warm=(rgb[:,:,0]>rgb[:,:,1])&(rgb[:,:,0]>rgb[:,:,2])
neutral=(rgb.max(2)-rgb.min(2)<12)&(rgb.max(2)>110)
remove=outer&(warm|neutral)&(a[:,:,3]>0)
a[remove]=0
a[:,16:80]=np.asarray(orig)
result=Image.fromarray(a)
padded=Image.new("RGBA",(112,96),(0,0,0,0));padded.paste(result,(8,0))
padded.save(ROOT/"cottonwood_complete.png")
assert np.array_equal(np.asarray(padded)[:,24:88],np.asarray(orig))
alpha=padded.getchannel("A");assert alpha.getbbox()[0]>=6 and alpha.getbbox()[2]<=106
meta={"source":str(source),"source_sha256":hashlib.sha256(source.read_bytes()).hexdigest(),"raw_outpaint":"cottonwood_outpaint_raw.png","background_cleanup":"cottonwood_outpaint_transparent.png","original_core_restored_exactly":True,"core_pixel_changes":0,"new_foliage_strips":[[8,24],[88,104]],"removed_matte_pixels":int(remove.sum()),"added_transparent_side_margin":8,"canvas":[112,96],"alpha_bbox":alpha.getbbox(),"trunk_and_foot_global_positions_preserved":True,"colour_interpolation":False}
(ROOT/"tree_repair_preparation.json").write_text(json.dumps(meta,indent=2))
sheet=Image.new("RGBA",(272,120),(35,47,45,255));sheet.paste(orig,(36,18),orig);sheet.paste(padded,(132,18),padded)
draw=ImageDraw.Draw(sheet);draw.text((24,2),"Before",fill="white");draw.text((132,2),"Restored crown",fill="white")
sheet.resize((816,360),Image.Resampling.NEAREST).convert("RGB").save(ROOT/"tree_crown_review.png")
print(json.dumps(meta))
