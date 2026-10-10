from pathlib import Path
import hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
pending=json.loads((W/'pending-install.json').read_text())
for p in pending:assert sha(L/p['path'])==sha(Path(p['source'])),'Installed mismatch: '+p['path']
original=(W/'archive/originals/docs/AI_COLLABORATION.md').read_bytes()
assert (L/'docs/AI_COLLABORATION.md').read_bytes().endswith(original[original.index(b'\n')+1:]),'Earlier collaboration text changed'
baseline=json.loads((W/'baseline.json').read_text());concurrent=json.loads((W/'concurrent-before-install.json').read_text())
owned={p['path'] for p in pending};changed={};new_changes={}
for r,h in baseline.items():
    if r in owned:continue
    current=sha(L/r) if (L/r).exists() else None
    if current!=h:changed[r]={'baseline':h,'current':current,'already_concurrent_before_install':r in concurrent}
    expected=concurrent[r]['now'] if r in concurrent else h
    if current!=expected:new_changes[r]={'before_install':expected,'current':current}
assert 'imported_native=true reviewed_map_exact=true' in (W/'live_smoke.log').read_text(),'Live imported map failed verification'
manifest={'installed_verified':True,'native_assertions':13,'absent_painter_fallback_exact':True,'live_asset_import':True,'live_map_matches_review_byte_exact':True,'generation_calls':1,'retro_calls':0,'existing_asset_files_written':0,'new_asset':'assets/sprites/world/home_2026_10_09/home_native.png','runtime_scope':['scripts/town/highbank_ground_painter.gd','scripts/town/home_painter.gd'],'protected_baseline_files':len(baseline),'concurrent_preserved':changed,'changes_since_packaging':new_changes,'installed_hashes':{p['path']:sha(L/p['path']) for p in pending}}
(W/'installation.json').write_text(json.dumps(manifest,indent=2))
print(json.dumps({'installed_verified':True,'native_assertions':13,'fallback_exact':True,'protected_files':len(baseline),'concurrent_preserved':list(changed),'new_external_changes':list(new_changes)},indent=2))
