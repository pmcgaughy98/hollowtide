from pathlib import Path
from PIL import Image
import runpy,json,hashlib
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide')
a=runpy.run_path(str(W/'originals/tools/ui/build_icons.py'))
b=runpy.run_path(str(W/'build_icons.py'))
assert {k:v for k,v in b['ICONS'].items() if k!='item/parcel'}==a['ICONS']
im=Image.open(W/'parcel.png').convert('RGBA')
assert im.size==(32,32)
assert set(im.getchannel('A').get_flattened_data())=={0,255}
allowed={a['OUTLINE']}|{a['hex_rgba'](h) for h in a['ICONS']['item/scroll'][0].values()}
assert {p for p in im.get_flattened_data() if p[3]}==allowed
for y in range(0,32,2):
    for x in range(0,32,2):assert len(set(im.crop((x,y,x+2,y+2)).get_flattened_data()))==1
protected=json.loads((W/'protected.json').read_text())
changed=[rel for rel,sha in protected.items() if hashlib.sha256((R/rel).read_bytes()).hexdigest()!=sha]
assert not changed,changed
result={'size':[32,32],'logical_grid':[16,16],'hard_alpha':True,'existing_scroll_palette_exact':True,'opaque_colors':len(allowed),'legacy_icon_recipes_exact':len(a['ICONS']),'protected_existing_files_exact':len(protected),'new_asset_sha256':hashlib.sha256((W/'parcel.png').read_bytes()).hexdigest()}
(W/'asset-verification.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
