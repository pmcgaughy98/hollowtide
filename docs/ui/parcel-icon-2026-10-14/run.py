from pathlib import Path
import subprocess,os,sys,json,time,re
W=Path(__file__).parent;live='--live' in sys.argv;mode=sys.argv[1]
R=Path('C:/Users/pmcga/dev/hollowtide') if live else Path('D:/dev/hollowtide-world-refinement-20261008/project')
phase='live' if live else 'stage';out=W/phase;out.mkdir(exist_ok=True)
env=os.environ.copy();env['APPDATA']=str(out/'profile');env['LOCALAPPDATA']=str(out/'profile')
cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(R),'--rendering-method','gl_compatibility','--audio-driver','Dummy']
if mode=='import':cmd+=['--headless','--editor','--import']
else:cmd+=['--fixed-fps','30','--script',str(W/(mode+'.gd')),'--',phase]
log=out/(mode+'.log')
if log.exists():log.rename(out/(mode+'-previous-'+str(int(time.time()))+'.log'))
project=R/'project.godot';original=None
if mode=='import' and not live:
    original=project.read_bytes()
    text=original.decode('utf-8-sig')
    text=re.sub(r'(\[editor_plugins\]\s*\n\s*enabled=)PackedStringArray\([^\n]*\)',r'\1PackedStringArray()',text)
    project.write_text(text,encoding='utf-8')
try:
    with log.open('w',encoding='utf-8') as f:
        p=subprocess.Popen(cmd,stdout=f,stderr=subprocess.STDOUT,env=env,creationflags=subprocess.CREATE_NO_WINDOW)
        (out/(mode+'-process.json')).write_text(json.dumps({'pid':p.pid,'command':cmd}))
        deadline=time.time()+300
        while p.poll() is None:
            output=log.read_text(encoding='utf-8',errors='replace')
            if 'SCRIPT ERROR' in output or 'Parse Error' in output or time.time()>deadline:
                p.kill();p.wait();break
            time.sleep(0.5)
finally:
    if original is not None:project.write_bytes(original)
print(log.read_text(encoding='utf-8',errors='replace')[-6500:]);print('EXIT',p.returncode)
sys.exit(0 if p.returncode==0 else 1)
