from pathlib import Path
import hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
baseline=json.loads((W/'baseline.json').read_text())
protected=json.loads((W/'preinstall-protected.json').read_text())
pending=json.loads((W/'pending-install.json').read_text())
allowed={'scripts/dungeon/dungeon.gd','scripts/ui/ui_style.gd','scripts/ui/game_pause_menu.gd','tools/debug/field_menu_check.gd'}
bad=[];concurrent={};exact=0
for r,h in protected.items():
    current=sha(L/r) if (L/r).exists() else None
    if current==h:exact+=1
    elif r in allowed: concurrent[r]={'preinstall':h,'now':current}
    else:bad.append(r)
for item in pending:
    r=item['path'];p=L/r
    if r=='docs/AI_COLLABORATION.md':
        ok=p.read_bytes().startswith((W/'candidate'/r).read_bytes())
    else:ok=sha(p)==item['after']
    if not ok:bad.append(r)
new=[]
for folder in ['scripts','assets','tools']:
    for p in (L/folder).rglob('*'):
        if p.is_file() and p.suffix not in ['.uid','.import','.pyc']:
            r=p.relative_to(L).as_posix()
            if r not in baseline and r not in [i['path'] for i in pending]:new.append(r)
report={'installed_files':pending,'protected_exact_since_preinstall':exact,'concurrent_edits_retained':concurrent,'concurrent_before_install_retained':json.loads((W/'concurrent-before-install.json').read_text()),'new_unowned_files_retained':new,'problems':bad,'original_art_and_creatures_unchanged':all(sha(L/r)==h for r,h in baseline.items() if r.startswith('assets/'))}
(W/'installation.json').write_text(json.dumps(report,indent=2))
print(json.dumps({k:v for k,v in report.items() if k not in ['installed_files','new_unowned_files_retained']},indent=2))
print('New unowned retained:',len(new))
assert not bad,bad
assert report['original_art_and_creatures_unchanged']
