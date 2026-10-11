from pathlib import Path
import shutil
W=Path(__file__).parent
S=Path('D:/dev/hollowtide-world-refinement-20261008/project')
source=(W/'originals/riverbank_painter.gd').read_text()
source=source.replace('const TileArt :=', 'const RootbankDetail := preload("res://scripts/dungeon/rootbank_detail.gd")\nconst TileArt :=',1)
source=source.replace('\treturn img\n', '\treturn RootbankDetail.finish(img, data, t, seed_value)\n',1)
(W/'riverbank_painter.gd').write_text(source)
for name in ['riverbank_painter.gd','rootbank_detail.gd']:
    shutil.copy2(W/name,S/'scripts/dungeon'/name)
capture=(W/'capture.gd').read_text().replace('/before/', '/after/').replace('ROOTBANK BEFORE:', 'ROOTBANK AFTER:')
(W/'after.gd').write_text(capture)
print('Staged wall-only Rootbank finish; existing procedural paint retained.')
