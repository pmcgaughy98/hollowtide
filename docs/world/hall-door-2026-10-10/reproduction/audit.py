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
assert (L/'assets/sprites/world/wayline_hall_2026_10_09/wayline_hall_native.png').read_bytes()==(W/'originals/assets/sprites/world/wayline_hall_2026_10_09/wayline_hall_native.png').read_bytes()
assert 'CHECKS 51 FAILURES 0' in (W/'live_menu_check.log').read_text()
assert 'ENTRANCE_RESULT passes=14 failures=0' in (W/'live_live_entrance_check.log').read_text()
assert 'RESULT: field menu works' in (W/'live_field_menu_check.log').read_text()
for name in ['quit_title','quit_pause']:
    assert 'QUIT CONFIRMATION REACHED' in (W/('live_'+name+'.log')).read_text()
result={'date':'2026-10-10','runtime_files_verified':installed,'unowned_existing_files_byte_exact':len(pre)-len(owned.intersection(pre)),'unexpected_unowned_changes':unexpected,'original_hall_png_unchanged':True,'initial_to_preinstall_concurrent_changes_retained':json.loads((W/'concurrent-before-install.json').read_text()),'installed_entrance_checks':{'passed':14,'failed':0},'installed_launch_menu_checks':{'passed':51,'failed':0},'claude_field_hall_hub_checks':'pass','native_quit_confirmations':'both close engines','preferences':'isolated APPDATA','generation':'three built-in imagegen edits, zero Retro','production_combat':'turn based, unchanged','full_natural_dungeon_completion':'not claimed','git':'no commit/reset/revert/stash'}
(W/'installation.json').write_text(json.dumps(result,indent=2))
P=W/'archive'
for f in W.glob('*.log'):dst=P/'logs'/f.name;dst.parent.mkdir(exist_ok=True);shutil.copy2(f,dst)
shutil.copytree(W/'review',P/'review',dirs_exist_ok=True)
for ext in ['*.gd','*.py','*.ps1']:
    for f in W.glob(ext):shutil.copy2(f,P/'reproduction'/f.name)
shutil.copy2(W/'installation.json',P/'installation.json')
print('Installed Hall original unchanged;',len(pre)-len(owned.intersection(pre)),'unowned existing files byte-exact; 14 entrance + 51 launch/menu checks pass')
