from pathlib import Path
import subprocess,sys
W=Path(__file__).parent
C=Path('D:/dev/hollowtide-world-refinement-20261008/project').resolve()
F=C/'assets/sprites/world/hall_interior_2026_10_10'
for name in ['hall_native.png','chart.png']:
    source=(F/name).resolve();hold=W/(name+'.fallback-hold')
    assert source.is_relative_to(C) and not hold.exists()
    source.rename(hold)
    try:
        subprocess.run([sys.executable,str(W/'run.py'),'fallback_check','--headless'],check=True)
        (W/('fallback-'+name+'.log')).write_bytes((W/'fallback_check.log').read_bytes())
    finally:
        hold.rename(source)
print('Missing floor and missing prop each restore exact original Hall.')
