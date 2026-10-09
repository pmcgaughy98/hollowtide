from pathlib import Path
import os,subprocess,sys
root=Path(__file__).parent
stage=Path('D:/dev/hollowtide-world-refinement-20261008/project')
env=os.environ.copy();env['APPDATA']=str(root/'profile')
(root/'profile').mkdir(exist_ok=True)
mode=sys.argv[1]
args=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(stage),'--rendering-method','gl_compatibility','--log-file',str(root/(mode+'-runtime.log'))]
if mode=='convert':args+=['--headless','--script',str(root/'import_repair.gd')]
elif mode=='import':args+=['--headless','--editor','--import']
else:args+=['--fixed-fps','60','--script','res://tools/debug/galeshear_wings_check.gd']
with (root/(mode+'-output.log')).open('w') as log:
    process=subprocess.Popen(args,env=env,stdout=log,stderr=subprocess.STDOUT)
    (root/(mode+'-pid.txt')).write_text(str(process.pid))
    try: code=process.wait(timeout=180)
    except subprocess.TimeoutExpired:
        process.kill();process.wait();raise
print(mode,'exit',code)
