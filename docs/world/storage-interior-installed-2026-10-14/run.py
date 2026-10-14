from pathlib import Path
import os,subprocess,sys,json,time
W=Path(__file__).parent;kind=sys.argv[1];phase='live' if '--live' in sys.argv else 'stage'
R=Path('C:/Users/pmcga/dev/hollowtide') if phase=='live' else Path('D:/dev/hollowtide-world-refinement-20261008/project')
out=W/phase/kind;out.mkdir(parents=True,exist_ok=True);log=out/'godot.log'
if log.exists():log.rename(out/('previous-'+str(int(time.time()))+'.log'))
env=os.environ.copy();env['APPDATA']=str(out/'profile');env['LOCALAPPDATA']=str(out/'profile')
cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(R),'--rendering-method','gl_compatibility','--audio-driver','Dummy','--fixed-fps','30','--script',str(W/'checks'/(kind+'.gd')),'--',phase]
if '--headless' in sys.argv:cmd.insert(1,'--headless')
with log.open('w',encoding='utf-8') as f:
    p=subprocess.Popen(cmd,stdout=f,stderr=subprocess.STDOUT,env=env,creationflags=subprocess.CREATE_NO_WINDOW)
    (out/'process.json').write_text(json.dumps({'pid':p.pid,'command':cmd},indent=2),encoding='utf-8')
    deadline=time.time()+300
    while p.poll() is None:
        if 'SCRIPT ERROR' in log.read_text(encoding='utf-8',errors='replace') or time.time()>deadline:p.kill();p.wait();break
        time.sleep(.5)
text=log.read_text(encoding='utf-8',errors='replace')
complete=('all ok' in text or 'STORAGE INTEGRATION: 20/20' in text or 'STORAGE QUIT/CONTINUE: 5/5' in text)
print(text[-6500:]);print('EXIT',p.returncode,'COMPLETE',complete);sys.exit(0 if p.returncode==0 and complete else 1)
