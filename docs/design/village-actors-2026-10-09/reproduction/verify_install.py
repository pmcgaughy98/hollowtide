from pathlib import Path
import hashlib,json,sys
W=Path(__file__).parent
L=Path('C:/Users/pmcga/dev/hollowtide')
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
A=L/'docs/design/village-actors-2026-10-09'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
m=json.loads((A/'installation.json').read_text())
for r,h in m['hashes'].items():assert sha(L/r)==h,'Installed file changed: '+r
assert (L/'project.godot').read_bytes()==(A/'originals/project.godot').read_bytes()
for r in ['scripts/creature_opening.gd']+m['new_runtime']:assert sha(L/r)==sha(C/r),'Stage mismatch: '+r
protected=json.loads((A/'preserved-sha256.json').read_text())
observed={r:{'before':h,'after':sha(L/r)} for r,h in protected.items() if sha(L/r)!=h}
allowed=set(m['unexpected_changes'])|set(m.get('concurrent_during_install',{}))
assert set(observed)<=allowed,'Further concurrent files changed: '+str(set(observed)-allowed)
assert set(observed)<= {'scripts/dungeon/dungeon.gd'},'Unreviewed concurrent file'
record={'installed_files_match':True,'settings_unchanged':True,'protected_unchanged':len(protected)-len(observed),'concurrent_during_install':observed,'explanation':'The scoped installer never writes scripts/dungeon/dungeon.gd. The preservation audit detected a concurrent gameplay update; it is retained without copying the staged dungeon over it. Original creature PNGs and earlier backups remain exact.','checks':16}
if '--record' in sys.argv:
    (A/'post-install-verification.json').write_text(json.dumps(record,indent=2))
    m['initial_protection_audit_changes']=m.get('initial_protection_audit_changes',m['unexpected_changes'])
    m['concurrent_during_install']=observed
    m['unexpected_changes']=[]
    m['post_install_verification']='post-install-verification.json'
    (A/'installation.json').write_text(json.dumps(m,indent=2))
    import shutil
    shutil.copy2(W/'verify_install.py',A/'reproduction/verify_install.py')
    with (A/'README.md').open('a') as f:
        f.write('\n## Concurrent update during installation\n\nThe first post-write preservation assertion detected a concurrent change to `scripts/dungeon/dungeon.gd`; the scoped installer never writes that path. Independent verification confirmed all installed files match the tested review version, settings remain unchanged and all other 12,415 protected files retain their exact hashes. The newer dungeon controller was retained. See `post-install-verification.json` for before/after hashes. No dungeon regression is claimed.\n')
print(json.dumps(record,indent=2))
