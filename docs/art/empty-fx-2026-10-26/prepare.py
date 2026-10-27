from pathlib import Path
import hashlib,json,shutil,subprocess,sys
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
protected={}
for folder in ('scripts','tools','scenes','data','dialogue'):
 for p in (L/folder).rglob('*'):
  if p.is_file() and p.suffix in ('.gd','.py','.tscn','.tres','.dialogue','.json'):protected[p.relative_to(L).as_posix()]=sha(p)
for name in ('project.godot','export_presets.cfg'):protected[name]=sha(L/name)
(W/'protected-before.json').write_text(json.dumps(protected,indent=2))
(W/'git-before.txt').write_text(subprocess.run(['git','status','--short','--untracked-files=no'],cwd=L,capture_output=True,text=True).stdout)
rel='tools/arena/slice_vfx.py';p=L/rel;d=W/'originals'/rel;d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,d)
s=p.read_text()
s=s.replace('and saved as assets/sprites/arena/vfx/<name>/f00..f15.png.', 'and saved as assets/sprites/arena/vfx/<name>/f00..f15.png.\nSix source cells are truly empty. They hold the preceding painted frame (cyclic for f00)\nwithout changing the 16-frame duration; originals and all other cuts stay untouched.')
s=s.replace('for sheet in sorted(SRC.glob("*_sheet.png")):', '''# FX-01 (2026-10-26): only these source cells contain no pixels. A new nonempty\n# source cell takes precedence. Exact adjacent holds avoid a one-frame disappearance;\n# no new paint, crossfade, rearrangement or timing change. f00 follows f15 in the loop.\nEMPTY_HOLDS = {"sail_slash": {4: 3, 8: 7, 12: 11},\n               "mark_glyph": {0: 15, 12: 11, 13: 11}}\n\nfor sheet in sorted(SRC.glob("*_sheet.png")):''')
s=s.replace('        shrink(im.crop((c * cw, r * cw, (c + 1) * cw, (r + 1) * cw)), 2).save(OUT / name / f"f{i:02d}.png")', '''        cut = im.crop((c * cw, r * cw, (c + 1) * cw, (r + 1) * cw))\n        if cut.getchannel("A").getbbox() is None and i in EMPTY_HOLDS.get(name, {}):\n            held = EMPTY_HOLDS[name][i]\n            hr, hc = divmod(held, 4)\n            cut = im.crop((hc * cw, hr * cw, (hc + 1) * cw, (hr + 1) * cw))\n            if cut.getchannel("A").getbbox() is None:\n                raise ValueError(f"{name} f{i:02d}: hold source f{held:02d} is empty")\n            print(f"{name} f{i:02d}: source empty, hold f{held:02d}")\n        shrink(cut, 2).save(OUT / name / f"f{i:02d}.png")''')
assert s!=p.read_text();d=W/'prepared'/rel;d.parent.mkdir(parents=True,exist_ok=True);d.write_text(s)
# Rebuild only these two sheets in a private project-shaped directory.
fixture=W/'rebuild-fixture';(fixture/'tools/arena').mkdir(parents=True,exist_ok=True)
shutil.copy2(d,fixture/rel);shutil.copy2(L/'tools/arena/downscale.py',fixture/'tools/arena/downscale.py')
for name in ('sail_slash','mark_glyph'):
 rel=f'docs/creatures/arena-starters-2026-10-07/vfx/{name}_sheet.png';d=fixture/rel;d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,d)
r=subprocess.run([sys.executable,str(fixture/'tools/arena/slice_vfx.py')],cwd=fixture,capture_output=True,text=True);(W/'rebuild.log').write_text(r.stdout+r.stderr);assert r.returncode==0
audit=json.loads((W/'audit.json').read_text());changed={}
for row in audit:
 rel=f'assets/sprites/arena/vfx/{row["name"]}/f{row["frame"]:02d}.png';new=fixture/rel
 if sha(new)!=row['old_sha']:
  assert row['old_bbox'] is None,rel
  d=W/'prepared'/rel;d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(new,d);changed[rel]=sha(d)
assert len(changed)==6,changed
changed['tools/arena/slice_vfx.py']=sha(W/'prepared/tools/arena/slice_vfx.py')
(W/'installed-files.json').write_text(json.dumps(changed,indent=2))
print((W/'rebuild.log').read_text());print('Prepared six PNG holds and one cutter; 26 other cuts byte-exact.')
