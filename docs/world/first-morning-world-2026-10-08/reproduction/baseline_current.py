from pathlib import Path
import os,subprocess
root=Path(__file__).parent;stage=root/'project'
files=['scripts/world_journey.gd','scripts/world_area.gd','scripts/area_landscape.gd','scripts/opening_flow.gd']
pending={name:(stage/name).read_bytes() for name in files}
env=os.environ.copy();env['APPDATA']=str(root/'profile')
try:
    for name in files:(stage/name).write_bytes((root/'originals'/name).read_bytes())
    args=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(stage),'--rendering-method','gl_compatibility','--fixed-fps','60','--script','res://tools/debug/world_refinement_check.gd','--log-file',str(root/'original-world-runtime.log')]
    with (root/'original-world-output.log').open('w') as log:subprocess.run(args,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=60,check=True)
finally:
    for name,data in pending.items():(stage/name).write_bytes(data)
print('Captured original world against current dependencies; candidate code restored')
