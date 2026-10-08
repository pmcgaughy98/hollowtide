"""Install only the reviewed seven-form PNGs after checking all source/code guards.

Preserve source snapshots and pipeline tools first. Rebuild only the named forms
through the unchanged current builder. No game code, settings or approved base is
edited, no asset is removed, and no paid generation or commit is performed.
"""
from pathlib import Path
import json,hashlib,shutil,subprocess,sys
W=Path(__file__).resolve().parent
P=Path('C:/Users/pmcga/dev/hollowtide')
C=W/'source-audit/candidate-project'
A=P/'docs/creatures/arena-material-consistency-2026-10-08'
FORMS=['slagglass','preostmar','oathfen','oxbowarchon','punchybun','sparkjab','starward']
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
manifest=json.loads((W/'source-audit/before-manifest.json').read_text())
guards=manifest['files']+manifest['protected_code_and_tools']+manifest['protected_assets']
bad=[r['path'] for r in guards if not(P/r['path']).exists() or sha(P/r['path'])!=r['sha256']]
if bad:raise RuntimeError('Live files changed since review: '+str(bad))
summary=json.loads((W/'candidate-review/consistency-check-summary.json').read_text())
for k in ['full_and_walk_frame_geometry_exact','exact_selected_reference_palette_pass','explicit_mirrors_exact','game_pngs_exact_existing_pipeline','hard_alpha_pass','small_canvases_and_foot_rows_exact']:
    assert summary[k],k
audit=json.loads((W/'candidate-audit.json').read_text());assert set(audit['forms'])==set(FORMS)
A.mkdir(parents=True,exist_ok=True);(A/'.gdignore').write_text('',encoding='utf8')
def copytree(src,dst):
    for p in src.rglob('*'):
        if not p.is_file():continue
        dest=dst/p.relative_to(src);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest)
copytree(W/'source-audit/originals',A/'source-audit/originals')
for name in ['before-manifest.json','before-metrics.json','before-metrics.csv','before-summary.json','audit_originals.py']:
    shutil.copy2(W/'source-audit'/name,A/'source-audit'/name)
copytree(W/'source-audit/references',A/'source-audit/references')
copytree(W/'palette-reference',A/'palette-reference')
for name in ['build_small.py','downscale.py','normalize_arena_palette.py','report_consistency.py']:
    dest=A/'source-audit/candidate-project/tools/arena'/name;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(C/'tools/arena'/name,dest)
shutil.copy2(W/'refine_arena_materials.py',P/'tools/arena/refine_arena_materials_20261008.py')
shutil.copy2(W/'candidate-tools/report_arena_materials.py',P/'tools/arena/report_arena_materials.py')
shutil.copy2(W/'candidate-audit.json',A/'candidate-audit.json')
changed=[]
for r in manifest['files']:
    rel=Path(r['path']);name=next((n for n in FORMS if r['path'].startswith('assets/sprites/arena/'+n+'/') or (rel.parent.name=='walk' and rel.name.startswith(n+'_'))),None)
    if not name:continue
    if 'small' in rel.parts:continue
    if sha(C/rel)==r['sha256']:continue
    shutil.copy2(C/rel,P/rel);changed.append(r['path'])
subprocess.run([sys.executable,str(P/'tools/arena/build_small.py'),*FORMS],cwd=P,check=True)
for r in manifest['files']:
    if '/small/' in r['path'] and sha(P/r['path'])!=r['sha256']:changed.append(r['path'])
(A/'installed-files.json').write_text(json.dumps({'active_png_changes':sorted(changed),'new_tools':['tools/arena/refine_arena_materials_20261008.py','tools/arena/report_arena_materials.py']},indent=2),encoding='utf8')
print(json.dumps({'installed_pngs':len(changed),'archive':str(A)},indent=2))
