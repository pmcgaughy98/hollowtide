from pathlib import Path
import json,hashlib,re,difflib
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
hashes=json.loads((W/'installed-files.json').read_text())
for rel,h in hashes.items():assert sha(L/rel)==h,rel+' changed after tests'
old=(W/'originals/scripts/soul_prologue.gd').read_text();new=(L/'scripts/soul_prologue.gd').read_text()
def method(s,n):return re.search(r'^func '+n+r'\(.*?(?=^func |\Z)',s,re.M|re.S).group().rstrip()
exact=['_fly','_draw_void','_fit_backdrop','_exit_tree','_reveal_opening','_text','_start_line','_card_rect']
for n in exact:assert method(old,n)==method(new,n),n
assert old[old.index('const FORMS'):old.index('var reduce_motion')]==new[new.index('const FORMS'):new.index('var reduce_motion')]
driver=(L/'tools/debug/opening_flow_check.gd').read_text()
assert 'await frames(12)   # an answer list' in driver
assert 'First Storm press only arms skip' in driver and 'Starter asks before committing' in driver
native=json.loads((W/'after-result.json').read_text());assert native['failed']==0 and native['total']==47
flows=json.loads((W/'real-flow-result.json').read_text());assert len(flows)==3 and all(not a['failures'] for a in flows)
base=json.loads((W/'protected-before.json').read_text());concurrent=[]
for rel,h in base.items():
 if rel in hashes:continue
 if not (L/rel).is_file() or sha(L/rel)!=h:
  concurrent.append(rel)
  if (L/rel).is_file():
   dest=W/'concurrent-at-finish'/rel;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes((L/rel).read_bytes())
diff=''
for rel in hashes:diff+=''.join(difflib.unified_diff((W/'originals'/rel).read_text().splitlines(True),(L/rel).read_text().splitlines(True),fromfile='before/'+rel,tofile='after/'+rel))
(W/'source.diff').write_text(diff,encoding='utf-8')
out={'owned':hashes,'exact_methods':exact,'story_and_creature_constants_exact':True,'Claude_partner_guard_preserved':True,'native':native['total'],'real_flow_native':sum(a['checks'] for a in flows),'concurrent_paths_preserved':concurrent}
(W/'verification.json').write_text(json.dumps(out,indent=2));print(json.dumps(out,indent=2))
