from pathlib import Path
import hashlib,json,shutil,difflib
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
rel='scripts/town/town_room.gd';live=(L/rel).read_bytes();old=(W/'latest-before-integration'/rel).read_bytes()
print(''.join(difflib.unified_diff(old.decode().splitlines(),live.decode().splitlines(),fromfile='earlier Claude',tofile='current Claude',lineterm='\n')))
backup=W/'concurrent-before-integration'/rel;backup.parent.mkdir(parents=True,exist_ok=True);backup.write_bytes(live)
hook=b'\t\t_guild_desk(map)\r\n\tvar layer'
added=b'\t\t_guild_desk(map)\r\n\tif room_id in ["hall", "hall_low", "chamber", "runners"]:\r\n\t\tpreload("res://scripts/town/hall_floors_art.gd").finish(map, room_id)\r\n\tvar layer'
if b'\r\n' not in live:hook=hook.replace(b'\r\n',b'\n');added=added.replace(b'\r\n',b'\n')
assert live.count(hook)==1
(C/rel).write_bytes(live.replace(hook,added))
before=json.loads((W/'install-before-hashes.json').read_text());before[rel]=hashlib.sha256(live).hexdigest()
(W/'install-before-hashes.json').write_text(json.dumps(before,indent=2),encoding='utf-8')
print('Current live town_room preserved in staging with only two-line art hook added.')
