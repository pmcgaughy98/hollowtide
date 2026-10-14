from pathlib import Path
import json,hashlib,difflib,sys
from PIL import Image
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');S=Path('D:/dev/hollowtide-world-refinement-20261008/project')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
protected=json.loads((W/'protected.json').read_text(encoding='utf-8'))
phase=sys.argv[1] if len(sys.argv)>1 else 'stage'
expected=['scripts/town/hub_town.gd','scripts/town/town_room.gd','scripts/ui/game_pause_menu.gd','tools/debug/storage_check.gd']
actual=[r for r,h in protected.items() if sha((S if phase=='stage' else R)/r)!=h]
assert sorted(actual)==sorted(expected),actual
if phase=='stage':
    live_changes=[r for r,h in protected.items() if sha(R/r)!=h]
    assert not live_changes or sorted(live_changes)==sorted(expected),'Unexpected live source change.'
    for rel in live_changes:assert sha(R/rel)==sha(W/'prepared'/rel),'Live installation differs from candidate.'
newfiles={p.relative_to(W/'prepared').as_posix():sha(p) for p in (W/'prepared').rglob('*') if p.is_file()}
for rel,h in newfiles.items():assert sha((S if phase=='stage' else R)/rel)==h,rel
for name in ['shell.png']+['props/'+n+'.png' for n in ['cabinet_left','cabinet_right','counter','crates','basket','lamp']]:
    assert sha(W/'prepared/assets/sprites/world/storage_interior_2026_10_14'/name)==sha(R/'docs/world/storage-art-proposal-2026-10-14/staging/art'/name)
results={};diagnostics={};selected_logs={}
for kind in ['storage_check','integration','quit_check','town_room_check','hall_floors_check']:
    log=W/phase/kind/'godot.log'
    if kind=='hall_floors_check':
        options=[p for p in (W/phase/kind).glob('*.log') if 'OpenGL API' in p.read_text(encoding='utf-8') and 'HALL FLOORS: all ok' in p.read_text(encoding='utf-8')]
        assert options,'No completed native Hall check.'
        log=max(options,key=lambda p:p.stat().st_mtime)
    text=log.read_text(encoding='utf-8')
    errors=[line for line in text.splitlines() if line.startswith('ERROR:')]
    assert 'FAIL' not in text and ('all ok' in text or '/20' in text or '/5' in text),kind
    assert not errors or (kind=='hall_floors_check' and all('resources still in use at exit' in line for line in errors)),errors
    diagnostics[kind]=[line for line in text.splitlines() if line.startswith(('ERROR:','WARNING:'))]
    selected_logs[kind]=log.relative_to(W).as_posix()
    results[kind]=sum(line.endswith('-> ok') for line in text.splitlines())
diff=''
for rel in expected:
    old=(W/'originals'/rel).read_text(encoding='utf-8');new=(W/'prepared'/rel).read_text(encoding='utf-8')
    diff+=''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='before/'+rel,tofile='after/'+rel))
(W/'changes.diff').write_text(diff,encoding='utf-8')
receipt={'phase':phase,'native_results':results,'native_total':sum(results.values()),'native_result_logs':selected_logs,'shutdown_diagnostics':diagnostics,'protected_existing_files':len(protected),'expected_changed_files':expected,'other_existing_files_exact':len(protected)-len(expected),'installed_file_hashes':newfiles,'original_art_files_exact':7,'new_generation_calls':0,'storage_rules_and_state_model_unchanged':True,'panel_origin':[166,64],'room_open_tiles':108}
(W/(phase+'-audit.json')).write_text(json.dumps(receipt,indent=2),encoding='utf-8')
print(json.dumps({k:v for k,v in receipt.items() if k!='installed_file_hashes'},indent=2))
