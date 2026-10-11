from pathlib import Path
import shutil,json,hashlib
W=Path(__file__).parent
P=W/'package'
P.mkdir(exist_ok=True)
for folder in ['originals','before','after','after-live','crew','before-stale-atlas']:
    shutil.copytree(W/folder,P/folder,dirs_exist_ok=True)
for name in ['README.md','package.py','install_docs.py','rootbank.diff','protected.json','concurrent-before-install.json','image-verification.json','live-verification.json','material-check.json','riverbank_painter.gd','rootbank_detail.gd','capture.gd','after.gd','livecapture.gd','crew.gd','dungeons.gd','material.gd','run.py','prepare.py','stage_art.py','prepare_checks.py','verify_images.py','verify_live.py','install_art.py']:
    shutil.copy2(W/name,P/name)
for phase in ['stage','live']:
    dest=P/'logs'/phase;dest.mkdir(parents=True,exist_ok=True)
    for p in (W/'logs'/phase).glob('*.log'):shutil.copy2(p,dest/p.name)
manifest={p.relative_to(P).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in P.rglob('*') if p.is_file()}
(P/'manifest.json').write_text(json.dumps(manifest,indent=2))
print('Packaged',len(manifest),'evidence files.')
