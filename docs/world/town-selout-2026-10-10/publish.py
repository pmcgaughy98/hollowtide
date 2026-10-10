from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');P=L/'docs/world/town-selout-2026-10-10'
markers={'finish_check':'RESULT 21/21 checks pass','hub_town_check':'Places: 12 of 12 answered E','town_walk_check':'RESULT: the team walks','dungeons_check':'DUNGEONS: all ok','hall_door_check':'RESULT: the hall door meets the steps','capture':'Captured live eight native Highbank views'}
for name,marker in markers.items():
 log=(W/('live-'+name+'.log')).read_text(encoding='utf-8')
 assert marker in log and all(err not in log for err in ['ERROR:','SCRIPT ERROR','SHADER ERROR','FAIL ','FAILED','WRONG','leaked']),name
audit=json.loads((W/'audit.json').read_text(encoding='utf-8'))
assert len(audit['installed_exact'])==11
for d in json.loads((W/'pending-install.json').read_text(encoding='utf-8')):
 assert hashlib.sha256((L/d['path']).read_bytes()).hexdigest()==d['after'],d['path']
for name in ['audit.json','audit.py','publish.py','install.ps1','pending-install.json','capture.gd']+['live-'+n+'.log' for n in markers]:shutil.copy2(W/name,P/name)
for folder in ['review/live','review/proof','concurrent-final']:
 if (W/folder).is_dir():shutil.copytree(W/folder,P/folder,dirs_exist_ok=True)
tail='''
## Final installed verification

All six live runs pass with no script/shader errors, certificate errors or leaks in the live logs: 21 finish/helper comparisons, hub reachability/12 services/gate, actual team walking, both Hall tiles, both dungeon story/rules/dispatch checks, and eight live native town captures. All 11 intended installed files match their reviewed candidate hashes. The audit reports %d protected active files exact and %d original active asset files exact. %d concurrent changes were retained (details in audit.json); no source art files were written by this task. Existing archive folders were not touched. Previous collaboration text is retained verbatim after the new entry.

Final native views: [Home](review/live/home.png), [Hall and Job Board](review/live/hall.png), [Item Shop](review/live/shop.png), [Storage](review/live/storage.png), [Scroll cellar](review/live/scrolls.png), [Growth Shrine](review/live/shrine.png), [Training Yard](review/live/yard.png), [Hollow Mouth](review/live/gate.png). See publication.json for hashes of every published archive file. No natural dungeon clear or Preston's visual approval claimed.
''' % (audit['protected_exact'],audit['original_asset_files_exact'],len(audit['concurrent_changes_preserved']))
(P/'README.md').write_text((W/'README.md').read_text(encoding='utf-8')+tail,encoding='utf-8')
manifest={p.relative_to(P).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in P.rglob('*') if p.is_file() and p.name!='publication.json'}
(W/'publication.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
shutil.copy2(W/'publication.json',P/'publication.json')
assert all(hashlib.sha256((P/r).read_bytes()).hexdigest()==h for r,h in manifest.items())
print('Verified publication:',len(manifest),'archive files; all 11 installed candidates exact.')
