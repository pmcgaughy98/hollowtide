from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent; L=Path('C:/Users/pmcga/dev/hollowtide'); C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else None
required={'finish_check':'FINISH 11/11 PASS','room_spots_check':'SPOTS all ok','hub_town_check':'Places: 12 of 12 answered E','job_board_check':'JOB BOARD: all ok','home_fallback':'FALLBACK original enlarged Board exact'}
for name,marker in required.items():
    log=(W/(name+'.log')).read_text(encoding='utf-8')
    assert marker in log and not any(x in log for x in ['SCRIPT ERROR','SHADER ERROR','FAIL ','failed','leaked']),name
paths=['scripts/town/job_board_painter.gd','scripts/town/room_painter.gd','scripts/town/town_room.gd','scripts/town/home_room_art.gd','assets/sprites/world/home_interior_2026_10_10/home_native.png','assets/sprites/world/job_board_selout_2026_10_10/board_native.png']
baseline=json.loads((W/'baseline.json').read_text(encoding='utf-8'))
for r in paths:
    assert sha(L/r)==baseline.get(r),('Concurrent owned file changed',r)
    q=W/'candidate'/r;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(C/r,q)
# Only presentation hooks enter Claude's room scripts; all original method bodies stay exact.
for r,hook in [('scripts/town/room_painter.gd','\tif id == "home":\n\t\timg = preload("res://scripts/town/home_room_art.gd").paint(img)\n'),('scripts/town/town_room.gd','\tif room_id == "home":\n\t\tpreload("res://scripts/town/home_room_art.gd").finish(map)\n')]:
    a=(W/'originals'/r).read_text(encoding='utf-8');b=(W/'candidate'/r).read_text(encoding='utf-8')
    assert b.count(hook)==1 and b.replace(hook,'')==a,r
old=(W/'originals/scripts/town/job_board_painter.gd').read_bytes();new=(W/'candidate/scripts/town/job_board_painter.gd').read_bytes()
for start,end in [(b'static func apply(',b'static func _visual_offset'),(b'static func _marker(',None)]:
    # apply() ends before the newly inserted display helper; marker/update stay untouched.
    if end:
        assert old.split(start)[1].split(end)[0]==new.split(start)[1].split(b'static func _display_texture')[0]
    else: assert old.split(start)[1]==new.split(start)[1]
note='''## Codex: Job Board outlines and first finished Home interior (October 10, 2026)

Preston asked for Board sel-out, then interiors, and clarified that Claude's block furniture must become detailed art matching the town/creatures. Board now has its own 96x48 native four-notice stand, carved warm root timber, outlined rails/posts/papers/seals/rope/brass. Shared exterior finish with full detail ink. Same enlarged canvas centre and exact original opaque foot row; native 1x pixel weight. Original 48x24 PNG stays untouched and is the exact 2x fallback. Reading (26,8), pad drawings/feedback, Hall clearance, ground, job/controller/state remain unchanged.

Home is the first interior art slice: a full 336x240 room made with our own exterior/layout references; rooted frame/soft moss bedding, woven blanket, stone fireplace/kettle, carved table/chart/lantern, jars/scrolls, dense plants and braided rug. Same 14x10/24px room, five solid/interaction spots and party/camera/events. Original south door drawing restored exactly. Shared masked terrain finish inks furniture and walls; floor/rug/exit are unmodified by the finish. Claude's entire Hall painting is pixel-exact; Hall art is next. No save/rest/dispatch rules added. Original code painter is the byte-exact absent-art fallback.

11 native finish/geometry/GPU/input comparisons; all five Home and nine Hall spots reached by actual walking and E, both exits; hub and full Board rescue/recovery/payout checks pass. Source PNGs, creature palettes/animations/backups, shaders and concurrent Claude code preserved. Built-in imagegen: two calls, no Retro; sources/prompts/nearest native preparation archived. [Previews, originals, scope, checks and preservation audit](world/board-home-interior-finish-2026-10-10/README.md). No commit or settings edit. Art remains a visual proposal for Preston. Launch pixel-frame task stays open.

'''
r='docs/AI_COLLABORATION.md';raw=(L/r).read_bytes();header=raw.split(b'\n',2)[:2];prefix=b'\n'.join(header)+b'\n'
assert raw.startswith(b'# Working Together on Hollowtide')
q=W/'originals-current'/r;q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(raw)
q=W/'candidate'/r;q.parent.mkdir(parents=True,exist_ok=True)
q.write_bytes(prefix+note.replace('\n','\r\n').encode('utf-8')+raw[len(prefix):])
paths.append(r)
pending=[{'path':r,'before':sha(L/r),'after':sha(W/'candidate'/r)} for r in paths]
pending.sort(key=lambda d:(d['before'] is not None,d['path']=='docs/AI_COLLABORATION.md',d['path']))
(W/'pending-install.json').write_text(json.dumps(pending,indent=2),encoding='utf-8')
sources={'home':'exec-28dcdf03-c699-407e-99dd-b74ffb95154d.png','board':'exec-b8154cb5-b5ce-4d97-beee-c522520d7cdf.png'}
generation=Path('C:/Users/pmcga/.codex/generated_images/01a11b73-6d5a-78a3-819c-fd3b9ced7188')
for name,p in sources.items():
    q=W/'original-generation'/(name+'.png');q.parent.mkdir(exist_ok=True);shutil.copy2(generation/p,q)
for r in ['assets/sprites/world/job_board_2026_10_10/board_native.png','assets/sprites/world/home_2026_10_09/home_native.png','assets/sprites/world/wayline_hall_2026_10_10/wayline_hall_native.png']:
    q=W/'original-art'/r;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,q)
readme='''# Job Board finish and Home interior art

Preston requested sel-out on the enlarged Board, then the interior handoff; he clarified that the rooms need finished art matching the town and creatures, beyond block furniture. This slice finishes the Board and Home's art. Wayline Hall retains Claude's exact painting and is the next interior art task. No additional room or game systems are claimed built.

## Board

New transparent 96x48 native stand, four separate cream notices with line marks/seals, carved warm root timber, rope and brass joints, restrained moss. The full purposeful-building detail ink and selective outer rim are the installed shared town finish. Native 1x art gives the same pixel weight as the buildings. Canvas centre remains (648,168); original opaque contact row remains the original Board's measured foot y, using offset (-24, original_used.end.y - display_used.end.y). Original 48x24 PNG is untouched and falls back at its prior 2x scale if new art is absent/invalid. Source padding is measured rather than assuming the canvas bottom. Same z, contact shadow, logical layout, reading tile (26,8), Hall doorway/sign clearance, original ground and all three reading-feedback drawings. Job/request/payout systems unchanged.

## Home

336x240 native room at the original 14x10/24px grid. Original room layout reference and our approved Home exterior were the only generation references. Detailed rooted bed, moss cushion, embroidered folded cloth/pillow, limestone hearth/fire/kettle, rooted table, map/lantern, carved shelves with jars/scrolls, dense clover/fern, woven rug, timber/stone walls and warm quiet plank floor. Top-left daylight and warm fire light. The original south door drawing (165,216,30,24) is restored exactly in the image, retaining its real exit.

HomeRoomArt uses the existing shared masked terrain shader at its normal 0.75 detail ink on bounded furniture and walls. The finish does not modify walking floor/rug/exit. All room definitions, blocked tiles, interaction names/text, team/follower motion, camera, controls, return position and state methods are verbatim. A three-line Home-only art hook in room_painter and two-line map-finish hook in town_room; Hall unchanged. Missing Home art returns the exact original code painter. The room still has Claude's existing interaction behavior; no saving, healing/day cycle, dispatch, roster or persistence system has been added by this art task.

## Preparation and checks

Built-in imagegen two calls, zero Retro. Original generations and exact prompts saved. Godot nearest-neighbour normalization only: Home 1484x1060 ->336x240; Board ->96x48 preserving transparency. Shared finish is applied at runtime; no shared shader modified. Initial code-detail-only Home and Board prototypes were rejected as too block-like and are retained locally as development history, not installed.

Native Godot 4.7.2/NVIDIA Compatibility: 11 finish comparisons cover source/fallback preservation, Hall image exact, Home dimensions/door, actual GPU mask output (walking floor/rug/exit exact), Board centre/foot/native pixel weight, Hall clearance and real E/Escape reading feedback. All five Home and nine Hall interactions reached by real grid walking and E; both exits return to original building. Current Claude hub and full job rescue/recovery/return/payout checks pass. Missing-art check verifies exact original Home painting and original enlarged Board. Test profiles/output paths are isolated from player settings/saves. Review sandbox logs contain the Windows certificate-store warning. Early fixture/type/format diagnostics were corrected before installation; the legacy town_room_check assertions passed but its exit cleanup warning is retained. Final live verification is recorded below.

## Preservation and handoff

Only Board painter, two Home presentation hooks, one new Home art module, two sibling PNGs and collaboration note. Originals/candidates and active-file hashes archived. No source art replacement, creature palette/animation/body edit, shared shader change, layout/path/collision/rules change, title/menu/settings edit, commit/revert/stash. Concurrent edits are guarded and retained. Art is implemented for Preston's visual review; approval is not claimed.

Next: detailed Wayline Hall art at Claude's same 22x14 grid (dispatch counter, notice wall, roster, pillars, benches, charts/reports and parcels), with the existing job API when systems are expanded. Launch-frame handoff job8 and creature sel-out A/B choice remain open.
'''
(W/'README.md').write_text(readme,encoding='utf-8')
archive=W/'archive';archive.mkdir(exist_ok=True)
for folder in ['originals','originals-current','candidate','review','original-generation','original-art']:
    shutil.copytree(W/folder,archive/folder,dirs_exist_ok=True)
for p in W.iterdir():
    if p.is_file() and p.suffix in ['.py','.gd','.txt','.log','.json','.md','.png']:shutil.copy2(p,archive/p.name)
install=Path('D:/dev/hollowtide-town-structures-20261010/install.ps1').read_text(encoding='utf-8').replace('hollowtide-town-structures-20261010','hollowtide-board-home-20261010').replace('town-structures-finish-2026-10-10','board-home-interior-finish-2026-10-10')
(W/'install.ps1').write_text(install,encoding='utf-8')
print('Prepared',len(pending),'guarded install paths; exact originals and generation sources archived.')
