from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');P=L/'docs/world/board-home-interior-finish-2026-10-10'
markers={'finish_check':'FINISH 11/11 PASS','room_spots_check':'SPOTS all ok','hub_town_check':'Places: 12 of 12 answered E','job_board_check':'JOB BOARD: all ok','capture':'Captured live'}
for name,marker in markers.items():
    log=(W/('live-'+name+'.log')).read_text(encoding='utf-8')
    assert marker in log and not any(err in log for err in ['ERROR:','FAIL ','FAILED','leaked']),name
audit=json.loads((W/'audit.json').read_text(encoding='utf-8'))
assert len(audit['installed_exact'])==7
for d in json.loads((W/'pending-install.json').read_text(encoding='utf-8')):
    assert hashlib.sha256((L/d['path']).read_bytes()).hexdigest()==d['after'],d['path']
for name in ['audit.json','audit.py','publish.py','verify_live.py','install.ps1','pending-install.json','capture.log']+['live-'+n+'.log' for n in markers]:shutil.copy2(W/name,P/name)
for folder in ['review/live','concurrent-final']:
    if (W/folder).is_dir():shutil.copytree(W/folder,P/folder,dirs_exist_ok=True)
tail='''
## Final live verification

All five installed native live runs pass with clean final logs: 11/11 finish checks, all 14 room interaction spots reached by walking and real E, both room exits, hub's 12 service interactions, full Board rescue/recovery/return/payout loop and installed native captures. No user profile/save changes. All seven installed paths match reviewed candidate hashes. %d protected active files and all %d original active asset files match the baseline. %d concurrent changes retained and snapshotted; Claude added pilot-story job12 in the handoff while this task ran, left intact. Prior collaboration body remains verbatim.

Installed views: [Board](review/live/board.png), [Home at entry](review/live/home.png), [Home north](review/live/home-north.png), [unchanged Hall](review/live/hall.png). Original source and exact prompts are in original-generation/ and home_prompt.txt / board_prompt.txt. Whole Home and Board source assets are siblings, never replacements for old sources. Every published archive file is hashed in publication.json.

Next art slice: Wayline Hall. Late story job12 and launch pixel frames remain open; see the current Claude handoff before choosing subsequent work. Preston's visual approval is not claimed.
''' % (audit['protected_exact'],audit['original_asset_files_exact'],len(audit['concurrent_changes_preserved']))
(P/'README.md').write_text((W/'README.md').read_text(encoding='utf-8')+tail,encoding='utf-8')
manifest={p.relative_to(P).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in P.rglob('*') if p.is_file() and p.name!='publication.json'}
(W/'publication.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8');shutil.copy2(W/'publication.json',P/'publication.json')
assert all(hashlib.sha256((P/r).read_bytes()).hexdigest()==h for r,h in manifest.items())
print('Verified',len(manifest),'published files; all seven installed paths exact.')
