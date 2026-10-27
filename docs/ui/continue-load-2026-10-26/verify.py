from pathlib import Path
import hashlib,json,re,difflib
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');rel='scripts/main_menu.gd'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
owned=json.loads((W/'installed-files.json').read_text());assert sha(L/rel)==owned[rel]
old=(W/'originals'/rel).read_text();new=(L/rel).read_text()
def methods(s):return {m.group(1):m.group(0).rstrip() for m in re.finditer(r'^func (\w+)\(.*?(?=^func |\Z)',s,re.M|re.S)}
a=methods(old);b=methods(new);changed={'_ready','_request_route','_poll_route','_on_new_game','_on_continue'};exact=[]
for name,body in a.items():
 if name in changed:continue
 assert body==b[name],name;exact.append(name)
assert '@export var new_game_confirm_enabled := false' in new
body=b['_on_continue'];order=['_sound(CONFIRM_SOUND)','await tween.finished','TeamState.load_save()','UI._fade_rect(tree, 1.0)','await _load_continue(path)','packed.instantiate()','tree.change_scene_to_node(town)','TeamState.take_suspended()']
assert [body.index(s) for s in order]==sorted(body.index(s) for s in order)
assert '_request_route()' not in b['_ready'] and '_request_route()' in b['_on_new_game']
assert '_route_scene.instantiate()' in (L/'scripts/opening_flow.gd').read_text()
base=json.loads((W/'protected-before.json').read_text());concurrent=[]
for path,h in base.items():
 if path==rel:continue
 if not (L/path).is_file() or sha(L/path)!=h:
  concurrent.append(path)
  if (L/path).is_file():
   dest=W/'concurrent-at-finish'/path;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes((L/path).read_bytes())
critical=['scripts/town/team_state.gd','scripts/town/hub_town.gd','scripts/dungeon/dungeon.gd','scripts/opening_flow.gd','scripts/creature_opening.gd','scripts/ui/ui_style.gd','project.godot']
for path in critical:assert sha(L/path)==base[path],path+' changed since test baseline, review needed'
before=json.loads((W/'before-result.json').read_text());after=json.loads((W/'after-result.json').read_text());assert before['failed']==after['failed']==0
assert after['total']==52 and 'PASS 2' in (W/'official.log').read_text()
(W/'source.diff').write_text(''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='before/'+rel,tofile='after/'+rel)),encoding='utf-8')
report={'owned':owned,'unchanged_original_methods':exact,'changed_original_methods':sorted(changed),'critical_source_project_exact':critical,'C6_stays_off':True,'Continue_order_verified':order,'legacy_route_used_and_now_requested_on_demand':True,'baseline_assertions':before['total'],'native_assertions':after['total'],'baseline_confirm_ms':before['metrics'][0]['confirm_ms'],'baseline_dispatch_ms':before['metrics'][0]['dispatch_ms'],'after_dispatch_ms':{m['case']:m['dispatch_ms'] for m in after['metrics']},'native_exit_warning_before':216,'native_exit_warning_after':309,'concurrent_paths_preserved':concurrent}
(W/'verification.json').write_text(json.dumps(report,indent=2));print(json.dumps(report,indent=2))
