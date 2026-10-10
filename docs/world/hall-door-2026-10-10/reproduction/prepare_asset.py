from pathlib import Path
from PIL import Image
import shutil,json
W=Path(__file__).parent
source=Path('C:/Users/pmcga/.codex/generated_images/01a11b73-6d5a-78a3-819c-fd3b9ced7188/exec-e17a7081-d1ac-4506-90e0-48aa7ede2e45.png')
(W/'sources').mkdir(exist_ok=True); (W/'review').mkdir(exist_ok=True)
shutil.copy2(source,W/'sources/hall_generated_original.png')
image=Image.open(source).convert('RGBA')
bounds=image.getchannel('A').point(lambda a:255 if a>1 else 0).getbbox()
native=image.crop(bounds).resize((240,144),Image.Resampling.NEAREST)
native.save(W/'review/generated_native.png')
(W/'asset-preparation.json').write_text(json.dumps({'source_size':image.size,'alpha_bounds':bounds,'whole_native':native.size,'method':'alpha padding crop and nearest native preparation; generated source untouched'},indent=2))
print('Prepared whole generated reference for doorway extraction',bounds)
