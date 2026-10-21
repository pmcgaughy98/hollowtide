from pathlib import Path
import difflib,shutil
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');p=R/'scripts/main_menu_art_preview.gd'
b=p.read_bytes();old=b'(UI.font("display") as FontFile).duplicate()';new=b'(load(UI.TYPE["display"]["file"]) as FontFile).duplicate()'
assert b.count(old)==1;p.write_bytes(b.replace(old,new,1))
for n in ['summer-scenes.log']:
    if (W/n).exists():shutil.copy2(W/n,W/('first-attempt-'+n))
if (W/'captures').exists():shutil.copytree(W/'captures',W/'first-attempt-captures')
original=(W/'original-main_menu_art_preview.gd').read_bytes()
(W/'fix.diff').write_text(''.join(difflib.unified_diff(original.decode().splitlines(True),p.read_text(encoding='utf-8').splitlines(True),fromfile='scripts/main_menu_art_preview.gd (before)',tofile='scripts/main_menu_art_preview.gd (after)')),encoding='utf-8')
print('Use shared display role source FontFile; the wordmark keeps its existing native-pixel renderer.')
