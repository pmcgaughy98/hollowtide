from pathlib import Path
import subprocess, os, json, argparse, time
ROOT=Path('C:/Users/pmcga/dev/hollowtide')
STAGE=Path('D:/dev/hollowtide-world-refinement-20261008/project')
WORK=Path(__file__).parent
GODOT='C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe'
parser=argparse.ArgumentParser()
parser.add_argument('name')
parser.add_argument('--live',action='store_true')
parser.add_argument('--retired',action='store_true')
parser.add_argument('--verbose',action='store_true')
parser.add_argument('--parse',choices=['world_navigation_check','riverfront_quay_check'])
parser.add_argument('args',nargs='*')
a=parser.parse_args()
phase='live' if a.live else 'stage'
out=WORK/'review'/phase/a.name
out.mkdir(parents=True,exist_ok=True)
profile=out/'profile'; profile.mkdir(exist_ok=True)
env=os.environ.copy(); env['APPDATA']=str(profile); env['LOCALAPPDATA']=str(profile)
script=a.parse+'.gd' if a.parse else ('first_morning_check.gd' if a.retired else 'opening_flow_check.gd')
cmd=[GODOT,'--path',str(ROOT if a.live else STAGE),'--rendering-method','gl_compatibility','--audio-driver','Dummy','--fixed-fps','30','--script','res://tools/debug/'+script]
if a.retired or a.parse: cmd.insert(1,'--headless')
if a.verbose: cmd.insert(1,'--verbose')
if a.parse: cmd.insert(1,'--check-only')
if a.args: cmd+=['--']+a.args
start=time.time()
with (out/'godot.log').open('w',encoding='utf-8') as log:
    proc=subprocess.Popen(cmd,stdout=log,stderr=subprocess.STDOUT,env=env,creationflags=subprocess.CREATE_NO_WINDOW)
    (out/'running.json').write_text(json.dumps({'pid':proc.pid,'command':cmd},indent=2),encoding='utf-8')
    try: code=proc.wait(timeout=110)
    except subprocess.TimeoutExpired:
        proc.kill(); proc.wait(); code=124
log=(out/'godot.log').read_text(encoding='utf-8')
expected=2 if a.retired else 0
results=list(profile.rglob('checks.json'))
receipt={'command':cmd,'exit':code,'expected_exit':expected,'seconds':round(time.time()-start,2),'results':[str(p) for p in results]}
(out/'run.json').write_text(json.dumps(receipt,indent=2),encoding='utf-8')
print(json.dumps(receipt,indent=2))
print(log[-8500:])
raise SystemExit(0 if code==expected and 'SCRIPT ERROR' not in log and 'Parse Error' not in log else 1)
