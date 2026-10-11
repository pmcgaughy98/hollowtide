from pathlib import Path
import json,hashlib,shutil,difflib
W=Path(__file__).parent;C=Path('C:/Users/pmcga/dev/hollowtide')
baseline=json.loads((W/'baseline.json').read_text());owned={'scripts/town/room_painter.gd','scripts/town/hall_floors_art.gd'}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
changed=[];missing=[]
for rel,h in baseline.items():
    if rel in owned:continue
    p=C/rel
    if not p.exists():missing.append(rel)
    elif sha(p)!=h:changed.append(rel)
hooks=json.loads('{}')
for rel in owned:
    expected=(W/'prepared'/rel).read_bytes()
    assert (C/rel).read_bytes()==expected,rel
    hooks[rel]={'original_sha256':sha(W/'originals'/rel),'installed_sha256':sha(C/rel)}
assert (C/'scripts/town/hall_fixtures_art.gd').read_bytes()==(W/'prepared/scripts/town/hall_fixtures_art.gd').read_bytes()
allowed_concurrent={'scripts/creature_prologue.gd','scripts/town/guild_crew.gd','scripts/town/guild_scene.gd'}
concurrent={}
for rel in changed:
    before=Path('D:/dev/hollowtide-world-refinement-20261008/project')/rel
    assert rel in allowed_concurrent and sha(before)==baseline[rel],f'Unreviewed or missing before source: {rel}'
    for phase,src in [('before',before),('after',C/rel)]:
        dst=W/'concurrent'/phase/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst)
    delta=''.join(difflib.unified_diff(before.read_text().splitlines(True),(C/rel).read_text().splitlines(True),fromfile='before/'+rel,tofile='after/'+rel))
    dst=W/'concurrent'/(Path(rel).name+'.patch');dst.write_text(delta)
    concurrent[rel]={'before_sha256':baseline[rel],'after_sha256':sha(C/rel),'patch':str(dst.relative_to(W))}
    print(delta)
report={'protected_files':len(baseline)-len(owned),'exact_protected_files':len(baseline)-len(owned)-len(changed),'changed':changed,'concurrent_changes_preserved':concurrent,'missing':missing,'owned_sources':hooks,'new_helper_sha256':sha(C/'scripts/town/hall_fixtures_art.gd'),'town_room_sha256':sha(C/'scripts/town/town_room.gd')}
(W/'audit.json').write_text(json.dumps(report,indent=2))
print(json.dumps({k:v for k,v in report.items() if k not in ['owned_sources','new_helper_sha256','town_room_sha256']},indent=2))
assert not missing and set(changed).issubset(allowed_concurrent),'Inspect concurrent changes before handoff.'
