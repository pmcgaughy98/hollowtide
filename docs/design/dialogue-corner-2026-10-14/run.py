from pathlib import Path
import os,subprocess,sys,json,time
W=Path(__file__).parent;phase=sys.argv[1];kind=sys.argv[2] if len(sys.argv)>2 else 'flood'
R=Path('C:/Users/pmcga/dev/hollowtide') if phase=='before' else Path('D:/dev/hollowtide-world-refinement-20261008/project')
out=W/phase;out.mkdir(exist_ok=True)
env=os.environ.copy();env['APPDATA']=str(out/'profile');env['LOCALAPPDATA']=str(out/'profile')
cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(R),'--rendering-method','gl_compatibility','--audio-driver','Dummy','--fixed-fps','30','--script',str(W/(kind+'.gd')),'--',phase]
log=out/(kind+'.log')
with log.open('w',encoding='utf-8') as f:
    p=subprocess.Popen(cmd,stdout=f,stderr=subprocess.STDOUT,env=env,creationflags=subprocess.CREATE_NO_WINDOW)
    (out/(kind+'-process.json')).write_text(json.dumps({'pid':p.pid,'command':cmd},indent=2),encoding='utf-8')
    deadline=time.time()+240
    while p.poll() is None:
        if 'SCRIPT ERROR' in log.read_text(encoding='utf-8',errors='replace') or time.time()>deadline:p.kill();p.wait();break
        time.sleep(.5)
print(log.read_text(encoding='utf-8',errors='replace'));print('EXIT',p.returncode);sys.exit(0 if p.returncode==0 else 1)
