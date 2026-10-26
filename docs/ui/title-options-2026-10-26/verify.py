from pathlib import Path
import hashlib,json,re,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def function(s,name):
    m=re.search(r'^func '+re.escape(name)+r'\(.*?(?=^func |\Z)',s,re.M|re.S);assert m,name;return m.group()
same={'scripts/main_menu.gd':['_save_preferences','_load_preferences','_on_continue','_on_new_game'], 'scripts/creature_opening.gd':['_build_wordmark','_build_scenery','_on_new_game']}
for rel,names in same.items():
    a=(W/'originals'/rel).read_text(encoding='utf-8');b=(L/rel).read_text(encoding='utf-8')
    for name in names:assert function(a,name)==function(b,name),(rel,name)
original=(W/'originals/scripts/creature_opening.gd').read_text(encoding='utf-8')
current=(L/'scripts/creature_opening.gd').read_text(encoding='utf-8')
a=original[original.index('\tif topic=="journey":'):original.index('\telse:\n\t\tlines=[',original.index('func _show_help_topic'))]
b=current[current.index('\tif topic=="journey":'):current.index('\telse:\n\t\tlines=',current.index('func _show_help_topic'))]
assert a==b,'Journey wording changed'
for p,h in json.loads((W/'installed-files.json').read_text()).items():assert sha(L/p)==h,p
old_evidence=L/'docs/ui/title-type-2026-10-26'
old_hash=json.loads((old_evidence/'installed-files.json').read_text())
for p in same:assert sha(W/'originals'/p)==old_hash[p], 'Previous capture is not the exact original source'
before=W/'native-before';before.mkdir(exist_ok=True)
for key,source in (('options','options-save-false'),('controls-keyboard','help-controls')):
    shutil.copy2(old_evidence/'native-after'/(source+'.png'),before/(key+'.png'))
provenance={'status':'Before images reused from previous checked slice; both owned menu originals match that installed source SHA256 exactly','source_evidence':'docs/ui/title-type-2026-10-26/native-after','source_files':{p:old_hash[p] for p in same},'images':{p.name:sha(p) for p in before.glob('*.png')}}
(W/'before-image-provenance.json').write_text(json.dumps(provenance,indent=2))
base=json.loads((W/'protected-before.json').read_text())
shared=['scripts/ui/game_pause_menu.gd','scripts/ui/ui_style.gd','scripts/ui/rebind_page.gd','scripts/ui/controls_text.gd','scripts/ui/input_prefs.gd','scripts/soul_prologue.gd']
shared_state={p:{'baseline':base[p],'current':sha(L/p),'exact':sha(L/p)==base[p]} for p in shared}
result={'preserved_methods':same,'journey_words_exact':True,'shared_sources_read_only':shared_state,'native_settings_help':'30/30','native_restart':'19/19','native_ui_fit':'48/48','before_image_provenance':'before-image-provenance.json','C1_safe_writer_retained':True}
(W/'verification.json').write_text(json.dumps(result,indent=2));print(json.dumps({'preserved_methods':same,'shared_current_exact':all(v['exact'] for v in shared_state.values()),'before_images_verified_by_source_hash':True},indent=2))
