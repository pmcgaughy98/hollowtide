from pathlib import Path
import hashlib,re
S=Path('D:/dev/hollowtide-world-refinement-20261008/project')
path='res://assets/sprites/ui/item/parcel.png'
template=(S/'assets/sprites/ui/item/scroll.png.import').read_text()
old=re.search(r'res://.godot/imported/scroll.png-[a-f0-9]+.ctex',template).group()
new='res://.godot/imported/parcel.png-'+hashlib.md5(path.encode()).hexdigest()+'.ctex'
template=template.replace(old,new).replace('res://assets/sprites/ui/item/scroll.png',path)
template=re.sub(r'^uid=.*\n','',template,flags=re.MULTILINE)
(S/'assets/sprites/ui/item/parcel.png.import').write_text(template)
print('Applied existing lossless item-icon import parameters; Godot assigns a new resource UID.')
