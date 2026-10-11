from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');P=L/'docs/world/hall-interior-finish-2026-10-10'
markers={'finish_check':'HALL FINISH 17/17 PASS','room_spots_check':'SPOTS all ok','capture':'Captured live five Hall views'}
for name,marker in markers.items():
    log=(W/('live-'+name+'.log')).read_text(encoding='utf-8')
    assert marker in log and not any(e in log for e in ['ERROR:','FAIL ','FAILED','leaked']),name
audit=json.loads((W/'audit.json').read_text(encoding='utf-8'))
assert len(audit['installed_exact'])==11
for d in json.loads((W/'pending-install.json').read_text(encoding='utf-8')):
    assert hashlib.sha256((L/d['path']).read_bytes()).hexdigest()==d['after'],d['path']
for name in ['audit.json','audit.py','publish.py']+['live-'+n+'.log' for n in markers]:shutil.copy2(W/name,P/name)
for folder in ['review/live','concurrent-final']:
    if (W/folder).is_dir():shutil.copytree(W/folder,P/folder,dirs_exist_ok=True)
# Native full-room proof was rerendered against the installed files.
shutil.copy2(W/'review/hall-finished-native.png',P/'review/hall-finished-native.png')
tail='''
## Final live verification

Installed native Godot runs pass with clean final logs: 17/17 finish checks including actual GPU output; all 14 Home/Hall interaction spots reached by walking and real E; both exits; five installed Hall captures. Profiles and outputs are isolated from the player's save/settings. All 11 installed files match reviewed hashes. %d protected active files and all %d original active asset files match the baseline. %d concurrent active changes retained and snapshotted; prior collaboration body verbatim.

Installed views: [entry](review/live/entry.png), [middle aisle](review/live/middle.png), [counter](review/live/counter.png), [chart](review/live/chart.png), [roster](review/live/roster.png). [Full native finished room](review/hall-finished-native.png). Published source/candidate/original/proof files are verified in publication.json. Final checks did not edit player saves or source gameplay systems. Visual approval is pending.
'''%(audit['protected_exact'],audit['original_asset_files_exact'],len(audit['concurrent_changes_preserved']))
(P/'README.md').write_text((W/'README.md').read_text(encoding='utf-8')+tail,encoding='utf-8')
manifest={p.relative_to(P).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in P.rglob('*') if p.is_file() and p.name!='publication.json'}
(W/'publication.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8');shutil.copy2(W/'publication.json',P/'publication.json')
assert all(hashlib.sha256((P/r).read_bytes()).hexdigest()==h for r,h in manifest.items())
print('Verified',len(manifest),'published files; all 11 installed paths exact.')
