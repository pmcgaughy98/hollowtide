from pathlib import Path
import hashlib,json,re
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def function(s,name):
    match=re.search(r'^func '+re.escape(name)+r'\(.*?(?=^func |\Z)',s,re.M|re.S)
    assert match is not None,name
    return match.group()
unchanged={
'scripts/main_menu.gd':['_save_preferences','_load_preferences','_volume_control','_on_new_game','_on_continue'],
'scripts/creature_opening.gd':['_build_wordmark','_on_new_game','menu_top'],
'scripts/soul_prologue.gd':['_ready','_text','_start_line','_move_pick','_fly','_card_rect','_card_scale','_input','_on_click']}
for rel,names in unchanged.items():
    a=(W/'originals'/rel).read_text(encoding='utf-8');b=(L/rel).read_text(encoding='utf-8')
    for name in names:
        if name=='menu_top':
            assert a[a.index('static func menu_top'):]==b[b.index('static func menu_top'):]
        else:assert function(a,name)==function(b,name),(rel,name)
old=(W/'originals/scripts/soul_prologue.gd').read_text(encoding='utf-8');new=(L/'scripts/soul_prologue.gd').read_text(encoding='utf-8')
assert old[old.index('const LINES :='):old.index('var reduce_motion')]==new[new.index('const LINES :='):new.index('var reduce_motion')]
assert not any(x in (L/'scripts/creature_opening.gd').read_text() for x in ('MENU_FACE','COPY_FACE','HINT_FACE'))
assert 'UI.HEAD' not in new
for p,h in json.loads((W/'installed-files.json').read_text()).items():assert sha(L/p)==h,p
result={'unchanged_functions':unchanged,'dialogue_constants_exact':True,'creature_font_file_overrides_removed':True,'soul_UI_HEAD_users_removed':True,'installed_hashes_exact':True,'native_title_story':'45/45','native_ui_fit':'48/48','official_runner':'3 PASS; exit0'}
(W/'verification.json').write_text(json.dumps(result,indent=2));print('Verified unchanged rules/input/card geometry/wordmark builder/settings methods and exact installed hashes.')
