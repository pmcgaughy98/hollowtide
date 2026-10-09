from pathlib import Path
import os, subprocess, sys

root = Path('D:/dev/hollowtide-opening-20261008')
env = os.environ.copy()
env['APPDATA'] = str(root/'profile')
(root/'profile').mkdir(exist_ok=True)
engine = 'C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe'
mode = sys.argv[1]
tag = '-'.join(sys.argv[1:])
args = [engine, '--path', str(root/'project'), '--rendering-method', 'gl_compatibility', '--log-file', str(root/(tag+'-runtime.log'))]
if mode == 'import': args += ['--headless','--editor','--import']
elif mode == 'baseline': args += ['--fixed-fps','60','--script','res://tools/debug/opening_baseline.gd']
elif mode == 'portraits': args += ['--fixed-fps','60','--script','res://tools/debug/starter_portrait_preview.gd']
elif mode == 'autostart': args += ['--fixed-fps','60','--script','res://tools/debug/opening_launch_check.gd','--']+sys.argv[2:]
elif mode == 'original-entry': args += ['--fixed-fps','60','--script','res://tools/debug/original_menu_entry_check.gd']
elif mode == 'launch': args += ['--fixed-fps','60','--quit-after','210']
else: args += ['--fixed-fps','60','--script','res://tools/debug/opening_flow_check.gd','--']+sys.argv[2:]
with (root/(tag+'-output.log')).open('w') as log:
    result = subprocess.run(args, env=env, stdout=log, stderr=subprocess.STDOUT)
print(tag, 'exit', result.returncode)
raise SystemExit(result.returncode)
