from pathlib import Path
import hashlib,json,shutil,difflib
W=Path(__file__).parent;C=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
report=json.loads((W/'install-audit.json').read_text());records=report['concurrent_changes_preserved']
if (W/'reviewed-final-concurrent.json').exists():records=json.loads((W/'reviewed-final-concurrent.json').read_text())
for rel,r in records.items():
    if sha(C/rel)==r['concurrent_sha256']:continue
    assert rel=='scripts/town/guild_crew.gd',f'Inspect new file: {rel}'
    old=W/'concurrent/after'/rel;assert sha(old)==r['concurrent_sha256']
    keep=W/'concurrent/versions'/r['concurrent_sha256']/rel;keep.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(old,keep)
    delta=''.join(difflib.unified_diff(old.read_text().splitlines(True),(C/rel).read_text().splitlines(True),fromfile='at-install/'+rel,tofile='after/'+rel));print(delta)
    # Snapshot only. The game source is never written.
    shutil.copy2(C/rel,old)
    (W/'concurrent'/('guild_crew-after-'+r['concurrent_sha256'][:12]+'.patch')).write_text(delta)
    if 'install_sha256' not in r:r['install_sha256']=r['concurrent_sha256']
    r['concurrent_sha256']=sha(C/rel)
(W/'reviewed-final-concurrent.json').write_text(json.dumps(records,indent=2))
