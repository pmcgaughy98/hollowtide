from pathlib import Path
import subprocess,sys
W=Path(__file__).parent
live=len(sys.argv)>1 and sys.argv[1]=='live'
runner=W/('live_check.py' if live else 'run.py')
names=['menu_check','field_menu_check','hall_door_check','hub_town_check','quit_title','quit_pause']
if live:names.insert(0,'live_entrance_check')
for name in names:
    subprocess.run([sys.executable,str(runner),name],check=True)
    log=(W/(('live_' if live else '')+name+'.log')).read_text()
    errors=[s for s in log.splitlines() if ('ERROR:' in s or 'Parse Error' in s) and 'Failed to read the root certificate store' not in s]
    if name=='field_menu_check':
        # Claude's existing fixture quits before freeing its final music nodes.
        errors=[s for s in errors if 'resources still in use at exit' not in s]
        assert 'RESULT: field menu works' in log,log
    assert not errors,(name,errors)
    if name=='menu_check':assert 'CHECKS 51 FAILURES 0' in log
    if name=='live_entrance_check':assert 'ENTRANCE_RESULT passes=14 failures=0' in log
    print('Verified',name,flush=True)
