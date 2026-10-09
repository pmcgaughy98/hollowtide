from pathlib import Path
from datetime import datetime,timezone
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
A=L/'docs/creatures/texture-consistency-2026-10-08'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
rel='scripts/arena/arena_prototype.gd'
original=(W/'arena-original.gd').read_bytes()
assert (L/rel).read_bytes()==original,'Claude changed arena since tested snapshot; inspect and retest before insertion'
newline=b'\r\n' if b'\r\n' in original else b'\n'
needle=b'\tvar art := _load_art(form[0])'+newline
assert original.count(needle)==1
updated=original.replace(needle,b'\tpreload("res://scripts/arena/creature_finish.gd").apply(sprite)'+newline+needle)
assert updated.replace(b'\r\n',b'\n')==(C/rel).read_bytes().replace(b'\r\n',b'\n'),'Tested code differs'
checks=json.loads((W/'checks.json').read_text());integration=json.loads((W/'integration-checks.json').read_text())
assert len(checks['forms'])==30 and checks['texture_swaps']==2160 and not checks['failures'] and not integration['failures']
for tag in ['texture_check','texture_gallery','integration_check']:
 log=(W/(tag+'.log')).read_text(errors='replace')
 assert 'SCRIPT ERROR' not in log and 'Failed loading resource' not in log and 'SHADER ERROR' not in log,tag
for row in checks['forms']:
 assert row['erased_pixels']==row['beyond_one_pixel']==0 and row['textures']==72
 for p in (L/'assets/sprites/arena'/row['form']/'small').glob('*.png'):
  assert sha(p)==sha(C/p.relative_to(L)),'Art changed since rendered '+str(p)
new=['scripts/arena/creature_finish.gd','scripts/arena/creature_finish.gdshader']
assert not A.exists()
for r in new:assert not (L/r).exists()
guard={}
for folder in ['assets','scripts','scenes','data','tools']:
 for p in (L/folder).rglob('*'):
  if p.is_file() and p.suffix not in ['.uid','.import','.pyc'] and '__pycache__' not in p.parts and p.relative_to(L).as_posix()!=rel:
   guard[p.relative_to(L).as_posix()]=sha(p)
guard['project.godot']=sha(L/'project.godot')
notes=L/'docs/AI_COLLABORATION.md';before_notes=notes.read_bytes()
A.mkdir(parents=True);(A/'.gdignore').write_text('')
(A/'originals').mkdir();(A/'originals/arena_prototype.gd').write_bytes(original)
(A/'originals/AI_COLLABORATION.md').write_bytes(before_notes)
(A/'native').mkdir();(A/'logs').mkdir();(A/'reproduction').mkdir()
for name in ['gallery-native.png','gallery-2x.png','roster-before.png','arena-six-before.png','arena-six-after.png','hollow-after.png']:
 shutil.copy2(W/name,A/'native'/name)
shutil.copytree(W/'frames',A/'native/frames')
for pattern,target in [('*.log','logs'),('*.py','reproduction'),('*.gd','reproduction')]:
 for p in W.glob(pattern):shutil.copy2(p,A/target/p.name)
for name in ['README.md','checks.json','integration-checks.json','arena-png-baseline.json','roster.json']:
 shutil.copy2(W/name,A/name)
for r in new:shutil.copy2(C/r,L/r)
assert (L/rel).read_bytes()==original,'Concurrent edit before insertion'
(L/rel).write_bytes(updated)
note='''## Codex: Hollowtide Sprite finish across 30 arena forms (October 8, 2026)

Preston asked for consistent creature outlines/detail and chose the Hollowtide Sprite reference/preset. Read the saved Forge house style, audited all 30 forms and installed a shared **rendering** finish: near-black silhouette contours, at most one native pixel to repair pale edges, conservative cleanup of weak isolated shade specks using existing neighbouring colours. All eight facings and walk cycles use it, including the new Riftfin/Scourmaw. It also appears in Hollow exploration, story arena fights and relay practice through the common constructor. Original PNGs, source sheets, the seven-form refinements, dark-jade Oxbowarchon, Listener pass, Galeshear wings and all old backups are untouched. Menu portraits/picker icons still show their original art; this is not a full material redraw. No generation or paid calls.

Only one added line in `arena_prototype.gd` attaches `creature_finish.gd`/`.gdshader`; all Claude code around it is preserved. Native checks: 2,160 rendered textures with zero body pixels erased or outline pixels beyond the one-pixel allowance; 2,160 actual texture swaps preserve anchored feet; six-fighter movement, Hollow inheritance and alpha fade pass. Final creature logs have no script errors, with the Windows certificate diagnostic retained. [Native comparisons, exact scope, preserved code and checks](creatures/texture-consistency-2026-10-08/README.md). The earlier riverfront quay slice is also installed with 92 native world assertions. No settings change or commit.

'''
assert notes.read_bytes()==before_notes,'Concurrent collaboration update; append separately'
end=before_notes.index(b'\n')+1
notes.write_bytes(before_notes[:end]+b'\n'+note.encode()+before_notes[end:])
changed=[r for r,h in guard.items() if not (L/r).exists() or sha(L/r)!=h]
result={'installed_utc':datetime.now(timezone.utc).isoformat(),'files':[{'path':r,'sha256':sha(L/r)} for r in [rel]+new], 'forms':30,'rendered_textures':2160,'anchored_texture_swaps':2160,'source_pixels_checked':sum(x['source_pixels'] for x in checks['forms']),'weak_interior_shade_pixels_grouped':sum(x['cluster_pixels'] for x in checks['forms']),'unrelated_existing_files_guarded':len(guard),'concurrent_changes_during_install':changed,'source_pngs_written':0,'generation_calls':0,'original_arena_sha256':hashlib.sha256(original).hexdigest(),'project_settings_sha256':sha(L/'project.godot')}
(A/'installation.json').write_text(json.dumps(result,indent=2));(W/'installation.json').write_text(json.dumps(result,indent=2))
print(json.dumps(result,indent=2))
