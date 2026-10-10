from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent; L=Path('C:/Users/pmcga/dev/hollowtide')
baseline=json.loads((W/'baseline.json').read_text())
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
owned=[p.relative_to(W/'candidate').as_posix() for p in (W/'candidate').rglob('*') if p.is_file()]
changed={r:{'before':h,'now':sha(L/r) if (L/r).exists() else None} for r,h in baseline.items() if r not in owned and r!='docs/AI_COLLABORATION.md' and (not (L/r).exists() or sha(L/r)!=h)}
(W/'concurrent-before-install.json').write_text(json.dumps(changed,indent=2))
for r in owned:
    if r in baseline: assert sha(L/r)==baseline[r], 'Concurrent owned edit: '+r
    else: assert not (L/r).exists(), 'New target exists: '+r
for r in ['assets/sprites/world/home_2026_10_09/home_native.png','assets/sprites/world/item_shop_2026_10_09/item_shop_native.png','scripts/arena/creature_finish.gdshader']:
    assert sha(L/r)==baseline[r]
    dest=W/'originals'/r;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,dest)
entry='''## Codex: Home and Item Shop town finish (October 10, 2026)

Started job 0 in CODEX_HANDOFF and followed CODEX_TOWN_FINISH_BRIEF with Home / Item Shop first. Both existing exteriors now render as separate Sprite2Ds. Preston clarified that near-black outlines must run through the whole building's details (windows, root ribs, arches, roof/counter seams), identifying purposeful buildings against quieter decoration. building_detail_finish.gdshader preserves the creature finish's silhouette/cluster pass and adds internal ink; the creature shader and all original PNGs are unchanged. Ground-coloured contact shadows, foundation stones, sparse overlapping grass, worn approaches, exact-tile steps and an original bag sign installed. Finished pair's floating plaques are suppressed; other labels stay.

Three generated-in-code door textures (closed / ajar / open) follow each original arch mask and respond to the existing service panel. Existing E/J/Enter/sound/close paths stay; this is presentation, not new interiors, sleep/save/economy. Layout, doors, paths, camera, state/rules, title, creature textures/palette locks and original backups preserved. No imagegen/Retro call, external art/code copied, commit or settings change.

28 native finish/actual-input checks pass, including actual interior-outline pixels, distinct nonempty door frames, walking/E from the door and approach, opening/closing and exact ground outside the pair's bounded aprons. Missing exterior module restores the original whole-map pixels. Existing hub/Hall checks pass. Native 1152x648 captures inspected. Whole-building captures use a test camera framing; service captures use the production camera. [Previews, original snapshots, checks and install audit](world/town-finish-2026-10-10/README.md).

Next in brief order: Wayline Hall with its existing two-tile arch, then remaining services, then decoration. Purposeful building detail outlines are Preston's direction; do not apply them to background decoration by default. Claude retains state/rules/interiors.


'''
notes=L/'docs/AI_COLLABORATION.md';old=notes.read_bytes()
header=b'# Working Together on Hollowtide\r\n\r\n' if old.startswith(b'# Working Together on Hollowtide\r\n') else b'# Working Together on Hollowtide\n\n'
assert old.startswith(header)
candidate=W/'candidate/docs/AI_COLLABORATION.md';candidate.parent.mkdir(parents=True,exist_ok=True)
candidate.write_bytes(header+entry.replace('\n','\r\n').encode()+old[len(header):])
owned.append('docs/AI_COLLABORATION.md')
pending=[]
for r in owned:
    pending.append({'path':r,'before':sha(L/r) if (L/r).exists() else None,'after':sha(W/'candidate'/r),'source':str(W/'candidate'/r)})
(W/'pending-install.json').write_text(json.dumps(pending,indent=2))
protected={r:sha(L/r) for r in baseline if r not in owned}
(W/'preinstall-protected.json').write_text(json.dumps(protected,indent=2))
readme='''# Highbank finish: Home and Item Shop, October 10

Job 0, first pair in Claude's town finish brief. Preston's refinement: purposeful buildings need near-black internal outlines, including windows and architecture; background decoration should remain quieter.

## Installed

- Existing original PNGs as separate Sprite2Ds at the exact layout positions and sizes. Original silhouettes and palettes preserved.
- Building detail shader based on the unchanged creature house finish. Shared outline colour/weight plus internal dark-side contours; no blur or source-pixel replacement.
- Contact shadows falling bottom-right, broken foundation stones, ground-green grass overlaps, earthen approaches joining the existing street, threshold steps and an original shop bag sign.
- Procedural closed / ajar / open door textures, masked to each original opening. Opening/closing follows the existing service panel (E/J/Enter and Esc), without delaying or changing rules/sound. Frames are `buildings[id]["frames"][0..2]`; no hookup remains for this pair.
- Only the finished pair's old floating plaques removed. Existing service labels elsewhere stay.

Runtime files: `scripts/town/building_exteriors.gd`, `building_detail_finish.gdshader`, `home_painter.gd`, `item_shop_painter.gd`, and two small optional hooks / label skip in `hub_town.gd`. No act_use/state/layout/camera/UI/style/title/creature change.

## Verification

28 native assertions in finish_check.gd: rendered internal black-pixel increase, sprite placement/size, visible distinct door drawings, actual walking and key E from both approaches, same services/sound, intermediate/open/closed frames, and every ground pixel outside bounded Home/shop footprints plus shadows/aprons unchanged. Screenshots are 1152x648. Exterior captures manually frame the whole building in the fixture; service captures use the actual production camera.

Physically absent exterior module check restores the old entire map byte for byte, safely removes the optional view, and leaves Home usable. Existing hub_town_check: no overlaps, all reachable, all 12 ordinary services answer, walking/following and dungeon entrance remain. hall_door_check: both old Hall door tiles/steps remain usable.

Review editor import retained existing Windows certificate / stale review audio UID diagnostics; native final checks have no script/resource errors, only the pre-existing certificate warning. One intermediate run had a transient shutdown resource warning; final finish check was clean. These are presentation/route checks, not a natural dungeon-clear claim.

No generated art, imagegen/Retro calls, borrowed game code/assets, settings edits or commit. Original PNGs, original scripts, palette locks and prior archives preserved. Five runtime files plus a collaboration-note prepend are installed with before-hash guards; all other protected files audited separately. Installation/audit JSON contains exact scope.

## Next

Wayline Hall, preserving its October 10 coherent art and two-tile doorway. Then remaining services, then decorative buildings. No new interiors, sleep, disk saves or economy in this slice; Claude owns those systems. This art treatment is implemented and native-reviewed, awaiting Preston's visual review.
'''
(W/'README.md').write_text(readme)
archive=W/'archive';archive.mkdir(exist_ok=True)
for folder in ['originals','candidate','review']: shutil.copytree(W/folder,archive/folder,dirs_exist_ok=True)
for p in W.iterdir():
    if p.is_file() and p.suffix in ['.md','.gd','.py','.json','.log']: shutil.copy2(p,archive/p.name)
print('Concurrent unowned changes:',json.dumps(changed,indent=2))
print('Prepared',len(pending),'guarded files and archive.')
