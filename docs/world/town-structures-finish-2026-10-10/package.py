from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else None
required={'structures_check':'RESULT 27/27 structure checks pass','hub_town_check':'Places: 12 of 12 answered E','job_board_check':'JOB BOARD: all ok','town_walk_check':'RESULT: the team walks','hall_door_check':'RESULT: the hall door meets the steps','capture':'Captured after six town structure views'}
for name,marker in required.items():
 log=(W/(name+'.log')).read_text(encoding='utf-8')
 assert marker in log and all(err not in log for err in ['SCRIPT ERROR','SHADER ERROR','FAIL ','FAILED','WRONG','leaked']),name
# Every original foundation/sign and door function stays verbatim, including line endings.
r='scripts/town/building_exteriors.gd';original=(W/'originals'/r).read_bytes();candidate=(W/'candidate'/r).read_bytes()
assert original.split(b'static func _details',1)[1].split(b'func _process',1)[0]==candidate.split(b'static func _details',1)[1].split(b'func _process',1)[0]
note='''## Codex: remaining town exterior structures and larger Job Board (October 10, 2026)

Preston redirected the next task to finishing exteriors/town structures and said the Board was too small. All 13 existing places now have finished views. Added code-native Lookout masonry/bench, Ferry Landing moorings/gear/river marker and Dock edge beams/posts/rope/entrance treads on top of Claude's ground. Same black internal detail, material outer rim and 2px contact shadow; unchanged spots/paths/collision/services. Optional module, no imagegen or PNG edits. Preserve Claude's new interiors and ongoing code.

Job Board uses its exact original 48x24 art at integer 2x (96x48 display), centred on its original stand and anchored to the original actual opaque foot row. Visual offset is (-24, -source_used_rect.end.y); logical rect (26,7) 2x1 and reading (26,8) are unchanged. Real Hall door/steps and guild sign stay clear. Reading-pad drawings and animated response retained. Ground changes only remove the old small baked Board shadow; the larger shadow draws over final Highbank ground. No layout or town controller edit.

27 native checks pass, including actual E/Escape Board input/response, all five foundations/signs and fifteen door/hatch drawings exact, clear new service activation spots and Hollow Mouth, bounded ground changes. Hub 12 services/gate, walking, both Hall door tiles and Claude's complete Board rescue/recovery/payout loop pass. [Originals, native before/after, scope and audit](world/town-structures-finish-2026-10-10/README.md). Launch pixel frames were deferred for Preston's exterior priority; menu/story/source art/shared finish/creature A/B choice unchanged. No commit/settings edit. Visual direction remains proposal for Preston.

'''
r='docs/AI_COLLABORATION.md';raw=(L/r).read_bytes()
header=b'# Working Together on Hollowtide\r\n\r\n'
if not raw.startswith(header):header=b'# Working Together on Hollowtide\n\n'
assert raw.startswith(header)
q=W/'originals-current'/r;q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(raw)
q=W/'candidate'/r;q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(header+note.replace('\n','\r\n').encode('utf-8')+raw[len(header):])
readme='''# Remaining Highbank exterior structures and larger Job Board

Preston requested finishing exterior art and remaining town structures, and specifically a larger Board. This completes finished views for all 13 existing places. Original service buildings keep their installed art, black internal detail and selective outer rim. No decorative buildings or new service rules were invented.

## Job Board

Displays the exact original 48x24 PNG at integer 2x: 96x48 canvas, centred on the existing stand. The actual alpha foot row is measured with Image.get_used_rect; lifting by its original end.y preserves the original opaque contact row despite transparent source padding. Visual offset from (624,168) is (-24,-used.end.y); no logical footprint change, door/read point remains (26,8). Clear of the Hall's two-tile doorway, steps and guild mark. Nearest sampling only; no crop, resize file, redraw or new PNG. The old small baked shadow is removed, replaced by a 2px-offset transparent shadow of the enlarged art on the final ground. Existing reading pad and its three response drawings remain exact.

## Three remaining structures

`scripts/town/landmark_exteriors.gd` paints original native pixel details in code. Lookout: low weathered masonry, bench and river mark. Landing: larger mooring posts at the existing positions/foot row, rope wraps, old gear crate and river marker. Dock: timber edge beams, posts, low rope and three worn entrance treads. Shares black internal contours, material outer rim and top-left lighting with the purposeful exteriors. Ground-coloured contact darkening is a separate 2px-offset transparent sprite; it responds to the actual grass/paving/water beneath rather than baking an old ground palette.

All three preserve Claude's exact positions, dimensions, doors/activation spots, paths and ground. Dock's existing one-tile extension over the water is retained (the ground painter already draws it). Details remain below creatures as low open-air props, with broad walking surfaces and clear standing positions. No collision or boundary rule added. Landing art leaves the Hollow Mouth and its approach clear. The original HUD place name replaces the temporary floating plaques through the existing finished-view hook. Region map and ferry crossing remain future services; this does not implement travel.

Optional integration in building_exteriors.gd registers the three views. A missing optional landmark module retains the existing ground/labels/services; no missing module is preloaded. Static landmarks are excluded from the door-animation loop. Every previous doorway, hatch, foundation, sign and other service animator is retained.

## Native verification

Godot 4.7.2 NVIDIA Compatibility renderer. 27 structure checks pass: all 13 place views; 2x original Board art; exact opaque foot and centre anchoring; no Hall door/steps/sign intersection; three reading markers exact; real E/Escape opens/closes Claude's four Board requests and active/dormant feedback; all three new services still answer; standing spots and gate approach clear; five original foundations/signs and fifteen original door/hatch drawings exact; ground outside the old Board shadow patch exact. Source PNGs and shared finish are untouched, so prior creature/palette/animation verification remains preserved, not a new animation audit.

Current Claude checks copied with outputs redirected and explicit cleanup: hub_town_check (13 reachable places, 12 services answer, follower movement, gate starts run); town_walk_check; hall_door_check; job_board_check (take requests, rescue client, recover lost item, return and receive rewards/rank). Six actual town views captured before/after. Review runs have the sandbox Windows root-certificate-store warning; corrected final runs have no shader/script errors. Initial static-landmark/fixture diagnostics retained. Each process uses isolated test preferences, never user settings/saves.

## Preservation and handoff

Only two existing town presentation scripts, one new painter and collaboration note installed. Exact originals and candidates are archived. No shared shader/palette, creature/source PNG/backups, Claude ground/interiors/controller/state/dungeon, layout, title, menu, story, balance or project settings edit. Original backups elsewhere are untouched. No image generation, commit, revert or stash. Preston's visual approval and a natural dungeon clear are not claimed. See final live verification and audit below.

Launch/UI handoff job 8 remains open, deferred when Preston asked for exteriors. Creature A/B finish remains review-only. Town structures are now filled; additional decoration or ferry/region gameplay needs its own scope.
'''
(W/'README.md').write_text(readme,encoding='utf-8')
archive=W/'archive';archive.mkdir(exist_ok=True)
for folder in ['originals','originals-current','candidate','review']:shutil.copytree(W/folder,archive/folder,dirs_exist_ok=True)
for name in ['README.md','baseline.json','setup.py','run.py','edit.py','package.py','prepare_checks.py','landmark_exteriors.gd','structures_check.gd','capture.gd','capture-static-landmark-failure.log','structures-check-input-fixture-failure.log']+[n+'.gd' for n in required]+[n+'.log' for n in required]:
 if (W/name).is_file():shutil.copy2(W/name,archive/name)
baseline=json.loads((W/'baseline.json').read_text(encoding='utf-8'))
pending=[]
for q in (W/'candidate').rglob('*'):
 if not q.is_file():continue
 r=q.relative_to(W/'candidate').as_posix()
 before=hashlib.sha256(raw).hexdigest() if r=='docs/AI_COLLABORATION.md' else baseline.get(r)
 assert sha(L/r)==before,('Concurrent owned file changed',r)
 pending.append({'path':r,'before':before,'after':sha(q)})
pending.sort(key=lambda d:(d['before'] is not None,d['path']=='docs/AI_COLLABORATION.md',d['path']))
(W/'pending-install.json').write_text(json.dumps(pending,indent=2),encoding='utf-8')
install=Path('D:/dev/hollowtide-town-selout-20261010/install.ps1').read_text(encoding='utf-8').replace('hollowtide-town-selout-20261010','hollowtide-town-structures-20261010').replace('town-selout-2026-10-10','town-structures-finish-2026-10-10')
(W/'install.ps1').write_text(install,encoding='utf-8')
print('Verified all native checks; prepared',len(pending),'guarded files and new archive.')
