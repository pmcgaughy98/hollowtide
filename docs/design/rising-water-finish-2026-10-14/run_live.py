from pathlib import Path
import subprocess,sys
W=Path(__file__).parent
assert (W/'installed-verification.json').exists(),'Install must complete before any live verification.'
for mode in ['resume','logic','livecapture']:
    subprocess.run([sys.executable,str(W/'run.py'),mode,'--live'],check=True)
