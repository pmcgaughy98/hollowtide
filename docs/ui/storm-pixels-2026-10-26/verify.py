from pathlib import Path
import hashlib,json,re,difflib
from PIL import Image,ImageDraw
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');rel='scripts/storm_open.gd'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
owned=json.loads((W/'installed-files.json').read_text());assert sha(L/rel)==owned[rel]
old=(W/'originals'/rel).read_text();new=(L/rel).read_text()
def methods(s):return {m.group(1):m.group(0).rstrip() for m in re.finditer(r'^func (\w+)\(.*?(?=^func |\Z)',s,re.M|re.S)}
before=methods(old);after=methods(new);exact=[]
for name,body in before.items():
 if name=='_draw_soul':continue
 assert body==after[name],name;exact.append(name)
assert new.count('soul.draw_circle')==0
assert old[:old.index('var reduce_motion')]==new[:new.index('# Authored on the same')]
assert old[old.index('var reduce_motion'):old.index('func _ready')]==new[new.index('var reduce_motion'):new.index('func _ready')]
o=before['_draw_soul'];n=after['_draw_soul']
assert o[o.index('\tif white >'):]==n[n.index('\tif white >'):]
assert o[:o.index('\t\tsoul.draw_circle')]==n[:n.index('\t\t_draw_soul_cluster')]
baseline=json.loads((W/'before-result.json').read_text());native=json.loads((W/'after-result.json').read_text());flows=json.loads((W/'real-flow-result.json').read_text())
assert baseline['failed']==native['failed']==0 and len(flows)==2 and all(not f['failures'] for f in flows)
base=json.loads((W/'protected-before.json').read_text());concurrent=[]
for path,h in base.items():
 if path==rel:continue
 if not (L/path).is_file() or sha(L/path)!=h:
  concurrent.append(path)
  if (L/path).is_file():
   dest=W/'concurrent-at-finish'/path;dest.parent.mkdir(parents=True,exist_ok=True);shutil_src=L/path;dest.write_bytes(shutil_src.read_bytes())
diff=''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='before/'+rel,tofile='after/'+rel));(W/'source.diff').write_text(diff,encoding='utf-8')
# Native screenshots only. Magnified panels are nearest-neighbour proof, never runtime assets.
sheet=Image.new('RGB',(1024,1060),(14,16,25));d=ImageDraw.Draw(sheet)
for col,phase in enumerate(('before','after')):
 for row,case in enumerate(('landed','bloom')):
  im=Image.open(W/phase/(case+'.png')).convert('RGB').crop((384,120,624,360)).resize((480,480),Image.Resampling.NEAREST)
  x=col*512+16;y=row*530+36;sheet.paste(im,(x,y));d.text((x,y-23),phase.upper()+' / '+case,fill=(244,230,186))
sheet.save(W/'before-after.png')
result={'owned':owned,'all_other_original_methods_exact':exact,'state_and_animation_inputs_exact':True,'white_overlay_exact':True,'no_circle_calls_in_storm_soul':True,'baseline':baseline['total'],'native_visual':native['total'],'native_real_flow':sum(f['checks'] for f in flows),'concurrent_paths_preserved':concurrent}
(W/'verification.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
