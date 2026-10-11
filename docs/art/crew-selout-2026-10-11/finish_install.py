from pathlib import Path
import hashlib,json,shutil,re
W=Path(__file__).parent;C=Path('C:/Users/pmcga/dev/hollowtide');archive=C/'docs/art/crew-selout-2026-10-11'
records=json.loads((W/'manifest.json').read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert all(sha(C/r['path'])==r['after'] for r in records),'Installed source changed concurrently; inspect before continuing.'
assert all(sha(archive/'originals'/r['path'])==r['before'] for r in records)
protected={}
for folder in ['scripts','scenes','resources','data','dialogue','addons']:
    root=C/folder
    if root.exists():
        for p in root.rglob('*'):
            if p.is_file():protected[p.relative_to(C).as_posix()]=sha(p)
protected['project.godot']=sha(C/'project.godot')
(W/'protected-cache-baseline.json').write_text(json.dumps(protected,indent=2))
planned=[];new_metadata=[]
for r in records:
    if not r['path'].startswith('assets/'):continue
    meta_rel=r['path']+'.import';live_meta=C/meta_rel;generated=W/'import-project'/meta_rel
    gm=generated.read_text()
    if live_meta.exists():
        lm=live_meta.read_text()
        assert lm.split('[params]')[1]==gm.split('[params]')[1],r['path']
        assert re.search(r'path="res://([^"\n]+\.ctex)"',lm).group(1)==re.search(r'path="res://([^"\n]+\.ctex)"',gm).group(1)
    else:new_metadata.append(meta_rel);planned.append(meta_rel)
    ctex=re.search(r'path="res://([^"\n]+\.ctex)"',gm).group(1)
    planned.extend([ctex,ctex[:-5]+'.md5'])
for rel in planned:
    src=W/'import-project'/rel;assert src.exists(),rel
    dst=C/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst)
assert all(sha(C/r['path'])==r['after'] for r in records)
concurrent=[p for p,s in protected.items() if sha(C/p)!=s]
assert not concurrent,concurrent
(W/'install-audit.json').write_text(json.dumps({'installed_pngs':len(records),'originals_verified':len(records),'protected_files_during_cache_install':len(protected),'protected_changes':concurrent,'all_installed_hashes_exact':True,'new_import_metadata':new_metadata,'existing_import_settings_preserved':True},indent=2))
print('Installed PNGs/originals exact. Created',len(new_metadata),'missing native import metadata files; existing settings preserved. Protected code/settings exact:',len(protected))
