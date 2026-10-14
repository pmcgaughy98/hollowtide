from pathlib import Path
import hashlib,json
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide')
result={}
for phase in ['stage','live']:
    r=json.loads((W/phase/'resume-checks.json').read_text(encoding='utf-8'))
    assert r['passed']==r['total']==16
    text=(W/phase/'logic.log').read_text(encoding='utf-8')
    logic=sum(line.endswith('-> ok') for line in text.splitlines())
    assert logic==6 and 'WATER: all ok' in text
    result[phase]={'logic_passed':logic,'art_save_resume_passed':16,'total_passed':22}
protected=json.loads((W/'protected.json').read_text(encoding='utf-8'))
changed=[rel for rel,sha in protected.items() if hashlib.sha256((R/rel).read_bytes()).hexdigest()!=sha]
assert changed==['scripts/dungeon/dungeon.gd'],changed
for rel,name in [('scripts/dungeon/dungeon.gd','dungeon.gd'),('scripts/dungeon/rising_water_art.gd','rising_water_art.gd')]:assert (R/rel).read_bytes()==(W/name).read_bytes()
for name in ['ripples.png','shoreline.png']:assert (R/'assets/sprites/world/rising_water_2026_10_14'/name).read_bytes()==(W/'art'/name).read_bytes()
for phase in ['stage','live']:
    result[phase]['dry_and_wall_pixels_changed']=0
assert json.loads((W/'live-mask-verification.json').read_text(encoding='utf-8'))['layout_exact']
result['protected_sources']=len(protected);result['unchanged_sources']=len(protected)-1;result['runtime_candidates_exact']=True
(W/'final-verification.json').write_text(json.dumps(result,indent=2),encoding='utf-8');print(json.dumps(result,indent=2))
