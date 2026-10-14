from pathlib import Path
import subprocess,os,json,time,sys
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');out=W/'review';out.mkdir(exist_ok=True)
env=os.environ.copy();env['APPDATA']=str(W/'profile');env['LOCALAPPDATA']=str(W/'profile');env['HT_CAPTURE_REVIEW']=str(out)
cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(R),'--rendering-method','gl_compatibility','--audio-driver','Dummy','--fixed-fps','30']
parse='--parse' in sys.argv
if parse:cmd+=['--headless','--check-only']
else:cmd+=['--write-movie',str(out/'raw.avi')]
cmd+=['--script',str(W/'prepared/tools/trailer/record_pitch_v4.gd'),'--','--storage-only']
log=out/('parse.log' if parse else 'record.log')
assert not log.exists(),'Preserve or relocate the previous recording/log before rerunning.'
with log.open('w',encoding='utf-8') as f:
    p=subprocess.Popen(cmd,stdout=f,stderr=subprocess.STDOUT,env=env,creationflags=subprocess.CREATE_NO_WINDOW)
    (out/('parse-process.json' if parse else 'record-process.json')).write_text(json.dumps({'pid':p.pid,'command':cmd},indent=2),encoding='utf-8')
    deadline=time.time()+240
    while p.poll() is None:
        text=log.read_text(encoding='utf-8',errors='replace')
        if 'SCRIPT ERROR' in text or time.time()>deadline:p.kill();p.wait();break
        time.sleep(.5)
text=log.read_text(encoding='utf-8',errors='replace');complete=parse or ('STORAGE SHOT: 12/12' in text and 'RECORDED' in text)
print(text[-6000:]);print('EXIT',p.returncode,'COMPLETE',complete);sys.exit(0 if p.returncode==0 and complete else 1)
