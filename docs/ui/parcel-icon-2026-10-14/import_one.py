from pathlib import Path
import os,subprocess,shutil
W=Path(__file__).parent;S=Path('D:/dev/hollowtide-world-refinement-20261008/project');P=W/'import-project'
dest=P/'assets/sprites/ui/item';dest.mkdir(parents=True,exist_ok=True)
shutil.copy2(W/'parcel.png',dest/'parcel.png')
shutil.copy2(S/'assets/sprites/ui/item/parcel.png.import',dest/'parcel.png.import')
(P/'project.godot').write_text('config_version=5\n\n[application]\nconfig/name="ParcelImportFixture"\n\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n')
env=os.environ.copy();env['APPDATA']=str(W/'import-profile');env['LOCALAPPDATA']=str(W/'import-profile')
cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--headless','--path',str(P),'--editor','--import']
with (W/'import-one.log').open('w',encoding='utf-8') as f:
    p=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,env=env,creationflags=subprocess.CREATE_NO_WINDOW,timeout=60)
log=(W/'import-one.log').read_text();print(log[-1800:]);assert p.returncode==0 and 'SCRIPT ERROR' not in log
print('Native one-asset import ready. Cache installation is a separate guarded step.')
