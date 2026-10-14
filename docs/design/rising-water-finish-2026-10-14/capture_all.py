from pathlib import Path
import subprocess,sys
W=Path(__file__).parent;S=Path('D:/dev/hollowtide-world-refinement-20261008/project')
p=S/'scripts/dungeon/dungeon.gd';candidate=p.read_bytes()
assert candidate==(W/'dungeon.gd').read_bytes()
try:
    p.write_bytes((W/'originals/scripts/dungeon/dungeon.gd').read_bytes())
    subprocess.run([sys.executable,str(W/'run.py'),'before'],check=True)
finally:p.write_bytes(candidate)
src=(W/'before.gd').read_text(encoding='utf-8').replace('WORK+"before/"','WORK+"after/"').replace('WATER BASELINE:','WATER AFTER:')
(W/'after.gd').write_text(src,encoding='utf-8')
subprocess.run([sys.executable,str(W/'run.py'),'after'],check=True)
