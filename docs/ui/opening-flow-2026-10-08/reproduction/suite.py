from pathlib import Path
import subprocess
import sys

root = Path(__file__).parent
cases = [('Male', 0, 'keyboard'), ('Male', 1, 'mouse'), ('Male', 2, 'pad'),
         ('Female', 0, 'pad'), ('Female', 1, 'keyboard'), ('Female', 2, 'mouse'),
         ('Female', 2, 'reduced')]
for model, starter, mode in cases:
    result = subprocess.run([sys.executable, str(root/'run.py'), 'check', model, str(starter), mode])
    if result.returncode:
        print('STOP: check failed', model, starter, mode)
        raise SystemExit(result.returncode)
print('All opening cases passed')
