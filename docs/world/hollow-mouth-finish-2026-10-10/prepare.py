from pathlib import Path
from PIL import Image
import shutil,json
W=Path(__file__).parent
src=Path('C:/Users/pmcga/.codex/generated_images/01a11b73-6d5a-78a3-819c-fd3b9ced7188/exec-e3dda3c3-2112-4186-9fec-cd04e4dd8ae2.png')
shutil.copy2(src,W/'sources/mouth_original.png')
im=Image.open(src).convert('RGBA');box=im.getbbox();im=im.crop(box)
scale=min(46/im.width,46/im.height);size=tuple(round(n*scale) for n in im.size);offset=((48-size[0])//2,48-size[1])
native=Image.new('RGBA',(48,48));native.paste(im.resize(size,Image.Resampling.NEAREST),offset);native.save(W/'candidate/assets/sprites/world/hollow_mouth_2026_10_10/mouth_native.png')
(W/'preparation.json').write_text(json.dumps({'crop':box,'scaled_size':size,'offset':offset,'canvas':[48,48],'method':'transparent padding crop and uniform nearest scaling only; generated alpha retained'},indent=2))
print('Native preparation',size,offset)
