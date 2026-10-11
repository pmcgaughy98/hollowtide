from pathlib import Path
import os,subprocess,sys,json,shutil,time
WORK=Path(__file__).parent
STAGE=Path('D:/dev/hollowtide-world-refinement-20261008/project')
ROOT=Path('C:/Users/pmcga/dev/hollowtide')
live='--live' in sys.argv
script=sys.argv[1] if len(sys.argv)>1 else 'capture'
out=WORK/'logs'/('live' if live else 'stage')
out.mkdir(parents=True,exist_ok=True)
env=os.environ.copy();env['APPDATA']=str(out/'profile');env['LOCALAPPDATA']=str(out/'profile')
if not live:shutil.copy2(WORK/(script+'.gd'),STAGE/'tools/debug'/('rootbank_'+script+'.gd'))
cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(ROOT if live else STAGE),'--rendering-method','gl_compatibility','--audio-driver','Dummy','--fixed-fps','30','--script',str(WORK/(script+'.gd')) if live else 'res://tools/debug/rootbank_'+script+'.gd']
log=out/(script+'.log')
if log.exists():shutil.copy2(log,out/(script+'-previous-'+str(int(time.time()))+'.log'))
with log.open('w',encoding='utf-8') as f:
    p=subprocess.Popen(cmd,stdout=f,stderr=subprocess.STDOUT,env=env,creationflags=subprocess.CREATE_NO_WINDOW)
    (out/(script+'-pid.json')).write_text(json.dumps({'pid':p.pid,'cmd':cmd}))
    deadline=time.time()+180
    while p.poll() is None:
        text=log.read_text(encoding='utf-8',errors='replace')
        if 'SCRIPT ERROR' in text or 'Parse Error' in text or time.time()>deadline:
            p.kill();p.wait();break
        time.sleep(0.5)
    code=p.returncode
text=(out/(script+'.log')).read_text(encoding='utf-8');print(text[-8000:]);print('EXIT',code)
sys.exit(0 if code==0 and 'SCRIPT ERROR' not in text and 'Parse Error' not in text else 1)
