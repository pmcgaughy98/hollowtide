from pathlib import Path
import hashlib,json,re
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def method(text,name):
    m=re.search(r'^func '+re.escape(name)+r'\([^\n]*(?:\n(?!func |static func |@export|var |const |class_name |extends ).*)*',text,re.M)
    assert m,name
    # Comments preceding the next method may change; compare executable body.
    return '\n'.join(line.rstrip() for line in m[0].splitlines() if line.strip() and not line.lstrip().startswith('#'))
installed=json.loads((W/'installed-files.json').read_text())
for rel,h in installed.items():assert sha(L/rel)==h,rel
preserved={}
for rel,names in {
    'scripts/main_menu.gd':['_load_preferences','_save_preferences','_on_continue','_begin_journey','_build_scenery'],
    'scripts/creature_opening.gd':['_begin_journey','_build_scenery']
}.items():
    old=(W/'originals'/rel).read_text(encoding='utf-8');now=(L/rel).read_text(encoding='utf-8')
    for name in names:assert method(old,name)==method(now,name),(rel,name)
    preserved[rel]=names
main=(L/'scripts/main_menu.gd').read_text(encoding='utf-8')
assert '@export var new_game_confirm_enabled := false' in main
assert 'Saving the new journey will replace your current save.' in main
assert not any('new_game_confirm_enabled' in p.read_text(encoding='utf-8') for p in (L/'scenes').rglob('*.tscn'))
native=json.loads((W/'native-result.json').read_text());assert native['passed']==47 and native['failed']==0
for phase in ('native','ui_fit'):
    log=(W/(phase+'.log')).read_text(encoding='utf-8')
    assert not any(s in log for s in ('SCRIPT ERROR','ERROR:','ObjectDB instances were leaked')),phase
    assert json.loads((W/(phase+'-command.json')).read_text())['exit']==0
assert (W/'ui_fit.log').read_text(encoding='utf-8').count('ok    ')==48
assert 'Totals: PASS 3' in (W/'runner-result.md').read_text()
base=json.loads((W/'protected-before.json').read_text())
changed=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h]
owned=set(installed);docs={'docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-22.md'}
concurrent=[p for p in changed if p not in owned|docs]
assert sha(L/'scripts/town/team_state.gd')==sha(W/'originals/scripts/town/team_state.gd')
result={'protected_baseline_files':len(base),'owned_hashes_exact':True,'default_prompt_flag':'OFF; no scene override','preserved_methods':preserved,'native':'47/47; clean','native_ui_fit':'48/48; clean','official':'3 PASS; known exit warnings retained','changed_existing_paths':changed,'concurrent_changes_preserved':concurrent,'team_state_source_exact':True}
(W/'verification.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
