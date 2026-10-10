from pathlib import Path
import os,subprocess,sys
W=Path(__file__).parent; L=Path('C:/Users/pmcga/dev/hollowtide'); mode=sys.argv[1]
if mode!='import':
    source=(W/(mode+'.gd')).read_text() if (W/(mode+'.gd')).exists() else (L/'tools/debug'/(mode+'.gd')).read_text()
    source=source.replace('res://docs/world/hub-layout-2026-10-09/',W.as_posix()+'/review/')
    script=W/('live_'+mode+'.gd');script.write_text(source)
env=os.environ.copy();env['APPDATA']=str(W/'live-profile')
args=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(L),'--rendering-method','gl_compatibility']
args+=['--headless','--editor','--import','--quit'] if mode=='import' else ['--fixed-fps','30','--script',str(script)]
if len(sys.argv)>2 and sys.argv[2]=='verbose': args+=['--verbose']
with (W/('live_'+mode+'.log')).open('w') as f:
    result=subprocess.run(args,env=env,stdout=f,stderr=subprocess.STDOUT,timeout=900 if mode=='import' else 240,creationflags=subprocess.CREATE_NO_WINDOW)
print('Installed',mode,'exit',result.returncode)
print((W/('live_'+mode+'.log')).read_text()[-4500:])
raise SystemExit(result.returncode)
