from pathlib import Path
import os,subprocess,sys,json,shutil
W=Path(__file__).parent;C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
env=os.environ.copy();env['APPDATA']=str(W/'profile');(W/'profile').mkdir(exist_ok=True)
mode=sys.argv[1];args=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(C),'--rendering-method','gl_compatibility','--log-file',str(W/(mode+'-runtime.log'))]
if mode=='import':args+=['--headless','--editor','--import']
elif mode in ['before','after','direct']:
    shutil.copy2(W/'riverfront_overview.gd',C/'tools/debug/riverfront_overview.gd')
    args+=['--fixed-fps','60','--script','res://tools/debug/riverfront_overview.gd','--',str(W/mode)]
    if mode=='direct':args+=['direct']
else:
    shutil.copy2(W/'riverfront_quay_check.gd',C/'tools/debug/riverfront_quay_check.gd')
    args+=['--fixed-fps','60','--script','res://tools/debug/riverfront_quay_check.gd','--',str(W/mode),*sys.argv[2:]]
with (W/(mode+'-output.log')).open('w') as log:
    p=subprocess.Popen(args,env=env,stdout=log,stderr=subprocess.STDOUT)
    (W/(mode+'-process.json')).write_text(json.dumps({'pid':p.pid,'args':args}))
    try:code=p.wait(timeout=240)
    except subprocess.TimeoutExpired:p.kill();p.wait();raise
print(mode,'exit',code);raise SystemExit(code)
