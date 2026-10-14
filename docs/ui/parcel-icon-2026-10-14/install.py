from pathlib import Path
import hashlib,json,shutil,difflib
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');P=W/'import-project'
protected=json.loads((W/'protected.json').read_text())
changed=[rel for rel,sha in protected.items() if hashlib.sha256((R/rel).read_bytes()).hexdigest()!=sha]
assert not changed,('Concurrent source changes: rebase before install',changed)
assert not (R/'assets/sprites/ui/item/parcel.png').exists()
assert not (R/'assets/sprites/ui/item/parcel.png.import').exists()
assert json.loads((W/'stage/checks.json').read_text())['passed']==20
diff=''
for rel,candidate in [('tools/ui/build_icons.py','build_icons.py'),('scripts/town/hub_town.gd','hub_town.gd')]:
    before=(W/'originals'/rel).read_text();after=(W/candidate).read_text()
    diff+=''.join(difflib.unified_diff(before.splitlines(True),after.splitlines(True),fromfile='original/'+rel,tofile='installed/'+rel))
    shutil.copy2(W/candidate,R/rel)
(W/'changes.diff').write_text(diff)
shutil.copy2(W/'parcel.png',R/'assets/sprites/ui/item/parcel.png')
for rel in json.loads((W/'imported-files.json').read_text()):
    dest=R/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(P/rel,dest)
for rel,candidate in [('tools/ui/build_icons.py','build_icons.py'),('scripts/town/hub_town.gd','hub_town.gd'),('assets/sprites/ui/item/parcel.png','parcel.png')]:assert (R/rel).read_bytes()==(W/candidate).read_bytes()
changed=[rel for rel,sha in protected.items() if hashlib.sha256((R/rel).read_bytes()).hexdigest()!=sha]
assert set(changed)=={'tools/ui/build_icons.py','scripts/town/hub_town.gd'},changed
(W/'installed-verification.json').write_text(json.dumps({'protected_existing_files':len(protected),'unchanged_existing_files':len(protected)-len(changed),'changed_owned_files':changed,'new_texture_import_and_native_cache':json.loads((W/'imported-files.json').read_text()),'installed_png_exact':True},indent=2))
print('Installed Parcel PNG/native import, recipe and delivery-only Board rendering. 809 other existing source/UI files exact.')
