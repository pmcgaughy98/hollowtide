from pathlib import Path
from PIL import Image
import json,runpy,subprocess,sys,os
sys.dont_write_bytecode=True
L=Path(__file__).resolve().parents[3];R=L/'docs/art/slot-candidates';w=runpy.run_path(str(R/'_workflow.py'));clean=runpy.run_path(str(R/'_cleanup.py'))['clean']
def native(sid):
 d=R/'cx-09-road'/sid;s=w['reg'].spec(sid);width,height=s['size']
 if s['alpha']=='binary':
  import numpy as np
  raw=Image.open(d/'raw.png').convert('RGBA');arr=np.array(raw)
  if sid.endswith('.river'):
   # The generator letterboxed the water with opaque black. Preserve the actual painted ribbon.
   visible=(arr[:,:,:3].max(2)>40)&(arr[:,:,3]>64);ys,xs=np.nonzero(visible);assert len(ys)
   crop=(int(xs.min()),int(ys.min()),int(xs.max())+1,int(ys.max())+1);raw=raw.crop(crop)
   part=raw.convert('RGB').resize((width,height),Image.Resampling.BOX).convert('RGBA');canvas=part;top=0
  else:
   box=raw.getchannel('A').point(lambda v:255 if v>=64 else 0).getbbox();assert box,sid+' no art'
   top=12 if sid.endswith('.near') else 0
   crop=box if sid.endswith('.near') else (box[0],0,box[2],raw.height)
   raw=raw.crop(crop)
   part=raw.convert('RGBa').resize((width,height-top),Image.Resampling.BOX).convert('RGBA')
   if sid.endswith('.far'):
    # Hills are solid below the silhouette, never translucent holes in the land.
    a=np.array(part)
    for x in range(width):
     solid=np.nonzero(a[:,x,3]>=64)[0]
     if len(solid):a[int(solid.min()):,x,3]=255
    part=Image.fromarray(a)
   canvas=Image.new('RGBA',(width,height));canvas.alpha_composite(part,(0,top))
  canvas.save(d/'native-strip.png')
  env=os.environ.copy();env['PYTHONDONTWRITEBYTECODE']='1'
  cmd=[sys.executable,'-B',str(L/'tools/art/prepare_slot.py'),sid,str(d/'native-strip.png'),str(d/'prepared.png')]
  r=subprocess.run(cmd,cwd=L,env=env,capture_output=True,text=True);assert r.returncode==0,r.stdout+r.stderr
  (d/'prepare-native-strip.log').write_text(r.stdout+r.stderr)
  (d/'strip-layout.json').write_text(json.dumps({'canvas':[width,height],'clear_top_rows':top,'raw_crop':list(crop),'strategy':'fixed strip width; retain the painted ribbon/foreground bounds, solid hills below silhouette, near12-row clearance; raw unchanged'},indent=2))
 return clean('cx-09-road',sid)
