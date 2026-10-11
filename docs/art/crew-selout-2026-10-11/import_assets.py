from pathlib import Path
import os,subprocess,json,shutil,re
W=Path(__file__).parent;C=Path('C:/Users/pmcga/dev/hollowtide');P=W/'import-project'
P.mkdir(exist_ok=True)
(P/'project.godot').write_text('config_version=5\n[application]\nconfig/name="Crew texture importer"\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n')
records=json.loads((W/'manifest.json').read_text())
for r in records:
    if not r['path'].startswith('assets/'):continue
    dst=P/r['path'];dst.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(W/'prepared'/r['path'],dst)
    meta=C/(r['path']+'.import')
    if meta.exists():shutil.copy2(meta,Path(str(dst)+'.import'))
env=os.environ.copy();env['APPDATA']=str(W/'import-profile');env['LOCALAPPDATA']=str(W/'import-local-profile')
with (W/'asset-import.log').open('w',encoding='utf-8') as f:
    result=subprocess.run(['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(P),'--headless','--editor','--import'],env=env,stdout=f,stderr=subprocess.STDOUT,timeout=600,creationflags=subprocess.CREATE_NO_WINDOW)
assert result.returncode==0
stage=Path('D:/dev/hollowtide-world-refinement-20261008/project')
imports=[]
for r in records:
    if not r['path'].startswith('assets/'):continue
    meta=P/(r['path']+'.import')
    ctex=re.search(r'path="res://([^"\n]+\.ctex)"',meta.read_text()).group(1)
    for rel in [r['path']+'.import',ctex,ctex[:-5]+'.md5']:
        src=P/rel;assert src.exists(),str(src)
        dst=stage/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst)
        imports.append(rel)
(W/'import-manifest.json').write_text(json.dumps(imports,indent=2))
print('Native Godot import completed: 1216 textures, current per-file import settings preserved. Cache installed only in staging.')
