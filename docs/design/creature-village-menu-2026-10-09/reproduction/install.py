from pathlib import Path
import hashlib,json,shutil,sys
W=Path(__file__).parent
L=Path('C:/Users/pmcga/dev/hollowtide')
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
A=L/'docs/design/creature-village-menu-2026-10-09'
SCRIPT='scripts/creature_opening.gd'
ART='assets/sprites/menu/creature_village_2026_10_09.png'
NOTES='docs/AI_COLLABORATION.md'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else None
def copy(src,dst):dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst)
baseline=json.loads((W/'baseline.json').read_text())
assert sha(L/SCRIPT)==baseline[SCRIPT],'Creature menu concurrently edited; inspect before installing'
assert not (L/ART).exists() and not A.exists(),'Install target already exists; inspect before retry'
deps=['scripts/main_menu.gd','scripts/main_menu_art_preview.gd','scripts/opening_flow.gd','scripts/creature_prologue.gd','scripts/arena/creature_finish.gd','scripts/arena/creature_finish.gdshader']
for r in deps:assert sha(L/r)==sha(C/r),'A tested menu dependency changed: '+r
counts={}
for name in ['checks.json','input-checks.json']:
    result=json.loads((W/name).read_text());assert not result['failures'],name
    counts[name]=len(result['checks'])
for name in ['opening_check','input_check']:
    log=(W/(name+'.log')).read_text()
    assert 'SCRIPT ERROR:' not in log and 'Failed loading resource' not in log,name
assert sum(counts.values())==39
protected={}
for folder in ['assets','scripts','scenes','data','tools','docs/creatures']:
    for p in (L/folder).rglob('*'):
        if p.is_file() and p.suffix not in ['.import','.uid','.pyc'] and '__pycache__' not in p.parts:
            r=p.relative_to(L).as_posix()
            if r!=SCRIPT:protected[r]=sha(p)
project=(L/'project.godot').read_bytes()
original=(L/SCRIPT).read_bytes();notes=(L/NOTES).read_bytes()
assert b'run/main_scene="res://scenes/creature_opening.tscn"' in project
concurrent={r:sha(L/r) for r,h in baseline.items() if r!=SCRIPT and sha(L/r)!=h}
entry='''## Codex: creature-village title menu (October 9, 2026)

Preston said the river-town menu no longer fit the creature/Mystery Dungeon direction and authorized Retro. Installed one original Retro Diffusion `rd_pro__fantasy` 256x144 village backdrop ($0.18): root/clay burrows, moss roofs, stone guild entrance, stream, bridges and lanterns. No baked characters or UI. It replaces the title-screen town composition, not the playable hometown. Architecture is a visual proposal. The old sunset artwork is preserved.

The existing wordmark is smaller over the canopy; the main choices move to the lower-left bank with earth/moss panels and parchment focus. Two existing finished creature sprites stand at village scale with their existing arrival walk; a few fireflies animate, Reduce Motion freezes them. Music, settings, inputs and quit confirmation remain. New Game keeps the awakening/identity/companion flow and passes the selected party into the existing turn-based dungeon.

32 native flow/terrain assertions and 7 real mouse/keyboard checks pass (39 total); native title/options/prologue/dungeon screenshots inspected. No final script/resource errors. Existing certificate diagnostic and 102 opening shutdown ObjectDB instances remain. This does not claim a full dungeon clear or validate Claude's new combat mechanics; prior autoplay limitation remains in the previous slice.

Runtime edits: only `scripts/creature_opening.gd`, plus `assets/sprites/menu/creature_village_2026_10_09.png`. No creature PNGs, shared controller, gameplay code, stats or project settings edited. Original menu script, source/prompt/cost receipt, native previews, checks and exact preservation manifest: [creature village menu](design/creature-village-menu-2026-10-09/README.md). No commit.

'''
nl='\r\n' if b'\r\n' in notes else '\n'
split=notes.index(b'\n')+1
newnotes=notes[:split]+nl.encode()+entry.replace('\n',nl).encode()+notes[split:]
if '--check' in sys.argv:
    print(json.dumps({'ready':True,'checks':counts,'protected_files':len(protected),'concurrent_unowned_changes':list(concurrent)},indent=2));sys.exit()
A.mkdir(parents=True)
copy(W/'README.md',A/'README.md')
for r,data in [(SCRIPT,original),(NOTES,notes),('project.godot',project)]:
    p=A/'originals'/r;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data)
for name in ['town-source.png','generation.json']:copy(W/name,A/'source'/name)
for p in W.glob('*.png'):
    if p.name!='town-source.png':copy(p,A/'native'/p.name)
for p in W.glob('*.log'):copy(p,A/'logs'/p.name)
for p in W.iterdir():
    if p.suffix in ['.gd','.py']:copy(p,A/'reproduction'/p.name)
for name in ['checks.json','input-checks.json']:copy(W/name,A/name)
(A/'preserved-sha256.json').write_text(json.dumps(protected,indent=2))
assert (L/SCRIPT).read_bytes()==original and (L/NOTES).read_bytes()==notes,'Concurrent edit before installation'
assert (L/'project.godot').read_bytes()==project,'Main settings changed; inspect'
copy(C/ART,L/ART)
(L/SCRIPT).write_bytes((C/SCRIPT).read_bytes())
(L/NOTES).write_bytes(newnotes)
unexpected=[r for r,h in protected.items() if sha(L/r)!=h]
manifest={'runtime_script':SCRIPT,'new_asset':ART,'hashes':{r:sha(L/r) for r in [SCRIPT,ART,NOTES]},'protected_files':len(protected),'unexpected_changes':unexpected,'settings_unchanged':(L/'project.godot').read_bytes()==project,'checks':counts,'generation_cost':0.18,'generation_calls':1,'creature_pngs_modified':0,'concurrent_unowned_changes':concurrent,'menu_dependencies':{r:sha(L/r) for r in deps}}
(A/'installation.json').write_text(json.dumps(manifest,indent=2))
assert not unexpected,'Concurrent protected changes during installation: '+str(unexpected)
assert manifest['settings_unchanged']
for r in [SCRIPT,ART]:assert sha(L/r)==sha(C/r),r
print(json.dumps({'installed':True,'archive':str(A),'checks':counts,'protected_files':len(protected),'cost':0.18},indent=2))
