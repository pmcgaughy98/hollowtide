from pathlib import Path
import csv,hashlib,json,re
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def method(s,name):
    m=re.search(r'^(?:static )?func '+re.escape(name)+r'\([^\n]*(?:\n(?!(?:static )?func ).*)*',s,re.M);assert m,name
    return '\n'.join(line.rstrip() for line in m[0].splitlines() if line.strip() and not line.lstrip().startswith('#'))
base=json.loads((W/'protected-before.json').read_text());installed=json.loads((W/'installed-files.json').read_text())
for p,h in installed.items():assert sha(L/p)==h,p
for rel,names in {
    'scripts/storm_open.gd':['_lightning','_unhandled_input','_draw_soul','_draw_rain'],
    'scripts/soul_prologue.gd':['advance','_process','_move_pick','_draw_void','_draw_card'],
    'scripts/ui/ui_style.gd':['fade_out','fade_in','_fade_rect','motion_secs'],
}.items():
    old=(W/'originals'/rel).read_text(encoding='utf-8');now=(L/rel).read_text(encoding='utf-8')
    for name in names:assert method(old,name)==method(now,name),(rel,name)
assert sha(L/'scripts/creature_prologue.gd')==sha(W/'originals/scripts/creature_prologue.gd')
old=(W/'originals/scripts/soul_prologue.gd').read_text(encoding='utf-8');now=(L/'scripts/soul_prologue.gd').read_text(encoding='utf-8')
assert old.split('var reduce_motion')[0]==now.split('var reduce_motion')[0]
assert method(old,'_input')==method(now.replace('auto or _opening_fade or stage','auto or stage'),'_input')
for phase,count in [('before',10),('after',34)]:
    r=json.loads((W/(phase+'-result.json')).read_text());assert r['passed']==count and r['failed']==0
    log=(W/(phase+'.log')).read_text(encoding='utf-8');assert not any(s in log for s in ('SCRIPT ERROR','ERROR:','ObjectDB instances were leaked'))
    assert json.loads((W/(phase+'-command.json')).read_text())['exit']==0
assert 'Totals: PASS 3' in (W/'runner-result.md').read_text()
summary=[]
with (W/'luminance.csv').open('w',newline='',encoding='utf-8') as f:
    writer=csv.writer(f);writer.writerow(['phase','case','frame','scene','luminance','shared_black','white','flash','bank_veil'])
    for phase in ('before','after'):
        r=json.loads((W/(phase+'-result.json')).read_text())
        for c in r['cases']:
            summary.append({k:v for k,v in c.items() if k!='samples'}|{'phase':phase})
            for row in c['samples']:writer.writerow([phase,c['case'],row['frame'],row['scene'],row['luma'],row['shared_black'],row['white'],row['flash'],row['veil']])
(W/'luminance-summary.json').write_text(json.dumps(summary,indent=2))
changed=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h]
docs={'docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-26.md'};concurrent=[p for p in changed if p not in installed and p not in docs]
result={'protected_baseline_files':len(base),'owned_hashes_exact':True,'native_baseline':'10/10 clean','native_installed':'34/34 clean; actual scene swaps, normal/reduced, natural/skip','official':'3 PASS; known raw exit warnings retained','bank_source':'exact; existing covered construction/reveal preserved','shared_fade_helpers':'current bodies match tested baseline','story_and_critical_inputs':'preserved; soul opening temporarily blocks input until reveal finishes','concurrent_source_changes_preserved':concurrent,'all_changed_existing_paths':changed,'A3_remainder':'C8 cards, C9 top bar/shafts, Storm pixel soul still pending'}
(W/'verification.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
