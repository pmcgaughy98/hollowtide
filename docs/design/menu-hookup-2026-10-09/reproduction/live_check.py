from pathlib import Path
import os,subprocess,sys
W=Path(__file__).parent; mode=sys.argv[1] if len(sys.argv)>1 else 'menu_check'
env=os.environ.copy(); env['APPDATA']=str(W/'live-profile'); (W/'live-profile').mkdir(exist_ok=True)
script=W/(mode+'.gd')
if not script.exists(): script=Path('C:/Users/pmcga/dev/hollowtide/tools/debug')/(mode+'.gd')
args=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path','C:/Users/pmcga/dev/hollowtide','--rendering-method','gl_compatibility','--fixed-fps','30','--script',str(script)]
with (W/('live_'+mode+'.log')).open('w') as f:
    p=subprocess.Popen(args,env=env,stdout=f,stderr=subprocess.STDOUT,creationflags=subprocess.CREATE_NO_WINDOW)
    try: code=p.wait(timeout=300)
    except subprocess.TimeoutExpired: p.kill(); p.wait(); raise
print('Installed',mode,'exit',code); raise SystemExit(code)
