from pathlib import Path
import hashlib,json,shutil,sys
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');P=W/'candidate';C=Path('D:/dev/hollowtide-world-refinement-20261008/project');A=L/'docs/creatures/handoff-palette-locks-2026-10-09'
NOTES=['docs/AI_COLLABORATION.md','docs/team/CODEX_HANDOFF_2026-10-10.md']
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def copy(src,dst):dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst)
baseline=json.loads((W/'baseline.json').read_text());owned=json.loads((W/'owned.json').read_text());report=json.loads((W/'structural-and-palette-checks.json').read_text())
assert not A.exists(),'Already installed; inspect before retry'
assert not report['failures'] and report['alpha_exact']==785 and report['palette_exact']==785
for r,h in baseline.items():assert sha(L/r)==h,'Concurrent source/pipeline change: '+r
native=json.loads((W/'native-checks.json').read_text());assert not native['failures'] and native['textures']==720
for model in ['male','female']:
    relay=json.loads((W/'relay'/(model+'-checks.json')).read_text());assert len(relay['checks'])==25 and not relay['failures'],model
for name in ['palette_native_check','relay_yard_check','relay_yard_check-female']:
    log=(W/(name+'.log')).read_text();assert all(s not in log for s in ['SCRIPT ERROR:','Failed loading resource','No loader found']),name
changes=[r for r in owned if sha(L/r)!=sha(P/r)];assert len(changes)==784,len(changes)
original_notes={r:(L/r).read_bytes() for r in NOTES};settings=(L/'project.godot').read_bytes()
protected={}
for folder in ['assets','scripts','scenes','data','tools','docs/creatures']:
    for p in (L/folder).rglob('*'):
        if p.is_file() and p.suffix not in ['.import','.uid','.pyc'] and '__pycache__' not in p.parts:
            r=p.relative_to(L).as_posix()
            if r not in changes:protected[r]=sha(p)
if '--check' in sys.argv:print(json.dumps({'ready':True,'changed_pngs':len(changes),'protected':len(protected),'native_textures':720,'relay_checks':50},indent=2));sys.exit()
entry='''## Codex: October 10 handoff palette locks and relay check (October 9, 2026)

Resumed the handoff after inspecting installed terrain/menu and current Claude/Grok work. Locked Dustkite/Waywhistle/Highsignal and the remade Riftfin/Scourmaw to each approved front take using the existing deterministic normalizer; rebuilt ONLY these five arena and dungeon sets with the unchanged builders. 784 PNG RGB updates, all 785 source/derived canvases, alpha bytes and transparent RGBA exact. All painted colors are from the approved form palette. No old blade-fin/serpent art, cleaned Dustkite silhouette, seven-form refinements, dark-jade Oxbowarchon, Listener finish, Galeshear repair or prior backup overwritten.

Native art verification uses both actual constructors and finish materials, all 720 facing/walk texture swaps with planted anchors, fresh controlled native render/loop. The requested relay regression passes 25 checks for each appearance (50): real yard walking, clue/choice flow, Cinderhide/Fusern practice fight, escape through picker to the cached world, party/route state and exit/reentry preserved. No script/resource errors; existing certificate diagnostic remains. This does not certify a full dungeon clear or rebalance combat. No runtime code, data, settings or menu edit; no paid calls or commit. Detailed remaining walking variation and originals: [handoff palette archive](creatures/handoff-palette-locks-2026-10-09/README.md).

Next handoff job: creature guild/job-board presentation, dispatch and return with Claude's dungeon/save contract. Emotional portraits stay later.

'''
progress='''## Codex progress checked October 9, 2026

The original handoff below is retained as written by Claude. Current state supersedes its old main-scene statement: F5 opens the creature-village menu, then the awakening/identity/companion story; no starter choice on the title screen.

- Job 1 initial 24px terrain atlas/painter is installed, with the procedural fallback (`docs/design/creature-player-opening-2026-10-09/`). Secondary terrain remains inactive.
- Job 2 palette locks now installed for Dustkite, Waywhistle, Highsignal and current remade Riftfin/Scourmaw, in both arena and dungeon sets. Current models and cleaned silhouettes preserved.
- Job 3 relay check rerun: both appearances pass 25 real input/world/practice checks each against the rebuilt picker.
- Jobs 4 and 5 remain: creature guild/board/roster/dispatch/return with Claude, then emotion portraits. Old human-world courier content is retained; the creature guild loop and persistent identity are not claimed built.

Evidence and scope: `docs/creatures/handoff-palette-locks-2026-10-09/README.md`. No commit or gameplay/settings edits.

'''
planned={}
for r,data in original_notes.items():
    nl='\r\n' if b'\r\n' in data else '\n';s=data.index(b'\n')+1;block=entry if r==NOTES[0] else progress
    planned[r]=data[:s]+nl.encode()+block.replace('\n',nl).encode()+data[s:]
A.mkdir(parents=True);(A/'.gdignore').write_text('')
copy(W/'README.md',A/'README.md');shutil.copytree(W/'originals',A/'originals');shutil.copytree(P,A/'candidate')
for r,data in original_notes.items():
    dest=A/'originals'/r;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(data)
for p in W.iterdir():
    if p.is_file() and p.suffix in ['.json','.png','.gif','.log','.py','.gd']:
        folder='reproduction' if p.suffix in ['.py','.gd'] else 'logs' if p.suffix=='.log' else ''
        copy(p,A/folder/p.name)
shutil.copytree(W/'relay',A/'relay')
(A/'preserved-sha256.json').write_text(json.dumps(protected,indent=2))
for r,h in baseline.items():assert sha(L/r)==h,'Concurrent source/pipeline change before install: '+r
for r,data in original_notes.items():assert (L/r).read_bytes()==data,'Concurrent handoff update: '+r
for r in changes:
    assert sha(L/r)==baseline[r],'Concurrent asset write: '+r
    copy(P/r,L/r)
for r,data in planned.items():
    assert (L/r).read_bytes()==original_notes[r],'Concurrent note update: '+r
    (L/r).write_bytes(data)
concurrent={r:{'before':h,'after':sha(L/r)} for r,h in protected.items() if sha(L/r)!=h}
assert not any(r.startswith('assets/') for r in concurrent),'Concurrent protected art change; review required'
for r in changes:assert sha(L/r)==sha(P/r),'Installed mismatch: '+r
assert (L/'project.godot').read_bytes()==settings,'Settings changed concurrently'
(A/'installed-files.json').write_text(json.dumps({r:sha(L/r) for r in changes},indent=2))
manifest={'changed_pngs':len(changes),'checked_pngs':785,'native_checks':native,'relay_checks':50,'protected_files':len(protected),'concurrent_protected_changes':concurrent,'changed_notes':NOTES,'runtime_code_written':0,'generation_calls':0,'settings_unchanged':True}
(A/'installation.json').write_text(json.dumps(manifest,indent=2))
print(json.dumps({'installed':True,'archive':str(A),'changed_pngs':len(changes),'native_textures':720,'relay_checks':50,'concurrent':list(concurrent)},indent=2))
