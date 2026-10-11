from pathlib import Path
from PIL import Image
import hashlib,json
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide')
a=Image.open(W/'original.png').convert('RGBA')
b=Image.open(W/'candidate.png').convert('RGBA')
assert b.size==(a.width,a.height+8)
assert b.crop((0,0,a.width,a.height)).tobytes()==a.tobytes()
assert b.crop((0,a.height,b.width,b.height)).tobytes()==bytes(b.width*8*4)
assert a.crop((30,8,70,48)).tobytes()==b.crop((30,8,70,48)).tobytes()
protected=json.loads((W/'protected.json').read_text())
changed=[p for p,sha in protected.items() if hashlib.sha256((R/p).read_bytes()).hexdigest()!=sha]
assert not changed,changed
report={'before_size':a.size,'after_size':b.size,'original_rgba_exact':True,'original_coordinates_exact':True,'portrait_source_crop_exact':True,'added_rows':8,'added_rows_fully_transparent':True,'original_alpha_bounds':a.getchannel('A').getbbox(),'padded_alpha_bounds':b.getchannel('A').getbbox(),'protected_files_exact':len(protected),'changed_protected_files':changed}
(W/'verification.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report,indent=2))
