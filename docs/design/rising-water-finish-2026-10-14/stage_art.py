from pathlib import Path
import shutil
W=Path(__file__).parent;S=Path('D:/dev/hollowtide-world-refinement-20261008/project')
source=(W/'originals/scripts/dungeon/dungeon.gd').read_text(encoding='utf-8')
source=source.replace('const DungeonFinish :=','const RisingWaterArt := preload("res://scripts/dungeon/rising_water_art.gd")\nconst DungeonFinish :=',1)
needle='func _draw_water() -> void:\n\tif water_rows <= 0:\n\t\treturn\n'
assert needle in source
source=source.replace(needle,needle+'\tif RisingWaterArt.draw(self, _floor_fx):\n\t\treturn\n',1)
(W/'dungeon.gd').write_text(source,encoding='utf-8')
shutil.copy2(W/'dungeon.gd',S/'scripts/dungeon/dungeon.gd')
shutil.copy2(W/'rising_water_art.gd',S/'scripts/dungeon/rising_water_art.gd')
dest=S/'assets/sprites/world/rising_water_2026_10_14';dest.mkdir(exist_ok=True)
for name in ['ripples.png','shoreline.png']:shutil.copy2(W/'art'/name,dest/name)
src=(W/'before.gd').read_text(encoding='utf-8').replace('WORK+"before/"','WORK+"after/"').replace('WATER BASELINE:','WATER AFTER:')
(W/'after.gd').write_text(src,encoding='utf-8')
print('Staged two native atlases, one drawing helper and a two-line water-render hook; old renderer retained as exact fallback.')
