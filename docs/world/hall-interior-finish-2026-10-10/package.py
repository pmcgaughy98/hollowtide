from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent; L=Path('C:/Users/pmcga/dev/hollowtide'); C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else None
checks={'finish_check':'HALL FINISH 17/17 PASS','room_spots_check':'SPOTS all ok','fallback-hall_native.png':'FALLBACK Hall original exact','fallback-chart.png':'FALLBACK Hall original exact'}
for name,marker in checks.items():
    log=(W/(name+'.log')).read_text(encoding='utf-8')
    assert marker in log and not any(e in log for e in ['SCRIPT ERROR','SHADER ERROR','FAIL ','leaked']),name
paths=['scripts/town/room_painter.gd','scripts/town/town_room.gd','scripts/town/hall_room_art.gd']
paths += ['assets/sprites/world/hall_interior_2026_10_10/'+n+'.png' for n in ['hall_native','pillar','fern','bench','chart','reports','parcels']]
baseline=json.loads((W/'baseline.json').read_text(encoding='utf-8'))
for r in paths:
    assert sha(L/r)==baseline.get(r),('Concurrent owned file changed',r)
    q=W/'candidate'/r;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(C/r,q)
for r,hook in [('scripts/town/room_painter.gd','\telif id == "hall":\n\t\timg = preload("res://scripts/town/hall_room_art.gd").paint(img)\n'),('scripts/town/town_room.gd','\telif room_id == "hall":\n\t\tpreload("res://scripts/town/hall_room_art.gd").finish(map)\n')]:
    original=(W/'originals'/r).read_text(encoding='utf-8');candidate=(W/'candidate'/r).read_text(encoding='utf-8')
    assert candidate.count(hook)==1 and candidate.replace(hook,'')==original,r
note='''## Codex: detailed Wayline Hall interior (October 10, 2026)

Preston approved the finished Home and Job Board and asked for the same treatment on the other interiors. Wayline Hall now has detailed limestone walls/flagstones, carved dispatch counter, notice and roster panels, lanterns/banners, teal runner, four pillars, two ferns, benches, chart/report tables and parcels. Near-black material detail through the existing masked finish. Separate transparent props sit in all twelve original visual rectangles; same 22x14/24px room, solid/event grid, interaction text, party/camera/exit/return. Original south door drawing restored exactly. Approved Home pixels and Board are preserved. Home and Hall are the currently wired rooms; other services remain their existing panels.

17 native geometry/door/actual GPU finish checks pass; all five Home and nine Hall spots reached by walking and real E, both exits. Missing floor or any prop restores the exact original Hall painter. Source assets/creatures/palettes/backups/shared shaders and concurrent Claude code preserved. Built-in imagegen four calls, zero Retro: whole-room alignment candidates retained but rejected; installed floor background plus separately fitted props. Sources, exact prompts, nearest crop/resize preparation, before/after and final live proof are archived in [Hall interior handoff](world/hall-interior-finish-2026-10-10/README.md). No systems/settings/commit edits; Hall visual approval is pending. Launch pixel frames and pilot waking job12 remain in Claude's current handoff.

'''
r='docs/AI_COLLABORATION.md';raw=(L/r).read_bytes()
assert raw.startswith(b'# Working Together on Hollowtide')
prefix=b'\n'.join(raw.split(b'\n',2)[:2])+b'\n'
for folder,content in [('originals-current',raw),('candidate',prefix+note.replace('\n','\r\n').encode('utf-8')+raw[len(prefix):])]:
    q=W/folder/r;q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(content)
paths.append(r)
pending=[{'path':r,'before':sha(L/r),'after':sha(W/'candidate'/r)} for r in paths]
pending.sort(key=lambda d:(d['before'] is not None,d['path']=='docs/AI_COLLABORATION.md',d['path']))
(W/'pending-install.json').write_text(json.dumps(pending,indent=2),encoding='utf-8')
generation=Path('C:/Users/pmcga/.codex/generated_images/01a11b73-6d5a-78a3-819c-fd3b9ced7188')
sources={'rejected-whole-room':'exec-ea988832-47fc-44a0-b088-de57601db8e0.png','rejected-alignment':'exec-94c557a3-8b6b-4a2a-b5fe-ae5b80a2d968.png','chosen-floor':'exec-c07736b7-a2f0-42d3-a3fd-440ea77e7411.png','chosen-props':'exec-674aeeb7-4ade-439a-b3a3-a2aa3ca0825b.png'}
for name,p in sources.items():
    q=W/'original-generation'/(name+'.png');q.parent.mkdir(exist_ok=True);shutil.copy2(generation/p,q)
for r in ['assets/sprites/world/wayline_hall_2026_10_10/wayline_hall_native.png','assets/sprites/world/home_interior_2026_10_10/home_native.png']:
    q=W/'original-art'/r;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,q)
install=Path('D:/dev/hollowtide-board-home-20261010/install.ps1').read_text(encoding='utf-8').replace('hollowtide-board-home-20261010','hollowtide-hall-interior-20261010').replace('board-home-interior-finish-2026-10-10','hall-interior-finish-2026-10-10')
(W/'install.ps1').write_text(install,encoding='utf-8')
archive=W/'archive';archive.mkdir(exist_ok=True)
for folder in ['originals','originals-current','candidate','review','original-generation','original-art']:
    shutil.copytree(W/folder,archive/folder,dirs_exist_ok=True)
for p in W.iterdir():
    if p.is_file() and p.suffix in ['.py','.ps1','.gd','.txt','.log','.json','.md','.png']:shutil.copy2(p,archive/p.name)
print('Prepared',len(pending),'guarded paths; original room methods retained exactly.')
