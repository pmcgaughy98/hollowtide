from pathlib import Path
import shutil,json,hashlib
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
p='scripts/town/hollow_approach.gd'
for r in ['scripts/town/hub_town.gd',p,'scenes/hollow_approach.tscn']:
 shutil.copy2(L/r,C/r)
 q=W/'originals'/r;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,q)
s=(L/p).read_text()
s=s.replace('const ENTRANCE := "res://assets/backgrounds/hollow_entrance.png"','const ENTRANCE := "res://assets/sprites/world/waking_bank_2026_10_10/entrance_native.png"\nconst EntranceFinish := preload("res://scripts/ui/hollow_entrance_finish.gd")')
s=s.replace('entrance.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS','entrance.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST')
old='\tif ResourceLoader.exists(ENTRANCE):\n\t\treturn load(ENTRANCE)\n\treturn ImageTexture.create_from_image(_stand_in())'
new='\tvar img := preload("res://scripts/ui/waking_bank.gd").detailed_image(ENTRANCE)\n\tif img != null:\n\t\tEntranceFinish.apply(entrance, img)\n\t\treturn ImageTexture.create_from_image(EntranceFinish.finished_image(img))\n\treturn ImageTexture.create_from_image(_stand_in())'
assert old in s;s=s.replace(old,new)
(C/p).write_text(s)
# The real loop now follows Claude's concurrent cinematic after the first clear.
p=W/'town_loop_check.gd';s=p.read_text()
old='\tif _scene()=="waking_riverbank.tscn":\n\t\tcurrent_scene._travel(true);await _frames(8)\n\t\tif _scene()=="hollow_entrance.tscn":\n\t\t\tcurrent_scene._enter_arch();await _frames(8)'
new='\tif _scene()=="hollow_approach.tscn":\n\t\tcurrent_scene.reduce_motion=true;current_scene.auto=true\n\t\tfor frame in 600:\n\t\t\tif _scene()=="dungeon.tscn":break\n\t\t\tif current_scene.ready_to_cross:current_scene._cross()\n\t\t\tawait _frames(1)'
assert old in s;s=s.replace(old,new);p.write_text(s)
guard=json.loads((W/'baseline.json').read_text())
guard['scripts/town/hollow_approach.gd']=hashlib.sha256((L/'scripts/town/hollow_approach.gd').read_bytes()).hexdigest()
(W/'install-baseline.json').write_text(json.dumps(guard,indent=2))
print('Town hook and Claude movement/cross/entry/fades intact; only entrance art loader/filter adapted.')
