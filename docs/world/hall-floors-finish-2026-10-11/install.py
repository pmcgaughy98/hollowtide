from pathlib import Path
import shutil,hashlib,json,difflib
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
P=L/'docs/world/hall-floors-finish-2026-10-11'
before=json.loads((W/'install-before-hashes.json').read_text())
for rel,digest in before.items():
    assert hashlib.sha256((L/rel).read_bytes()).hexdigest()==digest,'Claude changed '+rel+'; rebase required'
new=['scripts/town/hall_floors_art.gd']+[str(p.relative_to(C)).replace('\\','/') for p in (C/'assets/sprites/world/hall_floors_2026_10_11').glob('*.png')]
for rel in new:assert not (L/rel).exists(),'Existing file must be inspected first: '+rel
P.mkdir(parents=True,exist_ok=True)
for folder in ['originals','latest-before-integration','concurrent-before-integration','generation','before']:
    shutil.copytree(W/folder,P/folder,dirs_exist_ok=True)
for p in W.iterdir():
    if p.is_file() and p.suffix in ['.gd','.py','.txt','.json','.diff','.log','.png']:shutil.copy2(p,P/p.name)
diff=[]
for rel in before:
    old=(L/rel).read_bytes().decode('utf-8').replace('\r\n','\n')
    now=(C/rel).read_bytes().decode('utf-8').replace('\r\n','\n')
    diff.extend(difflib.unified_diff(old.splitlines(True),now.splitlines(True),fromfile='before/'+rel,tofile='after/'+rel))
(P/'presentation-hooks.diff').write_text(''.join(diff),encoding='utf-8',newline='')
manifest={}
for rel in list(before)+new:
    dst=L/rel;dst.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(C/rel,dst)
    manifest[rel]=hashlib.sha256(dst.read_bytes()).hexdigest()
(P/'installed-hashes.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print(f'Installed {len(before)} guarded presentation hooks, one new helper and {len(new)-1} new PNGs. Archive: {P}')
