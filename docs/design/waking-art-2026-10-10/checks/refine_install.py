from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project');P=L/'docs/design/waking-art-2026-10-10';r='scripts/arena/creature_finish.gd'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
d=json.loads((W/'install-manifest.json').read_text());assert sha(L/r)==d['files'][r]['candidate'],'Concurrent helper changed.'
backup=P/'refinement-originals'/r
if backup.exists():backup=P/'refinement-originals-2'/r
backup.parent.mkdir(parents=True,exist_ok=True);assert not backup.exists();shutil.copy2(L/r,backup)
for root in [L,P/'candidate',W/'package/candidate']:
 shutil.copy2(C/r,root/r)
d['files'][r]['candidate']=sha(L/r)
for dest in [W/'install-manifest.json',P/'manifest.json']:
 dest.write_text(json.dumps(d,indent=2),encoding='utf-8')
print('Starward also opts into existing Team headshot and breathing-preview finish; other forms unchanged.')
