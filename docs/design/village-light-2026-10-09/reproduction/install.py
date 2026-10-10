from pathlib import Path
import hashlib,json,shutil,sys
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project');A=L/'docs/design/village-light-2026-10-09'
OWNED=['scripts/ui/village_menu_actor.gd','scripts/creature_opening.gd'];NOTES='docs/AI_COLLABORATION.md'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def copy(src,dst):dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst)
baseline=json.loads((W/'baseline.json').read_text())
assert not A.exists(),'Already installed; inspect first'
for r,h in baseline.items():
    assert sha(L/r)==h,'Concurrent menu dependency/settings change: '+r
    if r not in OWNED and r!='project.godot':assert sha(C/r)==h,'Review dependency mismatch: '+r
for name,count in [('animation',9),('input',7)]:
    result=json.loads((W/(name+'-checks.json')).read_text());assert len(result['checks'])==count and not result['failures']
for name in ['menu_animation_check','input_check']:
    log=(W/(name+'.log')).read_text()
    assert all(x not in log for x in ['SCRIPT ERROR:','Failed loading resource','SHADER ERROR:','Shader compilation failed']),name
originals={r:(L/r).read_bytes() for r in OWNED+[NOTES,'project.godot']}
protected={}
for folder in ['assets','scripts','scenes','data','tools','docs/creatures']:
    for p in (L/folder).rglob('*'):
        if p.is_file() and p.suffix not in ['.import','.uid','.pyc'] and '__pycache__' not in p.parts:
            r=p.relative_to(L).as_posix()
            if r not in OWNED:protected[r]=sha(p)
if '--check' in sys.argv:print(json.dumps({'ready':True,'checks':16,'protected':len(protected)}));sys.exit()
entry='''## Codex: village lighting on menu creatures (October 9, 2026)

Preston asked to blend the new Punchybun/Cinderhide actors into the town like the old sunset Cinderhide. Inspected that original dusk integration, then adapted its warm highlights, colored shade/contour and contact footprint to this amber/moss village. A menu-only RGB shader runs after the shared creature finish across all sixteen existing frames; no original PNG, alpha, anatomy, timing or feet anchor changes. Outer ground shade added to the existing footprints. No generation charge.

Only runtime edits: `scripts/ui/village_menu_actor.gd` and `scripts/creature_opening.gd`. Nine native animation assertions plus seven real mouse/keyboard assertions pass, with native still/loop captures inspected; final logs retain only the existing certificate diagnostic. New Game/awakening, Reduce Motion and menu controls remain. No dungeon regression claimed; Claude/Grok code, creature originals and prior backups remain untouched. No settings edit or commit. [Preview, originals, logs and installation](design/village-light-2026-10-09/README.md).

'''
notes=originals[NOTES];split=notes.index(b'\n')+1;nl='\r\n' if b'\r\n' in notes else '\n'
planned={r:(C/r).read_bytes() for r in OWNED};planned[NOTES]=notes[:split]+nl.encode()+entry.replace('\n',nl).encode()+notes[split:]
A.mkdir(parents=True)
copy(W/'README.md',A/'README.md')
for r,data in originals.items():
    p=A/'originals'/r;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data)
for p in W.iterdir():
    if p.is_file() and p.suffix in ['.png','.gif','.json','.log','.gd','.py']:
        folder='reproduction' if p.suffix in ['.gd','.py'] else 'logs' if p.suffix=='.log' else 'evidence'
        copy(p,A/folder/p.name)
copy(W/'title.png',A/'title.png');copy(W/'menu-loop.gif',A/'menu-loop.gif')
(A/'preserved-sha256.json').write_text(json.dumps(protected,indent=2))
for r,data in originals.items():assert (L/r).read_bytes()==data,'Concurrent edit before write: '+r
for r,data in planned.items():
    assert (L/r).read_bytes()==originals[r],'Concurrent edit during write: '+r
    (L/r).write_bytes(data)
concurrent={r:{'before':h,'after':sha(L/r)} for r,h in protected.items() if sha(L/r)!=h}
for r,data in planned.items():assert (L/r).read_bytes()==data,'Installed mismatch: '+r
assert (L/'project.godot').read_bytes()==originals['project.godot']
assert not any(r.startswith('assets/sprites/menu/') for r in concurrent),'Concurrent menu PNG change'
manifest={'changed_existing':list(planned),'hashes':{r:sha(L/r) for r in planned},'checks':16,'protected_files':len(protected),'concurrent_protected_changes':concurrent,'creature_pngs_written':0,'generation_calls':0,'settings_unchanged':True}
(A/'installation.json').write_text(json.dumps(manifest,indent=2))
print(json.dumps({'installed':True,'archive':str(A),'checks':16,'protected_files':len(protected),'concurrent':list(concurrent)},indent=2))
