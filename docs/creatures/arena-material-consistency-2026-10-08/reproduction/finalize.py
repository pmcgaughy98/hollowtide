"""Archive installed proof, fresh native captures, exact changes and a dated handoff."""
from pathlib import Path
import json,hashlib,shutil,datetime
from PIL import Image,ImageDraw
W=Path(__file__).resolve().parent;P=Path('C:/Users/pmcga/dev/hollowtide');A=P/'docs/creatures/arena-material-consistency-2026-10-08'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def copytree(src,dst):
    for p in src.rglob('*'):
        if p.is_file():
            d=dst/p.relative_to(src);d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,d)
summary=json.loads((W/'installed-review/consistency-check-summary.json').read_text())
assert summary['structural_and_palette_pass']
copytree(W/'installed-review',A/'review')
native=[]
for name in ['oxbowarchon','starward','slagglass']:
    runs=list((W/('native-'+name)/'runs').glob('runtime_*'))
    run=max(runs,key=lambda p:p.stat().st_mtime);receipt=json.loads((run/'receipt.json').read_text(encoding='utf-8-sig'))
    assert receipt['exitCode']==0 and not receipt['timeout'] and not receipt['scriptErrors'],name
    start=datetime.datetime.fromisoformat(receipt['startedUtc'].replace('Z','+00:00'))
    after={r['relative']:r for r in receipt['capturesAfter']}
    captures=[]
    for f in receipt['expectedCaptureNames']:
        row=after[f];mtime=datetime.datetime.fromisoformat(row['lastWriteUtc'].replace('Z','+00:00'))
        assert mtime>=start,(name,f,'stale capture')
        im=Image.open(run/'stills'/f);assert im.size==(1152,648),(f,im.size)
        assert sha(run/'stills'/f)==row['sha256']
        captures.append({'file':f,'sha256':row['sha256'],'size':list(im.size),'fresh':True})
    copytree(run,A/'native'/name)
    native.append({'name':name,'script':receipt['arguments'],'exit_code':receipt['exitCode'],'script_errors':receipt['scriptErrors'],'general_errors':receipt['generalErrors'],'warnings':receipt['warnings'],'captures':captures})
imports=list((W/'native-oxbowarchon/runs').glob('import_*'))
for run in imports:copytree(run,A/'native'/run.name)
last=max(imports,key=lambda p:p.stat().st_mtime);import_receipt=json.loads((last/'receipt.json').read_text(encoding='utf-8-sig'))
assert import_receipt['exitCode']==0 and not import_receipt['scriptErrors'] and not import_receipt['timeout']
(A/'native-verification.json').write_text(json.dumps({'final_import':import_receipt,'runtime':native,'fresh_capture_count':sum(len(r['captures']) for r in native)},indent=2),encoding='utf8')
reference_checks=[]
for r in (W/'source-audit/references').rglob('*.png'):
    rel=r.relative_to(W/'source-audit/references')
    reference_checks.append({'path':rel.as_posix(),'unchanged':sha(r)==sha(P/rel),'original_sha256':sha(r),'current_sha256':sha(P/rel)})
assert all(r['unchanged'] for r in reference_checks)
rawrel=Path('assets/sprites/creatures/slagglass_redo_2026_10_08/slagglass_front.png');d=A/'references'/rawrel;d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(P/rawrel,d)
reference_checks.append({'path':rawrel.as_posix(),'raw_chosen_front_preserved':True,'sha256':sha(d)})
(A/'reference-checks.json').write_text(json.dumps(reference_checks,indent=2),encoding='utf8')
helpers=A/'reproduction';helpers.mkdir(exist_ok=True)
for f in ['prepare.py','prepare_report.py','refine_arena_materials.py','install_reviewed.py','install_jade_revision.py','prepare_native.py','walk_overviews.py','finalize.py','launch_oxbowarchon_check.ps1','launch_starward_check.ps1','launch_slagglass_check.ps1']:
    shutil.copy2(W/f,helpers/f)
copytree(W/'candidate-tools',helpers/'candidate-tools')
shutil.copy2(W/'candidate-audit.json',A/'candidate-audit.json')
shutil.copy2(W/'source-audit/references.png',A/'references.png')
change=json.loads((A/'installed-files.json').read_text())
assert len(change['active_png_changes'])==595
guide=P/'docs/AI_COLLABORATION.md';old=guide.read_text(encoding='utf8');shutil.copy2(guide,A/'AI_COLLABORATION-before.md')
entry='''## Codex: new Slagglass, jade King and Punchybun arena materials installed (October 8, 2026)

Preston asked for the redesigned Slagglass and Preostmar/Oathfen/Oxbowarchon arena material pass, restoring Oxbowarchon's overly pale green closer to its original and signature card, then added Punchybun/Sparkjab/Starward. Installed 595 active PNG changes: 56 full facings, 35 source walk sheets and 504 rebuilt game PNGs. Slagglass retains its new beetle/kiln design with orange mid-dome mortar rather than yellow walk drift. Preostmar and Oathfen walks no longer flash white/mint jade. Punchybun's line uses each approved cream/pink base palette. Oxbowarchon keeps retake A's shape but its pale jade is selectively mapped onto darker exact jade colors from assets/sprites/creatures/oxbowarchon.png; charcoal, gold and saturated rails remain distinct. Its explicit corrected palette reference is archived; the unchanged pale base is NOT its current color authority.

All full/small facing brightness spreads are below 8. Walking-frame spreads are measured honestly, including game-size values above 8 for Slagglass, Preostmar, Oathfen and Sparkjab; generated pose/detail variations remain. Alpha bytes, canvas, poses, feet and facing assignments are exact at source; current per-form scales are preserved. All 168 derived walk mirrors and 504 exact current builder-pipeline comparisons pass. Preserved 620 original art PNGs, original references and previous captures. All 1190 other-fourteen arena assets and 654 existing code/tool/settings guards remain unchanged. Added tools/arena/refine_arena_materials_20261008.py and report_arena_materials.py; no existing builder/downscale/normalizer/reporter, game code, title card, raw take, creature rules or settings edited. No paid generation or commit.

Final Godot 4.7.2 import and current backline/protector/Vitrecrag line checks exit 0, with zero script errors and 23 freshly verified 1152x648 captures. Backline/protector runs are clean; the Vitrecrag-line check logs a shutdown ObjectDB/resource leak. Initial import diagnostics are retained separately; final import is clean. Do not re-slice raw sheets over these corrections or run a bare all-form builder. Reproduce the seven-form candidate from the preserved sources using the new helper and its explicit archive workspace. [Exact changed files, palette authority, source backups, metrics, contacts/GIFs, reproduction and native logs](creatures/arena-material-consistency-2026-10-08/README.md).

'''
heading='# Working Together on Hollowtide'
assert old.startswith(heading)
guide.write_text(heading+'\n\n'+entry+old[len(heading):].lstrip('\r\n'),encoding='utf8')
change['documentation_changes']=['docs/AI_COLLABORATION.md','docs/creatures/arena-material-consistency-2026-10-08/']
change['native_capture_outputs']=[str(Path(json.loads((max((W/('native-'+r['name'])/'runs').glob('runtime_*'),key=lambda p:p.stat().st_mtime)/'receipt.json').read_text(encoding='utf-8-sig'))['captureRoot']).relative_to(P)/c['file']).replace('\\','/') for r in native for c in r['captures']]
(A/'installed-files.json').write_text(json.dumps(change,indent=2),encoding='utf8')
rows=json.loads((A/'review/before-after-spreads.json').read_text());spreads={n:{r['kind']:r['after']['brightness_spread'] for r in rows if r['form']==n} for n in ['slagglass','preostmar','oathfen','oxbowarchon','punchybun','sparkjab','starward']}
table='| Form | Full facing spread | Game facing spread | Game walk spread |\n| --- | --- | --- | --- |\n'+''.join(f"| {n} | {v['full']:.2f} | {v['small']:.2f} | {v['walk_small']:.2f} |\n" for n,v in spreads.items())
readme='''# Arena material consistency installed, October 8, 2026

Scope: the new Slagglass, Preostmar/Oathfen/Oxbowarchon, and Punchybun/Sparkjab/Starward.

## Result

595 active PNGs changed: 56 full facings, 35 source walk sheets and 504 rebuilt game PNGs. [Every changed path](installed-files.json). Repainted existing pixels only; source alpha bytes, canvas, poses, feet and facing assignments remain exact. Current approved per-form sizes are preserved through the unchanged builder. No game code, settings, creature rules, title-card image, approved raw base, paid call or commit was changed/performed.

Oxbowarchon retains the approved new A pose and silhouette, with the pale desaturated jade recolored using eight exact muted emerald/jade colors sampled from its original front. Saturated rail greens, dark body and gold retain their own roles. This is an explicit Preston-authorized color override, not an assertion that the unchanged pale arena take is the palette authority. See [the corrected reference](palette-reference/oxbowarchon-dark-jade.png), [palette selection](palette-reference/references.json), [references](references.png) and [reference hash checks](reference-checks.json). The signature card itself stays unchanged.

Slagglass keeps the chosen new kiln-beetle design, dark bricks and orange seams, reducing yellow seam flashes in mid-dome walk pixels while preserving the crater. Preostmar/Oathfen walking jade no longer projects to white/mint highlights. Punchybun's line retains cream fur and pink accents from each approved base; it is deliberately much lighter than the stone lines.

## Proof and practical limits

All full/game facing spreads are below 8. These averages measure actual saved pixels; they do not prove identical anatomy. Walking poses expose different material proportions, and sparse-palette downsampling changes proportions further. Residual game-walk spreads above 8 are retained and disclosed instead of forcing white fur or glowing material into flat colors. Source-generated motion/pose differences remain; this pass did not redraw shapes.

'''+table+'''
See [every facing's brightness/saturation/color count](review/before-after-facings.md), [spread tables](review/before-after-spreads.md), source/game walking CSVs in review/, [structural and palette proof](review/consistency-check-summary.json), [candidate parameters and pixel counts](candidate-audit.json), [contacts](review/contacts/) and [walk GIFs](review/walk-previews/).

Checks: 847 metric records; 620 unchanged original snapshots; 168 exact walk mirrors; 504 RGBA-exact comparisons against the current builder, including its per-form resample scales; all 1190 other-fourteen arena PNGs unchanged; 654 existing code/tool/settings guards unchanged. No source geometry exemption was needed. All painted output colors belong to the selected reference palette, with the single explicit Oxbowarchon override. Original files live in source-audit/originals/ and source-audit/references/.

## Native verification

Final headless Godot 4.7.2 import exits 0, no errors. Current arena_backline_check.gd and arena_protector_check.gd exit 0 with no errors/warnings. arena_vitrecrag_check.gd shows the new Slagglass and exits 0 with no script errors, but logs a shutdown ObjectDB/resource leak; that code issue is not repaired by this art pass. Initial import diagnostics are separately preserved. All 23 captured stills are new, checked against timestamps/hashes and 1152x648 dimensions. [Native evidence](native-verification.json); screenshots, logs, receipts and backups of the earlier stills are under native/<line>/.

## Reproduce without overwriting active art

From the project root, run:

```text
python tools/arena/refine_arena_materials_20261008.py --workspace docs/creatures/arena-material-consistency-2026-10-08
```

This reads preserved originals and writes candidates under the archive's source-audit/candidate-project/, then builds ONLY these seven forms using the copied unchanged pipeline. The archive has .gdignore. It does not install candidates into the live game. The optional --forms limits a repeat to named forms. The new report_arena_materials.py accepts --project, --before-audit, --output, --forms and --palette-reference; it parses the current SCALE constants without executing the builder.

Do not reslice raw rotation sheets over the fixed facings, restore the old Slagglass, or use the pale Oxbowarchon take as current color authority. Named build_small.py calls are safe after the fixed full facings and source walks are installed. Local reproduction/ helpers retain the actual preparation, guarded installation and native-run workflow; original materials and game settings are untouched.
'''
(A/'README.md').write_text(readme,encoding='utf8')
hashes=[{'path':f.relative_to(A).as_posix(),'sha256':sha(f),'bytes':f.stat().st_size} for f in A.rglob('*') if f.is_file() and f.name!='evidence-manifest.json']
(A/'evidence-manifest.json').write_text(json.dumps(hashes,indent=2),encoding='utf8')
print(json.dumps({'active_pngs':595,'fresh_native_stills':23,'archive_files':len(hashes),'all_checks_pass':True,'readme':str(A/'README.md')},indent=2))
