from pathlib import Path
import hashlib,json,shutil,difflib
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');P=W/'package'
result=json.loads((W/'final-verification.json').read_text(encoding='utf-8'))
assert result['stage']['total_passed']==result['live']['total_passed']==22
P.mkdir(exist_ok=True)
for folder in ['originals','art','before','after','live-captures']:
    shutil.copytree(W/folder,P/folder,dirs_exist_ok=True)
for phase in ['stage','live']:
    dest=P/phase;dest.mkdir(exist_ok=True)
    for p in (W/phase).iterdir():
        if p.is_file() and p.suffix in ['.log','.json','.png']:shutil.copy2(p,dest/p.name)
for p in W.iterdir():
    if p.is_file() and p.suffix in ['.py','.gd','.json','.md','.log','.diff']:shutil.copy2(p,P/p.name)
for rel in json.loads((W/'imported-files.json').read_text(encoding='utf-8')):
    dest=P/'native-import'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(W/'import-project'/rel,dest)
protected=json.loads((W/'protected.json').read_text(encoding='utf-8'))
changed=[rel for rel,sha in protected.items() if hashlib.sha256((R/rel).read_bytes()).hexdigest()!=sha]
assert changed==['scripts/dungeon/dungeon.gd'],changed
assert (R/'scripts/dungeon/dungeon.gd').read_bytes()==(W/'dungeon.gd').read_bytes()
assert (R/'scripts/dungeon/rising_water_art.gd').read_bytes()==(W/'rising_water_art.gd').read_bytes()
evidence='docs/design/rising-water-finish-2026-10-14/README.md'
summary='Task 2 complete: installed native shoreline/ripple atlases and rising_water_art helper on the existing translucent water, with four quiet 400ms frames. Exactly three presentation lines added to dungeon.gd; all water rules/numbers, suspend/resume and textured valley remain exact (USE_TILE_ART=false). Native 22/22 staging and 22/22 installed live: original six water assertions plus sixteen atlas/turn/save/real Continue checks; one-use suspend and the next rise preserved. Dry/wall pixels and floor data exact at turns9/10/20/30; all 822 other protected source files exact. Originals, diff, native captures, builder/import drivers and receipts: '+evidence+'. AI-assisted code-painted art; no generation, paid call, other art/creature/settings/audio edit or commit. Claude proposals and local training untouched. Tasks 1-2 complete. Task 3, staged Storage interior art for Claude, is next; tasks 3-5 remain pending.'
plans={}
for rel in ['docs/team/CODEX_TASKS_2026-10-14.md','docs/team/CODEX_START_HERE_2026-10-14.md','docs/AI_COLLABORATION.md']:
    p=R/rel;old=p.read_bytes();text=old.decode('utf-8-sig').replace('\r\n','\n')
    if 'CODEX_TASKS_' in rel:
        assert '2. **Rising water, painted.**' in text
        text=text.replace('2. **Rising water, painted.**','2. **DONE: Rising water, painted.**',1)
        text+='\n\nCodex, October 14: '+summary+'\n'
    elif 'CODEX_START_HERE_' in rel:
        start=text.index('## Current status\n\n')+len('## Current status\n\n')
        end=text.index('\n\n## Read before work',start)
        text=text[:start]+summary+text[end:]
        text=text.replace('the painted\n   rising water,','the painted\n   rising water (complete),',1)
    else:
        assert '# Working Together on Hollowtide\n' in text
        text=text.replace('# Working Together on Hollowtide\n','# Working Together on Hollowtide\n\n## Codex: painted rising water installed (October 14, 2026)\n\n'+summary+'\n',1)
    backup=P/'originals-docs'/p.name;backup.parent.mkdir(exist_ok=True);backup.write_bytes(old)
    diff=''.join(difflib.unified_diff(old.decode('utf-8-sig').replace('\r\n','\n').splitlines(True),text.splitlines(True),fromfile='original/'+rel,tofile='installed/'+rel))
    (P/(p.name+'.diff')).write_text(diff,encoding='utf-8',newline='\n')
    plans[rel]=(old,(text.replace('\n','\r\n') if b'\r\n' in old else text).encode('utf-8'))
dest=R/'docs/design/rising-water-finish-2026-10-14';assert not dest.exists()
for rel,(old,new) in plans.items():assert (R/rel).read_bytes()==old
for rel,(_,new) in plans.items():(R/rel).write_bytes(new)
manifest={p.relative_to(P).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in P.rglob('*') if p.is_file() and p.name!='manifest.json'}
(P/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
shutil.copytree(P,dest)
for rel,sha in manifest.items():assert hashlib.sha256((dest/rel).read_bytes()).hexdigest()==sha
for rel,(_,new) in plans.items():assert (R/rel).read_bytes()==new
print('Archived and verified',len(manifest),'evidence files; updated three handoffs. Task 3 Storage art is next.')
