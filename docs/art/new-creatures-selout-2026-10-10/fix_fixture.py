from pathlib import Path
p=Path(__file__).parent/'finish_check.gd';s=p.read_text()
for a,b in [('5120,1280','6144,1536'),('2560','3072'),('2568','3080'),('*160','*192'),(',160,160',',192,192'),('for y in 160','for y in 192'),('for x in 160','for x in 192'),('Image.create(320,160','Image.create(384,192'),('Vector2i(160,0)','Vector2i(192,0)'),('Rect2i(0,0,160,160)','Rect2i(0,0,192,192)')]:s=s.replace(a,b)
s=s.replace('for file in DirAccess.get_files_at(dir):','if not DirAccess.dir_exists_absolute(dir):continue\n\t\t\tfor file in DirAccess.get_files_at(dir):')
s=s.replace('if form in ["town","dungeon"]:', 'if form=="dialogue":form=paths[start+k].get_file().get_basename().get_slice("_",0)\n\t\t\tif form in ["town","dungeon"]:')
p.write_text(s)
