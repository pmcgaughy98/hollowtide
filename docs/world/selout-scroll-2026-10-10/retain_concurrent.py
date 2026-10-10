from pathlib import Path
import hashlib,json,subprocess
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
paths=json.loads((W/'concurrent-before-install.json').read_text());out=W/'concurrent';out.mkdir(exist_ok=True)
for r in paths:
    dest=out/r;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes((L/r).read_bytes())
r='scripts/dungeon/dungeon.gd';p=out/r
data={r:{'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'reason':'Inspected boss/escort sizing and updated full-body ground shadow; preserved Claude edit after preinstall.'}}
(W/'accepted-post-preinstall.json').write_text(json.dumps(data,indent=2))
diff=subprocess.run(['git','diff','--no-index','--',str(C/r),str(p)],capture_output=True,text=True)
(out/'dungeon-retained.diff').write_text(diff.stdout)
print(json.dumps(data,indent=2));print(diff.stdout)
