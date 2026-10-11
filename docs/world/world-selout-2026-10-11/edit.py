from pathlib import Path
import difflib
W=Path(__file__).parent;C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
changes={
'scripts/town/highbank_painter.gd':(b'\treturn Detail.river(img)',b'\treturn preload("res://scripts/town/world_finish.gd").paint(Detail.river(img))'),
'scripts/town/hub_town.gd':(b'\tmap.texture = ImageTexture.create_from_image(paint())\r\n\t_world.add_child(map)',b'\tmap.texture = ImageTexture.create_from_image(paint())\r\n\tpreload("res://scripts/town/world_finish.gd").apply(map)\r\n\t_world.add_child(map)')}
diff=[]
for rel,(old,new) in changes.items():
    p=C/rel;t=p.read_bytes()
    if b'\r\n' not in t:old=old.replace(b'\r\n',b'\n');new=new.replace(b'\r\n',b'\n')
    assert t.count(old)==1,rel
    now=t.replace(old,new);p.write_bytes(now)
    diff.extend(difflib.unified_diff(t.decode().replace('\r\n','\n').splitlines(True),now.decode().replace('\r\n','\n').splitlines(True),fromfile='before/'+rel,tofile='after/'+rel))
(W/'presentation.diff').write_text(''.join(diff),encoding='utf-8',newline='')
print('One return hook and one map-material hook added in staging; no asset painting or generation.')
