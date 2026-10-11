from pathlib import Path
import os,subprocess,sys
W=Path(__file__).parent; mode=sys.argv[1]; live='--live' in sys.argv
C=Path('C:/Users/pmcga/dev/hollowtide') if live else Path('D:/dev/hollowtide-world-refinement-20261008/project')
env=os.environ.copy();env['APPDATA']=str(W/(('live-profile-' if live else 'profile-')+mode))
args=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(C),'--rendering-method','gl_compatibility','--fixed-fps','30','--script',str(W/(mode+'.gd'))]
if '--verbose' in sys.argv:args.append('--verbose')
if '--headless' in sys.argv:args.append('--headless')
log=W/(('live-' if live else '')+mode+'.log')
with log.open('w',encoding='utf-8') as f:r=subprocess.run(args,env=env,stdout=f,stderr=subprocess.STDOUT,timeout=240,creationflags=subprocess.CREATE_NO_WINDOW)
print(mode,'exit',r.returncode);print(log.read_text(encoding='utf-8',errors='replace')[-6000:]);raise SystemExit(r.returncode)
