from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
baseline=json.loads((W/'baseline.json').read_text())
owned=[p.relative_to(W/'candidate').as_posix() for p in (W/'candidate').rglob('*') if p.is_file()]
for r in owned:
    if r in baseline:assert sha(L/r)==baseline[r], 'Concurrent owned edit: '+r
    else:assert not (L/r).exists(), 'New target exists: '+r
changed={r:{'before':h,'now':sha(L/r) if (L/r).exists() else None} for r,h in baseline.items() if r not in owned and r!='docs/AI_COLLABORATION.md' and (not (L/r).exists() or sha(L/r)!=h)}
(W/'concurrent-before-install.json').write_text(json.dumps(changed,indent=2))
entry='''## Codex: Storage exterior and town finish (October 10, 2026)

Next in the town finish brief after Hall. Storage replaces its blockout with one original low timber/root storehouse: moss roof, cross-braced panels, warm windows/lantern and crates. Built-in imagegen, one call, zero Retro. Unmodified source and exact final prompt archived. Native preparation is transparent-padding crop and uniform nearest scaling onto a 144x120 canvas; no architectural fragments pasted, pixel painting or palette replacement. Original facade's doorway aligns with the unchanged (40,7) tile within the (912,72) footprint.

Separate sprite wears the installed house silhouette/internal-detail shader; near-black outlines extend through beams/windows/crates. Ground-coloured contact shadow, foundations/grass, worn approach, step and original crate sign installed. Three source-masked door frames open/close with the existing service panel and sound; Storage's floating label is suppressed. No actual inventory transfer/storage system, interior, save/economy or rules added. Source layout, doors/paths, controller, camera, title/UI, creature textures/palette locks and backups preserved.

Runtime scope: new storage_native.png, new storage_painter.gd, Storage-only building_exteriors extension and ground capture/optional hook in highbank_ground_painter.gd. All Home/shop/Hall foundation/sign and nine door textures compare exact; all ground outside bounded Storage/shadow/apron exact. 21 native checks pass, including actual interior ink, source-door alignment, visible distinct frames, actual walking/native E and closing/from-approach. Physically absent new PNG or painter returns exact old ground/blockout with the finished trio and Storage interaction retained. Native 1152x648 previews reviewed. [Asset, prompt, sources, native checks and audit](world/storage-finish-2026-10-10/README.md).

Next in the brief: Scroll Keeper, then remaining services and decorative buildings. Keep purposeful buildings strongly outlined throughout; decoration stays quieter. Claude owns actual service inventory/state and guild/dungeon rules. No commit or settings edit.


'''
p=L/'docs/AI_COLLABORATION.md';old=p.read_bytes()
header=b'# Working Together on Hollowtide\r\n\r\n' if old.startswith(b'# Working Together on Hollowtide\r\n') else b'# Working Together on Hollowtide\n\n'
assert old.startswith(header)
notes=W/'candidate/docs/AI_COLLABORATION.md';notes.parent.mkdir(parents=True,exist_ok=True);notes.write_bytes(header+entry.replace('\n','\r\n').encode()+old[len(header):])
owned.append('docs/AI_COLLABORATION.md')
pending=[{'path':r,'before':sha(L/r) if (L/r).exists() else None,'after':sha(W/'candidate'/r),'source':str(W/'candidate'/r)} for r in owned]
(W/'pending-install.json').write_text(json.dumps(pending,indent=2))
(W/'preinstall-protected.json').write_text(json.dumps({r:sha(L/r) for r in baseline if r not in owned},indent=2))
(W/'README.md').write_text('''# Storage exterior and finish, October 10

Next town-finish slice after Home / Item Shop / Wayline Hall. One original low timber storehouse with root beams, moss roofing, cross-braced panels, warm windows/lantern and crates. Strong internal near-black contours mark it as purposeful at Preston's direction. Architecture is an implemented visual proposal, awaiting his review.

## Play / art

F6 scenes/hub_town.tscn, or the existing F5 story to Highbank. Storage is right of Item Shop, with a crate pictogram beside its door. E/J/Enter uses the existing service response; Esc closes it. One source-masked wooden door has closed / ajar / open frames in `buildings["storage"]["frames"][0..2]`; no hookup remains. Existing storage inventory functionality is not claimed; the panel remains Claude's description.

Asset: `assets/sprites/world/storage_2026_10_10/storage_native.png`. Exact world footprint (912,72), canvas144x120, one unchanged door tile(40,7), 24px grid. Uniformly fitted source remains a low broad storehouse; transparent canvas retains the complete source shape and original doorway alignment. No collision/path/camera changes.

## Provenance

Built-in imagegen, one generation, zero Retro. Unmodified output in `sources/storage_original.png`, exact tool prompt in [prompts/final-built-in.txt](prompts/final-built-in.txt). Original descriptive brief also retained. Preparation details in asset-preparation.json: crop transparent safety padding (excluding sub-8-alpha empty-canvas wisps, with two source pixels of room), uniform nearest scaling to134x81, offset(8,38) on144x120. Alpha within the crop is preserved. No architectural compositing, painting, colour replacement or source-image overwrite. Original built-in output remains at its generated_images path too.

Grounding/sign/animated door are original code-native Image textures. Sprite uses the unchanged installed building detail shader; foundations, grass overlap, contact shadow, threshold and worn approach follow the existing terrain colours. The existing optional view hook suppresses the Storage floating plaque only.

## Scope and checks

Runtime: new nativePNG and storage_painter.gd, Storage-only extension in building_exteriors.gd, capture/optional-painter hook in highbank_ground_painter.gd. Collaboration note prepended. Existing Home/shop/Hall, original PNGs/backups, creature finishes/palette locks, title, UI/controllers and Claude rules/state are preserved.

21 native checks pass: exact all ground outside Storage/shadow/apron, exact Home/shop/Hall foundations/signs and all nine door drawings, original footprint, actual near-black interior render, source doorway on existing tile (centre within2pixels), visible distinct door masks, transparent corners, actual walking/native E/sound/open/close/from-approach. Source PNG and optional painter were physically removed one at a time in the review checkout: exact old entire ground/blockout returns, the finished trio stays, service remains usable; restored before install. One fallback fixture left a small shutdown resource warning; the final primary native check was clean except the review certificate diagnostic. No production cleanup change claimed.

Native1152x648 captures in review/: storage_exterior uses fixture framing for the complete building, storage_service uses the actual camera. No production camera change, new interior/storage economy, natural dungeon clear or disk-save claim. Guarded hashes and original snapshots preserve concurrent work. No commit/settings edit or borrowed game assets/code.

## Next

Scroll Keeper, then remaining services and decoration. Keep purposeful buildings outlined through their details; decorative buildings get quieter treatment. Claude owns service inventory/state and dungeon rules.
''')
archive=W/'archive';archive.mkdir(exist_ok=True)
for folder in ['originals','candidate','review','sources','prompts']:shutil.copytree(W/folder,archive/folder,dirs_exist_ok=True)
for p in W.iterdir():
    if p.is_file() and p.suffix in ['.md','.gd','.py','.json','.log']:shutil.copy2(p,archive/p.name)
print('Concurrent unowned edits:',json.dumps(changed,indent=2))
print('Prepared',len(pending),'guarded files.')
