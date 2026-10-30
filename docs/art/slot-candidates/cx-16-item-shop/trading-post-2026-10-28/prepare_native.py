"""Reproduce cx-16 trading-post native registration and authorized pixel cleanup. Raw remains untouched."""
import hashlib, json, sys
from pathlib import Path
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[5]
sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'tools/art'))
import slot_registry as reg
import prepare_slot
# Load only the NumPy-only cleanup helpers; the full module also imports SciPy,
# unavailable in this runtime. Shared source and all validators stay unchanged.
import ast, types
helper_names={'luma','snap_index','neighbours8','orphan_mask','_pair','clear_orphans'}
helper_path=ROOT/'tools/art/clean_slot.py'
tree=ast.parse(helper_path.read_text())
module=ast.Module(body=[n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name in helper_names],type_ignores=[])
# The helpers call each other, so give them the same globals.
helper_globals={'np':np}
exec(compile(module,str(helper_path),'exec'),helper_globals)
clean_slot=types.SimpleNamespace(**{n:helper_globals[n] for n in helper_names})
B=Path(__file__).resolve().parent
D=B/'town.building.shop'
s=reg.spec('town.building.shop')
raw=Image.open(D/'raw.png').convert('RGBA')
small=raw.convert('RGBa').resize(tuple(s['size']),Image.Resampling.BOX).convert('RGBA')
a=np.array(small)
a[:,:,3]=np.where(a[:,:,3]>=128,255,0)
a[a[:,:,3]==0,:3]=0
a[0]=0;a[:,0]=0;a[:,-1]=0
ys=np.nonzero((a[:,:,3]>0).any(1))[0]
dy=s['anchor'][1]-int(ys.max())
if dy>0:
 a[dy:]=a[:-dy];a[:dy]=0
elif dy<0:
 a[:dy]=a[-dy:];a[dy:]=0
native=prepare_slot.snap(Image.fromarray(a),s)
a=np.array(native)
pal=reg.palette(s)
m=a[:,:,3]>0
idx=np.full(m.shape,-1,int)
idx[m]=clean_slot.snap_index(a[:,:,:3],pal)[m]
before=int(clean_slot.orphan_mask(idx).sum())
clean_slot.clear_orphans(idx,pal,keep=40.0)
x,y,w,h=s['door_px']
dark=int(((pal.astype(int)-np.array([23,28,24]))**2).sum(1).argmin())
# Enforce the exact open doorway rectangle; the engine supplies its door leaves and step.
idx[y:y+h,x:x+w]=dark
out=np.zeros(a.shape,np.uint8)
solid=idx>=0
out[solid,:3]=pal[idx[solid]]
out[solid,3]=255
Image.fromarray(out).save(D/'native-input.png')
notes={'raw_size':list(raw.size),'native_size':s['size'],'registration_shift_y':dy,'resampling':'premultiplied BOX, alpha >=128','orphans_before':before,'orphans_after':int(clean_slot.orphan_mask(idx).sum()),'changed_from_initial_snap':int(np.any(out!=a,axis=2).sum()),'opaque_before':int(m.sum()),'opaque_after':int(solid.sum()),'door_box':s['door_px'],'door_colour':pal[dark].tolist(),'cleanup':'existing clean_slot.clear_orphans, keep=40; exact dark doorway; no shared tool changes','raw_sha256':hashlib.sha256((D/'raw.png').read_bytes()).hexdigest(),'registry_sha256':reg.registry_hash()}
(D/'pixel-cleanup.json').write_text(json.dumps(notes,indent=2)+'\n')
print(json.dumps(notes))