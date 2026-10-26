from pathlib import Path
import hashlib, importlib.util, json, os
W=Path(__file__).parent
L=Path('C:/Users/pmcga/dev/hollowtide')
os.chdir(L)
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def module(name,path):
    spec=importlib.util.spec_from_file_location(name,path)
    m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
    m.ART=L/'assets/sprites/arena'
    return m
old=module('old_portraits',W/'originals/tools/arena/build_portraits.py')
new=module('new_portraits',L/'tools/arena/build_portraits.py')
targets={'skimlet','ozbender','valvekin'}
unchanged=[]
for folder in new.ART.iterdir():
    if folder.name in targets or not (folder/'s.png').exists(): continue
    a=old.portrait(folder.name);b=new.portrait(folder.name)
    assert a.tobytes()==b.tobytes(),folder.name
    unchanged.append(folder.name)
for form in targets:
    actual=L/'assets/sprites/arena'/form/'portrait.png'
    assert new.portrait(form).tobytes()==__import__('PIL.Image',fromlist=['Image']).open(actual).convert('RGBA').tobytes()
baseline=json.loads((W/'protected-before.json').read_text(encoding='utf-8'))
installed=json.loads((W/'installed-files.json').read_text(encoding='utf-8'))
for p,h in installed.items(): assert sha(L/p)==h,p
changes=[p for p,h in baseline.items() if not (L/p).is_file() or sha(L/p)!=h]
assert changes==['tools/arena/build_portraits.py'],changes
result={'protected_before':len(baseline),'protected_unchanged':len(baseline)-1,'only_existing_file_changed':changes,'installed_files':installed,'all_other_builder_results_exact':unchanged,'reproducible_target_crops':sorted(targets),'visual_status':'Codex inspected source and crops; Preston approval pending','new_generation':False}
(W/'verification.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
print(json.dumps({'other_builder_results_exact':len(unchanged),'protected_unchanged':len(baseline)-1,'changed_existing':changes,'targets_reproduced':3}))
