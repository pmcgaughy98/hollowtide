from pathlib import Path
from PIL import Image
import numpy as np,json,hashlib
ROOT=Path(__file__).resolve().parent/"polish"
src=ROOT/"dispatch_hall_complete.png"
im=Image.open(src).convert("RGBA");a=np.array(im);original=a.copy()
# Remove the unintended miniature person. Reuse the adjacent eight-pixel
# brick pattern at the same rows, retaining the wall's material and baseline.
for y in range(104,113):
 for x in range(23,43):a[y,x]=original[y,16+((x-16)%8)]
a[113:128,23:43]=0
outside=np.ones((128,128),bool);outside[104:128,23:43]=False
assert np.array_equal(a[outside],original[outside])
fixed=Image.fromarray(a);padded=Image.new("RGBA",(136,136));padded.paste(fixed,(4,4))
padded.save(ROOT/"dispatch_hall_prepared.png")
meta={"raw_source_sha256":hashlib.sha256(src.read_bytes()).hexdigest(),"canvas":[136,136],"alpha_bbox":padded.getchannel("A").getbbox(),"stray_figure_region":[23,104,43,128],"material_repair":"Same-row existing eight-pixel brick pattern from x16..23; pixels outside the small repair rectangle unchanged.","extra_transparent_margin":4,"foot_baseline":122,"sprite_offset_y":-54,"colour_interpolation":False}
(ROOT/"dispatch_hall_preparation.json").write_text(json.dumps(meta,indent=2))
print(json.dumps(meta))
