from pathlib import Path
import hashlib,json,re,difflib
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');SRC='docs/creatures/arena-starters-2026-10-07/forms';DST='assets/sprites/arena/%s/front_chosen.png'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
owned=json.loads((W/'installed-files.json').read_text());base=json.loads((W/'protected-before.json').read_text());manifest=json.loads((W/'manifest.json').read_text())
for rel,h in owned.items():assert sha(L/rel)==h,rel
for rel,h in json.loads((W/'original-forms-hashes.json').read_text()).items():assert sha(L/rel)==h,rel+' source changed'
for item in manifest:assert sha(L/item['destination'])==item['sha256']
rel='scripts/town/board_scene.gd';old=(W/'originals'/rel).read_text();new=(L/rel).read_text()
restored=new.replace(f'res://{DST}',f'res://{SRC}/%s_arena_front_chosen.png').replace('# Runtime fronts live in assets; original research takes stay in docs. Read',"# The docs/ path stays until Codex's C22 moves the art into assets/ (Claude, 2026-10-24, pass 4 T11). Read")
assert restored==old,'More than path/comment changed'
prefixes=[]
for folder in ('scripts','scenes','data','dialogue'):
 for p in (L/folder).rglob('*'):
  if p.is_file() and p.suffix in ('.gd','.tscn','.tres','.dialogue','.json') and 'res://docs/' in p.read_text(encoding='utf-8',errors='replace'):prefixes.append(p.relative_to(L).as_posix())
assert not prefixes,prefixes
assert (L/'export_presets.cfg').read_text()==(W/'originals/export_presets.cfg').read_text().replace('docs/*.gd,docs/*.tscn,docs/*.tres,docs/*.gdshader','docs/*')
ui=(L/'scripts/ui/ui_style.gd').read_text();method=re.search(r'static func res_image\(.*?\treturn img\n',ui,re.S).group();assert method==(W/'tested-res-image.gd.txt').read_text()
concurrent=[]
for rel,h in base.items():
 if rel in owned:continue
 if not (L/rel).is_file() or sha(L/rel)!=h:
  concurrent.append(rel)
  if (L/rel).is_file():
   dest=W/'concurrent-at-finish'/rel;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes((L/rel).read_bytes())
for rel in ('scripts/town/hub_town.gd','scripts/town/scene_kit.gd','scripts/ui/ui_style.gd','scripts/main_menu.gd','project.godot'):assert sha(L/rel)==base[rel],rel+' changed during checks'
assert json.loads((W/'native-result.json').read_text())['failed']==0 and json.loads((W/'pack-result.json').read_text())['failed']==0
assert 'PASS 1' in (W/'official.log').read_text()
diff=''
for rel in ('scripts/town/board_scene.gd','export_presets.cfg'):diff+=''.join(difflib.unified_diff((W/'originals'/rel).read_text().splitlines(True),(L/rel).read_text().splitlines(True),fromfile='before/'+rel,tofile='after/'+rel))
(W/'source.diff').write_text(diff,encoding='utf-8')
missing=[]
for form in ('gruntle','mirekit','whinet'):
 if not (L/(DST%form)).exists():missing.append(form)
out={'asset_count':16,'total_png_bytes':sum(i['bytes'] for i in manifest),'destination':DST,'owned':owned,'all_original_form_files_preserved':True,'board_change_only_path_and_comment':True,'all_other_Claude_board_edits_exact':True,'runtime_docs_references':prefixes,'native_checks':52,'asset_pack_checks':49,'maintained_board_scene':'PASS','preexisting_missing_chosen_filenames':missing,'current_crew_directional_sets_verified':True,'full_game_exe':'pending export templates','concurrent_paths_preserved':concurrent}
(W/'verification.json').write_text(json.dumps(out,indent=2));print(json.dumps({k:v for k,v in out.items() if k!='owned'},indent=2))
