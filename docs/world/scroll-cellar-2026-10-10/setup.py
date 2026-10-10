from pathlib import Path
import shutil,json
from PIL import Image
W=Path(__file__).parent
for name in ['prepare.py','scroll_check.gd']:
 p=W/name;p.write_text(p.read_text().replace('hollowtide-selout-scroll-20261010','hollowtide-scroll-cellar-20261010').replace('scroll_keeper_2026_10_10','scroll_cellar_2026_10_10'))
exec(compile((W/'prepare.py').read_text(),str(W/'prepare.py'),'exec'))
for n,f in [('rejected_direction.png','exec-4d2d755b-5d3f-43fc-a10c-d08cdc0fc972.png'),('cellar_original.png','exec-fa85aa39-5ebb-426a-b043-0dbcbf74d5e4.png')]:
 shutil.copy2(Path('C:/Users/pmcga/.codex/generated_images/01a11b73-6d5a-78a3-819c-fd3b9ced7188')/f,W/'sources'/n)
im=Image.open(W/'sources/cellar_original.png').convert('RGBA');box=im.getbbox(); cropped=im.crop(box)
scale=min(132/cropped.width,115/cropped.height); size=tuple(round(n*scale) for n in cropped.size)
native=Image.new('RGBA',(144,120));native.paste(cropped.resize(size,Image.Resampling.NEAREST),(4,0))
native.save(W/'candidate/assets/sprites/world/scroll_cellar_2026_10_10/scroll_native.png')
(W/'preparation.json').write_text(json.dumps({'crop':box,'native_size':size,'offset':[4,0],'canvas':[144,120],'method':'transparent padding crop, uniform nearest resize only'},indent=2))
shutil.copy2(W/'originals/scripts/town/building_exteriors.gd',W/'candidate/scripts/town/building_exteriors.gd')
print('Native prepared',box,size)
