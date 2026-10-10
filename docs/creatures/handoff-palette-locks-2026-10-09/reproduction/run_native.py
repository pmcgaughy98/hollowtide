from pathlib import Path
import os,sys,subprocess
W=Path(__file__).parent;C=Path('D:/dev/hollowtide-world-refinement-20261008/project');mode=sys.argv[1];label=mode+('-female' if 'female' in sys.argv else '')
env=os.environ.copy();env['APPDATA']=str(W/'profile');(W/'profile').mkdir(exist_ok=True)
args=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(C),'--rendering-method','gl_compatibility']
if mode=='import':args+=['--headless','--editor','--import','--quit']
else:
    source=(W/(mode+'.gd')).read_text() if (W/(mode+'.gd')).exists() else (C/'tools/debug'/(mode+'.gd')).read_text()
    source=source.replace('D:/dev/hollowtide-map-20261008/review/',W.as_posix()+'/relay/')
    (C/'tools/debug'/('handoff_'+mode+'.gd')).write_text(source)
    args+=['--fixed-fps','60','--script','res://tools/debug/handoff_'+mode+'.gd']
    if 'female' in sys.argv:args+=['--','female']
with (W/(label+'.log')).open('w') as f:
    p=subprocess.Popen(args,env=env,stdout=f,stderr=subprocess.STDOUT);(W/(label+'.pid')).write_text(str(p.pid))
    try:code=p.wait(timeout=1500 if mode=='import' else 300)
    except subprocess.TimeoutExpired:p.kill();p.wait();raise
print(label,'exit',code);raise SystemExit(code)
