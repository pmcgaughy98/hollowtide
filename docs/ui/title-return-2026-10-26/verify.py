from pathlib import Path
import json,hashlib,re,difflib
from PIL import Image,ImageDraw
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
owned=json.loads((W/'installed-files.json').read_text())
for rel,h in owned.items():assert sha(L/rel)==h,rel
def methods(s):return {m.group(1):m.group(0).rstrip() for m in re.finditer(r'^func (\w+)\(.*?(?=^func |\Z)',s,re.M|re.S)}
rel='scripts/opening_flow.gd';old=(W/'originals'/rel).read_text();new=(L/rel).read_text();a=methods(old);b=methods(new);exact=[]
for name,body in a.items():
 if name in ('_ready','_build_boot','_finish_boot','_process'):continue
 assert body==b[name],name;exact.append(name)
rel='scripts/creature_opening.gd';old=(W/'originals'/rel).read_text();new=(L/rel).read_text()
oldline='\t\t_launch_hint.text={"keyboard":"Enter to continue","controller":"A to continue","mouse":"Click to continue"}[device]'
assert old.replace(oldline,'\t\t_launch_hint.text=_launch_skip_text()')==new
base=json.loads((W/'protected-before.json').read_text());concurrent=[]
for rel,h in base.items():
 if rel in owned:continue
 if not (L/rel).is_file() or sha(L/rel)!=h:
  concurrent.append(rel)
  if (L/rel).is_file():
   dest=W/'concurrent-at-finish'/rel;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes((L/rel).read_bytes())
for rel in ('scripts/main_menu.gd','scripts/ui/ui_style.gd','scripts/ui/title_settings.gd','project.godot'):
 assert sha(L/rel)==base[rel],rel+' changed during tests'
assert '@export var new_game_confirm_enabled := false' in (L/'scripts/main_menu.gd').read_text()
results={phase:json.loads((W/(phase+'-result.json')).read_text()) for phase in ('before','after','after-legacy')}
assert all(r['failed']==0 for r in results.values())
assert results['before']['metrics'][0]['return_wait_frames']==77
assert all(m['return_wait_frames']==0 for k in ('after','after-legacy') for m in results[k]['metrics'])
diff=''
for rel in owned:diff+=''.join(difflib.unified_diff((W/'originals'/rel).read_text().splitlines(True),(L/rel).read_text().splitlines(True),fromfile='before/'+rel,tofile='after/'+rel))
(W/'source.diff').write_text(diff,encoding='utf-8')
# True-aspect native screenshots, comparison only, never game art.
sheet=Image.new('RGB',(1152,1360),(12,16,20));draw=ImageDraw.Draw(sheet)
for row,(label,p) in enumerate([('FRESH LAUNCH: timed card with a Skip hint',W/'after/normal-auto-launch.png'),('RETURN: main menu before first draw',W/'after/normal-auto-return.png')]):
 draw.text((16,row*680+6),label,fill=(240,225,180));sheet.paste(Image.open(p).convert('RGB'),(0,row*680+24))
sheet.save(W/'title-states.png')
stale=W/'return-before-after.png'
if stale.exists():stale.unlink()
report={'owned':owned,'opening_other_methods_exact':exact,'creature_change_exactly_one_hint_line':True,'main_menu_shared_ui_title_settings_project_exact':True,'C6_still_off':True,'baseline':results['before']['total'],'campaign_native':results['after']['total'],'legacy_native':results['after-legacy']['total'],'return_wait_frames_before':77,'return_wait_frames_after':0,'legacy_exit_warning':'102 ObjectDB instances; raw log retained, not a clean exit claim','concurrent_paths_preserved':concurrent}
(W/'verification.json').write_text(json.dumps(report,indent=2));print(json.dumps(report,indent=2))
