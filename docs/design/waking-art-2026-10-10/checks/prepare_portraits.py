from pathlib import Path
W=Path(__file__).parent
src=Path('D:/dev/hollowtide-new-scene-selout-20261010/portrait_scene_check.gd').read_text()
src=src.replace('D:/dev/hollowtide-new-scene-selout-20261010/','D:/dev/hollowtide-waking-art-20261010/')
src=src.replace('["gruntle:angry","starward:worried"]','["starward:normal","starward:happy","starward:joyous","starward:surprised","starward:sad","starward:worried","starward:angry","starward:determined","gruntle:angry"]')
src=src.replace('form.replace(":","_")+".png"','("starward.png" if form=="starward:normal" else form.replace(":","_")+".png")')
src=src.replace('\t\t\tif not ok:fails+=1','\t\t\tif form.begins_with("starward"):\n\t\t\t\tok=ok and layer.sprites[0].material.shader==load("res://scripts/arena/starward_finish.gdshader")\n\t\t\telse:ok=ok and layer.sprites[0].material.shader==load("res://scripts/arena/creature_finish.gdshader")\n\t\t\tif not ok:fails+=1')
(W/'portrait_scene_check.gd').write_text(src)
print('Native actual town/dungeon portraits: all eight emotions, then pooled Gruntle.')
