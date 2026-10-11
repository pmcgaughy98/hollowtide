from pathlib import Path
import hashlib,json,shutil,difflib
W=Path(__file__).parent;C=Path('C:/Users/pmcga/dev/hollowtide');S=Path('D:/dev/hollowtide-world-refinement-20261008/project')
protected=json.loads((W/'protected.json').read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
changed=[rel for rel,h in protected.items() if sha(C/rel)!=h]
records={}
for rel in changed:
    before_matches=sha(S/rel)==protected[rel]
    for phase,root in [('before' if before_matches else 'staging',S),('after',C)]:
        dst=W/'concurrent'/phase/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(root/rel,dst)
    patch=''.join(difflib.unified_diff((S/rel).read_text().splitlines(True),(C/rel).read_text().splitlines(True),fromfile='before/'+rel,tofile='after/'+rel))
    dst=W/'concurrent'/(Path(rel).name+'.patch');dst.write_text(patch);print(patch)
    records[rel]={'original_sha256':protected[rel],'concurrent_sha256':sha(C/rel),'staging_matches_original_hash':before_matches,'patch':str(dst.relative_to(W))}
(W/'concurrent.json').write_text(json.dumps(records,indent=2))
