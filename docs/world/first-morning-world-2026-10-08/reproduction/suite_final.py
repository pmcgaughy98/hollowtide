from pathlib import Path
import subprocess,sys
root=Path(__file__).parent
commands=[['import'],['check','male','kithflare'],['check','female','tallowroot'],['check','male','rimefin'],['navigation'],['relay']]
for args in commands:
    subprocess.run([sys.executable,str(root/'run.py')]+args,check=True)
subprocess.run([sys.executable,'D:/dev/hollowtide-galeshear-wings-20261008/run_art.py','check'],check=True)
print('Final world, opening, navigation, practice and Galeshear checks complete')
