from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
baseline=json.loads((W/'baseline.json').read_text())
owned=[p.relative_to(W/'candidate').as_posix() for p in (W/'candidate').rglob('*') if p.is_file()]
for r in owned:assert sha(L/r)==baseline[r], 'Concurrent owned edit: '+r
changed={r:{'before':h,'now':sha(L/r) if (L/r).exists() else None} for r,h in baseline.items() if r not in owned and r!='docs/AI_COLLABORATION.md' and (not (L/r).exists() or sha(L/r)!=h)}
(W/'concurrent-before-install.json').write_text(json.dumps(changed,indent=2))
entry='''## Codex: Wayline Hall town finish (October 10, 2026)

Next in the town finish brief, after Home / Item Shop. Hall now uses the same separate-sprite detail finish: near-black window/mullion, root/roof and stone contours, ground-coloured bottom-right contact shadow, foundation/grass edges and one two-tile threshold. Preserved the coherent October 10 source art, both side windows, the exact 240x144 footprint, door tiles (23,6)/(24,6), authored steps and original backups. Added an original three-route waymark sign beside the door (visual proposal for guild identification); Hall's floating label is suppressed by the existing view hook.

One source-arch mask and three paired-leaf door textures span both tiles. Either tile or approach opens the same animation and existing guild description/sound; Esc closes it. No act_use, controller, collision, paths, camera, state/rules, UI/title or PNG edits. Runtime scope: building_exteriors.gd Hall-only extension and the optional hook in wayline_hall_painter.gd. Home/shop foundation/sign and all six door drawings compare exact; shared detail/creature shaders unchanged. No generation, borrowed art/code, settings edit or commit.

26 native checks pass: actual added internal ink including both window regions, footprint/alignment, three visible consistent masks, actual walking/native E/closing from both entrances and steps, exact Home/shop drawings, and every ground pixel outside Hall plus a two-pixel shadow band unchanged. Existing paved steps below that band remain exact. Physically missing October 10 Hall PNG uses the historical October 9 fallback, retains the finished pair and both guild interactions. Native 1152x648 captures reviewed; full-Hall fixture framing does not change the production camera. [Previews, originals, checks and preservation audit](world/hall-finish-2026-10-10/README.md).

Next: Storage, then Scroll Keeper / remaining services, then decorative buildings. Keep purposeful-building internal outlines distinct from quieter background decoration. Claude still owns interiors, guild jobs/state and dungeon rules.


'''
p=L/'docs/AI_COLLABORATION.md';old=p.read_bytes()
header=b'# Working Together on Hollowtide\r\n\r\n' if old.startswith(b'# Working Together on Hollowtide\r\n') else b'# Working Together on Hollowtide\n\n'
assert old.startswith(header)
notes=W/'candidate/docs/AI_COLLABORATION.md';notes.parent.mkdir(parents=True,exist_ok=True);notes.write_bytes(header+entry.replace('\n','\r\n').encode()+old[len(header):])
owned.append('docs/AI_COLLABORATION.md')
pending=[{'path':r,'before':sha(L/r),'after':sha(W/'candidate'/r),'source':str(W/'candidate'/r)} for r in owned]
(W/'pending-install.json').write_text(json.dumps(pending,indent=2))
(W/'preinstall-protected.json').write_text(json.dumps({r:sha(L/r) for r in baseline if r not in owned},indent=2))
(W/'README.md').write_text('''# Wayline Hall finish, October 10

Second town-finish slice: Hall, following the completed Home / Item Shop. Purposeful buildings use near-black internal outlines at Preston's direction. The existing coherent October 10 PNG, side windows, silhouette and original backup art stay untouched.

## Installed

Hall is a separate Sprite2D using the installed building_detail_finish shader, with dark window/mullion, root/roof and stone contours. Ground-coloured bottom-right contact band, broken foundations and ground-green grass overlap anchor it to the terrain. An original three-route waymark plaque identifies the guild (visual proposal). The existing label hook removes Hall's floating plaque; other labels remain.

One animated paired-leaf door spans the existing two-tile entrance. `buildings["hall"]["frames"][0..2]` are closed / ajar / open. Either entrance or approach activates the same panel-driven animation; Esc closes it. Source arch mask preserves the coherent masonry and side windows. No hookup work remains for this door. Existing sound, guild response and controls are unchanged; no new interior/guild gameplay is claimed.

Runtime scope: building_exteriors.gd and wayline_hall_painter.gd, plus collaboration-note prepend. No asset/shader/controller/layout/path/camera/settings/title/creature/state/rule/UI edit. Exact world footprint (456,24), size240x144, door tiles(23,6)/(24,6), steps Rect2i(23,7,2,2). One-tile Home/shop rendering defaults retain identical output.

## Verification

26 native checks: actual shader output adds interior ink in both window regions and whole-building interior; correct sprite size/position and centered two-tile mask; three distinct nonempty drawings share the source shape; actual walking/native E from both entrance tiles and both steps, guild/sound, ajar/open/closed; Home/shop foundation/sign and six door drawings byte-exact; every ground pixel outside Hall and the two-pixel contact band exact, paved steps below that band exact.

Physically missing new Hall PNG / import metadata check in the isolated review checkout confirms exact historical fallback artwork, retained finished Home/shop and both usable Hall tiles. Original sources restored before installation. Final main native check has no script/resource errors (review checkout's existing certificate diagnostic remains); fallback fixture left a small shutdown resource warning, with no production cleanup change claimed.

`review/hall_exterior.png` is a native1152x648 capture with fixture camera framing for the complete Hall. `hall_service_23.png` / `hall_service_24.png` use the production camera. No production camera change, natural dungeon-clear or disk-save claim.

Guarded before-hash installation and originals snapshots preserve concurrent edits. No imagegen/Retro call, copied game assets/code or commit. All original assets and prior archives remain untouched. Reproduction scripts and exact install/preservation manifest accompany this file.

## Next

Storage, then Scroll Keeper / remaining services, then decoration. Preserve near-black internal detail contours for purposeful buildings and quieter background treatment. Claude owns guild gameplay, interiors and state/rules.
''')
archive=W/'archive';archive.mkdir(exist_ok=True)
for folder in ['originals','candidate','review']:shutil.copytree(W/folder,archive/folder,dirs_exist_ok=True)
for p in W.iterdir():
    if p.is_file() and p.suffix in ['.md','.gd','.py','.json','.log']:shutil.copy2(p,archive/p.name)
print('Concurrent unowned edits retained:',json.dumps(changed,indent=2))
print('Prepared',len(pending),'guarded files.')
