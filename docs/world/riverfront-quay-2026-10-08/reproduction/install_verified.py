from pathlib import Path
from datetime import datetime,timezone
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
A=L/'docs/world/riverfront-quay-2026-10-08'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
baseline=json.loads((W/'baseline.json').read_text())
owned=['scripts/area_landscape.gd','scripts/world_area.gd']
new={'scripts/riverfront_quay.gd':C/'scripts/riverfront_quay.gd','tools/debug/riverfront_quay_check.gd':W/'riverfront_quay_check.gd'}
assert not A.exists(),'Archive exists; inspect before retry'
research=L/'docs/research/riverfront-world-references-2026-10-08.md'
assert not research.exists()
for rel in owned:
    assert sha(L/rel)==baseline[rel],'Concurrent owned edit '+rel
    assert sha(W/'originals'/rel)==baseline[rel]
for rel in new:assert not (L/rel).exists(),'New file already exists '+rel
quay=json.loads((W/'check/checks.json').read_text());opening=json.loads((W/'opening/female-1-checks.json').read_text())
for report,count in [(quay,44),(opening,45)]:assert len(report['checks'])==count and not report['failures'] and all(c['passed'] for c in report['checks'])
for tag in ['check','after','direct','opening']:
    log=(W/(tag+'-output.log')).read_text(errors='replace')
    assert 'SCRIPT ERROR' not in log and 'Failed loading resource' not in log,tag
assert 'Direct F6 preview: 3 assertions passed' in (W/'direct-output.log').read_text()
# Explicit world verification boundary; current arena/picker edits are preserved, not rolled back.
dependencies=['scripts/world_journey.gd','scripts/first_fight.gd','scripts/first_route_prototype.gd','scripts/player.gd','scripts/player_party.gd','scripts/courier_partner_story.gd','scripts/opening_flow.gd','scripts/world_atlas.gd','scripts/hometown_commons.gd','scripts/city_relay_yard.gd','scripts/historic_street.gd','tools/debug/first_morning_check.gd','scenes/world_journey.tscn','scenes/city_riverfront.tscn']
for rel in dependencies:assert sha(L/rel)==sha(C/rel),'World test dependency changed '+rel
protected=L/'docs/creatures/arena-material-consistency-2026-10-08'
seven=json.loads((protected/'final-state-check.json').read_text())['images']
originals=[i for i in json.loads((protected/'evidence-manifest.json').read_text()) if i['path'].startswith(('source-audit/originals/','palette-reference/'))]
gale=[i for i in json.loads((L/'docs/creatures/galeshear-wing-repair-2026-10-08/installation.json').read_text())['files'] if i['path'].endswith('.png')]
listener=[i for i in json.loads((L/'docs/creatures/listener-palette-refinement-2026-10-08/installation.json').read_text())['files'] if i['path'].endswith('.png')]
def check_art():
    for i in seven:assert sha(L/i['path'])==i['current_sha256'],'Seven-form refinement '+i['path']
    for i in originals:assert sha(protected/i['path'])==i['sha256'],'Original/palette '+i['path']
    for i in gale+listener:assert sha(L/i['path'])==i['sha256'],'Recent refinement '+i['path']
check_art()
guard={}
for folder in ['assets','scripts','scenes','data','tools']:
    for p in (L/folder).rglob('*'):
        if p.is_file() and p.suffix not in ['.import','.uid','.pyc'] and '__pycache__' not in p.parts:
            rel=p.relative_to(L).as_posix()
            if rel not in owned:guard[rel]=sha(p)
guard['project.godot']=sha(L/'project.godot')
settings=(L/'project.godot').read_bytes()
note_path=L/'docs/AI_COLLABORATION.md';notes=note_path.read_bytes()
tested={rel:sha(C/rel) for rel in dependencies+owned+['scripts/riverfront_quay.gd']}
later=[rel for rel,h in baseline.items() if rel not in owned and (not (L/rel).exists() or sha(L/rel)!=h)]
A.mkdir(parents=True);(A/'.gdignore').write_text('')
shutil.copytree(W/'originals',A/'originals')
(A/'originals/AI_COLLABORATION-before.md').write_bytes(notes)
(A/'originals/project-live-before-install.godot').write_bytes(settings)
(A/'native').mkdir()
for folder in ['before','after','direct','check','opening']:shutil.copytree(W/folder,A/'native'/folder)
(A/'logs').mkdir();(A/'reproduction').mkdir()
for p in W.glob('*.log'):shutil.copy2(p,A/'logs'/p.name)
for p in W.glob('*.py'):shutil.copy2(p,A/'reproduction'/p.name)
for p in W.glob('*.gd'):shutil.copy2(p,A/'reproduction'/p.name)
for p in W.glob('*.json'):shutil.copy2(p,A/p.name)
shutil.copy2(W/'README.md',A/'README.md')
installed=[]
for rel,p in {**{r:C/r for r in owned},**new}.items():
    shutil.copy2(p,L/rel);assert sha(p)==sha(L/rel)
    installed.append({'path':rel,'sha256':sha(L/rel)})
shutil.copy2(W/'world-research.md',research)
installed.append({'path':research.relative_to(L).as_posix(),'sha256':sha(research)})
note='''## Codex: the playable riverfront quay district (October 8, 2026)

Preston asked to continue upgrading the world with Firecrawl and clarified that he meant the playable world, not the map UI. Built the existing riverfront into a walkable quay: riverside promenade, railed timber landing and readable water edge, repair frontage, branch court, planted goods approach and a sheltered garden with two side entrances. A resident walks the branch lane, yields near the player and pauses under overlays/reduced motion. The optional quay walk accepts three observations in any order, then opens the garden's north gate on return to the board. Actual gate collision changes; repeat observations deduplicate; the existing area cache retains the result. All new place labels and prose are proposals. Existing art only, with no PNG edits or generation. [Before/after, controls, native evidence, originals and limits](world/riverfront-quay-2026-10-08/README.md); [Firecrawl source ledger](research/riverfront-world-references-2026-10-08.md).

Native Godot: 44 end-to-end quay assertions, 45 existing opening/story assertions (female/Tallowroot), and 3 direct city-scene assertions pass. Real movement verifies every landing edge, solid water, both garden entries, the shortcut, cached state, and all north/east/west city exits and returns. Main delivery flags and party stay intact. Opening is tested explicitly in an isolated opening-scene configuration; Claude's current live F5 arena/picker setting is preserved. To see this world slice immediately, open scenes/city_riverfront.tscn and use F6. No edits to the Route 1 controller, world_journey, party, battle, creature data, menu or settings. Claude's latest arena/anchoring/picker work is preserved and not covered by these world tests. Final quay/preview logs have no script errors; Windows certificate diagnostic remains, and the existing opening test reports 102 shutdown ObjectDB instances. Progress is run-local, with no save/commerce/interior expansion. All 620 seven-form images, 622 original/palette entries, 86 Galeshear repaired images and 255 Listener PNGs are exact. No commit.

'''
assert note_path.read_bytes()==notes,'Concurrent collaboration note changed; append separately'
end=notes.index(b'\n')+1;note_path.write_bytes(notes[:end]+b'\n'+note.encode()+notes[end:])
check_art()
concurrent=[r for r,h in guard.items() if not (L/r).exists() or sha(L/r)!=h]
assert (L/'project.godot').read_bytes()==settings,'Settings changed concurrently; inspect'
result={'installed_utc':datetime.now(timezone.utc).isoformat(),'files':installed,'native_assertions':{'quay':44,'existing_opening_female_tallowroot':45,'direct_city_scene':3,'total':92},'tested_world_dependencies':tested,'unrelated_files_compared':len(guard),'concurrent_changes_during_install':concurrent,'concurrent_changes_since_snapshot_preserved':later,'project_settings_sha256':sha(L/'project.godot'),'project_settings_changed':False,'live_main_scene':'res://scenes/arena_prototype.tscn','test_opening_scene':'res://scenes/opening_flow.tscn','protected_seven_form_images':len(seven),'protected_original_palette_entries':len(originals),'protected_galeshear_images':len(gale),'protected_listener_images':len(listener),'diagnostics':['Windows root-certificate-store diagnostic','Existing opening check: 102 ObjectDB instances at shutdown'],'progress':'Run-local cached scene state; no durable save'}
(A/'installation.json').write_text(json.dumps(result,indent=2));(W/'installation.json').write_text(json.dumps(result,indent=2))
print(json.dumps({k:v for k,v in result.items() if k not in ['files','tested_world_dependencies']},indent=2))
