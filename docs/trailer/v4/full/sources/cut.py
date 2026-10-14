from pathlib import Path
import subprocess,os,sys,json,time
W=Path(__file__).parent;take=sys.argv[1] if len(sys.argv)>1 else 'take2';assert take in ['take1','take2','take3']
out=W/(sys.argv[2] if len(sys.argv)>2 else 'delivery');out.mkdir(exist_ok=True)
log=out/'cut.log';assert not log.exists(),'Preserve earlier edit log/output.'
env=os.environ.copy();env['HT_PITCH_ROOT']='C:/Users/pmcga/dev/hollowtide';env['HT_PITCH_OUT']=str(out);env['HT_PITCH_RAW']=str(W/take/'raw.avi');env['HT_PITCH_MARKERS']=str(W/take/'shot-markers.json');env['PYTHONUNBUFFERED']='1'
cmd=[sys.executable,str(W/'prepared/tools/trailer/cut_pitch_v4.py')]
with log.open('w',encoding='utf-8') as f:
    p=subprocess.Popen(cmd,stdout=f,stderr=subprocess.STDOUT,env=env,creationflags=subprocess.CREATE_NO_WINDOW)
    (out/'process.json').write_text(json.dumps({'pid':p.pid,'command':cmd,'capture_take':take},indent=2),encoding='utf-8')
    try:code=p.wait(timeout=600)
    except subprocess.TimeoutExpired:p.kill();p.wait();raise
print(log.read_text(encoding='utf-8',errors='replace')[-2500:]);print('EXIT',code);sys.exit(0 if code==0 else 1)
