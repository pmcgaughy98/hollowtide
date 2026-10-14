from pathlib import Path
import shutil,json,re
W=Path(__file__).parent;P=W/'import-project';S=Path('D:/dev/hollowtide-world-refinement-20261008/project')
rel=Path('assets/sprites/ui/item/parcel.png.import')
shutil.copy2(P/rel,S/rel)
text=(P/rel).read_text();ctex=re.search('path="res://([^"]+)"',text).group(1)
for name in [ctex,ctex.replace('.ctex','.md5')]:
    shutil.copy2(P/name,S/name)
(W/'imported-files.json').write_text(json.dumps([rel.as_posix(),ctex,ctex.replace('.ctex','.md5')],indent=2))
print('Staged native Parcel texture/cache and import metadata.')
