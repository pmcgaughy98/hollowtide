from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
baseline=json.loads((W/'baseline.json').read_text())
hooks={
'scripts/town/board_scene.gd':[('.apply(sprite)','.apply(sprite, false, form)')],
'scripts/ui/ui_style.gd':[('.crew_detail(tex.resource_path) > 0.0','.portrait_target(tex.resource_path)')],
'scripts/town/hub_town.gd':[
('layer.add_child(_hud)\n','layer.add_child(_hud)\n\tvar crew_portraits := preload("res://scripts/ui/crew_portrait_canvas.gd").new()\n\tcrew_portraits.name = "CrewPortraitFinish"\n\t_hud.add_child(crew_portraits)\n'),
('func _draw_hud() -> void:\n','func _draw_hud() -> void:\n\t_hud.get_node("CrewPortraitFinish").clear()\n')]}
for r,changes in hooks.items():
    raw=(L/r).read_bytes();q=W/'originals-current'/r;q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(raw)
    s=raw.decode().replace('\r\n','\n')
    for a,b in changes:assert s.count(a)==1,(r,a);s=s.replace(a,b)
    (C/r).write_bytes(s.replace('\n','\r\n').encode() if b'\r\n' in raw else s.encode())
    baseline[r]=hashlib.sha256(raw).hexdigest()
for r in ['scripts/creatures/lines.gd']:
    (C/r).parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,C/r)
(W/'install-baseline.json').write_text(json.dumps(baseline,indent=2))
print('Merged three exact hooks into fresh Claude code; retained original and latest snapshots.')
