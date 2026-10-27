from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'protected-before.json').read_text())
for rel in ('project.godot','.gitignore'):assert sha(L/rel)==base[rel],rel+' changed, rebase first'
files={p.relative_to(W/'prepared').as_posix():p for p in (W/'prepared').rglob('*') if p.is_file() and p.name!='build_app_icon.gd'}
files['icon.png']=W/'icon.png';files['tools/ui/build_app_icon.gd']=W/'build_app_icon.gd'
for rel,p in files.items():
 if rel not in base:assert not (L/rel).exists(),rel+' already exists'
for rel,p in files.items():
 dest=L/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest)
(L/'builds/windows').mkdir(parents=True,exist_ok=True)
(W/'installed-files.json').write_text(json.dumps({rel:sha(L/rel) for rel in files},indent=2));print('Installed',len(files),'scoped files; no gameplay scripts changed.')
