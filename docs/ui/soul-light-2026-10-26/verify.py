from pathlib import Path
import hashlib,json,re
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def method(s,name):
    m=re.search(r'^(?:static )?func '+re.escape(name)+r'\([^\n]*(?:\n(?!(?:static )?func ).*)*',s,re.M);assert m,name
    return '\n'.join(line.rstrip() for line in m[0].splitlines() if line.strip() and not line.lstrip().startswith('#'))
base=json.loads((W/'protected-before.json').read_text());installed=json.loads((W/'installed-files.json').read_text())
for p,h in installed.items():assert sha(L/p)==h,p
old=(W/'originals/scripts/soul_prologue.gd').read_text(encoding='utf-8');now=(L/'scripts/soul_prologue.gd').read_text(encoding='utf-8')
for name in ('_input','advance','_process','_fly','_reveal_opening','_start_line','_card_rect','_card_scale','_draw_card','_draw_ui'):
    assert method(old,name)==method(now,name),name
assert old.split('var reduce_motion')[0]==now.split('var reduce_motion')[0]
assert 'c.draw_rect(Rect2(0, 0, LOW.x, 3)' not in now
assert 'PackedColorArray([top, top, end, end])' in now
for phase,count in [('before',3),('after',20)]:
    r=json.loads((W/(phase+'-result.json')).read_text());assert r['passed']==count and r['failed']==0
    log=(W/(phase+'.log')).read_text(encoding='utf-8');assert not any(s in log for s in ('SCRIPT ERROR','ERROR:','ObjectDB instances were leaked'))
    assert json.loads((W/(phase+'-command.json')).read_text())['exit']==0
assert 'Totals: PASS 2' in (W/'runner-result.md').read_text()
changed=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h]
docs={'docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-26.md'};concurrent=[p for p in changed if p not in installed and p not in docs]
result={'protected_baseline_files':len(base),'owned_hash_exact':True,'native_baseline':'3/3 clean','native_installed':'20/20 clean; 16:9, wide, tall, mouse and stretch lifecycle','official':'2 PASS; known raw exit warnings retained','story_input_card_and_transition_methods':'unchanged','scope':'one soul script; bar removed, lower shaft alpha0, backdrop fit and guarded aspect restoration','concurrent_source_changes_preserved':concurrent,'all_changed_existing_paths':changed,'remaining':'C8 cards/sounds/choice safety/hint contrast; Storm pixel soul; other queue tasks'}
(W/'verification.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
