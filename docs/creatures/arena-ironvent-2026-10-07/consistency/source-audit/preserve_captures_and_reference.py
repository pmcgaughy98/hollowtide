"""Preserve current native captures and add 3x game-size source-reference contacts.
Writes only this source-audit evidence folder; no project file is altered.
"""
from pathlib import Path
import json, shutil, hashlib, importlib.util
from PIL import Image, ImageDraw
P=Path('C:/Users/pmcga/dev/hollowtide'); W=Path('C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/arena-ironvent-consistency-2026-10-07/source-audit')
manifest_path=W/'before-manifest.json'; m=json.loads(manifest_path.read_text(encoding='utf-8-sig')); captures=[]
for p in sorted((P/'docs/creatures/arena-ironvent-2026-10-07').glob('*.png')):
    rel=p.relative_to(P).as_posix(); q=W/'originals'/rel; q.parent.mkdir(parents=True,exist_ok=True)
    if q.exists(): assert q.read_bytes()==p.read_bytes(),rel
    else: shutil.copy2(p,q)
    captures.append({'path':rel,'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bytes':p.stat().st_size})
m['capture_originals']=captures; manifest_path.write_text(json.dumps(m,indent=2),encoding='utf8')
spec=importlib.util.spec_from_file_location('arena_downscale_readonly',P/'tools/arena/downscale.py'); mod=importlib.util.module_from_spec(spec); spec.loader.exec_module(mod)
for n in ('cinderhide','clinkerhide','ironvent'):
    base=mod.shrink(Image.open(W/'originals/docs/creatures/arena-starters-2026-10-07/forms'/f'{n}.png').convert('RGBA'),3)
    row=Image.open(W/'contacts'/f'{n}-facings-before-game3x.png').convert('RGBA'); cw=row.width//8; out=Image.new('RGBA',(row.width+cw,row.height),(45,55,58,255)); out.alpha_composite(row,(cw,0)); d=ImageDraw.Draw(out); d.text((5,4),'Base reference',fill='white'); shown=base.resize((base.width*3,base.height*3),Image.Resampling.NEAREST); out.alpha_composite(shown,((cw-shown.width)//2,20+(row.height-20-shown.height)//2)); out.convert('RGB').save(W/'contacts'/f'{n}-base-and-facings-before-game3x.png')
print(json.dumps({'native_captures_preserved':len(captures),'game_contacts_with_base':3},indent=2))
