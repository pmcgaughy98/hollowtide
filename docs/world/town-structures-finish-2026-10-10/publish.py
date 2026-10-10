from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');P=L/'docs/world/town-structures-finish-2026-10-10'
markers={'structures_check':'RESULT 27/27 structure checks pass','hub_town_check':'Places: 12 of 12 answered E','job_board_check':'JOB BOARD: all ok','town_walk_check':'RESULT: the team walks','hall_door_check':'RESULT: the hall door meets the steps','capture':'Captured live six town structure views'}
for name,marker in markers.items():
 log=(W/('live-'+name+'.log')).read_text(encoding='utf-8')
 assert marker in log and all(err not in log for err in ['ERROR:','SCRIPT ERROR','SHADER ERROR','FAIL ','FAILED','WRONG','leaked']),name
audit=json.loads((W/'audit.json').read_text(encoding='utf-8'))
assert len(audit['installed_exact'])==4
for d in json.loads((W/'pending-install.json').read_text(encoding='utf-8')):
 assert hashlib.sha256((L/d['path']).read_bytes()).hexdigest()==d['after'],d['path']
for name in ['audit.json','audit.py','publish.py','install.ps1','pending-install.json']+['live-'+n+'.log' for n in markers]:shutil.copy2(W/name,P/name)
for folder in ['review/live','concurrent-final']:
 if (W/folder).is_dir():shutil.copytree(W/folder,P/folder,dirs_exist_ok=True)
orig=P/'original-art';orig.mkdir(exist_ok=True)
shutil.copy2(L/'assets/sprites/world/job_board_2026_10_10/board_native.png',orig/'board_native.png')
tail='''
## Final live verification

All six native live runs pass with no script/shader/certificate errors or leaks in their final logs. 27/27 structure checks, all 12 service interactions, the Board rescue/recovery/payout loop, actual town walking, both Hall door tiles, and six installed town captures. All four intended installed files match their reviewed candidate hashes. %d protected active files and %d original active asset files match the starting baseline. %d concurrent changes are retained and snapshotted in concurrent-final/; three of them are Claude's Whinet expression PNGs, not task art edits. Previous collaboration body is retained verbatim.

Final views: [larger Job Board](review/live/board.png), [Hall clearance](review/live/hall.png), [Lookout](review/live/lookout.png), [Ferry Landing](review/live/landing.png), [Dock](review/live/dock.png), [Hollow Mouth clearance](review/live/gate.png). Original Board PNG is also copied unchanged into original-art/. Every published archive file is hashed in publication.json. Preston's visual approval is not claimed.
''' % (audit['protected_exact'],audit['original_asset_files_exact'],len(audit['concurrent_changes_preserved']))
(P/'README.md').write_text((W/'README.md').read_text(encoding='utf-8')+tail,encoding='utf-8')
manifest={p.relative_to(P).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in P.rglob('*') if p.is_file() and p.name!='publication.json'}
(W/'publication.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8');shutil.copy2(W/'publication.json',P/'publication.json')
assert all(hashlib.sha256((P/r).read_bytes()).hexdigest()==h for r,h in manifest.items())
print('Verified',len(manifest),'published archive files; all four installed files exact.')
