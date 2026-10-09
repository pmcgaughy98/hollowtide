from pathlib import Path
import os, subprocess, sys
root=Path(__file__).parent
env=os.environ.copy()
env['APPDATA']=str(root/'profile')
(root/'profile').mkdir(exist_ok=True)
mode=sys.argv[1]
tag='-'.join(sys.argv[1:])
args=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(root/'project'),'--rendering-method','gl_compatibility','--log-file',str(root/(tag+'-runtime.log'))]
if mode=='import': args+=['--headless','--editor','--import']
elif mode=='relay': args+=['--fixed-fps','60','--script','res://tools/debug/world_route_regression.gd','--']+sys.argv[2:]
elif mode=='navigation': args+=['--fixed-fps','60','--script','res://tools/debug/world_navigation_check.gd']
else: args+=['--fixed-fps','60','--script','res://tools/debug/first_morning_check.gd','--']+sys.argv[1:]
with (root/(tag+'-output.log')).open('w') as log:
    result=subprocess.run(args,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=240)
print(tag,'exit',result.returncode)
raise SystemExit(result.returncode)
