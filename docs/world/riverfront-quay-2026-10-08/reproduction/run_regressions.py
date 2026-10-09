from pathlib import Path
import os,subprocess,json
W=Path(__file__).parent;C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
# Isolate output paths; keep the installed existing opening check untouched.
source=(C/'tools/debug/first_morning_check.gd').read_text()
source=source.replace('D:/dev/hollowtide-world-refinement-20261008/review/',(W/'opening').as_posix()+'/')
(C/'tools/debug/quay_opening_regression.gd').write_text(source)
env=os.environ.copy();env['APPDATA']=str(W/'regression-profile');(W/'regression-profile').mkdir(exist_ok=True)
args=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(C),'--rendering-method','gl_compatibility','--fixed-fps','60','--log-file',str(W/'opening-runtime.log'),'--script','res://tools/debug/quay_opening_regression.gd','--','female','tallowroot']
with (W/'opening-output.log').open('w') as log:
    p=subprocess.Popen(args,env=env,stdout=log,stderr=subprocess.STDOUT)
    (W/'opening-process.json').write_text(json.dumps({'pid':p.pid,'args':args}))
    try:code=p.wait(timeout=200)
    except subprocess.TimeoutExpired:p.kill();p.wait();raise
print('Opening regression exit',code);raise SystemExit(code)
