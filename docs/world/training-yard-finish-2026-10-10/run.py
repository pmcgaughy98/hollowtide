from pathlib import Path
import os,subprocess,sys,shutil
W=Path(__file__).parent; C=Path('D:/dev/hollowtide-world-refinement-20261008/project');mode=sys.argv[1]
for p in (W/'candidate').rglob('*'):
    if p.is_file():
        d=C/p.relative_to(W/'candidate');d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,d)
args=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(C),'--rendering-method','gl_compatibility']
if mode=='import':args+=['--headless','--editor','--import','--quit']
else:
    source=(W/'fallback_check.gd').read_text() if mode.startswith('fallback_') else (W/(mode+'.gd')).read_text() if (W/(mode+'.gd')).exists() else (C/'tools/debug'/(mode+'.gd')).read_text()
    source=source.replace('res://docs/world/hub-layout-2026-10-09/',W.as_posix()+'/review/').replace('res://docs/ui/ui-tour-2026-10-10/',W.as_posix()+'/review/')
    script=W/('review_'+mode+'.gd');script.write_text(source)
    args+=['--fixed-fps','30','--script',str(script)]
env=os.environ.copy();env['APPDATA']=str(W/'profile')
parked=[]
if mode=='fallback_art':
    targets=['assets/sprites/world/training_yard_2026_10_10/yard_native.png','assets/sprites/world/training_yard_2026_10_10/yard_native.png.import']
elif mode=='fallback_painter': targets=['scripts/town/training_yard_painter.gd']
else: targets=[]
for r in targets:
    p=C/r
    if p.exists():
        saved=W/('parked_'+p.name);shutil.move(p,saved);parked.append((saved,p))
try:
    with (W/(mode+'.log')).open('w') as f:
        result=subprocess.run(args,env=env,stdout=f,stderr=subprocess.STDOUT,timeout=900 if mode=='import' else 240,creationflags=subprocess.CREATE_NO_WINDOW)
finally:
    for saved,p in parked:shutil.move(saved,p)
print(mode,'exit',result.returncode);print((W/(mode+'.log')).read_text()[-3500:]);raise SystemExit(result.returncode)


