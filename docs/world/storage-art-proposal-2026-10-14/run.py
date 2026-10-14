from pathlib import Path
import subprocess,os,sys,time,json
W=Path(__file__).parent;packaged='--packaged' in sys.argv;P=W/'package/staging' if packaged else W/'staging';mode=sys.argv[1]
env=os.environ.copy();env['APPDATA']=str(W/'review-profile');env['LOCALAPPDATA']=str(W/'review-profile')
cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(P),'--rendering-method','gl_compatibility','--audio-driver','Dummy']
if mode=='import':cmd+=['--headless','--editor','--import']
elif mode=='review':cmd+=['--fixed-fps','30','--script',str(W/'review.gd'),'--','packaged' if packaged else 'source']
log=W/(mode+('-packaged' if packaged else '')+'.log')
if log.exists():log.rename(W/(mode+'-previous-'+str(int(time.time()))+'.log'))
with log.open('w',encoding='utf-8') as f:
    p=subprocess.Popen(cmd,stdout=f,stderr=subprocess.STDOUT,env=env,creationflags=subprocess.CREATE_NO_WINDOW)
    (W/(mode+'-process.json')).write_text(json.dumps({'pid':p.pid,'command':cmd}))
    deadline=time.time()+120
    while p.poll() is None:
        text=log.read_text(encoding='utf-8',errors='replace')
        if 'SCRIPT ERROR' in text or 'Parse Error' in text or time.time()>deadline:p.kill();p.wait();break
        time.sleep(0.5)
text=log.read_text(encoding='utf-8',errors='replace');print(text[-4500:]);print('EXIT',p.returncode)
sys.exit(0 if p.returncode==0 and 'SCRIPT ERROR' not in text else 1)
