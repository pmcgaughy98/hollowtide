from pathlib import Path
import subprocess,sys
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
name='hub_town_check'
(W/(name+'.gd')).write_text((L/'tools/debug'/ (name+'.gd')).read_text().replace('res://docs/world/hub-layout-2026-10-09/',W.as_posix()+'/review/'))
for name in ['hub_town_check','quit_title','quit_pause']:
    subprocess.run([sys.executable,str(W/'live_check.py'),name],check=True)
    log=(W/('live_'+name+'.log')).read_text()
    errors=[s for s in log.splitlines() if ('ERROR:' in s or 'Parse Error' in s) and 'Failed to read the root certificate store' not in s]
    assert not errors,(name,errors)
    print('Verified installed',name,flush=True)
