from pathlib import Path
from PIL import Image
import hashlib,json
W=Path(__file__).parent
R=Path('C:/Users/pmcga/dev/hollowtide')
checks=[]
for f in [1,2,3,4]:
    a=json.loads((W/f'after/floor{f}-data.json').read_text())
    b=json.loads((W/f'after-live/floor{f}-data.json').read_text())
    assert a==b
    for kind in ['raw','native']:
        a=Image.open(W/f'after/floor{f}-{kind}.png').convert('RGBA')
        b=Image.open(W/f'after-live/floor{f}-{kind}.png').convert('RGBA')
        assert a.size==b.size and a.tobytes()==b.tobytes(),(f,kind)
    checks.append({'floor':f,'layout_exact':True,'raw_exact':True,'native_shader_exact':True})
protected=json.loads((W/'protected.json').read_text())
changed=[]
for rel,sha in protected.items():
    p=R/rel
    if not p.exists() or hashlib.sha256(p.read_bytes()).hexdigest()!=sha:changed.append(rel)
assert changed==['scripts/dungeon/riverbank_painter.gd'], changed
for name in ['riverbank_painter.gd','rootbank_detail.gd']:
    assert (W/name).read_bytes()==(R/'scripts/dungeon'/name).read_bytes()
out={'native_floors':checks,'protected_existing_source_count':len(protected),'changed_existing_sources':changed,'installed_candidates_exact':True}
(W/'live-verification.json').write_text(json.dumps(out,indent=2))
print(json.dumps(out,indent=2))
