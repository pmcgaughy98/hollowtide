from pathlib import Path
import hashlib,json,difflib
W=Path(__file__).parent;C=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
report=json.loads((W/'install-audit.json').read_text());protected=json.loads((W/'protected.json').read_text())
records=report['concurrent_changes_preserved']
if (W/'reviewed-final-concurrent.json').exists():records=json.loads((W/'reviewed-final-concurrent.json').read_text())
# The soul music edit happened between the initial hash and the staging sync.
# Recover the two-line prior version in private evidence only, accepting it solely
# if its complete SHA-256 matches that initial hash. Never write a game script.
rel='scripts/soul_prologue.gd';raw=(C/rel).read_bytes()
nl=b'\r\n' if b'\r\n' in raw else b'\n'
prior=raw.replace(b'const Music := preload("res://scripts/audio/music.gd")'+nl,b'').replace(b'\tMusic.play(get_tree(), "hollow_flute")'+nl,b'')
if hashlib.sha256(prior).hexdigest()==protected[rel]:
    dst=W/'concurrent/before'/rel;dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes(prior)
    patch=''.join(difflib.unified_diff(prior.decode().splitlines(True),raw.decode().splitlines(True),fromfile='before/'+rel,tofile='after/'+rel))
    (W/'concurrent/soul_prologue.gd.patch').write_text(patch)
    records[rel]['before_source_reconstructed_and_hash_verified']=True
    print(patch)
for rel,r in records.items():protected[rel]=r['concurrent_sha256']
changed=[rel for rel,h in protected.items() if not (C/rel).exists() or sha(C/rel)!=h]
rows=json.loads((W/'evidence/manifest.json').read_text())
assert all(sha(C/r['output'])==r['output_sha256'] for r in rows)
tool='tools/ui/build_crew_dialogue_portraits.py';assert (C/tool).read_bytes()==(W/'prepared'/tool).read_bytes()
report.update({'final_protected_changes':changed,'installed_tool_sha256':sha(C/tool),'output_hashes_exact':True,'concurrent_changes_preserved':records})
(W/'final-audit.json').write_text(json.dumps(report,indent=2))
assert not changed,'Inspect latest concurrent edits: '+str(changed)
print('Final audit:',len(protected)-len(records),'files exact since initial snapshot;',len(records),'reviewed concurrent files preserved; zero changes by the portrait install.')
