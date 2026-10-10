from pathlib import Path
import shutil,json
from PIL import Image
W=Path(__file__).parent
L=Path('C:/Users/pmcga/dev/hollowtide')
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
S=Path('C:/Users/pmcga/.codex/generated_images/01a11b73-6d5a-78a3-819c-fd3b9ced7188/exec-c17e21f3-6543-492f-af42-ea92ae0e14f5.png')
def cp(s,d):d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(s,d)
for r in ['scripts/town/wayline_hall_painter.gd','assets/sprites/world/wayline_hall_2026_10_09/wayline_hall_native.png']:
    cp(L/r,W/'originals'/r);cp(L/r,C/r)
cp(L/'scripts/town/highbank_ground_painter.gd',C/'tools/debug/home_ground_before.gd')
cp(S,W/'sources/home_generated_original.png')
im=Image.open(S).convert('RGBA')
bbox=im.getchannel('A').point(lambda x:255 if x>1 else 0).getbbox()
out=W/'candidate/assets/sprites/world/home_2026_10_09/home_native.png'
out.parent.mkdir(parents=True,exist_ok=True)
im.crop(bbox).resize((120,120),Image.Resampling.NEAREST).save(out)
(W/'art-preparation.json').write_text(json.dumps({'source':str(S),'original_size':im.size,'padding_bounds_alpha_gt_1':bbox,'native_size':[120,120],'alpha_inside_crop':'preserved','resize':'nearest'},indent=2))
p=W/'candidate/scripts/town/highbank_ground_painter.gd'
s=p.read_text().replace('var hall_ground: Image','var hall_ground: Image\n\tvar home_ground: Image')
s=s.replace('hall_ground = img.get_region(px)','hall_ground = img.get_region(px)\n\t\t\tif place["id"] == "home":\n\t\t\t\thome_ground = img.get_region(px)')
s=s.replace('return load("res://scripts/town/wayline_hall_painter.gd").apply(img, hall_ground)','img = load("res://scripts/town/wayline_hall_painter.gd").apply(img, hall_ground)\n\tif ResourceLoader.exists("res://scripts/town/home_painter.gd"):\n\t\timg = load("res://scripts/town/home_painter.gd").apply(img, home_ground)')
s=s.replace('beneath the hall','beneath the hall and home')
p.write_text(s)
s=(L/'scripts/town/wayline_hall_painter.gd').read_text()
s=s.replace('Wayline Hall','Home').replace('wayline_hall_2026_10_09/wayline_hall_native','home_2026_10_09/home_native').replace('hall','home')
(W/'candidate/scripts/town/home_painter.gd').write_text(s)
for f in ['run.py']:
    p=W/f;p.write_text(p.read_text().replace('scripts/town/wayline_hall_painter.gd','scripts/town/home_painter.gd'))
print('Staged Home only, crop',bbox,'door pixel',Image.open(out).getpixel((60,108)))
