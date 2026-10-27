from pathlib import Path
from PIL import Image,ImageDraw
import hashlib,json,difflib
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
owned=json.loads((W/'installed-files.json').read_text());baseline=json.loads((W/'protected-before.json').read_text())
for rel,h in owned.items():assert sha(L/rel)==h,rel
audit=json.loads((W/'audit.json').read_text());holds={'sail_slash':{4:3,8:7,12:11},'mark_glyph':{0:15,12:11,13:11}}
manifest=[]
for row in audit:
 name,i=row['name'],row['frame'];rel=f'assets/sprites/arena/vfx/{name}/f{i:02d}.png';p=L/rel;im=Image.open(p).convert('RGBA')
 assert im.size==(32,32) and im.getchannel('A').getbbox(),rel
 if i in holds[name]:
  donor=holds[name][i];assert sha(p)==sha(W/f'originals/assets/sprites/arena/vfx/{name}/f{donor:02d}.png')
 else:assert sha(p)==row['old_sha'],rel
 manifest.append({'path':rel,'old_sha':row['old_sha'],'sha256':sha(p),'hold_source_frame':holds[name].get(i),'size':list(im.size),'visible_pixels':sum(v>0 for v in im.getchannel('A').tobytes())})
for name in holds:
 rel=f'docs/creatures/arena-starters-2026-10-07/vfx/{name}_sheet.png';assert sha(L/rel)==sha(W/'originals'/rel)
 for mode in ('before','after'):
  grid=Image.new('RGB',(8*104,2*122),(26,29,35));dr=ImageDraw.Draw(grid)
  for i in range(16):
   rel=f'assets/sprites/arena/vfx/{name}/f{i:02d}.png'
   im=Image.open((W/'originals'/rel) if mode=='before' else (W/f'native-{name}-f{i:02d}.png')).convert('RGBA')
   px=i%8*104+4;py=i//8*122+20
   thumb=im.resize((96,96),Image.Resampling.NEAREST);grid.paste(thumb,(px,py),thumb)
   dr.text((px,py-17),f'f{i:02d}'+(' hold' if mode=='after' and i in holds[name] else ''),fill=(255,215,120) if i in holds[name] else 'white')
  grid.save(W/f'{name}-{mode}.png')
 # GIFs use the actual native captures; same 16 frames and illustrative 50ms/frame.
 frames=[]
 for i in range(16):
  bg=Image.new('RGB',(160,160),(26,29,35));im=Image.open(W/f'native-{name}-f{i:02d}.png').convert('RGBA').resize((128,128),Image.Resampling.NEAREST);bg.paste(im,(16,16),im);frames.append(bg)
 frames[0].save(W/f'{name}-native-loop.gif',save_all=True,append_images=frames[1:],duration=50,loop=0,disposal=2)
concurrent=[]
for rel,h in baseline.items():
 if rel not in owned and (not (L/rel).exists() or sha(L/rel)!=h):
  concurrent.append(rel)
  if (L/rel).is_file():
   d=W/'concurrent-at-finish'/rel;d.parent.mkdir(parents=True,exist_ok=True);d.write_bytes((L/rel).read_bytes())
for rel in ('scripts/dungeon/dungeon.gd','scripts/arena/arena_prototype.gd','scripts/town/team_state.gd','scripts/ui/ui_style.gd','project.godot','export_presets.cfg'):assert sha(L/rel)==baseline[rel],rel
native=json.loads((W/'native-result.json').read_text());assert native['failed']==0 and native['total']==67
assert 'PASS 1' in (W/'official.log').read_text()
rel='tools/arena/slice_vfx.py';diff=''.join(difflib.unified_diff((W/'originals'/rel).read_text().splitlines(True),(L/rel).read_text().splitlines(True),fromfile='before/'+rel,tofile='after/'+rel));(W/'source.diff').write_text(diff)
(W/'manifest.json').write_text(json.dumps(manifest,indent=2))
result={'changed_pngs':6,'unchanged_other_frames':26,'nonempty_final_frames':32,'original_source_sheets_unchanged':True,'new_drawn_frames':0,'repair':'exact neighboring-frame holds for truly blank source cells','native_checks':native['total'],'native_failures':native['failed'],'maintained_dungeon_vfx':'PASS','concurrent_paths_preserved':concurrent,'gameplay_and_rules_unchanged':True}
(W/'verification.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
