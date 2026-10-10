from pathlib import Path
from PIL import Image
import json,shutil
W=Path(__file__).parent
paths=[Path('C:/Users/pmcga/.codex/generated_images/01a11b73-6d5a-78a3-819c-fd3b9ced7188/exec-ac26a21b-d128-41f5-a5da-9aa4267415c2.png'),Path('C:/Users/pmcga/.codex/generated_images/01a11b73-6d5a-78a3-819c-fd3b9ced7188/exec-e6a06ff7-63b4-4523-9d57-e79f260e7d98.png')]
(W/'sources').mkdir(exist_ok=True)
for p in paths:shutil.copy2(p,W/'sources'/p.name)
im=Image.open(paths[-1]).convert('RGBA');bbox=im.getchannel('A').point(lambda a:255 if a>1 else 0).getbbox()
native=im.crop(bbox).resize((240,144),Image.Resampling.NEAREST)
out=W/'candidate/assets/sprites/world/wayline_hall_2026_10_09/wayline_hall_native.png'
native.save(out)
record={'source_dimensions':list(im.size),'source_visible_alpha_bounds':list(bbox),'native_dimensions':list(native.size),'preparation':'Trim nearly transparent padding using alpha > 1 bounds (all alpha inside kept); nearest-neighbor preparation to layout 240x144. Source PNGs untouched.','native_door_tile':[120,120,24,24],'door_center_sample':list(native.getpixel((132,138))),'painted_pixels':sum(a>0 for a in native.getchannel('A').get_flattened_data())}
(W/'art-preparation.json').write_text(json.dumps(record,indent=2));print(json.dumps(record,indent=2))
