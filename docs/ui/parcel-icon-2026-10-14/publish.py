from pathlib import Path
import hashlib,json,shutil,difflib
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');P=W/'package'
P.mkdir(exist_ok=True)
for phase in ['stage','live']:
    assert json.loads((W/phase/'checks.json').read_text())['passed']==20
    dest=P/phase;dest.mkdir(exist_ok=True)
    for p in (W/phase).iterdir():
        if p.is_file() and p.suffix in ['.json','.log','.png']:shutil.copy2(p,dest/p.name)
for folder in ['originals']:
    shutil.copytree(W/folder,P/folder,dirs_exist_ok=True)
for p in W.iterdir():
    if p.is_file() and p.suffix in ['.py','.gd','.json','.png','.log','.diff','.md']:shutil.copy2(p,P/p.name)
for rel in json.loads((W/'imported-files.json').read_text()):
    p=W/'import-project'/rel;dest=P/'native-import'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest)
protected=json.loads((W/'protected.json').read_text())
changed=[rel for rel,sha in protected.items() if hashlib.sha256((R/rel).read_bytes()).hexdigest()!=sha]
assert set(changed)=={'tools/ui/build_icons.py','scripts/town/hub_town.gd'},changed
for rel,name in [('tools/ui/build_icons.py','build_icons.py'),('scripts/town/hub_town.gd','hub_town.gd'),('assets/sprites/ui/item/parcel.png','parcel.png')]:assert (R/rel).read_bytes()==(W/name).read_bytes()
evidence='docs/ui/parcel-icon-2026-10-14/README.md'
summary='Task 1 complete: native 32px sealed Parcel icon, exact existing Scroll paper/wax palette and six-colour outline recipe. Generic item lookup/Bag resolve automatically; delivery-only Board hook shows cargo beside the title while retaining the separate reward icon. Native 20/20 staging and 20/20 installed live: take a generated delivery at the real Board, exact Board cargo/reward pixels, actual Bag row and selected 3x detail, put-back cargo removal. All 17 prior icon recipes and 809 other protected source/UI files exact. Original sources, diff, native import, private drivers, captures and receipts: '+evidence+'. AI-assisted native-grid art; no image generation, paid call, rule/save/settings/other-asset edit or commit. Claude proposals and local training untouched. Task 2, painted rising water, is next; tasks 2-5 remain pending.'
plans={}
for rel in ['docs/team/CODEX_TASKS_2026-10-14.md','docs/team/CODEX_START_HERE_2026-10-14.md','docs/AI_COLLABORATION.md']:
    p=R/rel;old=p.read_bytes();text=old.decode('utf-8-sig').replace('\r\n','\n')
    if 'CODEX_TASKS_' in rel:
        assert '1. **A Parcel icon.**' in text
        text=text.replace('1. **A Parcel icon.**','1. **DONE: A Parcel icon.**',1)
        text+='\n\nCodex, October 14: '+summary+'\n'
    elif 'CODEX_START_HERE_' in rel:
        needle="Live project: **C:/Users/pmcga/dev/hollowtide**. Codex's writable workspace is **D:/dev**."
        assert needle in text
        text=text.replace(needle,needle+'\n\n## Current status\n\n'+summary,1)
        text=text.replace('Five tasks, in order: the Parcel icon, the painted','Five tasks, in order: the Parcel icon (complete), the painted',1)
    else:
        assert '# Working Together on Hollowtide\n' in text
        text=text.replace('# Working Together on Hollowtide\n','# Working Together on Hollowtide\n\n## Codex: Parcel icon installed (October 14, 2026)\n\n'+summary+'\n',1)
    backup=P/'originals-docs'/p.name;backup.parent.mkdir(exist_ok=True);backup.write_bytes(old)
    (P/(p.name+'.diff')).write_text(''.join(difflib.unified_diff(old.decode('utf-8-sig').replace('\r\n','\n').splitlines(True),text.splitlines(True),fromfile='original/'+rel,tofile='installed/'+rel)),encoding='utf-8',newline='\n')
    plans[rel]=(old,(text.replace('\n','\r\n') if b'\r\n' in old else text).encode('utf-8'))
dest=R/'docs/ui/parcel-icon-2026-10-14'
assert not dest.exists()
for rel,(old,new) in plans.items():assert (R/rel).read_bytes()==old
for rel,(_,new) in plans.items():(R/rel).write_bytes(new)
manifest={p.relative_to(P).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in P.rglob('*') if p.is_file() and p.name!='manifest.json'}
(P/'manifest.json').write_text(json.dumps(manifest,indent=2))
shutil.copytree(P,dest)
for rel,sha in manifest.items():assert hashlib.sha256((dest/rel).read_bytes()).hexdigest()==sha
for rel,(_,new) in plans.items():assert (R/rel).read_bytes()==new
print('Archived and verified',len(manifest),'evidence files; updated three current handoffs. Task 2 is next.')
