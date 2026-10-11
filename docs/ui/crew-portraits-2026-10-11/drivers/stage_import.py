from pathlib import Path
import os,subprocess,json,shutil,re
W=Path(__file__).parent;P=W/'import-project';S=Path('D:/dev/hollowtide-world-refinement-20261008/project')
P.mkdir(exist_ok=True)
(P/'project.godot').write_text('config_version=5\n[application]\nconfig/name="Crew portrait import"\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n[importer_defaults]\ntexture={"compress/mode":0,"detect_3d/compress_to":0,"mipmaps/generate":false,"process/fix_alpha_border":false}\n')
manifest=json.loads((W/'evidence/manifest.json').read_text())
for r in manifest:
    for root in [P,S]:
        dst=root/r['output'];dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(W/'prepared'/r['output'],dst)
tool='tools/ui/build_crew_dialogue_portraits.py';shutil.copy2(W/'prepared'/tool,S/tool)
env=os.environ.copy();env['APPDATA']=str(W/'import-profile');env['LOCALAPPDATA']=str(W/'import-local-profile')
with (W/'asset-import.log').open('w',encoding='utf-8') as f:
    result=subprocess.run(['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(P),'--headless','--editor','--import'],env=env,stdout=f,stderr=subprocess.STDOUT,timeout=180,creationflags=subprocess.CREATE_NO_WINDOW)
assert result.returncode==0
imports=[]
for r in manifest:
    rel=r['output']+'.import';meta=P/rel
    ctex=re.search(r'path="res://([^"\n]+\.ctex)"',meta.read_text()).group(1)
    for p in [rel,ctex,ctex[:-5]+'.md5']:
        dst=S/p;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(P/p,dst);imports.append(p)
(W/'imports.json').write_text(json.dumps(imports,indent=2));print('Six dialogue textures natively imported and staged, using current importer defaults.')
