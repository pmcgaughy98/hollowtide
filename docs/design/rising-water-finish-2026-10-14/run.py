from pathlib import Path
import os,subprocess,sys,time,json
W=Path(__file__).parent;mode=sys.argv[1];live='--live' in sys.argv
R=Path('C:/Users/pmcga/dev/hollowtide') if live else Path('D:/dev/hollowtide-world-refinement-20261008/project')
phase='live' if live else 'stage';out=W/phase;out.mkdir(exist_ok=True)
env=os.environ.copy();env['APPDATA']=str(out/'profile');env['LOCALAPPDATA']=str(out/'profile')
cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(R),'--rendering-method','gl_compatibility','--audio-driver','Dummy','--fixed-fps','30','--script',str(W/(mode+'.gd')),'--',phase]
log=out/(mode+'.log')
if log.exists():log.rename(out/(mode+'-previous-'+str(int(time.time()))+'.log'))
with log.open('w',encoding='utf-8') as f:
    p=subprocess.Popen(cmd,stdout=f,stderr=subprocess.STDOUT,env=env,creationflags=subprocess.CREATE_NO_WINDOW)
    (out/(mode+'-process.json')).write_text(json.dumps({'pid':p.pid,'command':cmd}))
    deadline=time.time()+300
    while p.poll() is None:
        text=log.read_text(encoding='utf-8',errors='replace')
        if 'SCRIPT ERROR' in text or 'Parse Error' in text or time.time()>deadline:p.kill();p.wait();break
        time.sleep(0.5)
print(log.read_text(encoding='utf-8',errors='replace')[-5000:]);print('EXIT',p.returncode);sys.exit(0 if p.returncode==0 else 1)
