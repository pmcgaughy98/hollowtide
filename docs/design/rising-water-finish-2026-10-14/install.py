from pathlib import Path
import hashlib,json,shutil,difflib
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');P=W/'import-project'
protected=json.loads((W/'protected.json').read_text(encoding='utf-8'))
changed=[rel for rel,sha in protected.items() if hashlib.sha256((R/rel).read_bytes()).hexdigest()!=sha]
assert not changed,('Concurrent source changes; rebase first',changed)
assert json.loads((W/'stage/resume-checks.json').read_text(encoding='utf-8'))['passed']==16
assert 'WATER: all ok' in (W/'stage/logic.log').read_text(encoding='utf-8')
assert json.loads((W/'mask-verification.json').read_text(encoding='utf-8'))['layout_exact']
before=(W/'originals/scripts/dungeon/dungeon.gd').read_text(encoding='utf-8')
after=(W/'dungeon.gd').read_text(encoding='utf-8')
restored=after.replace('const RisingWaterArt := preload("res://scripts/dungeon/rising_water_art.gd")\n','',1).replace('\tif RisingWaterArt.draw(self, _floor_fx):\n\t\treturn\n','',1)
assert restored==before,'Changed production code beyond the art hook'
assert not (R/'scripts/dungeon/rising_water_art.gd').exists()
folder=Path('assets/sprites/world/rising_water_2026_10_14');assert not (R/folder).exists()
(R/folder).mkdir()
for name in ['ripples.png','shoreline.png']:shutil.copy2(W/'art'/name,R/folder/name)
for rel in json.loads((W/'imported-files.json').read_text(encoding='utf-8')):
    dest=R/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(P/rel,dest)
for rel,name in [('scripts/dungeon/dungeon.gd','dungeon.gd'),('scripts/dungeon/rising_water_art.gd','rising_water_art.gd')]:
    shutil.copy2(W/name,R/rel);assert (W/name).read_bytes()==(R/rel).read_bytes()
diff=''.join(difflib.unified_diff(before.splitlines(True),after.splitlines(True),fromfile='original/scripts/dungeon/dungeon.gd',tofile='installed/scripts/dungeon/dungeon.gd'))
diff+=''.join(difflib.unified_diff([], (W/'rising_water_art.gd').read_text(encoding='utf-8').splitlines(True),fromfile='/dev/null',tofile='installed/scripts/dungeon/rising_water_art.gd'))
(W/'changes.diff').write_text(diff,encoding='utf-8',newline='\n')
changed=[rel for rel,sha in protected.items() if hashlib.sha256((R/rel).read_bytes()).hexdigest()!=sha]
assert changed==['scripts/dungeon/dungeon.gd'],changed
(W/'installed-verification.json').write_text(json.dumps({'protected_existing_sources':len(protected),'unchanged_sources':len(protected)-1,'changed_existing_sources':changed,'all_production_code_other_than_render_hook_exact':True,'legacy_water_renderer_exact':True,'new_source_and_textures_exact':True},indent=2),encoding='utf-8')
src=(W/'after.gd').read_text(encoding='utf-8').replace('WORK+"after/"','WORK+"live-captures/"').replace('WATER AFTER:','WATER LIVE:')
(W/'livecapture.gd').write_text(src,encoding='utf-8')
print('Installed two native atlases and render helper. 822 other existing source files exact; all water logic/save code exact.')
