from pathlib import Path
import hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'protected-before.json').read_text());installed=json.loads((W/'installed-files.json').read_text())
for p,h in installed.items():assert sha(L/p)==h,p
old=(W/'originals/scripts/opening_flow.gd').read_text(encoding='utf-8');now=(L/'scripts/opening_flow.gd').read_text(encoding='utf-8')
assert old.split('func _finish_boot()')[0]==now.split('func _finish_boot()')[0]
assert old.split('func _input(event: InputEvent)')[1]==now.split('func _input(event: InputEvent)')[1]
for p in ('scripts/main_menu.gd','scripts/creature_opening.gd','scripts/storm_open.gd','scripts/soul_prologue.gd','scripts/town/team_state.gd','scripts/ui/ui_style.gd','scripts/ui/game_pause_menu.gd','scripts/ui/hollowtide_wordmark.gd','project.godot'):
    assert sha(L/p)==base[p],p
for phase,count in [('before',36),('after',66),('after-legacy',20)]:
    results=json.loads((W/(phase+'-result.json')).read_text());assert results['passed']==count and results['failed']==0
    assert json.loads((W/(phase+'-command.json')).read_text())['exit']==0
    if phase!='before':
        assert all(c['overlap_frames']==0 and c['first_menu_frame']>c['last_launch_frame'] and c['cursor_ticks_at_load']==0 for c in results['cases'])
    else:assert all(c['overlap_frames']==14 for c in results['cases'] if c['case'].startswith('normal'))
for phase in ('before','after'):
    log=(W/(phase+'.log')).read_text(encoding='utf-8');assert not any(s in log for s in ('SCRIPT ERROR','ERROR:','ObjectDB instances were leaked'))
assert 'Totals: PASS 2' in (W/'runner-result.md').read_text()
changed=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h]
concurrent=[p for p in changed if p not in installed and p not in ('docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-22.md')]
result={'baseline_files':len(base),'only_owned_method_changed':True,'shared_and_campaign_sources_exact':True,'baseline_native':'36/36 clean; 14 overlapping frames in each normal case','installed_native':'66/66 clean; zero overlap in six campaign cases','legacy_native':'20/20; known 101-instance ObjectDB exit warning','official':'opening_flow and ui_fit PASS; exit0; raw known exit noise retained','concurrent_changed_paths':concurrent,'changed_existing_paths':changed,'prompt_flag':'prior C6 default OFF unchanged','Storm_and_soul':'untouched; pending next slices'}
(W/'verification.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
