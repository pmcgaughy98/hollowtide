from pathlib import Path
import subprocess,os,json,time
r=Path(r'C:/Users/pmcga/dev/hollowtide');out=r/'docs/art/slot-candidates/road-candidate-runtime-2026-10-28';godot=r'C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe';records=[]
for case in ['old','revised']:
 private=out/'private-appdata'/case;private.mkdir(parents=True,exist_ok=True);env=dict(os.environ,APPDATA=str(private),LOCALAPPDATA=str(private),HT_HIGHBANK_V2='1',HT_CANDIDATE_CASE=case,HT_CHECK_LOGS=str(out));env.pop('HT_FORCE_PLACEHOLDERS',None)
 args=[godot,'--headless','--fixed-fps','30','--audio-driver','Dummy','--path',str(r),'--script','res://docs/art/slot-candidates/road-candidate-runtime-2026-10-28/candidate_road_check.gd','--log-file',str(out/(case+'-godot.log'))];start=time.monotonic()
 try:
  p=subprocess.run(args,cwd=r,env=env,capture_output=True,text=True,timeout=180);log=p.stdout+p.stderr;(out/(case+'-output.log')).write_text(log,encoding='utf-8');record={'case':case,'exit_code':p.returncode,'elapsed_s':round(time.monotonic()-start,2),'argv':args,'cache_verified':'CANDIDATE_CACHE_VERIFIED '+case in log,'pass':'ROAD TOWER VIEW CHECK: PASS' in log};records.append(record);print(json.dumps(record),flush=True)
  for line in log.splitlines():
   if any(s in line for s in ['CANDIDATE_CACHE','->','ROAD TOWER VIEW CHECK','SCRIPT ERROR','Parse Error','bluff:','tower:','parcel:','crew:','whole trail']):print(line,flush=True)
 except subprocess.TimeoutExpired as e:
  text=(e.stdout or b'').decode(errors='replace') if isinstance(e.stdout,bytes) else e.stdout or '';(out/(case+'-output.log')).write_text(text,encoding='utf-8');records.append({'case':case,'timeout':True});print(case,'TIMEOUT',flush=True)
(out/'runs.json').write_text(json.dumps(records,indent=2)+'\n',encoding='utf-8')
