"""Finalize reviewed Vitrecrag-line evidence only after actual install and native proof.

Root owns install/native and explicitly invokes this helper afterwards. Preparation of
this file performs no project writes. Running it copies bounded evidence into the
specified docs archive and writes an evidence-derived README; it never installs art,
changes game code/settings, edits AI_COLLABORATION, generates art, launches Godot,
stages Git, commits, deletes files, or overwrites different existing evidence.

Usage:
  python finalize_vitrecrag_evidence.py --project <P> --workspace <Wroot> \
    --archive <P/docs/creatures/arena-vitrecrag-2026-10-07/consistency> \
    --installed-proof <actual installed-report folder> \
    --shell-proof <actual installed audit_fusern_shell folder> \
    --import-receipt <owned import receipt.json> \
    --runtime-receipt <owned runtime receipt.json>

All final claims come from installed hashes and the declared current shell pixels.
Eight copied runtime stills must match their receipt hashes and be freshly written
within that owned process interval. General engine/audio/shutdown diagnostics are
reported from the actual logs, never assumed clean or pre-declared harmless.
"""
from pathlib import Path
from datetime import datetime,timezone,timedelta
import argparse,json,hashlib,shutil,re,sys
from collections import Counter
import numpy as np
from PIL import Image
FORMS=['fusern','slagglass','vitrecrag']
REQUIRED_NATIVE=['line_stage1.png','line_stage2.png','line_stage3.png','glass_1.80s.png','glass_2.30s.png','glass_2.70s.png','glass_3.10s.png','match.png']
SCRIPT_PATTERN=re.compile(r'SCRIPT ERROR:|Parse Error:|Could not load script|Failed to load script')

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def utc(s):return datetime.fromisoformat(s.replace('Z','+00:00')).astimezone(timezone.utc)
def require(ok,message):
    if not ok:raise RuntimeError(message)

def safe_copy(src,dst):
    require(src.is_file(),'Missing evidence source: '+str(src));dst.parent.mkdir(parents=True,exist_ok=True)
    if dst.exists():require(sha(src)==sha(dst),'Existing archive evidence differs; preserve and inspect: '+str(dst))
    else:shutil.copy2(src,dst)

def copy_tree(src,dst):
    require(src.is_dir(),'Missing evidence folder: '+str(src))
    for p in sorted(src.rglob('*')):
        if p.is_file() and '__pycache__' not in p.parts and p.suffix!='.pyc':safe_copy(p,dst/p.relative_to(src))

def write_once(path,obj,json_data=False):
    data=(json.dumps(obj,indent=2)+'\n').encode('utf8') if json_data else obj.encode('utf8');path.parent.mkdir(parents=True,exist_ok=True)
    if path.exists():require(path.read_bytes()==data,'Existing final evidence differs; preserve and inspect: '+str(path))
    else:path.write_bytes(data)

def native_validate(receipt_path,expected_mode):
    r=read(receipt_path);require('Godot_v4.7.2' in r.get('engine',''),'Native receipt must use the declared Godot4.7.2 executable');require(r.get('mode')==expected_mode,'Wrong native receipt mode');require(r.get('exitCode')==0 and not r.get('timeout'),'Native process failed/timed out: '+str(receipt_path));require(not r.get('scriptErrors'),'Native receipt reports script errors')
    stdout=receipt_path.parent/'stdout.log';stderr=receipt_path.parent/'stderr.log';require(stdout.exists() and stderr.exists(),'Native owned stdout/stderr logs missing');text=stdout.read_text(encoding='utf-8-sig',errors='replace')+'\n'+stderr.read_text(encoding='utf-8-sig',errors='replace');lines=text.splitlines();script=[l for l in lines if SCRIPT_PATTERN.search(l)];require(not script,'Native raw logs contain script errors despite receipt')
    err_lines=[l.strip() for l in lines if re.search(r'(^|\s)ERROR:',l) and not SCRIPT_PATTERN.search(l)];warning_lines=[l.strip() for l in lines if 'WARNING:' in l]
    info={'receipt':str(receipt_path),'mode':expected_mode,'pid':r.get('pid'),'exit_code':r['exitCode'],'timeout':r['timeout'],'started_utc':r['startedUtc'],'completed_utc':r['completedUtc'],'script_errors':script,'general_error_lines':err_lines,'warning_lines':warning_lines,'stderr_bytes':stderr.stat().st_size,'stdout_bytes':stdout.stat().st_size,'audio_uid_error_present':bool(re.search(r'(unknown|invalid|unrecognized).*UID|unrecognized UID',text,re.I)),'empty_save_path_error_present':bool(re.search(r'empty.*(path|save)|save.*empty',text,re.I)),'shutdown_diagnostics':[l.strip() for l in lines if re.search(r'ObjectDB|resources still in use|resources.*in use at exit|leaked instance|leaked resource',l,re.I)]}
    if expected_mode=='import':require('--headless' in r.get('arguments','') and '--import' in r.get('arguments',''),'Import receipt must be headless import')
    if expected_mode=='runtime':
        require('--headless' not in r.get('arguments','') and '--fixed-fps 30' in r.get('arguments',''),'Runtime receipt must use renderer-enabled fixed-fps30');require('arena_vitrecrag_check.gd' in r.get('arguments',''),'Runtime receipt is for the wrong check');require(set(r.get('expectedCaptureNames',[]))==set(REQUIRED_NATIVE),'Unexpected runtime capture inventory');require(set(r.get('copiedCaptureNames',[]))==set(REQUIRED_NATIVE),'Not all8 owned captures were copied');start,end=utc(r['startedUtc']),utc(r['completedUtc']);after={a['relative']:a for a in r.get('capturesAfter',[])};before={a['relative']:a for a in r.get('capturesBefore',[])};fresh=[]
        for name in REQUIRED_NATIVE:
            require(name in after,'Missing after capture receipt row: '+name);row=after[name];captime=utc(row['lastWriteUtc']);require(start-timedelta(seconds=2)<=captime<=end+timedelta(seconds=2),'Capture not fresh within owned native interval: '+name)
            if name in before:require(captime>utc(before[name]['lastWriteUtc']),'Capture timestamp did not advance: '+name)
            p=receipt_path.parent/'stills'/name;require(p.exists() and sha(p)==row['sha256'],'Owned capture bytes disagree with receipt: '+name);im=Image.open(p);require(im.size==(1152,648),'Unexpected native capture canvas: '+name)
            fresh.append({'name':name,'sha256':row['sha256'],'last_write_utc':row['lastWriteUtc'],'canvas':list(im.size),'fresh_within_owned_interval':True,'pixels_changed_from_before':name not in before or before[name]['sha256']!=row['sha256']})
        info['captures']=fresh;info['fresh_capture_count']=len(fresh)
    return r,info

def diagnostic_sentence(info):
    chunks=[]
    if info['audio_uid_error_present']:chunks.append('audio UID errors')
    if info['empty_save_path_error_present']:chunks.append('empty-save-path errors')
    if info['shutdown_diagnostics']:chunks.append('shutdown ObjectDB/resource diagnostics')
    if info['general_error_lines'] and not chunks:chunks.append(f"{len(info['general_error_lines'])} general error lines")
    if info['warning_lines'] and not info['shutdown_diagnostics']:chunks.append(f"{len(info['warning_lines'])} warning lines")
    if chunks:return f"{info['mode'].title()} retains "+', '.join(chunks)+f" ({info['stderr_bytes']} stderr bytes). Raw lines are retained in native-proof and final-verification.json."
    return f"{info['mode'].title()} stderr is "+('empty.' if info['stderr_bytes']==0 else f"{info['stderr_bytes']} bytes; raw logs are retained and this is not called clean stderr.")

def material_audit_rows(path):
    if not path.exists():return None
    return read(path)

def nested_flags(obj,key):
    found=[]
    if isinstance(obj,dict):
        for k,v in obj.items():
            if key.lower() in k.lower():found.append((k,v))
            found.extend(nested_flags(v,key))
    elif isinstance(obj,list):
        for v in obj:found.extend(nested_flags(v,key))
    return found

def geometry_exception_pixels(summary):
    declared=summary.get('audited_geometry_repairs',{'repairs':[]})
    rows=declared.get('repairs',[]) if isinstance(declared,dict) else declared
    allowed={f'docs/creatures/arena-starters-2026-10-07/walk/vitrecrag_{f}_sheet.png' for f in ('s','se','e')}
    result={}
    for r in rows:
        require(r.get('operation')=='fill_enclosed_crater','Only the explicitly accepted enclosed-crater fill is permitted')
        require(r['path'] in allowed and r['path'] not in result,'Unexpected or duplicate alpha-exception sheet')
        points=[tuple(xy) for xy in r['sheet_pixels_xy']]
        require(len(points)==len(set(points)),'Duplicate audited fill coordinate')
        result[r['path']]=set(points)
    if result:require(set(result)==allowed and sum(map(len,result.values()))==2886,'Accepted fill must be exactly 2886 pixels in S/SE/E')
    return result


def validate_full_geometry(old,new,rel,expected):
    require(old.shape==new.shape,'Source canvas changed: '+rel)
    changed={(int(x),int(y)) for y,x in zip(*np.nonzero(old[:,:,3]!=new[:,:,3]))}
    require(changed==expected,'Actual source alpha delta differs from exact audited coordinates: '+rel)
    mask=np.zeros(old.shape[:2],dtype=bool)
    for x,y in expected:
        require(0<=x<old.shape[1] and 0<=y<old.shape[0],'Fill coordinate out of bounds')
        require(old[y,x,3]==0 and new[y,x,3]==255,'Fill must change transparent to fully opaque only')
        mask[y,x]=True
    untouched_transparent=(old[:,:,3]==0)&~mask
    require(np.array_equal(old[:,:,:3][untouched_transparent],new[:,:,:3][untouched_transparent]),'Original transparent RGB changed outside exact fills: '+rel)
    oy,ox=np.nonzero(old[:,:,3]);ny,nx=np.nonzero(new[:,:,3]);require([int(ox.min()),int(oy.min()),int(ox.max()),int(oy.max())]==[int(nx.min()),int(ny.min()),int(nx.max()),int(ny.max())],'Source bbox/feet changed')
    components=[]
    if expected:
        cell=old.shape[0]//2;require(old.shape[1]==4*cell,'Audited fill must use four by two walk topology')
        for i in range(8):
            xoff=(i%4)*cell;yoff=(i//4)*cell;frame=old[yoff:yoff+cell,xoff:xoff+cell];frame_mask=mask[yoff:yoff+cell,xoff:xoff+cell];remaining={(int(x),int(y)) for y,x in zip(*np.nonzero(frame_mask))}
            while remaining:
                seed=next(iter(remaining));group={seed};todo=[seed]
                while todo:
                    x,y=todo.pop()
                    require(x not in (0,cell-1) and y not in (0,cell-1),'Fill component reaches original external background')
                    for dy in (-1,0,1):
                        for dx in (-1,0,1):
                            xx=x+dx;yy=y+dy
                            if frame[yy,xx,3]==0 and (xx,yy) not in group:group.add((xx,yy));todo.append((xx,yy))
                require(group.issubset(remaining),'Audited mask only partly fills an original closed eight-connected component')
                remaining-=group;components.append({'frame':i,'pixels':len(group),'closed_whole_8_connected_original_component':True})
    return {'path':rel,'original_alpha_exact':not expected,'audited_added_pixels':len(expected),'transparent_rgb_outside_fills_exact':True,'outer_bbox_and_feet_exact':True,'components':components}


def main():
    ap=argparse.ArgumentParser(description=__doc__)
    for arg in ('project','workspace','archive','installed-proof','shell-proof','import-receipt','runtime-receipt'):ap.add_argument('--'+arg,type=Path,required=True)
    args=ap.parse_args();p=args.project.resolve();w=args.workspace.resolve();a=args.archive.resolve();proof=args.installed_proof.resolve();shell=args.shell_proof.resolve();require(a==p/'docs/creatures/arena-vitrecrag-2026-10-07/consistency','Archive must be the explicitly scoped Vitrecrag consistency folder');require(w!=p and a!=w,'Workspace and archive must remain separate')
    before=read(w/'source-audit/before-manifest.json');summary=read(proof/'consistency-check-summary.json');details=read(proof/'original-files-and-protected-code-checks.json');spreads=read(proof/'before-after-spreads.json');shellevidence=read(shell/'fusern-shell-before-after.json')
    keys=['structural_and_palette_pass','existing_code_guard_pass','approved_bases_unchanged','original_snapshot_hashes_pass','immutable_source_pngs_pass','full_and_walk_frame_geometry_valid','full_facing_and_whole_walk_sheet_alpha_valid','small_canvases_and_foot_rows_exact','exact_own_base_palette_pass','hard_alpha_pass','explicit_mirrors_exact','other_arena_assets_unchanged','game_pngs_exact_existing_pipeline']
    for key in keys:require(summary.get(key) is True,'Installed proof is incomplete/failed: '+key)
    require(summary.get('magenta_pixels_total')==0,'Installed proof retains magenta');fill_pixels=geometry_exception_pixels(summary);small_geometry=summary.get('small_geometry_changes',[])
    for r in small_geometry:require(bool(fill_pixels) and r['form']=='vitrecrag' and r['kind']=='walk_small' and r['facing'] in ('s','se','e','w','sw') and r['bbox_exact'] and r['foot_row_exact'],'Unexpected derived small geometry change')
    if not fill_pixels:require(summary['full_and_walk_frame_geometry_exact'] and summary['full_facing_and_whole_walk_sheet_alpha_exact'] and not small_geometry,'Color-only proof must retain all original alpha')
    require(summary.get('metric_records')==363 and summary.get('original_pngs')==len(before['files']),'Installed metric/original inventory does not match scope');require(summary.get('game_pngs_pipeline_checked')==216,'Expected216 exact game pipeline checks');require(summary.get('mirror_checks')==72,'Expected72 derived walk mirror checks');require(summary.get('other_arena_assets_checked')==len(before['protected_assets']),'Previous-form guard inventory mismatch')
    # Confirm actual live bytes still agree with the actual installed report.
    actual_files=[];transparent_checks=[]
    for r in details['images']:
        q=p/r['path'];require(q.exists() and sha(q)==r['after_sha256'],'Project PNG changed after installed proof: '+r['path']);actual_files.append({'path':r['path'],'sha256':r['after_sha256'],'changed':r['changed']})
        if r.get('full_facing_or_walk_sheet'):
            oa=np.array(Image.open(w/'source-audit/originals'/r['path']).convert('RGBA'));na=np.array(Image.open(q).convert('RGBA'));transparent_checks.append(validate_full_geometry(oa,na,r['path'],fill_pixels.get(r['path'],set())))
    if fill_pixels:require(sum(len(r['components']) for r in transparent_checks)==11,'Accepted fill must contain exactly 11 independently closed components')
    reporter='tools/arena/report_consistency.py'
    for group in ('protected_assets','protected_code_and_tools'):
        for r in before[group]:
            if fill_pixels and r['path']==reporter:continue
            require((p/r['path']).exists() and sha(p/r['path'])==r['sha256'],'Fresh preservation guard changed: '+r['path'])
    reporter_original=read(w/'source-audit/reporter-original.json');require(sha(w/'source-audit'/reporter_original['snapshot'])==reporter_original['original_sha256'],'Original reporter snapshot changed');require(sha(p/reporter)==sha(w/'candidate-tools/report_consistency.py'),'Installed reporter differs from reviewed staged reporter')
    preserved_tools=['normalize_arena_palette.py','build_small.py','downscale.py','slice_rotations.py']
    if not fill_pixels:preserved_tools.append('report_consistency.py')
    tool_map={r['path']:r for r in before['protected_code_and_tools']}
    require(reporter_original['original_sha256']==tool_map[reporter]['sha256'],'Original reporter snapshot disagrees with reviewed pre-install guard')
    for name in preserved_tools:require(sha(p/'tools/arena'/name)==tool_map['tools/arena/'+name]['sha256'],'Existing palette/build/report pipeline tool changed: '+name)
    require(sha(p/'tools/unity_port/finish_back.py')==tool_map['tools/unity_port/finish_back.py']['sha256'],'finish_back.py changed')
    changes=[r['path'] for r in actual_files if r['changed']];require(set(changes)==set(summary['changes']),'Changed-file report disagrees with installed hashes');types=Counter('game_small' if '/small/' in rel else 'source_walk_sheet' if '/walk/' in rel else 'full_facing' for rel in changes)
    # Verify shell statistics were calculated from P, rather than the candidate tree.
    require(Path(shellevidence['image_root']).resolve()==p,'Shell material proof is not measured from installed project');require(shellevidence.get('all_full_alpha_exact') is True and not shellevidence.get('missing_required_source_rows'),'Installed shell proof is incomplete');require(shellevidence.get('records_evaluated')==121,'Expected121 actual Fusern shell records')
    from importlib.util import spec_from_file_location,module_from_spec
    spec=spec_from_file_location('final_fusern_shell_readonly',w/'candidate-tools/audit_fusern_shell.py');meter=module_from_spec(spec);spec.loader.exec_module(meter)
    for r in shellevidence['records']:
        old=meter.frame(w/'source-audit/originals',r);now=meter.frame(p,r);roi,box=meter.mask(old);require(box==r['dome_bbox_original'],'Shell original ROI changed');require(meter.measure(now,roi)==r['after'],'Installed shell colors changed after material proof')
    import_receipt,imp=native_validate(args.import_receipt.resolve(),'import');runtime_receipt,run=native_validate(args.runtime_receipt.resolve(),'runtime');require(Path(import_receipt['project']).resolve()==p and Path(runtime_receipt['project']).resolve()==p,'Native proof belongs to another project')
    new_tools=['tools/arena/'+name for name in ('repair_fusern_brick.py','repair_vitrecrag_seams.py','repair_vitrecrag_core.py','fill_vitrecrag_core_voids.py','audit_fusern_shell.py') if (p/'tools/arena'/name).exists()]
    require('tools/arena/repair_fusern_brick.py' in new_tools and 'tools/arena/audit_fusern_shell.py' in new_tools,'Reviewed repair/evaluator tools not installed')
    require((w/'candidate/fusern-brick-masks').is_dir() and (w/'palette-baseline').is_dir(),'Accepted Fusern masks or palette baseline missing')
    require(read(w/'candidate/fusern-brick-audit.json').get('restore_nw_donor') is True,'Accepted NW donor restoration is not recorded')
    if fill_pixels:
        require(all('tools/arena/'+name in new_tools for name in ('repair_vitrecrag_seams.py','repair_vitrecrag_core.py','fill_vitrecrag_core_voids.py')),'Accepted Vitrecrag repair tools not installed')
        final_fill=read(w/'vitrecrag-enclosed-core-proposal/vitrecrag-enclosed-core-report.json')
        require(final_fill['operation']=='fill_enclosed_crater','Final fill recipe operation mismatch')
        for r in final_fill['records']:require(sha(p/r['path'])==r['output_sha256'],'Installed Vitrecrag sheet is not the accepted final enclosed-core recipe')
        require(geometry_exception_pixels({'audited_geometry_repairs':read(w/'vitrecrag-enclosed-core-proposal/vitrecrag-crater-repairs.json')})==fill_pixels,'Installed repair coords differ from accepted final recipe')
    # All validation finishes before any archive copies/writes.
    a.mkdir(parents=True,exist_ok=True);copy_tree(w/'source-audit',a/'source-audit');copy_tree(proof,a/'installed-proof');copy_tree(shell,a/'installed-shell-proof');copy_tree(args.import_receipt.resolve().parent,a/'native-proof/import');copy_tree(args.runtime_receipt.resolve().parent,a/'native-proof/runtime')
    if (w/'independent-review').exists():copy_tree(w/'independent-review',a/'independent-review')
    (a/'scripts').mkdir(exist_ok=True)
    for name in preserved_tools:safe_copy(p/'tools/arena'/name,a/'scripts'/name)
    safe_copy(p/'tools/unity_port/finish_back.py',a/'scripts/finish_back.py');safe_copy(p/reporter,a/'scripts/report_consistency.py')
    for name in new_tools:safe_copy(p/name,a/'scripts'/Path(name).name)
    copy_tree(w/'palette-baseline',a/'recipe-inputs/palette-baseline')
    copy_tree(w/'candidate/fusern-brick-masks',a/'recipe-inputs/fusern-brick-masks')
    if fill_pixels:
        copy_tree(w/'candidate/vitrecrag-material-audits',a/'accepted-vitrecrag-material/selected-material-audits')
        copy_tree(w/'candidate/vitrecrag-material-audits/palette-baseline',a/'recipe-inputs/vitrecrag-palette-baseline')
        for stage,folder in (('seams','vitrecrag-seam-proposal-v2'),('core','vitrecrag-core-proposal-v2'),('enclosed-core','vitrecrag-enclosed-core-proposal')):copy_tree(w/folder,a/'accepted-vitrecrag-material'/stage)
    if (w/'candidate/contacts').exists():
        for q in sorted((w/'candidate/contacts').rglob('*')):
            if q.is_file():
                folder='intermediate-proposals' if any(term in q.name for term in ('proposal','options','connected_course')) else 'reviewed-candidate-contacts'
                safe_copy(q,a/folder/q.relative_to(w/'candidate/contacts'))
    for folder in ('vitrecrag-seam-proposal','vitrecrag-core-proposal'):
        if (w/folder).exists():copy_tree(w/folder,a/'intermediate-proposals'/folder)
    if (w/'candidate/fusern-material-rerun-proof.json').exists():safe_copy(w/'candidate/fusern-material-rerun-proof.json',a/'fusern-material-rerun-proof.json')
    for q in sorted((w/'candidate').glob('*proposal*')):
        if q.is_file():safe_copy(q,a/'intermediate-proposals'/q.name)
    write_once(a/'intermediate-proposals/README.md','# Intermediate proposals\n\nThese proposal and option images record review history. They are not installed proof and may contain rejected material choices. Accepted recipe masks, installed hash checks and installed-proof/ contacts are the final authority.\n')
    safe_copy(Path(__file__).resolve(),a/'scripts/finalize_vitrecrag_evidence.py');safe_copy(w/'install_reviewed.py',a/'scripts/install_reviewed.py');safe_copy(w/'launch_vitrecrag_check.ps1',a/'scripts/launch_vitrecrag_check.ps1')
    audits={}
    for name in ('candidate-audit.json','candidate-invariants-and-walk-review.json','fusern-brick-audit.json','vitrecrag-seam-audit.json','vitrecrag-core-audit.json','vitrecrag-enclosed-core-report.json','vitrecrag-crater-repairs.json'):
        q=w/'candidate'/name
        if q.exists():safe_copy(q,a/name);audits[name]=read(q)
    write_once(a/'changed-files.json',{'active_pngs':changes,'active_png_count':len(changes),'active_png_groups':dict(types),'added_art_tools':new_tools,'existing_pipeline_unchanged':preserved_tools+['tools/unity_port/finish_back.py'],'reporter_extension':{'path':reporter,'installed_sha256':sha(p/reporter),'reviewed_staged_sha256':sha(w/'candidate-tools/report_consistency.py'),'original_sha256':reporter_original['original_sha256'],'changed_for_explicit_enclosed_fill':bool(fill_pixels)}},True)
    manifest_originals=len(before['files']);oldguard=len(before['protected_assets']);codeguard=len(before['protected_code_and_tools']);original_native=len(before.get('capture_originals',[]));external=before.get('concurrent_code_changes_before_install',[])
    verification={'installed_report_summary':summary,'active_installed_png_hashes':actual_files,'full_source_transparent_rgb_checks':transparent_checks,'fusern_shell_proof_measured_from_project':True,'original_pngs_preserved':manifest_originals,'initial_native_captures_preserved':original_native,'other_form_asset_guards':oldguard,'current_code_settings_tool_guard_inventory':codeguard,'code_settings_tools_unchanged_except_reporter':codeguard-(1 if fill_pixels else 0),'reporter_reviewed_extension':bool(fill_pixels),'exact_audited_fill_sheets':{k:len(v) for k,v in fill_pixels.items()},'derived_small_alpha_changes':small_geometry,'external_code_changes_read_and_preserved':external,'import':imp,'runtime':run,'new_paid_calls_by_this_pass':0,'commit_made_by_this_pass':False,'game_code_written_by_finalizer':False,'ai_collaboration_written_by_finalizer':False,'candidate_statistics_not_installed_proof':True,'accepted_material_recipe_audits_preserved':True}
    write_once(a/'final-verification.json',verification,True)
    table=['| Form | Full brightness spread before -> after | Game-size spread before -> after |','| --- | ---: | ---: |']
    for form in FORMS:
        full=next(r for r in spreads if r['form']==form and r['kind']=='full');small=next(r for r in spreads if r['form']==form and r['kind']=='small');table.append(f"| {form.title()} | {full['before']['brightness_spread']:.2f} -> {full['after']['brightness_spread']:.2f} | {small['before']['brightness_spread']:.2f} -> {small['after']['brightness_spread']:.2f} |")
    sr=[r for r in shellevidence['records'] if r['kind']=='full' and r['facing'] in ('e','ne','n','nw')];shelltable=['| Fusern facing | Dome mean before -> after | Bright-orange share% before -> after | Dark joint/shadow share% before -> after |','| --- | ---: | ---: | ---: |']
    for r in sr:
        b,c=r['before'],r['after'];shelltable.append(f"| {r['facing'].upper()} | {b['dome_mean_brightness']:.2f} -> {c['dome_mean_brightness']:.2f} | {b['bright_orange_L130_roi_pct']:.2f} -> {c['bright_orange_L130_roi_pct']:.2f} | {b['dark_joint_or_shadow_L60_roi_pct']:.2f} -> {c['dark_joint_or_shadow_L60_roi_pct']:.2f} |")
    fus=audits.get('fusern-brick-audit.json',{});donor=nested_flags(fus,'donor');donor_statement='The accepted Fusern recipe retains its exact source-derived repair masks and RGB-role audit in [fusern-brick-audit.json](fusern-brick-audit.json).'
    if donor:donor_statement+=' Any interior donor-brick detail is documented there; silhouettes and alpha remain exact.'
    vit_statement=''
    if fill_pixels:vit_statement=' Accepted seam, warm-pit and enclosed-alpha stage audits/masks are retained in [accepted-vitrecrag-material](accepted-vitrecrag-material/); their historical proposal_only flags record staging, while selected-integration and actual installed hashes prove the accepted final bytes.'
    elif 'vitrecrag-seam-audit.json' in audits:vit_statement=' The accepted Vitrecrag walk-seam recipe and its source/region comparisons are preserved in [vitrecrag-seam-audit.json](vitrecrag-seam-audit.json); final palette/geometry and game-pixel proof come from installed PNGs.'
    vit_reproduction=''
    if fill_pixels:vit_reproduction='''The accepted Vitrecrag recipe runs three bounded stages into separate output roots:

```text
python tools/arena/repair_vitrecrag_seams.py --project . --source <preserved-originals> --baseline docs/creatures/arena-vitrecrag-2026-10-07/consistency/recipe-inputs/vitrecrag-palette-baseline --output <separate-seams-output>
python tools/arena/repair_vitrecrag_core.py --project . --source <preserved-originals> --baseline docs/creatures/arena-vitrecrag-2026-10-07/consistency/recipe-inputs/vitrecrag-palette-baseline --seams <separate-seams-output> --output <separate-core-output>
python tools/arena/fill_vitrecrag_core_voids.py --project . --source <preserved-originals> --baseline docs/creatures/arena-vitrecrag-2026-10-07/consistency/recipe-inputs/vitrecrag-palette-baseline --input <separate-core-output> --output <separate-enclosed-core-output>
```

Here `<preserved-originals>` is `docs/creatures/arena-vitrecrag-2026-10-07/consistency/source-audit/originals`. Compare the five outputs with the archived accepted-stage hashes/masks, then copy only their five Vitrecrag walk sheets into the candidate's same relative paths. The source/acceptance proofs distinguish the exact 0-to-255 fill exception from palette edits.'''
    geometry_statement='Shapes, poses, alpha, canvases, foot rows and facing assignments remain exact; no silhouette/geometry exception was used.'
    if fill_pixels:geometry_statement='Shapes, poses, outer silhouettes, canvases, foot rows and facing assignments remain fixed. Alpha is exact for Fusern, Slagglass, every full facing and Vitrecrag NE/N walks. The accepted exception restores exactly 2,886 transparent crater pixels in 11 fully enclosed original components across Vitrecrag S/SE/E walk sheets. Added pixels are hard alpha 255 and own-base crater colours. Original external background and transparent RGB outside those exact masks remain unchanged; this is explicitly an internal alpha restoration, not an all-alpha-exact pass.'
    guard_statement=f'All {codeguard} fresh protected code/settings/tool files remain byte-identical.'
    if fill_pixels:guard_statement=f'Of {codeguard} reviewed code/settings/tool guards, {codeguard-1} remain byte-identical. The reporter alone was extended narrowly for typed `fill_enclosed_crater` coordinates, 0-to-255 transitions, independent enclosed-component checks and bbox/feet preservation; its installed hash matches the reviewed staged script. Its original version remains archived.'
    reporter_statement='Existing normalize/build/shrink/slice/report and finish_back tools remain unchanged.'
    if fill_pixels:reporter_statement='Existing normalize/build/shrink/slice and finish_back tools remain unchanged. The reporter extension is described above; default audited-removal behavior is preserved.'
    geometry_argument=' --geometry-repairs docs/creatures/arena-vitrecrag-2026-10-07/consistency/accepted-vitrecrag-material/enclosed-core/vitrecrag-crater-repairs.json' if fill_pixels else ''
    small_statement='Derived game silhouettes/alpha remain exact.'
    if fill_pixels:small_statement=f'Derived game alpha changes in {len(small_geometry)} saved walk frames are listed individually in final-verification.json and remain exact outputs of the unchanged shrink/mirror pipeline; small canvases, outer bounding boxes and feet remain fixed.'
    # Describe controls from the latest reviewed direction; this helper never modifies them.
    text=f'''# Vitrecrag line: arena material consistency, October 7, 2026

Installed Fusern, Slagglass and Vitrecrag material cleanup. Fusern's pale-orange E/NE/N/NW shell views and walks now use its approved darker brick/mortar colours. This is arena art only, with no paid generation or commit.

Approved bases `forms/fusern.png`, `forms/slagglass.png` and `forms/vitrecrag.png` remain the authority. Their brick kiln, glass plates and crater materials stay distinct. {geometry_statement}

{chr(10).join(table)}

Measured 24 full facings, 120 source walk frames, 24 game stills, 192 game walk frames and 3 bases: 363 records. Every painted output colour comes from its own approved base. No partial alpha or magenta; 72 derived walk mirrors and 216 exact unchanged-pipeline results pass. {small_statement} Full and game spread flags are recorded independently in [installed proof](installed-proof/consistency-check-summary.json), including any remaining >8 value rather than hiding it.

## Fusern shell fidelity

Source/S/SE/W/SW are the dark-brick references. The shell treatment separates brick faces, dark joints and limited hot fissures; the gray lower band, legs and eyes keep their existing geometry. Whole-body brightness alone was insufficient, so these final values are measured from actual installed PNGs:

{chr(10).join(shelltable)}

This fixed diagnostic ROI is the upper 52% of the original painted bbox, excluding the external silhouette edge. It is a comparable upper dome, **not semantic segmentation of the whole shell**. Bright warm orange uses L>=130; dark pixels L<=60 include joints and shadows. The measures support colour/contrast fidelity and do not prove a complete anatomy redraw. [Actual installed shell CSV/JSON and good/pale-facing contacts](installed-shell-proof/). {donor_statement}{vit_statement}

## Exact changes and preservation

Changed **{len(changes)} active PNGs**: {types.get('full_facing',0)} full facings, {types.get('source_walk_sheet',0)} source walk sheets and {types.get('game_small',0)} game PNGs. Exact paths/hashes and added tools are in [changed-files.json](changed-files.json) and [final-verification.json](final-verification.json). Preserved {manifest_originals} original art PNGs and {original_native} initial captures under [source-audit/originals](source-audit/originals/). Approved bases, pads, rotation sheets and raw source inputs stay unchanged.

All {oldguard} current assets belonging to the previous 12 arena forms remain byte-identical to reviewed pre-install guards. {guard_statement} {reporter_statement} Added tools: {', '.join(new_tools)}. Claude's {len(external)} concurrent code updates were read and preserved before refreshing guards; prior hashes/manifests and external snapshots are retained. No `.gd`/`.tscn`, settings, rules, audio or control edits by this pass.

Current controls remain Claude's newer model: AI footwork, player targeting, abilities on 1-4 with 4 as ultimate and SPACE team switching. Creature selection is through the matchup picker; historical line-selection key 5 is superseded.

## Native verification and limits

Godot 4.7.2 headless import and renderer-enabled fixed-fps 30 `res://tools/debug/arena_vitrecrag_check.gd` both exited 0 without script errors in bounded hidden owned processes. All 8 fresh 1152x648 captures match receipt hashes and were written within the owned runtime interval. [Receipts, original captures, logs and stills](native-proof/); [timestamp/hash validation](final-verification.json).

{diagnostic_sentence(imp)} {diagnostic_sentence(run)} This art pass does not claim unrelated audio/import/shutdown issues fixed. Native stills show the current runtime; exhaustive contact/palette/geometry/pipeline checks cover all saved frames. Original AI anatomy and motion-detail drift can remain; installed and reviewed is not a claim that the full arena or every creature is final.

## Evidence and reproduction

[24-facing brightness/saturation/colour table](installed-proof/before-after-facings.md), [CSV](installed-proof/before-after-facings.csv), [full/game spreads](installed-proof/before-after-spreads.md), [120 source-walk measurements](installed-proof/before-after-walk-source-frames.csv), [192 game-walk measurements](installed-proof/before-after-walk-game-frames.csv), [selected-form facing/walk contacts](installed-proof/contacts/), [15 walk GIF comparisons](installed-proof/walk-previews/), [original source/full2x contacts](source-audit/contacts/), [installed shell-material proof](installed-shell-proof/), [accepted masks and palette baseline](recipe-inputs/), [accepted Vitrecrag material/fill stages](accepted-vitrecrag-material/), [reviewed candidate material contacts](reviewed-candidate-contacts/), [clearly labelled intermediate proposals](intermediate-proposals/), [independent diagnostics](independent-review/).

Use preserved originals with the unchanged normalizer, always naming only these forms:

```text
python tools/arena/normalize_arena_palette.py --project . --forms fusern slagglass vitrecrag --source docs/creatures/arena-vitrecrag-2026-10-07/consistency/source-audit/originals --output <separate-candidate-folder>
```

The accepted Fusern repair uses the archived seven-file palette baseline and explicit NW interior donor option:

```text
python tools/arena/repair_fusern_brick.py --project . --source docs/creatures/arena-vitrecrag-2026-10-07/consistency/source-audit/originals --candidate <separate-candidate-folder> --baseline docs/creatures/arena-vitrecrag-2026-10-07/consistency/recipe-inputs/palette-baseline --restore-nw-donor
```

Do not run whole-image normalization again after this material repair: it would whiten the restored mortar. {vit_reproduction} From the candidate root, run the unchanged builder with only the three explicit names:

```text
python tools/arena/build_small.py fusern slagglass vitrecrag
```

Never run the slicer/builder bare. Then report actual installed PNGs:

```text
python tools/arena/report_consistency.py --project . --forms fusern slagglass vitrecrag --before-audit docs/creatures/arena-vitrecrag-2026-10-07/consistency/source-audit{geometry_argument} --output <separate-proof-folder>
python tools/arena/audit_fusern_shell.py --before-audit docs/creatures/arena-vitrecrag-2026-10-07/consistency/source-audit --image-root . --output <separate-shell-proof-folder>
```

Exact scripts, originals, accepted recipe audits, clearly tagged intermediate proposals, current metrics and native proof remain archived. Finalization does not update the shared AI guide; root handles that separately, preserving newer decisions.
'''
    write_once(a/'README.md',text)
    members=[]
    for q in sorted(a.rglob('*')):
        if q.is_file() and q.name!='evidence-manifest.json':members.append({'path':q.relative_to(a).as_posix(),'sha256':sha(q),'bytes':q.stat().st_size})
    write_once(a/'evidence-manifest.json',{'files':members,'count':len(members),'archive':str(a),'all_native_captures_fresh':True,'final_evidence_validated_before_copy':True},True)
    print(json.dumps({'archive':str(a),'active_png_changes':len(changes),'original_art_preserved':manifest_originals,'other_forms_guarded':oldguard,'code_tools_guarded':codeguard,'native_fresh_captures':run['fresh_capture_count'],'evidence_members':len(members),'guide_written':False},indent=2));return 0
if __name__=='__main__':sys.exit(main())
