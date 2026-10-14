from pathlib import Path
import os,subprocess,json,time,sys
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide')
take=sys.argv[sys.argv.index('--take')+1] if '--take' in sys.argv else 'take1'
assert take in ['take1','take2','take3']
out=W/take;out.mkdir(exist_ok=True)
env=os.environ.copy();env['APPDATA']=str(out/'profile');env['LOCALAPPDATA']=str(out/'profile');env['HT_CAPTURE_REVIEW']=str(out)
parse='--parse' in sys.argv
cmd=['C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe','--path',str(R),'--rendering-method','gl_compatibility','--audio-driver','Dummy','--fixed-fps','30']
cmd+=['--headless','--check-only'] if parse else ['--write-movie',str(out/'raw.avi')]
cmd+=['--script',str(W/'prepared/tools/trailer/record_pitch_v4.gd')]
log=out/('parse.log' if parse else 'record.log');assert not log.exists(),'Preserve earlier take/log.'
if not parse:
    import shutil
    shutil.copy2(W/'prepared/tools/trailer/record_pitch_v4.gd',out/'recorded-script.gd')
with log.open('w',encoding='utf-8') as f:
    p=subprocess.Popen(cmd,stdout=f,stderr=subprocess.STDOUT,env=env,creationflags=subprocess.CREATE_NO_WINDOW)
    (out/('parse-process.json' if parse else 'process.json')).write_text(json.dumps({'pid':p.pid,'command':cmd},indent=2),encoding='utf-8')
    deadline=time.time()+600
    while p.poll() is None:
        text=log.read_text(encoding='utf-8',errors='replace')
        if 'SCRIPT ERROR' in text or time.time()>deadline:p.kill();p.wait();break
        time.sleep(.5)
text=log.read_text(encoding='utf-8',errors='replace');complete=parse or ('CAPTURE TOTAL:' in text and 'RECORDED' in text and 'FAIL' not in text)
print(text[-9000:]);print('EXIT',p.returncode,'COMPLETE',complete);sys.exit(0 if p.returncode==0 and complete else 1)
