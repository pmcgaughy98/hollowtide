from pathlib import Path
import hashlib,json,re
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'protected-before.json').read_text());installed=json.loads((W/'installed-files.json').read_text())
for p,h in installed.items():assert sha(L/p)==h,p
old=(W/'originals/scripts/soul_prologue.gd').read_text(encoding='utf-8');now=(L/'scripts/soul_prologue.gd').read_text(encoding='utf-8')
back=now.replace('\t# Honor the title handoff and the saved preference when opening this scene directly.\n\treduce_motion = reduce_motion or UI.reduce_motion()\n','',1).replace('\t_flash = 0.4 if reduce_motion else 1.6','\t_flash = 1.6',1)
assert back==old,'Unexpected change beyond preference initialization and flash strength'
for phase,count in [('before',6),('after',87)]:
    data=json.loads((W/(phase+'-result.json')).read_text());assert data['passed']==count and data['failed']==0
    assert json.loads((W/(phase+'-command.json')).read_text())['exit']==0
    log=(W/(phase+'.log')).read_text(encoding='utf-8');assert not any(s in log for s in ('SCRIPT ERROR','ERROR:','ObjectDB instances were leaked'))
data=json.loads((W/'after-result.json').read_text());assert len(data['cases'])==9
for c in data['cases']:
    assert c['handoff_frame']-c['first_flash']==22
    if c['effective_reduce']:assert abs(c['peak']-0.4)<0.001 and c['first_zero']==40 and max(c['corner_rgb'])<0.6
    else:assert abs(c['peak']-1.6)<0.001 and min(c['corner_rgb'])>0.98
assert 'Totals: PASS 2' in (W/'runner-result.md').read_text()
def method(s,name):
    match=re.search(r'^static func '+re.escape(name)+r'\([^\n]*(?:\n(?!static func |func ).*)*',s,re.M);assert match,name
    return '\n'.join(line.rstrip() for line in match[0].splitlines() if line.strip() and not line.lstrip().startswith('#'))
tested=(W/'originals/scripts/ui/ui_style.gd').read_text(encoding='utf-8');current=(L/'scripts/ui/ui_style.gd').read_text(encoding='utf-8')
for name in ('reduce_motion','_pref','_load_prefs_file','_move_game_keys','reload_prefs'):
    assert method(tested,name)==method(current,name),('Shared preference helper changed',name)
changed=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h]
docs={'docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-26.md'}
concurrent=[p for p in changed if p not in installed and p not in docs]
result={'baseline_files':len(base),'owned_hash_exact':True,'scope':'only effective saved/forwarded preference initialization and reduced starting strength; all other soul source exact','baseline_native':'6/6 clean; peak1.6, rendered white','installed_native':'87/87 clean; all three heroes, normal/forwarded/saved cases; reduced0.4, normal1.6','official':'soul_prologue and opening_flow PASS; exit0; raw known exit warnings retained','preference_helper_bodies':'match original tested snapshot','concurrent_paths_preserved':concurrent,'changed_existing_paths':changed,'next':'A3 opening inputs/skip/white-outs/cards/light; still pending'}
(W/'verification.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
