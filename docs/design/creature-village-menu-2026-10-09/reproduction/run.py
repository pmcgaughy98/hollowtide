from pathlib import Path
import subprocess,os,sys,shutil
W=Path(__file__).parent;C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
mode=sys.argv[1];env=os.environ.copy();env['APPDATA']=str(W/'profile');(W/'profile').mkdir(exist_ok=True)
args=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(C),'--rendering-method','gl_compatibility']
if mode=='import':args+=['--headless','--editor','--import','--quit']
else:
 shutil.copy2(W/(mode+'.gd'),C/'tools/debug'/(mode+'.gd'))
 args+=['--fixed-fps','60','--script','res://tools/debug/'+mode+'.gd']
with (W/(mode+'.log')).open('w') as log:
 p=subprocess.Popen(args,env=env,stdout=log,stderr=subprocess.STDOUT)
 (W/(mode+'.pid')).write_text(str(p.pid))
 try:code=p.wait(timeout=240)
 except subprocess.TimeoutExpired:p.kill();p.wait();raise
print(mode,'exit',code);raise SystemExit(code)
