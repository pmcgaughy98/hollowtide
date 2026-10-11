from pathlib import Path
import json,hashlib,collections
L=Path('C:/Users/pmcga/dev/hollowtide');W=Path(__file__).parent
old=json.loads(Path('D:/dev/hollowtide-launch-frames-20261010/baseline.json').read_text(encoding='utf-8'))
added=[];changed=[]
for folder in ['assets','scripts','scenes','tools']:
    for p in (L/folder).rglob('*'):
        if not p.is_file() or p.suffix in ['.uid','.import']:continue
        r=p.relative_to(L).as_posix();h=hashlib.sha256(p.read_bytes()).hexdigest()
        if r not in old:added.append(r)
        elif h!=old[r]:changed.append(r)
(W/'inventory.json').write_text(json.dumps({'added':added,'changed':changed},indent=2),encoding='utf-8')
print('ADDED ASSETS',dict(collections.Counter('/'.join(r.split('/')[:5]) for r in added if r.startswith('assets/'))))
print('NEW/CHANGED CODE',*[r for r in added+changed if r.startswith(('scripts/','scenes/','tools/'))],sep='\n')
print('NEW DIALOGUE',*[r for r in added if '/dialogue/' in r],sep='\n')
print('CHANGED ASSETS',*[r for r in changed if r.startswith('assets/')],sep='\n')
