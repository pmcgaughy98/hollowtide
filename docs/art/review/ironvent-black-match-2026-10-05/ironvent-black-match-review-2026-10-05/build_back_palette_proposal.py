from pathlib import Path
from PIL import Image
import numpy as np,json,hashlib
root=Path(__file__).resolve().parent
manifest=json.loads((root/'back-palette-proposal.json').read_text())
for name,spec in manifest['assets'].items():
 src=Path(spec['source'])
 assert hashlib.sha256(src.read_bytes()).hexdigest()==spec['source_sha256'],f'Changed source: {name}'
 a=np.asarray(Image.open(src).convert('RGBA'));b=a.copy()
 for m in manifest['mapping']:
  hit=(a[:,:,3]>0)&np.all(a[:,:,:3]==m['front_title_rgb'],axis=2)
  b[hit,:3]=m['back_reference_rgb']
 assert np.array_equal(a[:,:,3],b[:,:,3])
 assert np.array_equal(a[a[:,:,3]==0],b[a[:,:,3]==0])
 dst=root/'proposals'/f'ironvent-{name}-back-palette-proposal.png'
 Image.fromarray(b,'RGBA').save(dst)
 assert hashlib.sha256(dst.read_bytes()).hexdigest()==spec['proposal_sha256']
 print(name,spec['mapped_pixels'],'back-palette RGB pixels; exact source geometry retained')
