from pathlib import Path
import json,os,runpy,subprocess,sys
from PIL import Image
sys.dont_write_bytecode=True
L=Path(__file__).resolve().parents[3];R=L/'docs/art/slot-candidates';w=runpy.run_path(str(R/'_workflow.py'));clean=runpy.run_path(str(R/'_cleanup.py'))['clean']
def derive(batch,source,prompt):
 ids=w['BATCHES'][batch];fw,fh=(336,240) if batch=='cx-03-shop-room' else (288,216)
 # One room painting, exact native crops: this keeps the five shared strip boundaries coherent.
 master=Image.open(source).convert('RGB').resize((fw,fh),Image.Resampling.BOX).convert('RGBA')
 # The generator centers the exit between tiles; the game's exits are tile 7/6.
 # Native door alignment is part of Preston's authorized exact-box cleanup.
 import numpy as np
 a=np.array(master);old=a.copy();dx=fw//2
 a[fh-24:fh,dx-36:dx+36]=a[fh-24:fh,48:120]
 a[fh-32:fh-24,dx-40:dx+40]=a[fh-32:fh-24,24:104]
 a[fh-24:fh,dx:dx+24]=a[fh-48:fh-24,dx:dx+24]
 # Two slim timber jambs, no header blocking the walking opening.
 a[fh-24:fh,dx-2:dx,:3]=[65,43,26];a[fh-24:fh,dx+24:dx+26,:3]=[65,43,26]
 master=Image.fromarray(a)
 (R/batch/'room-door-alignment.json').write_text(json.dumps({'door_px':[dx,fh-24,24,24],'source':'town_room.gd room door tile','changed_pixels':int(np.any(a!=old,axis=2).sum()),'raw_untouched':True},indent=2))
 master.save(R/batch/'native-room-master.png')
 (R/batch/'master-prompt.txt').write_text(prompt,encoding='utf-8')
 boxes={'north':(0,0,fw,48),'south':(0,fh-24,fw,fh),'west':(0,48,24,fh-24),'east':(fw-24,48,fw,fh-24),'floor':(24,48,fw-24,fh-24)}
 for sid in ids:
  w['ingest'](batch,sid,source,prompt+'\nThis slot is the '+sid.rsplit('.',1)[-1]+' crop of the single coherent room master.')
  d=R/batch/sid;box=boxes[sid.rsplit('.',1)[-1]];master.crop(box).save(d/'native-crop.png')
  ledger=json.loads((d/'ledger.json').read_text());ledger['references']=[str(R/('_references_'+batch+'.png'))];ledger['shared_generation']='one whole-room image generation shared by these five strips';ledger['native_master_size']=[fw,fh];ledger['native_crop_box']=box;(d/'ledger.json').write_text(json.dumps(ledger,indent=2))
  env=os.environ.copy();env['PYTHONDONTWRITEBYTECODE']='1'
  r=subprocess.run([sys.executable,'-B',str(L/'tools/art/prepare_slot.py'),sid,str(d/'native-crop.png'),str(d/'prepared.png')],cwd=L,env=env,capture_output=True,text=True);assert r.returncode==0
  (d/'prepare-native-crop.log').write_text(r.stdout+r.stderr)
  clean(batch,sid)
 assembly=Image.new('RGBA',(fw,fh))
 for sid in ids:
  box=boxes[sid.rsplit('.',1)[-1]];assembly.alpha_composite(Image.open(R/batch/sid/'prepared.png').convert('RGBA'),box[:2])
 assembly.save(R/batch/'assembly.png')
