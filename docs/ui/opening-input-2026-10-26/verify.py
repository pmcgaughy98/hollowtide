from pathlib import Path
import difflib,hashlib,json,re
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def method(s,name):
    m=re.search(r'^(?:static )?func '+re.escape(name)+r'\([^\n]*(?:\n(?!(?:static )?func ).*)*',s,re.M);assert m,name
    return '\n'.join(line.rstrip() for line in m[0].splitlines() if line.strip() and not line.lstrip().startswith('#'))
base=json.loads((W/'protected-before.json').read_text());installed=json.loads((W/'installed-files.json').read_text())
for p,h in installed.items():assert sha(L/p)==h,p
for rel,names in {
    'scripts/main_menu.gd':['_load_preferences','_save_preferences','_on_continue','_ask_new_game','_confirm_new_game'],
    'scripts/opening_flow.gd':['_finish_boot','_begin_journey'],
    'scripts/soul_prologue.gd':['_ready','advance','_fly','_process','_draw_void','_draw_card'],
    'scripts/storm_open.gd':['_run','_lightning','_draw_rain','_draw_soul','_next'],
    'scripts/ui/ui_style.gd':['pressed','binding_text','_motion_edge'],
    'scripts/ui/input_prefs.gd':['save_binding','apply_saved']
}.items():
    old=(W/'originals'/rel).read_text(encoding='utf-8');now=(L/rel).read_text(encoding='utf-8')
    for name in names:assert method(old,name)==method(now,name),(rel,name)
assert '_ensure_menu_inputs' not in (L/'scripts/main_menu.gd').read_text()
assert not any(re.search(r'\bUI\.HEAD\b|^const HEAD\s*[:=]',p.read_text(encoding='utf-8'),re.M) for p in (L/'scripts').rglob('*.gd'))
native=json.loads((W/'native-result.json').read_text());assert native['passed']==85 and native['failed']==0
flow=json.loads((W/'flow-results/checks.json').read_text());assert len(flow['checks'])==28 and not flow['failures']
for phase in ('native','flow'):
    log=(W/(phase+'.log')).read_text(encoding='utf-8');assert not any(s in log for s in ('SCRIPT ERROR','ERROR:','ObjectDB instances were leaked'))
    assert json.loads((W/(phase+'-command.json')).read_text())['exit']==0
assert 'Totals: PASS 4' in (W/'runner-result.md').read_text()
# Give Claude the minimal public-check update, with no private paths or teardown changes.
old=(W/'originals/tools/debug/opening_flow_check.gd').read_text(encoding='utf-8')
needle='\telse:\n\t\tawait key(KEY_ENTER)\n\tif not verify("Storm enters actual soul scene"';assert old.count(needle)==1
candidate=old.replace(needle,'\telse:\n\t\tawait key(KEY_ENTER)\n\t\tverify("One Enter only arms storm skip", scene_name() == "storm_open.tscn" and storm._skip_armed)\n\t\tawait key(KEY_ENTER)\n\tif not verify("Storm enters actual soul scene"',1)
p=W/'proposal/opening-flow-two-press.diff';p.parent.mkdir(exist_ok=True)
p.write_text(''.join(difflib.unified_diff(old.splitlines(True),candidate.splitlines(True),fromfile='a/tools/debug/opening_flow_check.gd',tofile='b/tools/debug/opening_flow_check.gd')),encoding='utf-8')
changed=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h]
docs={'docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-26.md'}
concurrent=[p for p in changed if p not in installed and p not in docs]
result={'protected_baseline_files':len(base),'owned_hashes_exact':True,'critical_story_save_flash_methods':'unchanged','shared_input_helpers':'current bodies match tested baseline','runtime_HEAD_users':'none; shared constant already removed by Claude','native_input':'85/85 clean','native_real_opening':'28/28 clean, including second-press skip','official':'4 PASS, exit0; known raw exit noise retained','public_check_followup':'minimal candidate only, equivalent private copy tested; live check not edited','concurrent_source_changes_preserved':concurrent,'all_changed_existing_paths':changed,'C6':'default OFF untouched','A3_remainder':'white-outs, cards/sounds/contrast, shafts and Storm pixel light remain pending'}
(W/'verification.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
