from pathlib import Path
import os,subprocess,sys,shutil
W=Path(__file__).parent; C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
mode=sys.argv[1]
for p in (W/'candidate').rglob('*'):
    if p.is_file():
        d=C/p.relative_to(W/'candidate');d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,d)
args=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(C),'--rendering-method','gl_compatibility']
if mode=='import': args+=['--headless','--editor','--import','--quit']
else:
    source=(W/(mode+'.gd')).read_text() if (W/(mode+'.gd')).exists() else (W/'fallback_art_check.gd').read_text() if mode=='fallback_painter_check' else (C/'tools/debug'/(mode+'.gd')).read_text()
    source=source.replace('res://docs/world/hub-layout-2026-10-09/',W.as_posix()+'/review/')
    (C/'tools/debug'/('town_finish_'+mode+'.gd')).write_text(source)
    args+=['--fixed-fps','30','--script','res://tools/debug/town_finish_'+mode+'.gd']
env=os.environ.copy();env['APPDATA']=str(W/'profile')
park=None
parked_art=[]
if mode=='fallback_check':
    park=W/'parked_exteriors.gd';shutil.move(str(C/'scripts/town/building_exteriors.gd'),str(park))
if mode=='fallback_art_check':
    for suffix in ['.png','.png.import']:
        target=C/('assets/sprites/world/storage_2026_10_10/storage_native'+suffix)
        if target.exists():
            saved=W/('parked_storage'+suffix);shutil.move(str(target),str(saved));parked_art.append((saved,target))
if mode=='fallback_painter_check':
    park=W/'parked_storage_painter.gd';shutil.move(str(C/'scripts/town/storage_painter.gd'),str(park))
try:
    with (W/(mode+'.log')).open('w') as f:
        result=subprocess.run(args,env=env,stdout=f,stderr=subprocess.STDOUT,timeout=900 if mode=='import' else 240)
finally:
    if park: shutil.move(str(park),str(C/('scripts/town/storage_painter.gd' if mode=='fallback_painter_check' else 'scripts/town/building_exteriors.gd')))
    for saved,target in parked_art:shutil.move(str(saved),str(target))
print(mode,'exit',result.returncode)
print((W/(mode+'.log')).read_text()[-4500:])
raise SystemExit(result.returncode)
