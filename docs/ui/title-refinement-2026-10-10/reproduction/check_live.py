from pathlib import Path
import subprocess,sys
W=Path(__file__).parent
for name in ['title_check','menu_check','quit_title']:
    subprocess.run([sys.executable,str(W/'live_check.py'),name],check=True)
    log=(W/('live_'+name+'.log')).read_text()
    errors=[s for s in log.splitlines() if ('ERROR:' in s or 'Parse Error' in s) and 'Failed to read the root certificate store' not in s]
    assert not errors,(name,errors)
    if name=='title_check':assert 'TITLE_RESULT passes=26 failures=0' in log
    if name=='menu_check':assert 'CHECKS 51 FAILURES 0' in log
    if name=='quit_title':assert 'TITLE QUIT CONFIRMATION REACHED' in log
    print('Verified installed',name,flush=True)
