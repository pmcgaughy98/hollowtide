from pathlib import Path
import subprocess,sys
W=Path(__file__).parent
names=['waking_check','journey_check','soul_check','starward_check','starward_team_check','portrait_scene_check','approach_check','town_loop_check','art_check','selout_check','dungeons_check','town_walk_check']
for name in names:
 r=subprocess.run([sys.executable,str(W/'run.py'),name,'--live'],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,encoding='utf-8',errors='replace',timeout=260)
 log=(W/f'live-{name}.log').read_text(encoding='utf-8',errors='replace')
 lines=[line for line in log.splitlines() if any(word in line for word in ['PASS','RESULT:','DUNGEONS:'])]
 print(name,lines[-1:] or ['no result'],flush=True)
 if r.returncode or any(word in log for word in ['SCRIPT ERROR:','ERROR:','FAIL','WRONG','leaked']):
  print(log[-5000:],flush=True);raise SystemExit(1)
print('FINAL LIVE ALL PASS',flush=True)
