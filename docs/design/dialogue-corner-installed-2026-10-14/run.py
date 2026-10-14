from pathlib import Path
import os,subprocess,sys,json,time
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');kind=sys.argv[1]
out=W/'live';out.mkdir(exist_ok=True)
env=os.environ.copy();env['APPDATA']=str(out/'profile');env['LOCALAPPDATA']=str(out/'profile')
cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(R),'--rendering-method','gl_compatibility','--audio-driver','Dummy','--fixed-fps','30','--script',str(W/(kind+'.gd')),'--','live']
log=out/(kind+'.log');assert not log.exists(),'Keep earlier results; choose a fresh output folder.'
with log.open('w',encoding='utf-8') as f:
    p=subprocess.Popen(cmd,stdout=f,stderr=subprocess.STDOUT,env=env,creationflags=subprocess.CREATE_NO_WINDOW)
    (out/(kind+'-process.json')).write_text(json.dumps({'pid':p.pid,'command':cmd},indent=2),encoding='utf-8')
    deadline=time.time()+240
    while p.poll() is None:
        if 'SCRIPT ERROR' in log.read_text(encoding='utf-8',errors='replace') or time.time()>deadline:p.kill();p.wait();break
        time.sleep(.5)
print(log.read_text(encoding='utf-8',errors='replace'));print('EXIT',p.returncode);sys.exit(0 if p.returncode==0 else 1)
