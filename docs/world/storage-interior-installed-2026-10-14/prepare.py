from pathlib import Path
import shutil,re,json,hashlib
from PIL import Image,ImageDraw
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');S=Path('D:/dev/hollowtide-world-refinement-20261008/project')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
protected={}
for folder in ['scripts','scenes','data','dialogue','tools/debug','assets/sprites/ui']:
    for p in (R/folder).rglob('*'):
        if p.is_file() and p.suffix!='.pyc':
            rel=p.relative_to(R);protected[rel.as_posix()]=sha(p)
            dst=S/rel;dst.parent.mkdir(parents=True,exist_ok=True)
            if not dst.exists() or sha(p)!=sha(dst):shutil.copy2(p,dst)
for name in ['project.godot','default_bus_layout.tres']:shutil.copy2(R/name,S/name)
(W/'protected.json').write_text(json.dumps(protected,indent=2),encoding='utf-8')
sources={name:(R/name).read_text(encoding='utf-8') for name in ['scripts/town/hub_town.gd','scripts/town/town_room.gd','scripts/ui/game_pause_menu.gd','tools/debug/storage_check.gd']}
for name,text in sources.items():
    dst=W/'originals'/name;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(R/name,dst)
hub=sources['scripts/town/hub_town.gd'];room=sources['scripts/town/town_room.gd']
def function(text,name):
    m=re.search(r'^func '+name+r'\(.*?(?=\n\S|\Z)',text,re.M|re.S);assert m,name
    return m.group().rstrip()+'\n'
shared='extends RefCounted\n## One unchanged Storage panel and controls shared by the town fallback and painted interior.\nconst Storage := preload("res://scripts/town/storage.gd")\nconst UI := preload("res://scripts/ui/ui_style.gd")\n\n'
names={'storage_rows':('entries',''), 'act_store':('store','n'), 'act_store_move':('select_row','dy'), '_draw_storage':('draw','h')}
for old,(new,args) in names.items():
    f=function(hub,old);body=f[f.index('\n')+1:]
    body=body.replace('storage_rows()','entries(host)').replace('_record()','host._record()').replace('_ui_sfx(','host._ui_sfx(')
    body=re.sub(r'(?<![\w.])panel\b','host.panel',body)
    body=body.replace('var rec := host._record()', 'var rec: Dictionary = host._record()')
    header=f[:f.index('\n')].replace('func '+old+'(', 'static func '+new+'(host: Node, ' if args else 'static func '+new+'(host: Node')
    if not args:header=header.replace('host: Node)', 'host: Node)')
    shared+=header+'\n'+body+'\n'
    sig=f[:f.index('\n')]
    call='StoragePanel.'+new+'(self'+(', '+args if args else '')+')'
    wrapper=sig+'\n\t'+('return ' if old=='storage_rows' else '')+call+'\n'
    hub=hub.replace(f.rstrip(),wrapper.rstrip(),1)
hub=hub.replace('const Storage :=','const StoragePanel := preload("res://scripts/town/storage_panel.gd")\nconst Storage :=',1)
old='elif p["service"] == "storage":   # R6: open once the river road past the Warren is clear (scripts/town/storage.gd)\n\t\tpanel = _storage_panel(p)\n\t\t_sfx("door")'
new='elif p["service"] == "storage":   # The same route gate; unlocked service is now inside its painted room.\n\t\tif Storage.open(_record()):\n\t\t\tpanel = {}\n\t\t\tenter_room("storage")\n\t\telse:\n\t\t\tpanel = _storage_panel(p)\n\t\t\t_sfx("door")'
assert old in hub;hub=hub.replace(old,new,1)
room=room.replace('const Objective :=','const StoragePanel := preload("res://scripts/town/storage_panel.gd")\nconst StorageArt := preload("res://scripts/town/storage_room_art.gd")\nconst Objective :=',1)
room=room.replace('var panel := {}','var panel := {}\nvar last_sfx := ""   # same UI-sound receipt as the town Storage panel',1)
definition='''
	"storage": {"name": "Storage", "w": 17, "h": 13, "door": Vector2i(8,12), "town_door": "storage", "floor_top": 3,
		"exit_rect": Rect2i(7,12,3,1),
		"solid": [Rect2i(2,3,3,2), Rect2i(12,3,3,2), Rect2i(6,5,5,2), Rect2i(2,9,2,2), Rect2i(13,9,2,2)],
		"spots": [{"id": "store_counter", "rect": Rect2i(6,5,5,2), "name": "Storage", "service": "storage"}]},
'''
room=room.replace('const ROOMS := {','const ROOMS := {'+definition,1)
room=room.replace('y >= 2 and y <= r["h"] - 2','y >= int(r.get("floor_top", 2)) and y <= r["h"] - 2',1)
old='\t\tgrid[r["door"].y * r["w"] + r["door"].x] = 1'
new='\t\tvar exit: Rect2i = r.get("exit_rect", Rect2i(r["door"], Vector2i.ONE))\n\t\tfor y in range(exit.position.y, exit.end.y):\n\t\t\tfor x in range(exit.position.x, exit.end.x):\n\t\t\t\tgrid[y * r["w"] + x] = 1'
assert old in room;room=room.replace(old,new,1)
old='map.texture = ImageTexture.create_from_image(Painter.paint(room_id, r))'
room=room.replace(old,'map.texture = StorageArt.shell() if room_id == "storage" else ImageTexture.create_from_image(Painter.paint(room_id, r)))',1)
# Remove the extra grouping parenthesis from the explicit conditional expression.
room=room.replace('ImageTexture.create_from_image(Painter.paint(room_id, r)))','ImageTexture.create_from_image(Painter.paint(room_id, r))',1)
room=room.replace('\t_world.add_child(map)\n','\t_world.add_child(map)\n\tif room_id == "storage":\n\t\tStorageArt.finish(_world, map)\n',1)
room=room.replace('if lead["pos"] == room()["door"]:', 'if room().get("exit_rect", Rect2i(room()["door"], Vector2i.ONE)).has_point(lead["pos"]):',1)
old='\tif not panel.is_empty():\n\t\tpanel = {}\n\t\treturn {}'
new='\tif panel.get("service", "") == "storage":\n\t\tact_store(1)\n\t\treturn {}\n'+old
assert old in room;room=room.replace(old,new,1)
room=room.replace('\t\t\tpanel = s\n','\t\t\tpanel = {"name": "Storage", "service": "storage", "sel": 0, "said": ""} if s.get("service", "") == "storage" else s\n',1)
poll='''	if panel.get("service", "") == "storage":
		if _tapped(KEY_W) or _tapped(KEY_UP): act_store_move(-1)
		if _tapped(KEY_S) or _tapped(KEY_DOWN): act_store_move(1)
		if _tapped(KEY_R): act_store(-1)
'''
at='\tif _tapped(KEY_E) or _tapped(KEY_J) or _tapped(KEY_ENTER):'
assert at in room;room=room.replace(at,poll+at,1)
room=room.replace('\tif not panel.is_empty():\n\t\tvar box :=','\tif panel.get("service", "") == "storage":\n\t\tStoragePanel.draw(self, h)\n\t\treturn\n\tif not panel.is_empty():\n\t\tvar box :=',1)
room+='\n\nfunc storage_rows() -> Array:\n\treturn StoragePanel.entries(self)\n\nfunc act_store(n: int) -> void:\n\tStoragePanel.store(self, n)\n\nfunc act_store_move(dy: int) -> void:\n\tStoragePanel.select_row(self, dy)\n\n'+function(sources['scripts/town/hub_town.gd'],'_ui_sfx')
check=sources['tools/debug/storage_check.gd']
check=check.replace('then a panel that moves items','then its painted room and counter panel that move items',1)
check=check.replace('\tquit(1 if fails else 0)','\tvar music = root.get_node_or_null("HollowtideMusic")\n\tif music != null: music.queue_free()\n\tawait _frames(4)\n\tquit(1 if fails else 0)',1)
check=check.replace('\troot.add_child(town)\n','\troot.add_child(town)\n\tcurrent_scene = town\n',1)
check=check.replace('\tTeamState.start([[0, 0], [1, 0]])','\tTeamState.save_path = CHECK_PATH\n\tTeamState.erase_save()\n\tTeamState.start([[0, 0], [1, 0]])',1)
old='\tTeamState.data["beaten"] = ["mouth", "first"]\n\ttown.act_use()\n\tvar rows:'
new='''	TeamState.data["beaten"] = ["mouth", "first"]
	town.act_use()
	await _frames(8)
	town = current_scene
	town.poll_input = false
	_ok("Unlocked door enters the painted Storage room", town.get("room_id") == "storage")
	for k in 4:
		await town.act_move(Vector2i.UP)
		await _frames(1)
	town.team[0]["facing"] = "n"
	town.act_use()
	var rows:'''
assert old in check;check=check.replace(old,new,1)
pause=sources['scripts/ui/game_pause_menu.gd']
old='if host != null and host.has_method("enter_hollow"):'
new='if host != null and (host.has_method("enter_hollow") or (host.has_method("room") and host.room_id == "storage")):'
assert old in pause;pause=pause.replace(old,new,1)
made={'scripts/town/hub_town.gd':hub,'scripts/town/town_room.gd':room,'scripts/town/storage_panel.gd':shared,'scripts/ui/game_pause_menu.gd':pause,'tools/debug/storage_check.gd':check}
for rel,text in made.items():
    out=W/'prepared'/rel;out.parent.mkdir(parents=True,exist_ok=True);out.write_text(text,encoding='utf-8')
    (S/rel).write_text(text,encoding='utf-8')
for base in [W/'prepared',S]:shutil.copy2(W/'storage_room_art.gd',base/'scripts/town/storage_room_art.gd')
art=R/'docs/world/storage-art-proposal-2026-10-14/staging/art';folder=Path('assets/sprites/world/storage_interior_2026_10_14')
for name in ['shell.png']+[f'props/{n}.png' for n in ['cabinet_left','cabinet_right','counter','crates','basket','lamp']]:
    for base in [W/'prepared',S]:
        out=base/folder/name;out.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(art/name,out)
mask=Image.new('RGBA',(408,312),(0,0,0,255));d=ImageDraw.Draw(mask)
for x,y,w,h in [(24,0,360,72),(0,0,24,312),(384,0,24,312),(24,288,144,24),(240,288,144,24)]:d.rectangle((x,y,x+w-1,y+h-1),fill='white')
for base in [W/'prepared',S]:mask.save(base/folder/'shell-mask.png')
print('Prepared two shared host hooks, unchanged shared panel extraction, room contract, updated service check, eight native PNGs. Protected',len(protected),'existing files.')
