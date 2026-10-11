from pathlib import Path
import shutil,difflib
W=Path(__file__).parent;C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
for p in W.glob('*.png'):
    dst=W/'before'/p.name;dst.parent.mkdir(exist_ok=True);shutil.copy2(p,dst)
shutil.copy2(W/'hall_floors.log',W/'before'/'hall_floors.log')
hooks={
'scripts/town/room_painter.gd':(b'\treturn img\r\n\r\n\r\n# ---------------------------------------------------------------- helpers',b'\tif id in ["hall", "hall_low", "chamber", "runners"]:\r\n\t\timg = preload("res://scripts/town/hall_floors_art.gd").paint(id, img)\r\n\treturn img\r\n\r\n\r\n# ---------------------------------------------------------------- helpers'),
'scripts/town/town_room.gd':(b'\t\t_guild_desk(map)\r\n\tvar layer',b'\t\t_guild_desk(map)\r\n\tif room_id in ["hall", "hall_low", "chamber", "runners"]:\r\n\t\tpreload("res://scripts/town/hall_floors_art.gd").finish(map, room_id)\r\n\tvar layer')}
diff=[]
for rel,(old,new) in hooks.items():
    p=C/rel;t=p.read_bytes()
    if b'\r\n' not in t:old=old.replace(b'\r\n',b'\n');new=new.replace(b'\r\n',b'\n')
    assert t.count(old)==1,rel
    after=t.replace(old,new);p.write_bytes(after)
    diff.extend(difflib.unified_diff(t.decode().splitlines(True),after.decode().splitlines(True),fromfile='before/'+rel,tofile='after/'+rel))
(W/'presentation-hooks.diff').write_text(''.join(diff),encoding='utf-8')
print('Two presentation branches installed in staging only; before images retained.')
