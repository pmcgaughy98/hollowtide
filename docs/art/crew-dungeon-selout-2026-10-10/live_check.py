from pathlib import Path
import os,subprocess,sys
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');mode=sys.argv[1]
s=(W/(mode+'.gd')).read_text().replace(W.as_posix()+'/review/',W.as_posix()+'/review/live/')
(W/'review/live').mkdir(parents=True,exist_ok=True)
p=W/('live_'+mode+'.gd');p.write_text(s)
env=os.environ.copy();env['APPDATA']=str(W/'live-profile')
args=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(L),'--rendering-method','gl_compatibility','--fixed-fps','30','--script',str(p)]
with (W/('live_'+mode+'.log')).open('w') as f:r=subprocess.run(args,env=env,stdout=f,stderr=subprocess.STDOUT,timeout=180,creationflags=subprocess.CREATE_NO_WINDOW)
log=(W/('live_'+mode+'.log')).read_text();print('Live',mode,'exit',r.returncode);print(log[-4000:])
assert r.returncode==0 and 'SCRIPT ERROR' not in log
assert ('SEL-OUT: 22 checks, 0 failures' if mode=='selout_check' else 'DUNGEONS: all ok') in log
