from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');P=L/'docs/ui/launch-pixel-frames-2026-10-10'
markers={'frame_check':'FRAMES 34/34 PASS','field_menu_check':'RESULT: field menu works','soul_prologue_check':'RESULT: the soul prologue works'}
for name,marker in markers.items():
    log=(W/('live-'+name+'.log')).read_text(encoding='utf-8')
    assert marker in log and not any(e in log for e in ['ERROR:','FAIL ','FAILED','leaked']),name
audit=json.loads((W/'audit.json').read_text(encoding='utf-8'))
assert len(audit['installed_exact'])==6
for d in json.loads((W/'pending-install.json').read_text(encoding='utf-8')):
    assert hashlib.sha256((L/d['path']).read_bytes()).hexdigest()==d['after'],d['path']
for name in ['audit.json','audit.py','publish.py']+['live-'+n+'.log' for n in markers]:shutil.copy2(W/name,P/name)
for folder in ['review/live','review/soul','concurrent-final']:
    if (W/folder).is_dir():shutil.copytree(W/folder,P/folder,dirs_exist_ok=True)
tail='''
## Final live verification

Installed native Godot runs pass with clean final logs: 34/34 launch frame/input/layout checks; current Claude field-menu check including Bag item spending a turn; current soul check with Tallowroot chosen, awakening and zero duplicate starter buttons. No runtime, shader or cleanup errors. All six installed files match reviewed candidate hashes. %d protected active files and all %d original active asset files match the baseline. %d concurrent active changes retained and snapshotted; prior collaboration body verbatim. Player saves/settings isolated from the tests.

Installed previews: [title](review/live/title.png), [Options](review/live/options.png), [Help](review/live/help-controls.png), [waking dialogue](review/live/wake-1.png), [welcome](review/live/partner-welcome.png). Current chosen-soul waking in [soul check](review/soul/wake.png). Source, originals, test fixtures and exact publication hashes saved. Job12 story revision remains open; visual approval pending.
'''%(audit['protected_exact'],audit['original_asset_files_exact'],len(audit['concurrent_changes_preserved']))
(P/'README.md').write_text((W/'README.md').read_text(encoding='utf-8')+tail,encoding='utf-8')
manifest={p.relative_to(P).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in P.rglob('*') if p.is_file() and p.name!='publication.json'}
(W/'publication.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8');shutil.copy2(W/'publication.json',P/'publication.json')
assert all(hashlib.sha256((P/r).read_bytes()).hexdigest()==h for r,h in manifest.items())
print('Verified',len(manifest),'published files; all six installed paths exact.')
