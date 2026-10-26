from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
baseline=json.loads((W/'protected-before.json').read_text(encoding='utf-8'))
changed=[p for p,h in baseline.items() if not (L/p).is_file() or sha(L/p)!=h]
assert not changed,changed
edits={
    'scripts/main_menu.gd': [('Vector2(700, 254), 410)', 'Vector2(700, 120), 410)')],
    'scripts/creature_opening.gd': [
        ('_options_panel.position=Vector2(666,180)', '_options_panel.position=Vector2(666,120)'),
        ('_quit_panel.position=Vector2(666,312)\n\t_quit_panel.custom_minimum_size.x=442', '_quit_panel.custom_minimum_size.x=442\n\t_quit_panel.position=Vector2(minf(666.0,1136.0-_quit_panel.get_combined_minimum_size().x),312)'),
        ('_panel("HowToPlay",Vector2(430,168),678)', '_panel("HowToPlay",Vector2(430,120),678)')]
}
installed={}
for rel,pairs in edits.items():
    raw=(L/rel).read_bytes();nl=b'\r\n' if b'\r\n' in raw else b'\n'
    for old,new in pairs:
        a=old.encode().replace(b'\n',nl);b=new.encode().replace(b'\n',nl)
        assert raw.count(a)==1,(rel,old)
        raw=raw.replace(a,b)
    out=W/'prepared'/rel;out.parent.mkdir(parents=True,exist_ok=True);out.write_bytes(raw)
    assert sha(L/rel)==baseline[rel]
    shutil.copy2(out,L/rel)
    installed[rel]=sha(L/rel)
(W/'installed-files.json').write_text(json.dumps(installed,indent=2),encoding='utf-8')
print('Installed only the two title scripts; four panel placements adjusted, original newlines preserved.')
