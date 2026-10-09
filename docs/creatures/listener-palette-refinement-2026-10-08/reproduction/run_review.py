from pathlib import Path
import os, shutil, subprocess, sys, json
W=Path(__file__).parent;C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
env=os.environ.copy();env['APPDATA']=str(W/'profile');(W/'profile').mkdir(exist_ok=True)
mode=sys.argv[1]
exe='C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe'
args=[exe,'--path',str(C),'--rendering-method','gl_compatibility','--log-file',str(W/(mode+'-runtime.log'))]
if mode=='import':
    shutil.copy2(W/'listener_palette_check.gd',C/'tools/debug/listener_palette_check.gd')
    args+=['--headless','--editor','--import']
else:
    shutil.copy2(W/'listener_palette_check.gd',C/'tools/debug/listener_palette_check.gd')
    args+=['--fixed-fps','60','--script','res://tools/debug/listener_palette_check.gd','--',str(W/'native'),str(W/'originals/assets/sprites/arena')]
with (W/(mode+'-output.log')).open('w') as log:
    p=subprocess.Popen(args,env=env,stdout=log,stderr=subprocess.STDOUT)
    (W/(mode+'-process.json')).write_text(json.dumps({'pid':p.pid,'args':args}))
    try:code=p.wait(timeout=180)
    except subprocess.TimeoutExpired:p.kill();p.wait();raise
print(mode,'exit',code);raise SystemExit(code)
