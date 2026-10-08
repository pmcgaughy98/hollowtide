"""Record a later external arena-script change without editing or rolling it back."""
from pathlib import Path
import json,hashlib,shutil,datetime,subprocess
P=Path('C:/Users/pmcga/dev/hollowtide');A=P/'docs/creatures/arena-material-consistency-2026-10-08'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
proof=json.loads((A/'review/original-files-and-protected-code-checks.json').read_text())
images=[{'path':r['path'],'verified_sha256':r['after_sha256'],'current_sha256':sha(P/r['path']),'unchanged_since_verification':sha(P/r['path'])==r['after_sha256']} for r in proof['images']]
assert all(r['unchanged_since_verification'] for r in images)
code=[{'path':r['path'],'verified_sha256':r['after_sha256'],'current_sha256':sha(P/r['path']),'unchanged_since_verification':sha(P/r['path'])==r['after_sha256']} for r in proof['existing_code_and_tools']]
changed=[r for r in code if not r['unchanged_since_verification']]
assert all(r['path']=='scripts/arena/arena_prototype.gd' for r in changed)
other=json.loads((A/'review/protected-other-arena-assets.json').read_text());assert all(sha(P/r['path'])==r['after_sha256'] for r in other)
dest=A/'concurrent-code';dest.mkdir(exist_ok=True)
for r in changed:
    target=dest/Path(r['path']).name;shutil.copy2(P/r['path'],target)
    r['current_snapshot']=target.relative_to(A).as_posix()
    r['current_last_write_utc']=datetime.datetime.fromtimestamp((P/r['path']).stat().st_mtime,datetime.timezone.utc).isoformat()
    r['preserved_without_codex_edit']=True
delta=subprocess.run(['git','diff','--','scripts/arena/arena_prototype.gd'],cwd=P,capture_output=True,text=True,encoding='utf8',check=True)
(dest/'current-vs-git-head.diff').write_text(delta.stdout,encoding='utf8')
(A/'final-state-check.json').write_text(json.dumps({'checked_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'all_verified_images_unchanged':True,'all_1190_other_arena_assets_unchanged':True,'code_guards_unchanged':len(code)-len(changed),'concurrent_external_code_changes':changed,'native_checks_cover_verified_script_hash_not_later_change':True,'images':images},indent=2),encoding='utf8')
note='\n## Concurrent code after verification\n\nThe final check found one later external update to scripts/arena/arena_prototype.gd, containing arena kit/control changes. It was read and preserved without edits by Codex. All 620 snapshotted image paths still match the installed proof, all 1190 other arena assets remain unchanged, and the other 653 existing code/tool/settings guards remain unchanged. The original report and 23 native captures describe the previously verified script hash; they do not certify the later concurrent code revision. [Final state and both script hashes](final-state-check.json); the latest script bytes and its diff against Git HEAD are preserved in concurrent-code/. The Git diff includes earlier shared work and is not claimed to isolate only the last edit. No art blocker remains.\n'
readme=A/'README.md';readme.write_text(readme.read_text(encoding='utf8')+note,encoding='utf8')
guide=P/'docs/AI_COLLABORATION.md';text=guide.read_text(encoding='utf8')
text=text.replace('All 1190 other-fourteen arena assets and 654 existing code/tool/settings guards remain unchanged.','At the installed-report snapshot all 1190 other-fourteen arena assets and 654 existing code/tool/settings guards were unchanged. A final check detected one later external arena_prototype.gd kit/control update; it was read, snapshotted and preserved. All art and the other 653 guards remain unchanged. Native evidence covers the verified earlier script hash, not that later code revision; see final-state-check.json.')
guide.write_text(text,encoding='utf8')
shutil.copy2(Path(__file__),A/'reproduction/record_concurrent_update.py')
hashes=[{'path':f.relative_to(A).as_posix(),'sha256':sha(f),'bytes':f.stat().st_size} for f in A.rglob('*') if f.is_file() and f.name!='evidence-manifest.json']
(A/'evidence-manifest.json').write_text(json.dumps(hashes,indent=2),encoding='utf8')
print(json.dumps({'verified_images_unchanged':len(images),'protected_other_art_unchanged':len(other),'external_code_changes':len(changed),'code_not_edited_by_codex':True},indent=2))
