from pathlib import Path
W=Path(__file__).parent;C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def edit(r,old,new):
    raw=(W/'originals'/r).read_bytes();crlf=b'\r\n' in raw
    s=raw.decode('utf-8').replace('\r\n','\n');assert s.count(old)==1
    s=s.replace(old,new)
    (C/r).write_bytes(s.replace('\n','\r\n').encode('utf-8') if crlf else s.encode('utf-8'))
edit('scripts/town/room_painter.gd','\t\timg = preload("res://scripts/town/home_room_art.gd").paint(img)\n','\t\timg = preload("res://scripts/town/home_room_art.gd").paint(img)\n\telif id == "hall":\n\t\timg = preload("res://scripts/town/hall_room_art.gd").paint(img)\n')
edit('scripts/town/town_room.gd','\t\tpreload("res://scripts/town/home_room_art.gd").finish(map)\n','\t\tpreload("res://scripts/town/home_room_art.gd").finish(map)\n\telif room_id == "hall":\n\t\tpreload("res://scripts/town/hall_room_art.gd").finish(map)\n')
(W/'after.flag').write_text('candidate',encoding='utf-8')
print('Integrated Hall-only art hooks; all existing room/event/controller methods retained.')
