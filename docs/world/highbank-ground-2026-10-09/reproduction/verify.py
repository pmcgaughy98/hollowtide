from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
pending=json.loads((W/'pending-install.json').read_text())
for p in pending:assert sha(L/p['path'])==sha(Path(p['source'])), 'Installed mismatch '+p['path']
original=(W/'archive/originals/docs/AI_COLLABORATION.md').read_bytes()
live=(L/'docs/AI_COLLABORATION.md').read_bytes()
assert live.endswith(original[original.index(b'\n')+1:]), 'Previous collaboration text changed'
baseline=json.loads((W/'baseline.json').read_text());before=json.loads((W/'concurrent-before-install.json').read_text())
owned={p['path'] for p in pending};changed={}
for r,h in baseline.items():
    if r in owned:continue
    current=sha(L/r) if (L/r).exists() else None
    if current!=h:changed[r]={'original':h,'current':current,'already_concurrent_before_install':r in before}
runtime=[r for r in changed if r.startswith(('scripts/','scenes/','data/'))]
assert not runtime,'Runtime changed during install; inspect '+str(runtime)
record={'installed_verified':True,'runtime_files_written':['scripts/town/hub_town.gd','scripts/town/highbank_ground_painter.gd'],'note_written':'docs/AI_COLLABORATION.md','ground_assertions':13,'fallback_exact':True,'existing_hub_check':'all 13 places reachable, 12/12 services, Mouth dispatch','existing_loop_check':'real scene changes, forced clear/faint record transfer; no organic full clear claimed','generation_calls':0,'asset_files_written':0,'protected_baseline_files':len(baseline),'concurrent_preserved':changed,'installed_hashes':{p['path']:sha(L/p['path']) for p in pending}}
(W/'installation.json').write_text(json.dumps(record,indent=2))
print(json.dumps({'installed_verified':True,'protected_baseline':len(baseline),'concurrent_changes_preserved':len(changed),'asset_writes':0,'runtime_writes':2,'ground_assertions':13},indent=2))
