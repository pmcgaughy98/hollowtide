from pathlib import Path
from PIL import Image
import shutil,json
W=Path(__file__).parent
names={'coherent_offcentre_original':'exec-2efe2cad-784d-414a-a814-404daee5fd93.png','coherent_centred_original':'exec-0028548c-999f-431c-b912-cc1e857e6dc1.png'}
root=Path('C:/Users/pmcga/.codex/generated_images/01a11b73-6d5a-78a3-819c-fd3b9ced7188')
for name,f in names.items(): shutil.copy2(root/f,W/'sources'/(name+'.png'))
image=Image.open(root/names['coherent_centred_original']).convert('RGBA')
bounds=image.getchannel('A').point(lambda a:255 if a>1 else 0).getbbox()
native=image.crop(bounds).resize((240,144),Image.Resampling.NEAREST)
asset=W/'candidate/assets/sprites/world/wayline_hall_2026_10_10/wayline_hall_native.png'
native.save(asset)
rejected=W/'candidate/assets/sprites/world/wayline_hall_2026_10_10/hall_entrance_native.png'
shutil.copy2(rejected,W/'sources/rejected_entrance_insert_native.png'); rejected.unlink()
text=(W/'originals/scripts/town/wayline_hall_painter.gd').read_text()
old='res://assets/sprites/world/wayline_hall_2026_10_09/wayline_hall_native.png'
new='res://assets/sprites/world/wayline_hall_2026_10_10/wayline_hall_native.png'
text=text.replace('const ART = "'+old+'"','const ART = "'+new+'"\nconst ORIGINAL_ART = "'+old+'"')
text=text.replace('\tif not ResourceLoader.exists(ART):\n\t\treturn img\n\tvar art: Image = load(ART).get_image()','\t# One coherent complete sprite, not an entrance pasted over the old facade.\n\tvar source: String = ART if ResourceLoader.exists(ART) else ORIGINAL_ART\n\tif not ResourceLoader.exists(source):\n\t\treturn img\n\tvar art: Image = load(source).get_image()')
(W/'candidate/scripts/town/wayline_hall_painter.gd').write_text(text)
(W/'asset-preparation.json').write_text(json.dumps({'source_size':image.size,'alpha_bounds':bounds,'native_size':native.size,'method':'whole sprite alpha-padding crop/nearest fit; no inserted/copy-pasted section','scope_world_rect':[456,24,240,144],'original_png':'preserved untouched; fallback','generation_calls':3,'rejected':'localized insert rejected by Preston; offcentre whole redraw not installed'},indent=2))
print('Prepared one complete centred Hall sprite; rejected insert removed from runtime candidate.')
