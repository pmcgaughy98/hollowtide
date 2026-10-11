from pathlib import Path
import hashlib,json,shutil,ast
W=Path(__file__).parent;C=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
rows=json.loads((W/'evidence/manifest.json').read_text());protected=json.loads((W/'protected.json').read_text())
concurrent=json.loads((W/'concurrent.json').read_text())
assert set(concurrent).issubset({'scripts/soul_prologue.gd','scripts/town/guild_crew.gd','scripts/town/town_room.gd'})
for rel,record in concurrent.items():
    assert sha(C/rel)==record['concurrent_sha256'],f'Concurrent source changed again: {rel}'
    assert protected[rel]==record['original_sha256']
    protected[rel]=record['concurrent_sha256']
assert 'CREW PORTRAITS 49/49 PASS' in (W/'verify.log').read_text()
changed=[rel for rel,h in protected.items() if not (C/rel).exists() or sha(C/rel)!=h]
assert not changed,'Inspect concurrent changes before installing: '+str(changed)
tool='tools/ui/build_crew_dialogue_portraits.py'
ast.parse((W/'prepared'/tool).read_text())
assert not (C/tool).exists(),'A builder appeared concurrently; inspect first.'
imports=json.loads((W/'imports.json').read_text())
assert len(imports)==18 and all((W/'import-project'/rel).exists() for rel in imports)
for row in rows:
    assert not (C/row['output']).exists() and not (C/(row['output']+'.import')).exists(),'A portrait appeared concurrently: '+row['form']
    assert sha(W/'prepared'/row['output'])==row['output_sha256']
for row in rows:shutil.copy2(W/'prepared'/row['output'],C/row['output'])
for rel in imports:
    dst=C/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(W/'import-project'/rel,dst)
shutil.copy2(W/'prepared'/tool,C/tool)
assert all(sha(C/row['output'])==row['output_sha256'] for row in rows)
changed=[rel for rel,h in protected.items() if sha(C/rel)!=h]
assert not changed,'Concurrent protected change after install: '+str(changed)
report={'new_portraits':6,'new_native_import_metadata':6,'new_builder':tool,'protected_files_exact_at_install':len(protected),'exact_since_initial_snapshot':len(protected)-len(concurrent),'concurrent_changes_preserved':concurrent,'protected_changes_by_this_install':changed,'all_installed_rgba_hashes_exact':True,'game_script_changes_by_codex':0,'existing_portrait_changes':0,'expression_variants':'deferred; existing lookup falls back to normal','production_idle_swap':'Claude owns; unchanged by this portrait slice'}
(W/'install-audit.json').write_text(json.dumps(report,indent=2))
print('Installed six portraits, six imports and one reproducible preparation tool; all',len(protected),'protected files exact.')
