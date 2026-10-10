from pathlib import Path
import shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def cp(s,d):d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(s,d)
r='scripts/creature_opening.gd';cp(L/r,W/'originals'/r)
s=(L/r).read_text()
s=s.replace('const Finish = preload("res://scripts/arena/creature_finish.gd")\n','').replace('var companions: Array[Sprite2D] = []\n','')
start=s.index('func _build_characters() -> void:');end=s.index('func _build_journey_panel()',start)
s=s[:start]+'''func _build_characters() -> void:
\t# The village carries the title scene; Preston removed the foreground creatures.
\tpass

'''+s[end:]
start=s.index('\nfunc _process(delta:float) -> void:')
s=s[:start]+'\n'
p=W/'candidate'/r;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s)
for r in ['scripts/town/home_painter.gd','scripts/town/wayline_hall_painter.gd','assets/sprites/world/home_2026_10_09/home_native.png','assets/sprites/world/wayline_hall_2026_10_09/wayline_hall_native.png']:
    cp(L/r,W/'originals'/r);cp(L/r,C/r)
cp(L/'scripts/town/highbank_ground_painter.gd',C/'tools/debug/shop_ground_before.gd')
print('Staged title without foreground sprites/shadows; all original actor assets retained')
