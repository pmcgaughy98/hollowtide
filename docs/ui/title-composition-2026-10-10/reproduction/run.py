from pathlib import Path
import os,subprocess,sys,shutil
W=Path(__file__).parent;C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
mode=sys.argv[1]
for p in (W/'candidate').rglob('*'):
    if p.is_file():
        d=C/p.relative_to(W/'candidate');d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,d)
(W/'review').mkdir(exist_ok=True)
if mode!='import':
    source=(W/(mode+'.gd')).read_text() if (W/(mode+'.gd')).exists() else (C/'tools/debug'/(mode+'.gd')).read_text()
    source=source.replace('res://docs/world/hub-layout-2026-10-09/',W.as_posix()+'/review/')
    (C/'tools/debug'/('highbank_'+mode+'.gd')).write_text(source)
env=os.environ.copy();env['APPDATA']=str(W/'profile');(W/'profile').mkdir(exist_ok=True)
park=None
if mode=='fallback_check':
    original=C/'scripts/town/home_painter.gd';park=W/'fallback-painter.gd'
    shutil.move(str(original),str(park))
args=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(C),'--rendering-method','gl_compatibility']
args+=['--headless','--editor','--import','--quit'] if mode=='import' else ['--fixed-fps','30','--script','res://tools/debug/highbank_'+mode+'.gd']
try:
    with (W/(mode+'.log')).open('w') as f:
        p=subprocess.Popen(args,env=env,stdout=f,stderr=subprocess.STDOUT)
        try:code=p.wait(timeout=900 if mode=='import' else 300)
        except subprocess.TimeoutExpired:p.kill();p.wait();raise
finally:
    if park:shutil.move(str(park),str(original))
print(mode,'exit',code);raise SystemExit(code)
