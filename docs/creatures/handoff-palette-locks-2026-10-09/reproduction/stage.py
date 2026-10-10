from pathlib import Path
import json,shutil
W=Path(__file__).parent;C=Path('D:/dev/hollowtide-world-refinement-20261008/project');P=W/'candidate'
for r in json.loads((W/'owned.json').read_text()):
    dst=C/r;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(P/r,dst)
print('Only the five palette candidates staged for native review')
