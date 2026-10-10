from pathlib import Path
import hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
pending=json.loads((W/'pending-install.json').read_text())
problems=[i['path'] for i in pending if not (L/i['path']).exists() or sha(L/i['path'])!=i['after']]
result={}
for local,rel in [(W/'archive','docs/creatures/sparkwick-material-consistency-2026-10-10'),(Path('D:/dev/hollowtide-hollow-mouth-20261010/archive'),'docs/world/hollow-mouth-finish-2026-10-10')]:
 files=[p for p in local.rglob('*') if p.is_file()]
 bad=[p.relative_to(local).as_posix() for p in files if not (L/rel/p.relative_to(local)).exists() or sha(p)!=sha(L/rel/p.relative_to(local))]
 result[rel]={'files':len(files),'mismatches':bad}
result['owned_runtime_mismatches']=problems
print(json.dumps(result,indent=2));(W/'publication.json').write_text(json.dumps(result,indent=2))
assert not problems and not any(x.get('mismatches') for x in result.values() if isinstance(x,dict))
