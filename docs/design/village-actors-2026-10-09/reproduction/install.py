from pathlib import Path
import hashlib,json,shutil,sys
W=Path(__file__).parent
L=Path('C:/Users/pmcga/dev/hollowtide')
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
A=L/'docs/design/village-actors-2026-10-09'
OWNED='scripts/creature_opening.gd'
NOTES='docs/AI_COLLABORATION.md'
ASSETS='assets/sprites/menu/village_actors_2026_10_09'
NEW=['scripts/ui/village_menu_actor.gd',ASSETS+'/animations.json']+[ASSETS+'/'+form+'/frame_%02d.png'%i for form in ['punchybun','cinderhide'] for i in range(8)]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else None
def copy(src,dst):dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst)
baseline=json.loads((W/'baseline.json').read_text())
assert not A.exists(),'Already installed; inspect before retry'
assert sha(L/OWNED)==baseline[OWNED],'Concurrent edit to creature opening'
for r in NEW:assert not (L/r).exists(),'New path exists: '+r
for r in ['scripts/opening_flow.gd','scripts/main_menu.gd','scripts/creature_prologue.gd','scenes/creature_opening.tscn','scenes/creature_prologue.tscn','scripts/ui/hollowtide_wordmark.gd','scripts/arena/creature_finish.gd','scripts/arena/creature_finish.gdshader','assets/sprites/menu/creature_village_2026_10_09.png']:
    assert sha(L/r)==sha(C/r),'Tested dependency changed: '+r
for name,count in [('animation',9),('input',7)]:
    result=json.loads((W/(name+'-checks.json')).read_text())
    assert not result['failures'] and len(result['checks'])==count,(name,result)
for name in ['menu_animation_check','input_check']:
    log=(W/(name+'.log')).read_text()
    assert 'SCRIPT ERROR:' not in log and 'Failed loading resource' not in log and 'No loader found' not in log,name
originals={r:(L/r).read_bytes() for r in [OWNED,'project.godot',NOTES]}
entry='''## Codex: dedicated village menu creature animations (October 9, 2026)

Preston requested dedicated menu sprites like the original Cinderhide animation. Installed two eight-frame Retro Diffusion loops: Punchybun's occasional gentle hop and Cinderhide's quiet breathing/head glance. Preston rejected a Punchybun redraw; the installed hop uses the approved original front PNG directly as input, with short rounded ears, fluffy tail and pink glove paws. Rejected variants are archived only. No original creature PNG is replaced.

Only existing runtime edit: `scripts/creature_opening.gd`. Added `scripts/ui/village_menu_actor.gd` and sixteen separate transparent frames plus metadata in `assets/sprites/menu/village_actors_2026_10_09/`. Fixed ground canvas, integer 2x nearest sampling, shared creature finish and Reduce Motion. Existing town, carved wordmark, controls, awakening/identity/partner story and gameplay remain. Nine native animation assertions and seven real mouse/keyboard assertions pass; actual town loop captured. This is menu verification, not a dungeon regression. No commit or project-setting change; Claude/Grok files and earlier creature refinements/backups preserved. Returned generation receipts total $1.36 (four stills, three animations including rejected trials); shared account balance is not attributed to this task.

[Native loop, originals, frame reviews, receipts and installation manifest](design/village-actors-2026-10-09/README.md).

'''
notes=originals[NOTES];split=notes.index(b'\n')+1;nl='\r\n' if b'\r\n' in notes else '\n'
planned={OWNED:(C/OWNED).read_bytes(),NOTES:notes[:split]+nl.encode()+entry.replace('\n',nl).encode()+notes[split:]}
protected={}
for folder in ['assets','scripts','scenes','data','tools','docs/creatures']:
    for p in (L/folder).rglob('*'):
        if p.is_file() and p.suffix not in ['.import','.uid','.pyc'] and '__pycache__' not in p.parts:
            r=p.relative_to(L).as_posix()
            if r!=OWNED:protected[r]=sha(p)
concurrent=[r for r,h in baseline.items() if r!=OWNED and sha(L/r)!=h]
if '--check' in sys.argv:
    print(json.dumps({'ready':True,'checks':16,'new_files':len(NEW),'protected_files':len(protected),'concurrent_since_review_start':concurrent},indent=2));sys.exit()
A.mkdir(parents=True)
copy(W/'README.md',A/'README.md')
for r,data in originals.items():
    p=A/'originals'/r;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data)
for p in W.iterdir():
    if p.is_file() and p.suffix in ['.png','.gif','.json','.log','.gd','.py']:
        folder='reproduction' if p.suffix in ['.py','.gd'] else 'logs' if p.suffix=='.log' else 'evidence'
        copy(p,A/folder/p.name)
copy(W/'menu-loop.gif',A/'menu-loop.gif')
copy(W/'title.png',A/'title.png')
copy(L/'assets/sprites/creatures/punchybun_2026_10_05/punchybun_front.png',A/'source-references/punchybun-original-front.png')
copy(L/'assets/sprites/arena/cinderhide/se.png',A/'source-references/cinderhide-original-se.png')
(A/'preserved-sha256.json').write_text(json.dumps(protected,indent=2))
for r,data in originals.items():assert (L/r).read_bytes()==data,'Concurrent edit before install: '+r
for r in NEW:copy(C/r,L/r)
for r,data in planned.items():
    assert (L/r).read_bytes()==originals[r],'Concurrent edit during install: '+r
    (L/r).write_bytes(data)
unexpected=[r for r,h in protected.items() if sha(L/r)!=h]
assert (L/'project.godot').read_bytes()==originals['project.godot'],'Settings changed concurrently'
manifest={'changed_existing':sorted(planned),'new_runtime':NEW,'hashes':{r:sha(L/r) for r in list(planned)+NEW},'protected_files':len(protected),'unexpected_changes':unexpected,'concurrent_since_review_start':concurrent,'checks':16,'creature_originals_modified':0,'generation_receipt_total':1.36}
(A/'installation.json').write_text(json.dumps(manifest,indent=2))
assert not unexpected,'Protected files changed concurrently: '+str(unexpected)
for r,data in planned.items():assert (L/r).read_bytes()==data,r
for r in NEW:assert sha(L/r)==sha(C/r),r
print(json.dumps({'installed':True,'archive':str(A),'checks':16,'protected_files':len(protected)},indent=2))
