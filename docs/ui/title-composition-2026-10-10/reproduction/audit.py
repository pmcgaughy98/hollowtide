from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
pending=json.loads((W/'pending-install.json').read_text());owned={r['path'] for r in pending}
pre=json.loads((W/'preinstall-protected.json').read_text())
unexpected={r:{'before':h,'after':sha(L/r) if (L/r).exists() else None} for r,h in pre.items() if r not in owned and (not (L/r).exists() or sha(L/r)!=h)}
external_paths={'scripts/dungeon/dungeon.gd','scripts/town/hub_town.gd'}
assert set(unexpected).issubset(external_paths),unexpected
installed={i['path']:sha(L/i['path'])==i['after'] for i in pending}
notes_expected=(W/'candidate/docs/AI_COLLABORATION.md').read_bytes()
notes_now=(L/'docs/AI_COLLABORATION.md').read_bytes()
# Claude appended a new healer handoff after installation. Preserve it, verify our prefix.
assert notes_now.startswith(notes_expected),'Collaboration content changed, requires inspection'
installed['docs/AI_COLLABORATION.md']=True
assert all(installed.values()),installed
assert 'CHECKS 51 FAILURES 0' in (W/'live_menu_check.log').read_text()
assert 'TITLE_RESULT passes=29 failures=0' in (W/'live_title_check.log').read_text()
assert 'TITLE QUIT CONFIRMATION REACHED' in (W/'live_quit_title.log').read_text()
for name in ['title_check','menu_check','quit_title']:
    errors=[s for s in (W/('live_'+name+'.log')).read_text().splitlines() if ('ERROR:' in s or 'Parse Error' in s) and 'Failed to read the root certificate store' not in s]
    assert not errors,(name,errors)
# Latest pre-install notes must remain intact beneath our added entry.
old=(W/'originals/docs/AI_COLLABORATION.md').read_bytes().split(b'\n',1)[1]
assert old in notes_now
result={'date':'2026-10-10','runtime_files_verified':installed,'unowned_existing_files_byte_exact':len(pre)-len(owned.intersection(pre)),'unexpected_unowned_changes':unexpected,'concurrent_initial_to_preinstall_changes_retained':json.loads((W/'concurrent-before-install.json').read_text()),'latest_collaboration_tail_preserved':True,'installed_title_checks':{'passed':29,'failed':0},'installed_launch_menu_checks':{'passed':51,'failed':0},'native_title_quit':'confirmation closes engine','preferences':'isolated APPDATA','village_wordmark_creatures_audio_fonts_originals':'unchanged','generation_calls':0,'git':'no commit/reset/revert/stash'}
(W/'installation.json').write_text(json.dumps(result,indent=2))
result['post_install_collaboration_append']={'bytes':len(notes_now)-len(notes_expected),'installed_prefix_byte_exact':True,'current_sha256':sha(L/'docs/AI_COLLABORATION.md'),'description':'Claude appended Troughspine/Archroot/Springvault/Seep handoff; preserved unchanged'}
result['concurrent_unowned_code_edits_retained']=unexpected
result['unowned_existing_files_byte_exact']-=len(unexpected)
result['unexpected_unowned_changes']={}
result['new_claude_shared_ui_style']={'path':'scripts/ui/ui_style.gd','current_sha256':sha(L/'scripts/ui/ui_style.gd'),'written_by_this_install':False}
result['quit_shutdown_diagnostic']={'fixed_frame_fixture':'exit 0 with 8 ObjectDB instances and 3 resources at exit','verbose_repeat':'clean exit 0','standard_fixed_frame_repeat':'shutdown diagnostic recurred','final_fixture':'waits for actual boot completion plus settled frames; clean exit 0','production_cleanup_changes':'none; runtime memory-lifecycle fix not claimed'}
(W/'installation.json').write_text(json.dumps(result,indent=2))
P=W/'archive'
for f in W.glob('*.log'):dst=P/'logs'/f.name;dst.parent.mkdir(exist_ok=True);shutil.copy2(f,dst)
shutil.copytree(W/'review',P/'review',dirs_exist_ok=True)
for ext in ['*.gd','*.py','*.ps1']:
    for f in W.glob(ext):shutil.copy2(f,P/'reproduction'/f.name)
shutil.copy2(W/'installation.json',P/'installation.json')
shutil.copy2(W/'README.md',P/'README.md')
print('80 installed native checks pass;',result['unowned_existing_files_byte_exact'],'unowned existing files byte-exact; latest notes retained')
