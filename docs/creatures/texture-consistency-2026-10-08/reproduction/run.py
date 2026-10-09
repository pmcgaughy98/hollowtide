from pathlib import Path
import os,subprocess,sys,json,shutil
W=Path(__file__).parent;C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
mode=sys.argv[1];src=W/(mode+'.gd');shutil.copy2(src,C/'tools/debug'/src.name)
env=os.environ.copy();env['APPDATA']=str(W/'profile');(W/'profile').mkdir(exist_ok=True)
args=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(C),'--rendering-method','gl_compatibility','--fixed-fps','60','--script','res://tools/debug/'+src.name]
with (W/(mode+'.log')).open('w') as log:
 p=subprocess.Popen(args,env=env,stdout=log,stderr=subprocess.STDOUT)
 (W/(mode+'-process.json')).write_text(json.dumps({'pid':p.pid,'args':args}))
 try:code=p.wait(timeout=180)
 except subprocess.TimeoutExpired:p.kill();p.wait();raise
print(mode,'exit',code)
raise SystemExit(code)
