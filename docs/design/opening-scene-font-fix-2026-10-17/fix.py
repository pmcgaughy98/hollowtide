from pathlib import Path
import shutil,hashlib,json,difflib
R=Path('C:/Users/pmcga/dev/hollowtide');W=Path(__file__).parent;rel='scripts/main_menu_art_preview.gd';p=R/rel
before=p.read_bytes();old=b'(TITLE_FONT as FontFile).duplicate()';new=b'(UI.font("display") as FontFile).duplicate()'
assert before.count(old)==1
assert not (W/'original-main_menu_art_preview.gd').exists()
shutil.copy2(p,W/'original-main_menu_art_preview.gd')
protected={}
for folder in ['scripts','scenes','data','dialogue']:
    for f in (R/folder).rglob('*'):
        if f.is_file():protected[f.relative_to(R).as_posix()]=hashlib.sha256(f.read_bytes()).hexdigest()
protected['project.godot']=hashlib.sha256((R/'project.godot').read_bytes()).hexdigest()
(W/'protected-before.json').write_text(json.dumps(protected,indent=2),encoding='utf-8')
after=before.replace(old,new,1);p.write_bytes(after)
(W/'fix.diff').write_text(''.join(difflib.unified_diff(before.decode().splitlines(True),after.decode().splitlines(True),fromfile=rel+' (before)',tofile=rel+' (after)')),encoding='utf-8')
print('Fixed one inherited font reference; preserved original bytes and protected current sources.')
