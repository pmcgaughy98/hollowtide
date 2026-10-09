from pathlib import Path
from datetime import datetime,timezone
import hashlib,json,shutil,re

LIVE=Path('C:/Users/pmcga/dev/hollowtide')
ROOT=Path(__file__).parent
STAGE=ROOT/'project'
ART=Path('D:/dev/hollowtide-galeshear-wings-20261008')
WORLD_ARCHIVE=LIVE/'docs/world/first-morning-world-2026-10-08'
ART_ARCHIVE=LIVE/'docs/creatures/galeshear-wing-repair-2026-10-08'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
owned=['scripts/world_journey.gd','scripts/world_area.gd','scripts/area_landscape.gd','scripts/opening_flow.gd','tools/debug/opening_flow_check.gd']
new=['scripts/courier_partner_story.gd','scripts/world_atlas.gd','scripts/hometown_commons.gd','tools/debug/first_morning_check.gd','tools/debug/world_navigation_check.gd','tools/debug/world_route_regression.gd','tools/debug/galeshear_wings_check.gd']
baseline=json.loads((ROOT/'baseline.json').read_text())
for name in owned:assert sha(LIVE/name)==baseline[name],'Concurrent owned edit: '+name
for name in new:assert not (LIVE/name).exists(),'New target exists: '+name
assert not WORLD_ARCHIVE.exists() and not ART_ARCHIVE.exists(),'Archive exists; inspect before retry'
research=LIVE/'docs/research/world-references-2026-10-08.md'
assert not research.exists(),'Research already exists'
art_originals=json.loads((ART/'originals.json').read_text())
art_names=[r['path'] for r in art_originals]
assert len(art_names)==86
for item in art_originals:
    assert sha(LIVE/item['path'])==item['sha256'],'Concurrent Galeshear change: '+item['path']
    assert sha(ART/'originals'/item['path'])==item['sha256'],'Original backup mismatch'

# Verify the scripts and scene dependencies we actually exercised, without
# changing any current combat, data or launch settings during installation.
dependencies=['scripts/first_route_prototype.gd','scripts/player_party.gd','scripts/player.gd','scripts/courier_hall.gd','scripts/hometown_garden.gd','scripts/arena/arena_prototype.gd','scripts/arena/arena_signature.gd','scripts/main_menu.gd','scripts/main_menu_art_preview.gd','scripts/first_partner_arrival.gd','scripts/creature_portrait.gd','tools/arena/build_small.py','tools/arena/downscale.py','tools/arena/slice_rotations.py','scenes/opening_flow.tscn','scenes/main_menu_art_preview.tscn','data/creatures/103_kithflare.tres','data/creatures/1701_tallowroot.tres','data/creatures/001_rimefin.tres']
for name in dependencies:assert sha(LIVE/name)==sha(STAGE/name),'Test dependency changed: '+name
assert 'run/main_scene="res://scenes/opening_flow.tscn"' in (LIVE/'project.godot').read_text(),'Launch changed; inspect'
for p in (LIVE/'assets/sprites/arena').rglob('*.png'):
    rel=p.relative_to(LIVE).as_posix()
    if not rel.startswith('assets/sprites/arena/galeshear/'):
        assert (STAGE/rel).exists() and sha(p)==sha(STAGE/rel),'Concurrent arena asset changed: '+rel

reports=[]
for name in ['male-0-checks.json','female-1-checks.json','male-2-checks.json','navigation-checks.json','relay/male-checks.json']:
    report=json.loads((ROOT/'review'/name).read_text())
    assert not report['failures'] and all(x['passed'] for x in report['checks']),name
    reports.append({'case':name,'assertions':len(report['checks'])})
assert [r['assertions'] for r in reports[:3]]==[45,45,45]
art_report=json.loads((ART/'native/checks.json').read_text())
assert len(art_report['checks'])==138 and not art_report['failures']
audit=json.loads((ART/'asset-audit.json').read_text())
assert audit['palette_colors']==23 and audit['audited_images']==80
for name in ['check-male-kithflare','check-female-tallowroot','check-male-rimefin','navigation','relay']:
    log=(ROOT/(name+'-output.log')).read_text(errors='replace')
    assert 'SCRIPT ERROR' not in log and 'Failed loading resource' not in log,name
assert 'SCRIPT ERROR' not in (ART/'check-output.log').read_text(errors='replace')

protected_archive=LIVE/'docs/creatures/arena-material-consistency-2026-10-08'
state=json.loads((protected_archive/'final-state-check.json').read_text())
manifest=json.loads((protected_archive/'evidence-manifest.json').read_text())
old_originals=[i for i in manifest if i['path'].startswith(('source-audit/originals/','palette-reference/'))]
for item in state['images']:assert sha(LIVE/item['path'])==item['current_sha256'],'Protected refinement mismatch: '+item['path']
for item in old_originals:assert sha(protected_archive/item['path'])==item['sha256'],'Protected original/palette mismatch'

changed=set(owned+new+art_names)
protected={}
for folder in ['assets','data','scripts','scenes']:
    for p in (LIVE/folder).rglob('*'):
        if p.is_file() and p.suffix not in ['.import','.uid']:
            name=p.relative_to(LIVE).as_posix()
            if name not in changed:protected[name]=sha(p)
for name in ['project.godot','tools/arena/build_small.py','tools/arena/slice_rotations.py','tools/arena/downscale.py']:protected[name]=sha(LIVE/name)
note_path=LIVE/'docs/AI_COLLABORATION.md'
notes_before=note_path.read_bytes()
canvas_readme=LIVE/'docs/creatures/arena-canvaswing-2026-10-08/README.md'
canvas_before=canvas_readme.read_bytes()

for archive,source in [(WORLD_ARCHIVE,ROOT),(ART_ARCHIVE,ART)]:
    archive.mkdir(parents=True)
    (archive/'.gdignore').write_text('')
    shutil.copytree(source/'originals',archive/'originals')
    shutil.copy2(source/'README.md',archive/'README.md')
    (archive/'logs').mkdir()
    for p in source.glob('*.log'):shutil.copy2(p,archive/'logs'/p.name)
    (archive/'reproduction').mkdir()
    for p in source.glob('*.py'):shutil.copy2(p,archive/'reproduction'/p.name)
    for p in source.glob('*.gd'):shutil.copy2(p,archive/'reproduction'/p.name)
    for p in source.glob('*.json'):shutil.copy2(p,archive/p.name)
shutil.copytree(ROOT/'review',WORLD_ARCHIVE/'native')
shutil.copytree(ART/'native',ART_ARCHIVE/'native')
shutil.copytree(ART/'generated',ART_ARCHIVE/'generated')
(WORLD_ARCHIVE/'originals/AI_COLLABORATION-before.md').write_bytes(notes_before)
(ART_ARCHIVE/'originals/canvaswing-README-before.md').write_bytes(canvas_before)
(WORLD_ARCHIVE/'originals/project-live-before-install.godot').write_bytes((LIVE/'project.godot').read_bytes())

receipts=[]
for name in owned+new+art_names:
    target=LIVE/name
    target.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(STAGE/name,target)
    assert sha(target)==sha(STAGE/name)
    receipts.append({'path':name,'sha256':sha(target)})
    uid=STAGE/(name+'.uid')
    if name in new and name.endswith('.gd') and uid.exists():shutil.copy2(uid,LIVE/(name+'.uid'))
shutil.copy2(ROOT/'world-references-2026-10-08.md',research)
note='''## Codex: in-world first partner, regional map and Galeshear wing repair (October 8, 2026)

Preston requested a Firecrawl-informed world upgrade, then specified that starter selection belongs inside a story rather than at the menu, and separately reported Galeshear's clipped wings. Installed a playable first morning: New Game chooses courier appearance, enters the hometown with no fallback starter, leads to the existing hall, lets the player prepare outgoing mail with all three animated front-idle partners, and commits ownership only when one is invited. The dispatcher then gives the existing sealed-pouch route. Back/Keep looking is reversible; leaving for the levee before a partner gives an in-world direction back to the hall. New prose and the square label are proposals, not canon. Added an M-key regional map of the seven real areas with discovery, destination pins and next-exit directions, plus a planted courier square and lane signs using existing world art. Three full opening cases, navigation and relay/practice regressions pass in native Godot; see [world evidence and exact controls](world/first-morning-world-2026-10-08/README.md) and [Firecrawl source ledger](research/world-references-2026-10-08.md). The current opening_flow.tscn launch setting and approved menu base art/scripts are preserved. First-route controller and party code are unchanged; their existing fallback is suppressed only during New Game world initialization. Run-local progress only; current arena/campaign integration and save work are still outstanding. The legacy opening check now delegates to the first-morning check.

Galeshear's cuts were baked into source silhouettes. Built-in imagegen repaired the eight-facing reference and five walking sheets, followed by original-palette import into padded 192 px cells and the unchanged named-form builder. Installed 86 Galeshear PNGs/source sheets; all 86 previous files and generated originals are retained. The 1.1 arena scale and 23 original colors remain; this is silhouette reconstruction, not pixel-identical preservation of interior art. All 64 runtime walking frames, eight still facings and Gale Shear were checked; 138 native assertions pass. [Before/after, native captures, prompts, source authority, original backups and limitations](creatures/galeshear-wing-repair-2026-10-08/README.md). The existing three mirrored walking directions remain mirrored. No creature rules, battle code, data, builder or slicer changes.

Claude's latest VFX/chain/CC work, Listener line, Canvaswing/Windcut and all other artwork are preserved; final checks use the refreshed combat snapshot identified in the installation records. All 620 protected seven-form image paths and 622 original/palette entries are exact, including dark-jade Oxbowarchon. Opening checks retain certificate-store and shutdown ObjectDB warnings; native assertion success is not a claim of clean engine-wide diagnostics. No commit.

'''
assert note_path.read_bytes()==notes_before,'Concurrent notes edit; append handoff separately'
end=notes_before.index(b'\n')+1
note_path.write_bytes(notes_before[:end]+b'\n'+note.encode()+notes_before[end:])
assert canvas_readme.read_bytes()==canvas_before,'Concurrent Canvaswing README edit'
updated=canvas_before.decode().replace('- The rotation of the storm giant clips the tips of its crown spars at the top of a few cells.','- Wing/crown clipping repaired by Codex at Preston\'s request; see [the wing-repair archive](../galeshear-wing-repair-2026-10-08/README.md) for the current source sheets, native evidence and preserved originals.')
canvas_readme.write_text(updated)
for name,digest in protected.items():assert sha(LIVE/name)==digest,'Protected file changed during installation: '+name
for item in state['images']:assert sha(LIVE/item['path'])==item['current_sha256']
for item in old_originals:assert sha(protected_archive/item['path'])==item['sha256']
result={'installed_utc':datetime.now(timezone.utc).isoformat(),'files':receipts,'world_cases':reports,'world_assertions':sum(r['assertions'] for r in reports),'galeshear_native_assertions':138,'protected_files_unchanged_during_install':len(protected),'protected_seven_form_image_paths':len(state['images']),'original_palette_manifest_entries':len(old_originals),'preserved_galeshear_originals':len(art_originals),'tested_arena_sha256':sha(STAGE/'scripts/arena/arena_prototype.gd'),'live_arena_sha256':sha(LIVE/'scripts/arena/arena_prototype.gd'),'project_settings_sha256':sha(LIVE/'project.godot'),'project_settings_changed':False,'verification_boundary':'Final native checks use the refreshed snapshot. Later concurrent changes are outside that boundary.','diagnostics':['Windows certificate-store error in isolated profile','91 ObjectDB instances at shutdown in opening tests; direct original-world baseline does not reproduce this warning'],'progress':'Run-local; no disk progress save'}
for archive in [WORLD_ARCHIVE,ART_ARCHIVE]:(archive/'installation.json').write_text(json.dumps(result,indent=2))
print(json.dumps({k:v for k,v in result.items() if k not in ['files','world_cases']},indent=2))
