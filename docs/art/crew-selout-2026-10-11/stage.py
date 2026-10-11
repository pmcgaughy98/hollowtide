from pathlib import Path
import json,shutil
W=Path(__file__).parent
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
for r in json.loads((W/'manifest.json').read_text()):
    if r['path'].startswith('assets/'):
        dst=C/r['path'];dst.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(W/'prepared'/r['path'],dst)
print('Staged 1216 game textures.')
