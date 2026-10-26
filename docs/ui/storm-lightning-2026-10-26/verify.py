from pathlib import Path
import hashlib,json,re
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'protected-before.json').read_text());installed=json.loads((W/'installed-files.json').read_text())
for p,h in installed.items():assert sha(L/p)==h,p
old=(W/'originals/scripts/storm_open.gd').read_text(encoding='utf-8');now=(L/'scripts/storm_open.gd').read_text(encoding='utf-8')
back=now.replace('const UI := preload("res://scripts/ui/ui_style.gd")\n','',1).replace('\t# Respect both the title handoff and direct entry with the saved accessibility preference.\n\treduce_motion = reduce_motion or UI.reduce_motion()\n','',1).replace('await tree.create_timer(strike).timeout','await tree.create_timer(strike * (0.4 if reduce_motion else 1.0)).timeout',1)
start=back.index('func _lightning()');end=back.index('func _process(',start)
old_start=old.index('func _lightning()');old_end=old.index('func _process(',old_start)
back=back[:start]+old[old_start:old_end]+back[end:];assert back==old
for phase,count in [('before',6),('after',33)]:
    data=json.loads((W/(phase+'-result.json')).read_text());assert data['passed']==count and data['failed']==0
    assert json.loads((W/(phase+'-command.json')).read_text())['exit']==0
    log=(W/(phase+'.log')).read_text(encoding='utf-8');assert not any(s in log for s in ('SCRIPT ERROR','ERROR:','ObjectDB instances were leaked'))
data=json.loads((W/'after-result.json').read_text());assert len(data['cases'])==3
for c in data['cases']:
    assert c['thunder_count']==3 and len(c['strikes'])==3
    if c['effective_reduce']:assert c['pulses']==3 and c['shader_peak']<=0.4001
    else:assert c['pulses']==6 and abs(c['peak']-0.85)<0.001
assert 'Totals: PASS 2' in (W/'runner-result.md').read_text()
def method(s,name):
    match=re.search(r'^static func '+re.escape(name)+r'\([^\n]*(?:\n(?!static func |func ).*)*',s,re.M)
    assert match,name
    return '\n'.join(line.rstrip() for line in match[0].splitlines() if line.strip() and not line.lstrip().startswith('#'))
tested=(W/'tested-shared/ui_style.gd').read_text(encoding='utf-8');current=(L/'scripts/ui/ui_style.gd').read_text(encoding='utf-8')
for name in ('reduce_motion','_pref','_load_prefs_file','_move_game_keys','reload_prefs'):
    assert method(tested,name)==method(current,name),('Shared pref helper changed again',name)
changed=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h]
docs={'docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-26.md'}
concurrent=[p for p in changed if p not in installed and p not in docs]
result={'baseline_files':len(base),'owned_hash_exact':True,'scope':'one preload, effective preference read, uncompressed strike waits, reduced-only pulse branch; all other storm source exact','baseline_native':'6/6 clean; 6 bright pulses','installed_native':'33/33 clean; 3 soft pulses per reduced run; normal 6 pulses retained','official':'storm_open and opening_flow PASS, exit0; raw known exit warnings retained','shared_recheck':'Final tests rerun after Claude pref recovery/HEAD updates; current preference helper bodies match tested snapshot','concurrent_paths_preserved':concurrent,'changed_existing_paths':changed,'prompt_flag':'C6 OFF, unchanged by this slice','next':'ACC-14 soul flash; soul source not edited'}
(W/'verification.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
