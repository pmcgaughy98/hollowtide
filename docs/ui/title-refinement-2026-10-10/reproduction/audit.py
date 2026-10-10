from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
pending=json.loads((W/'pending-install.json').read_text());owned={r['path'] for r in pending}
pre=json.loads((W/'preinstall-protected.json').read_text())
unexpected={r:{'before':h,'after':sha(L/r) if (L/r).exists() else None} for r,h in pre.items() if r not in owned and (not (L/r).exists() or sha(L/r)!=h)}
assert not unexpected,unexpected
installed={i['path']:sha(L/i['path'])==i['after'] for i in pending}
assert all(installed.values()),installed
assert 'CHECKS 51 FAILURES 0' in (W/'live_menu_check.log').read_text()
assert 'TITLE_RESULT passes=26 failures=0' in (W/'live_title_check.log').read_text()
assert 'TITLE QUIT CONFIRMATION REACHED' in (W/'live_quit_title.log').read_text()
# Latest pre-install notes must remain intact beneath our added entry.
old=(W/'originals/docs/AI_COLLABORATION.md').read_bytes().split(b'\n',1)[1]
assert (L/'docs/AI_COLLABORATION.md').read_bytes().endswith(old)
result={'date':'2026-10-10','runtime_files_verified':installed,'unowned_existing_files_byte_exact':len(pre)-len(owned.intersection(pre)),'unexpected_unowned_changes':unexpected,'concurrent_initial_to_preinstall_changes_retained':json.loads((W/'concurrent-before-install.json').read_text()),'latest_collaboration_tail_preserved':True,'installed_title_checks':{'passed':26,'failed':0},'installed_launch_menu_checks':{'passed':51,'failed':0},'native_title_quit':'confirmation closes engine','preferences':'isolated APPDATA','village_wordmark_creatures_audio_originals':'unchanged','generation_calls':0,'git':'no commit/reset/revert/stash'}
(W/'installation.json').write_text(json.dumps(result,indent=2))
P=W/'archive'
for f in W.glob('*.log'):dst=P/'logs'/f.name;dst.parent.mkdir(exist_ok=True);shutil.copy2(f,dst)
shutil.copytree(W/'review',P/'review',dirs_exist_ok=True)
for ext in ['*.gd','*.py','*.ps1']:
    for f in W.glob(ext):shutil.copy2(f,P/'reproduction'/f.name)
shutil.copy2(W/'installation.json',P/'installation.json')
print('77 installed native checks pass;',result['unowned_existing_files_byte_exact'],'unowned existing files byte-exact; latest notes retained')
