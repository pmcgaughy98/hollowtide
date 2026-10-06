"""Rebuild the two exact native road-cap crops using archived sources only.
Run in a COPY of the archive. No game/project path, API or renderer is used.
"""
from pathlib import Path
from PIL import Image
import json,hashlib
ROOT=Path(__file__).resolve().parent
A=ROOT/'world-detail-audit-2026-10-05'
records=json.loads((A/'candidate-approaches/contracts.json').read_text(encoding='utf-8'))
outputs=[]
for r in records:
 p=A/'candidate-approaches/sources'/Path(r['source']).name
 assert hashlib.sha256(p.read_bytes()).hexdigest()==r['source_sha256'],r['id']
 im=Image.open(p).convert('RGBA');patch=im.crop(tuple(r['source_rect']))
 assert patch.size==tuple(r['max_canvas'])
 target=A/'candidate-approaches'/(r['id']+'.png');patch.save(target)
 assert hashlib.sha256(target.read_bytes()).hexdigest()==r['patch_sha256'],r['id']
 outputs.append({'name':r['id'],'size':list(patch.size),'source_crop_RGBA_exact':patch.tobytes()==im.crop(tuple(r['source_rect'])).tobytes(),'sha256':hashlib.sha256(target.read_bytes()).hexdigest()})
print(json.dumps({'outputs':outputs},indent=2))
