from pathlib import Path
import hashlib,json,re,shutil,sys
W=Path(__file__).parent
L=Path('C:/Users/pmcga/dev/hollowtide')
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
A=L/'docs/design/village-wordmark-2026-10-09'
SCRIPTS=['scripts/creature_opening.gd','scripts/main_menu.gd']
NEW='scripts/ui/hollowtide_wordmark.gd'
NOTES='docs/AI_COLLABORATION.md'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else None
def copy(src,dst):dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst)
baseline=json.loads((W/'baseline.json').read_text())
assert not A.exists() and not (L/NEW).exists(),'Already installed; inspect before retry'
for r in SCRIPTS:assert sha(L/r)==baseline[r],'Concurrent edit to owned script: '+r
for r in ['scripts/opening_flow.gd','scripts/main_menu_art_preview.gd','scripts/creature_prologue.gd','assets/fonts/Vollkorn-Variable.ttf']:
    assert sha(L/r)==sha(C/r),'Tested menu dependency changed: '+r
result=json.loads((W/'input-checks.json').read_text())
assert not result['failures'] and len(result['checks'])==7
for name in ['preview','input_check']:
    log=(W/(name+'.log')).read_text()
    assert 'SCRIPT ERROR:' not in log and 'Failed loading resource' not in log,name
originals={r:(L/r).read_bytes() for r in SCRIPTS+['project.godot',NOTES]}
project=originals['project.godot']
match=re.search(rb'^run/main_scene="([^"]+)"',project,re.M)
assert match
planned={r:(C/r).read_bytes() for r in SCRIPTS}
planned['project.godot']=project[:match.start()]+b'run/main_scene="res://scenes/creature_opening.tscn"'+project[match.end():]
entry='''## Codex: carved Hollowtide village wordmark (October 9, 2026)

Preston asked to redo the title text, then finish after the usage interruption. Installed exact code-native Hollowtide lettering: parchment/ochre serif faces, wood depth, moss tips, root branches and a small Hollow doorway. Existing OFL Vollkorn, native 384x84 transparent canvas at exact 2x; still lettering in both menu and prelude. New `scripts/ui/hollowtide_wordmark.gd`, integrated only into the creature opening. No generation charge or creature/background image edit.

The preview exposed varying resource-preload errors from the unused background request for the human world. `main_menu.gd` now delegates that one request through `_request_route()`: old menus retain it, the creature opening skips it. Final native title/prelude/options previews and seven real mouse/keyboard checks pass without script/resource errors; existing Windows certificate diagnostic remains. F5 had moved back to the old menu-art preview UID, so only the main-scene key was restored to `scenes/creature_opening.tscn`.

Village painting, menu controls, creature art, prior wordmark and Claude/Grok gameplay changes are preserved. No gameplay/data edits or commit. [Native previews, originals, diagnostics and installation](design/village-wordmark-2026-10-09/README.md).

'''
notes=originals[NOTES];split=notes.index(b'\n')+1;nl='\r\n' if b'\r\n' in notes else '\n'
planned[NOTES]=notes[:split]+nl.encode()+entry.replace('\n',nl).encode()+notes[split:]
protected={}
for folder in ['assets','scripts','scenes','data','tools','docs/creatures']:
    for p in (L/folder).rglob('*'):
        if p.is_file() and p.suffix not in ['.import','.uid','.pyc'] and '__pycache__' not in p.parts:
            r=p.relative_to(L).as_posix()
            if r not in SCRIPTS:protected[r]=sha(p)
if '--check' in sys.argv:
    print(json.dumps({'ready':True,'old_main':match.group(1).decode(),'checks':7,'protected_files':len(protected)},indent=2));sys.exit()
A.mkdir(parents=True)
copy(W/'README.md',A/'README.md')
for r,data in originals.items():
    p=A/'originals'/r;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data)
for p in W.glob('*.png'):copy(p,A/'native'/p.name)
for p in W.glob('*.log'):copy(p,A/'logs'/p.name)
for p in W.iterdir():
    if p.suffix in ['.gd','.py']:copy(p,A/'reproduction'/p.name)
copy(W/'input-checks.json',A/'input-checks.json')
(A/'preserved-sha256.json').write_text(json.dumps(protected,indent=2))
for r,data in originals.items():assert (L/r).read_bytes()==data,'Concurrent edit: '+r
copy(C/NEW,L/NEW)
for r,data in planned.items():
    assert (L/r).read_bytes()==originals[r],'Concurrent edit: '+r
    (L/r).write_bytes(data)
unexpected=[r for r,h in protected.items() if sha(L/r)!=h]
manifest={'changed_existing':sorted(planned),'new_script':NEW,'hashes':{r:sha(L/r) for r in list(planned)+[NEW]},'old_main':match.group(1).decode(),'new_main':'res://scenes/creature_opening.tscn','input_checks':7,'protected_files':len(protected),'unexpected_changes':unexpected,'generation_calls':0,'creature_pngs_modified':0}
(A/'installation.json').write_text(json.dumps(manifest,indent=2))
assert not unexpected,'Concurrent protected changes during install: '+str(unexpected)
for r,data in planned.items():assert (L/r).read_bytes()==data,r
assert sha(L/NEW)==sha(C/NEW)
print(json.dumps({'installed':True,'archive':str(A),'input_checks':7,'protected_files':len(protected)},indent=2))
