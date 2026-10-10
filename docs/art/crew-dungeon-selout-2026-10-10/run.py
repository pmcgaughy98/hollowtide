from pathlib import Path
import os,subprocess,sys
W=Path(__file__).parent;C=Path('D:/dev/hollowtide-world-refinement-20261008/project');mode=sys.argv[1]
env=os.environ.copy();env['APPDATA']=str(W/'profile')
args=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(C),'--rendering-method','gl_compatibility']
args+=['--headless','--editor','--import','--quit'] if mode=='import' else ['--fixed-fps','30','--script',str(W/(mode+'.gd'))]
with (W/(mode+'.log')).open('w') as f:r=subprocess.run(args,env=env,stdout=f,stderr=subprocess.STDOUT,timeout=240,creationflags=subprocess.CREATE_NO_WINDOW)
print(mode,'exit',r.returncode);print((W/(mode+'.log')).read_text()[-5000:]);raise SystemExit(r.returncode)
