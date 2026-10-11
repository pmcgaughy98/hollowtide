from pathlib import Path
import shutil,json,hashlib
L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project');W=Path(__file__).parent
p='scripts/arena/creature_finish.gd'
original=(L/p).read_text();backup=W/'originals'/p;backup.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/p,backup)
s=original.replace('const SHADER = preload("res://scripts/arena/creature_finish.gdshader")','const SHADER = preload("res://scripts/arena/creature_finish.gdshader")\nconst STARWARD_SHADER = preload("res://scripts/arena/starward_finish.gdshader")')
s=s.replace('var path := sprite.texture.resource_path if sprite.texture != null else ""','var path := sprite.texture.resource_path if sprite.texture != null else ""\n\t\t# Follow every facing/action and every emotion; pooled portraits restore the normal shader.\n\t\tvar starward := "/arena/starward/" in path or dialogue_form(path, "starward") or (path.is_empty() and form == "starward")\n\t\tfinish.shader = STARWARD_SHADER if starward else SHADER')
s=s.replace('1.0 if details else crew_detail(path, form))','0.55 if starward else (1.0 if details else crew_detail(path, form)))')
(C/p).write_text(s)
textures={}
for src in (L/'assets/sprites/arena/starward').rglob('*'):
 if src.is_file():
  dst=C/src.relative_to(L);dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst)
  if src.suffix=='.png':textures[src.relative_to(L).as_posix()]=hashlib.sha256(src.read_bytes()).hexdigest()
for src in (L/'assets/sprites/ui/dialogue').glob('starward*.png*'):
 shutil.copy2(src,C/src.relative_to(L))
 if src.suffix=='.png':textures[src.relative_to(L).as_posix()]=hashlib.sha256(src.read_bytes()).hexdigest()
(W/'starward-sources.json').write_text(json.dumps(textures,indent=2))
print('Starward runtime-only finish; source textures preserved:',len(textures))
