from pathlib import Path
import hashlib,json,shutil,re,sys
W=Path(__file__).parent;C=Path('C:/Users/pmcga/dev/hollowtide')
records=json.loads((W/'manifest.json').read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
changed=[r['path'] for r in records if sha(C/r['path'])!=r['before']]
assert not changed,'Concurrent PNG changes; rebase before installing: '+str(changed)
print('All 1224 live PNGs still match the fresh snapshots.')
if '--check' in sys.argv:raise SystemExit(0)
assert 'CREW SELOUT 37/37 PASS' in (W/'verify.log').read_text(), 'Complete native staging check first.'
archive=C/'docs/art/crew-selout-2026-10-11'
assert not archive.exists(),'Preserve existing archive; inspect before rerun.'
# Preflight every derived import before modifying any live PNG.
planned_imports=[]
for r in records:
    if not r['path'].startswith('assets/'):continue
    rel=r['path']+'.import';live_meta=C/rel;generated=W/'import-project'/rel
    gm=generated.read_text()
    ctex=re.search(r'path="res://([^"\n]+\.ctex)"',gm).group(1)
    if live_meta.exists():
        lm=live_meta.read_text()
        assert lm.split('[params]')[1]==gm.split('[params]')[1],r['path']
        assert re.search(r'path="res://([^"\n]+\.ctex)"',lm).group(1)==ctex
    else:planned_imports.append(rel)
    planned_imports.extend([ctex,ctex[:-5]+'.md5'])
protected={}
for folder in ['scripts','scenes','resources','data','dialogue','addons']:
    root=C/folder
    if root.exists():
        for p in root.rglob('*'):
            if p.is_file():protected[p.relative_to(C).as_posix()]=sha(p)
protected['project.godot']=sha(C/'project.godot')
(W/'protected-install-baseline.json').write_text(json.dumps(protected,indent=2))
for r in records:
    assert sha(C/r['path'])==r['before'],'Source changed after preflight: '+r['path']
    dst=archive/'originals'/r['path'];dst.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(W/'originals'/r['path'],dst)
    assert sha(dst)==r['before']
    shutil.copy2(W/'prepared'/r['path'],C/r['path'])
# Refresh only these derived caches so a native live run reads the installed PNGs.
# The live importer metadata and all project/plugin settings remain exact.
for rel in planned_imports:
    src=W/'import-project'/rel;dst=C/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst)
assert all(sha(C/r['path'])==r['after'] for r in records)
concurrent=[p for p,s in protected.items() if sha(C/p)!=s]
(W/'install-audit.json').write_text(json.dumps({'installed_pngs':len(records),'originals_verified':len(records),'protected_files':len(protected),'concurrent_nonowned_changes':concurrent,'all_installed_hashes_exact':True},indent=2))
print('Installed 1224 PNGs; originals verified; protected files',len(protected),'concurrent changes',concurrent)
