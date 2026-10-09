from pathlib import Path
import hashlib,json,re,shutil,sys

W=Path(__file__).parent
L=Path('C:/Users/pmcga/dev/hollowtide')
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
A=L/'docs/design/creature-player-opening-2026-10-09'
NEW=['scripts/creature_opening.gd','scripts/creature_prologue.gd','scenes/creature_opening.tscn','scenes/creature_prologue.tscn','scripts/dungeon/hollow_bank_painter.gd','assets/tilesets/hollow_bank_2026_10_09/terrain_24.png','assets/tilesets/hollow_bank_2026_10_09/terrain_24.tres']
PAINTER='scripts/dungeon/floor_painter.gd'
OWNED={PAINTER,'project.godot','THE_CONCEPT.md','docs/AI_COLLABORATION.md'}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else None
def copy(src,dst):dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst)
def prepend_after_title(raw,entry):
    split=raw.index(b'\n')+1
    nl=b'\r\n' if b'\r\n' in raw else b'\n'
    return raw[:split]+nl+entry.replace('\n','\r\n' if nl==b'\r\n' else '\n').encode()+nl+raw[split:]

baseline=json.loads((W/'baseline.json').read_text())
baseline.update(json.loads((W/'concurrent-refresh.json').read_text()))
changed=[r for r,h in baseline.items() if sha(L/r)!=h]
assert not changed, 'Live files changed since reviewed refresh: '+str(changed)
assert not A.exists(),'Archive already exists; inspect before retry'
assert all(not (L/r).exists() for r in NEW),'New runtime path already exists'
for r in NEW+[PAINTER]:assert (C/r).is_file(),r
for r,h in baseline.items():
    if h is not None and r!=PAINTER and r!='project.godot':assert sha(C/r)==h,'Staged dependency differs: '+r
counts={}
for name in ['checks.json','input-checks.json','bridge-checks.json']:
    result=json.loads((W/name).read_text())
    assert not result['failures'],name
    counts[name]=len(result.get('checks',result.get('results',[])))
for name in ['opening_check','input_check','terrain_bridge_check','turn_check']:
    log=(W/(name+'.log')).read_text()
    assert 'SCRIPT ERROR:' not in log and 'Failed loading resource' not in log,name
turn=(W/'turn_check.log').read_text()
assert 'B2F: team' in turn,'Turn-based regression has not completed'
assert 'overlaps 0, creatures in walls 0' in turn,'Turn regression collision issue needs review'
assert 'var real_time_battles := false' in (L/'scripts/dungeon/dungeon.gd').read_text()
originals={r:(L/r).read_bytes() for r in OWNED}
project=originals['project.godot']
match=re.search(rb'^run/main_scene="([^"]+)"',project,re.M)
assert match, 'Missing main scene'
newproject=project[:match.start()]+b'run/main_scene="res://scenes/creature_opening.tscn"'+project[match.end():]
concept='> **2026-10-09, Preston: creature protagonist.** The player is now a creature, in the Mystery Dungeon direction. New Game opens an awakening and companion encounter before entering a Hollow. The current playable opening is `scenes/creature_opening.tscn`; its new prose is a proposal. Dungeon combat stays turn-based under Claude\'s latest update. The former human courier opening and hometown remain available while the creature guild and return loop are future work.\n'
collab='''## Codex: creature-player opening and first Hollow terrain pass (October 9, 2026)

Preston directly revised the protagonist to a creature and asked to rethink launch, then upgrade the dungeon. F5 now opens `scenes/creature_opening.tscn`: the approved sunset menu with two finished creature sprites, New Game into an awakening, identity choice among Kithflare/Tallowroot/Rimefin, a different survivor as companion, then the existing Hollow with the chosen leader and party. Identity is selected inside the opening, not on the title menu. New story text and "The First Voice" are proposals. The old opening/world scenes remain intact. No persistent identity, save rewrite, creature guild or return loop is claimed.

Original generated 24px terrain atlas: silt/grass/clay ground, bank tops and cliff faces, neighbour edges/corner caps, root variants, shadow and stairs. `floor_painter.gd` delegates to the new painter at 24px and keeps the original procedural fallback. An editor TileSet exposes all sixteen cells; water art is present but not active terrain. One built-in imagegen call; Firecrawl read SkyTemple's dungeon tileset structure only. No borrowed art/code/maps/text.

Current native verification: 30 opening/terrain plus 7 real mouse/keyboard assertions pass. The broader turn-based regression, before Claude's positional-combat update, stayed on B1F after 1,035 turns despite clearing the enemies; zero overlaps, wall occupants or faints. Its final printed 'B2F' label is unconditional and does not mean the stairs were reached. This autoplay limitation needs follow-up with Claude. The optional hybrid bridge was explicitly enabled only in a separate paired old/new-art probe; both registered damage and shared the floor image. Earlier hybrid autoplay evidence and its arranged encounter frame-cap limitation are historical evidence. Final scoped logs have no script/resource errors; the existing certificate diagnostic and opening shutdown ObjectDB leak remain recorded.

Concurrent changes inspected and brought into the review copy: Claude's turn-based default, Dustkite dust cleanup, Hollow path commitment/body-width sight fix and the newer ambush/pincer/shove mechanics. The opening/input checks were repeated against that newer dungeon; the earlier combat probes do not validate his new mechanics. Those files and all creature PNGs are untouched by installation. Original seven-form palettes, dark-jade Oxbowarchon, Listener finish, Galeshear repair and prior backups remain exact. Changed existing runtime files: only the floor painter and main-scene setting; new launch scripts/scenes and terrain resources are separate. No commit. Originals, source prompt/Firecrawl receipts, native screenshots, tests and exact installation manifest: [creature-player opening](design/creature-player-opening-2026-10-09/README.md).

Next with Claude: creature guild/dispatch/return and persistent player identity. Palette locks and emotion portraits from the handoff remain separate jobs.
'''
planned={PAINTER:(C/PAINTER).read_bytes(),'project.godot':newproject,'THE_CONCEPT.md':prepend_after_title(originals['THE_CONCEPT.md'],concept),'docs/AI_COLLABORATION.md':prepend_after_title(originals['docs/AI_COLLABORATION.md'],collab)}
# Guard existing production assets/code and historical backup/reference files before any write.
protected={}
for folder in ['assets','scripts','scenes','data','tools','docs/creatures']:
    for p in (L/folder).rglob('*'):
        if p.is_file() and p.suffix not in ['.import','.uid','.pyc'] and '__pycache__' not in p.parts:
            r=p.relative_to(L).as_posix()
            if r not in OWNED:protected[r]=sha(p)
if '--check' in sys.argv:
    print(json.dumps({'ready':True,'new_files':NEW,'existing_changes':sorted(OWNED),'protected_files':len(protected),'checks':counts,'old_main':match.group(1).decode()},indent=2));sys.exit()

# Archive all originals/evidence before touching runtime files.
A.mkdir(parents=True)
for r,data in originals.items():
    p=A/'originals'/r;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data)
copy(W/'README.md',A/'README.md')
for name in ['terrain-source.png','generation-prompt.txt','firecrawl.json']:copy(W/name,A/'source'/name)
for p in W.glob('*.png'):
    if p.name!='terrain-source.png':copy(p,A/'native'/p.name)
for folder in ['hybrid','turn-regression']:
    if (W/folder).exists():shutil.copytree(W/folder,A/'native'/folder)
for p in W.glob('*.log'):copy(p,A/'logs'/p.name)
for p in W.iterdir():
    if p.suffix in ['.gd','.py']:copy(p,A/'reproduction'/p.name)
for name in ['checks.json','input-checks.json','bridge-checks.json','concurrent-changes.json','concurrent-refresh.json']:copy(W/name,A/name)
(A/'preserved-sha256.json').write_text(json.dumps(protected,indent=2))
# Recheck just before mutation; never revert another collaborator's edits.
for r,data in originals.items():assert (L/r).read_bytes()==data,'Concurrent edit: '+r
for r,h in baseline.items():assert sha(L/r)==h,'Concurrent runtime change: '+r
for r in NEW:copy(C/r,L/r)
for r,data in planned.items():
    assert (L/r).read_bytes()==originals[r],'Concurrent edit: '+r
    (L/r).write_bytes(data)
after={r:sha(L/r) for r in NEW+sorted(OWNED)}
unexpected=[r for r,h in protected.items() if sha(L/r)!=h]
manifest={'new_files':NEW,'changed_existing':sorted(OWNED),'sha256':after,'protected_files':len(protected),'unexpected_changes':unexpected,'old_main':match.group(1).decode(),'new_main':'res://scenes/creature_opening.tscn','checks':counts,'creature_pngs_modified':0,'imagegen_calls':1,'combat_default':'turn-based','concurrent_changes_preserved':json.loads((W/'concurrent-refresh.json').read_text())}
(A/'installation.json').write_text(json.dumps(manifest,indent=2))
assert not unexpected,'Concurrent changes during install: '+str(unexpected)
for r in NEW:assert sha(L/r)==sha(C/r),r
for r,data in planned.items():assert (L/r).read_bytes()==data,r
print(json.dumps({'installed':True,'archive':str(A),'protected_files':len(protected),'checks':counts,'new_main':manifest['new_main']},indent=2))
