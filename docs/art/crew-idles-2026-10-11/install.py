from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;C=Path('C:/Users/pmcga/dev/hollowtide');A=C/'docs/art/crew-idles-2026-10-11'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
manifest=json.loads((W/'manifest.json').read_text());protected=json.loads((W/'protected.json').read_text())
assert 'CREW IDLES 31/31 PASS' in (W/'verify.log').read_text()
changed=[p for p,s in protected.items() if sha(C/p)!=s]
assert not changed,'Concurrent source changes require review: '+str(changed)
assert not A.exists(),'Do not replace an existing archive.'
for r in manifest:
    assert not (C/r['output']).exists(),'An idle appeared concurrently: '+r['form']
    assert not (C/(r['output']+'.import')).exists()
imports=json.loads((W/'imports.json').read_text())
assert len(imports)==18 and all((W/'import-project'/rel).exists() for rel in imports)
shutil.copytree(W/'originals',A/'originals')
for r in manifest:
    assert sha(W/'prepared'/r['output'])==r['output_sha']
    shutil.copy2(W/'prepared'/r['output'],C/r['output'])
for rel in imports:
    dst=C/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(W/'import-project'/rel,dst)
assert all(sha(C/r['output'])==r['output_sha'] for r in manifest)
changed=[p for p,s in protected.items() if sha(C/p)!=s]
assert not changed,'Concurrent protected change: '+str(changed)
(W/'install-audit.json').write_text(json.dumps({'new_idle_pngs':6,'new_import_metadata':6,'protected_files_exact':len(protected),'protected_changes':changed,'all_new_hashes_exact':True,'production_swap_wiring':'Claude owns; not edited by this asset preparation pass'},indent=2))
print('Six idle PNGs and native imports installed. All',len(protected),'existing protected files exact; production scripts untouched.')
