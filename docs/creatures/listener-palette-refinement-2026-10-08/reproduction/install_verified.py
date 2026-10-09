from pathlib import Path
from datetime import datetime,timezone
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
A=L/'docs/creatures/listener-palette-refinement-2026-10-08'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
candidate=json.loads((W/'candidate-audit.json').read_text())
original=json.loads((W/'original-manifest.json').read_text())
tests=json.loads((W/'native/checks.json').read_text())
assert len(tests['checks'])==436 and not tests['failures']
assert all(i['passed'] for i in tests['checks'])
assert 'SCRIPT ERROR' not in (W/'check-output.log').read_text()
assert not A.exists(),'Archive already exists; inspect before retry'
for rel,h in original.items():
    assert sha(L/rel)==h,'Concurrent Listener art edit '+rel
    assert sha(W/'originals'/rel)==h
for rel,h in candidate['candidate_hashes'].items():
    assert sha(C/rel)==h
    assert sha(W/'reproduction-check'/rel)==h,'Reproduction mismatch '+rel
new={'tools/arena/refine_listener_palette.py':W/'refine_listener_palette.py','tools/debug/listener_palette_check.gd':W/'listener_palette_check.gd'}
for rel in new:assert not (L/rel).exists(),'New helper already exists '+rel
for name in ['normalize_arena_palette.py','build_small.py','downscale.py','slice_rotations.py']:
    assert sha(L/'tools/arena'/name)==sha(C/'tools/arena'/name),'Pipeline changed '+name
protected_archive=L/'docs/creatures/arena-material-consistency-2026-10-08'
state=json.loads((protected_archive/'final-state-check.json').read_text())
manifest=json.loads((protected_archive/'evidence-manifest.json').read_text())
old_originals=[i for i in manifest if i['path'].startswith(('source-audit/originals/','palette-reference/'))]
gale=json.loads((L/'docs/creatures/galeshear-wing-repair-2026-10-08/installation.json').read_text())
gale_art=[i for i in gale['files'] if i['path'].endswith('.png')]
assert len(gale_art)==86
def verify_protected():
    for i in state['images']:assert sha(L/i['path'])==i['current_sha256'],'Protected art '+i['path']
    for i in old_originals:assert sha(protected_archive/i['path'])==i['sha256'],'Protected backup '+i['path']
    for i in gale_art:assert sha(L/i['path'])==i['sha256'],'Galeshear '+i['path']
verify_protected()
scoped=set(candidate['files'])
guards={}
for folder in ['assets','scripts','scenes','data','tools']:
    for p in (L/folder).rglob('*'):
        if p.is_file() and p.suffix not in ['.import','.uid','.pyc'] and '__pycache__' not in p.parts:
            rel=p.relative_to(L).as_posix()
            if rel not in scoped:guards[rel]=sha(p)
guards['project.godot']=sha(L/'project.godot')
notes=L/'docs/AI_COLLABORATION.md';readme=L/'docs/creatures/arena-listener-2026-10-08/README.md'
nb=notes.read_bytes();rb=readme.read_bytes()
A.mkdir(parents=True);(A/'.gdignore').write_text('')
for folder in ['originals','native','prior-native']:shutil.copytree(W/folder,A/folder)
for p in W.glob('*.json'):shutil.copy2(p,A/p.name)
shutil.copy2(W/'README.md',A/'README.md')
(A/'reproduction').mkdir();(A/'logs').mkdir();(A/'pipeline').mkdir()
for p in W.glob('*.py'):shutil.copy2(p,A/'reproduction'/p.name)
for p in W.glob('*.gd'):shutil.copy2(p,A/'reproduction'/p.name)
for p in W.glob('*.log'):shutil.copy2(p,A/'logs'/p.name)
for name in ['normalize_arena_palette.py','build_small.py','downscale.py','slice_rotations.py']:shutil.copy2(C/'tools/arena'/name,A/'pipeline'/name)
(A/'originals/AI_COLLABORATION-before.md').write_bytes(nb)
(A/'originals/listener-README-before.md').write_bytes(rb)
installed=[]
for rel in candidate['files']:
    shutil.copy2(C/rel,L/rel)
    assert sha(L/rel)==candidate['candidate_hashes'][rel]
    installed.append({'path':rel,'sha256':sha(L/rel)})
for rel,p in new.items():
    shutil.copy2(p,L/rel);installed.append({'path':rel,'sha256':sha(L/rel)})
note='''## Codex: Cutbank Listener line palette refinement (October 8, 2026)

Preston asked to complete the pending Listener-line sprite/palette pass. Installed 255 PNGs for Cutbank Listener, Bend Caller and Quietwater Warden: all 24 full facings, 24 game facings, 192 game walks and 15 walk sources. Each form is normalized to its own approved base colors with the established deterministic pipeline. Exact alpha/canvas preservation, original frog anatomy/poses, scales 0.95/1.0/1.1 and five authored/eight total walking directions are retained. Caller throat and mouth colors remain; pose-dependent brightness remains and is documented rather than flattened. All 261 source/game originals are retained. Raw rotation sheets and approved bases are unchanged: do not reslice raw rotations over these corrected facings. New scoped helper reproduces all 255 candidates exactly; unchanged named-only builder. [Evidence, native previews, sources, reproduction and limits](creatures/listener-palette-refinement-2026-10-08/README.md).

Native verification: 436 assertions pass, including all 216 actual game textures, 24 still/192 walk runtime selections, all three stages and Hush; 216 independent pipeline comparisons pass. Final check has no script errors or shutdown resource warnings; the Windows certificate diagnostic remains, and import retains the known audio UID/empty-path diagnostics. Claude's concurrent movement/camera and picker work was refreshed into the test snapshot and preserved live. No battle/world/menu/data/audio/settings edits. All 620 seven-form image paths, 622 protected original/palette entries and 86 Galeshear repaired images are exact. Precise tested snapshot and later concurrent differences are in the archive. No commit; no new creature design or balance claim.

'''
assert notes.read_bytes()==nb,'Concurrent collaboration edit; add note separately'
end=nb.index(b'\n')+1;notes.write_bytes(nb[:end]+b'\n'+note.encode()+nb[end:])
assert readme.read_bytes()==rb,'Concurrent Listener README edit'
old='**Codex:** palette lock pending, like the other new lines.'
assert old in rb.decode()
readme.write_text(rb.decode().replace(old,'**Codex:** palette refinement installed; [native evidence, original backups and reproduction](../listener-palette-refinement-2026-10-08/README.md). The approved silhouettes and scales remain unchanged.'),encoding='utf8')
verify_protected()
concurrent=[rel for rel,h in guards.items() if not (L/rel).exists() or sha(L/rel)!=h]
tested=json.loads((W/'tested-code.json').read_text())
later=[rel for rel,h in tested.items() if not (L/rel).exists() or sha(L/rel)!=h]
result={'installed_utc':datetime.now(timezone.utc).isoformat(),'files':installed,'originals_preserved':len(original),'native_assertions':436,'pipeline_comparisons':216,'reproduction_matches':255,'unrelated_files_compared':len(guards),'unrelated_concurrent_changes_during_install':concurrent,'protected_seven_form_images':len(state['images']),'protected_original_palette_entries':len(old_originals),'protected_galeshear_images':len(gale_art),'tested_arena_sha256':tested['scripts/arena/arena_prototype.gd'],'live_arena_sha256':sha(L/'scripts/arena/arena_prototype.gd'),'later_concurrent_code_changes':later,'settings_unchanged':sha(L/'project.godot')==guards['project.godot']}
(A/'installation.json').write_text(json.dumps(result,indent=2));(W/'installation.json').write_text(json.dumps(result,indent=2))
print(json.dumps({k:v for k,v in result.items() if k!='files'},indent=2))
