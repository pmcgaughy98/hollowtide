"""Record final handoff writes and concurrent git history in the owned review archive."""
from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).resolve().parent;P=Path('C:/Users/pmcga/dev/hollowtide');A=P/'docs/creatures/arena-vitrecrag-2026-10-07/consistency'
assert (A/'README.md').exists() and (A/'AI_COLLABORATION-before-entry.md').exists()
m=json.loads((A/'source-audit/before-manifest.json').read_text(encoding='utf8'))
note='\n## Concurrent project history\n\nClaude committed project work while this pass was running. The observed VFX commit was `5c9a42e` (October 7, 2026, 21:30:23 CDT); its code was already present before the owned runtime launch and was read and preserved. Codex did not stage, commit or reset the project. The reviewed guard histories retain the successive external revisions.\n'
readme=A/'README.md';text=readme.read_text(encoding='utf8');assert '## Concurrent project history' not in text
readme.write_text(text+note,encoding='utf8')
changes=A/'changed-files.json';data=json.loads(changes.read_text(encoding='utf8'))
data['documentation_updated']=['docs/AI_COLLABORATION.md','docs/creatures/arena-vitrecrag-2026-10-07/consistency/']
data['modified_report_tool']='tools/arena/report_consistency.py'
data['native_capture_names']=['line_stage1.png','line_stage2.png','line_stage3.png','glass_1.80s.png','glass_2.30s.png','glass_2.70s.png','glass_3.10s.png','match.png']
data['native_capture_directory']='docs/creatures/arena-vitrecrag-2026-10-07/'
data['commit_performed_by_codex']=False;data['concurrent_external_commit']=m['external_commit_during_pass']
changes.write_text(json.dumps(data,indent=2)+'\n',encoding='utf8')
for name in ('update_shared_handoff.py','preserve_vfx_runtime_code.py','install_report_frame_fix.py','finish_archive_record.py'):
    shutil.copy2(W/name,A/'scripts'/name)
members=[]
for q in sorted(A.rglob('*')):
    if q.is_file() and q.name!='evidence-manifest.json':members.append({'path':q.relative_to(A).as_posix(),'sha256':hashlib.sha256(q.read_bytes()).hexdigest(),'bytes':q.stat().st_size})
(A/'evidence-manifest.json').write_text(json.dumps({'files':members,'count':len(members),'archive':str(A),'all_native_captures_fresh':True,'final_evidence_validated_before_copy':True,'includes_final_handoff_snapshot':True},indent=2)+'\n',encoding='utf8')
print('Final handoff/history recorded; evidence members:',len(members))
