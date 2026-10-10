from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def cp(s,d):d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(s,d)
owned=[p.relative_to(W/'candidate').as_posix() for p in (W/'candidate').rglob('*') if p.is_file()]
for r in owned:
    orig=W/'originals'/r
    if orig.exists():assert sha(L/r)==sha(orig),'Concurrent edit requires rebase: '+r
    else:assert not (L/r).exists(),'Concurrent new file: '+r
for name in ['entrance_check','menu_check','hall_door_check','hub_town_check','field_menu_check','quit_title','quit_pause']:
    log=(W/(name+'.log')).read_text()
    errors=[s for s in log.splitlines() if ('ERROR:' in s or 'Parse Error' in s) and 'Failed to read the root certificate store' not in s]
    if name=='field_menu_check':errors=[s for s in errors if 'resources still in use at exit' not in s]
    assert not errors,(name,errors)
assert 'ENTRANCE_RESULT passes=14 failures=0' in (W/'entrance_check.log').read_text()
assert 'CHECKS 51 FAILURES 0' in (W/'menu_check.log').read_text()
assert 'RESULT: field menu works' in (W/'field_menu_check.log').read_text()
baseline=json.loads((W/'baseline.json').read_text())
current={r:sha(L/r) if (L/r).exists() else None for r in baseline}
(W/'preinstall-protected.json').write_text(json.dumps(current,indent=2))
concurrent={r:{'initial':h,'preinstall':current[r]} for r,h in baseline.items() if current[r]!=h}
(W/'concurrent-before-install.json').write_text(json.dumps(concurrent,indent=2))
entry='''## Codex: coherent Hall doorway and launch regression (October 10, 2026)

Preston clarified that the doorway already met the lane; the pasted drawing was the defect. Rejected the localized insert and installed one coherent complete Hall PNG with a centered wide arch/gable and intact side windows. Original October 9 Hall PNG stays untouched as fallback. Both Claude doorway tiles (23,6)/(24,6) and authored two-tile steps remain the contract. Ground painting reads door_tiles; removed the now-obsolete third paving strip. No Layout/controller/service logic changes.

Restored F5 from standalone hollow_floor to creature_opening. Retained Claude's new Team/Bag/Floor/Log pages and default turn-based dungeon; compressed the nine-button pause main page to fit the viewport and corrected Controls copy. No state/combat/levels/evolution/audio/creature edits. 14 native entrance and 51 actual-input launch/menu checks pass; both Quit confirmations close engines. Claude's field-menu, Hall door and hub checks pass. Isolated test profiles preserve user preferences; no natural dungeon-clear or disk-save claim. Three built-in imagegen edits, zero Retro calls, original sources/prompts/rejected proposal archived. All unowned protected files audited; no commit.

[Native previews, original snapshots, provenance, checks and install audit](world/hall-door-2026-10-10/README.md). Next: style Claude's existing field pages, then Growth Shrine using existing rules; retain current handoff ownership.

'''
notes=L/'docs/AI_COLLABORATION.md';original=notes.read_bytes();first,tail=original.split(b'\n',1)
target=W/'candidate/docs/AI_COLLABORATION.md';target.parent.mkdir(parents=True,exist_ok=True)
target.write_bytes(first+b'\n\n'+entry.encode()+tail)
cp(notes,W/'originals/docs/AI_COLLABORATION.md');owned.append('docs/AI_COLLABORATION.md')
P=W/'archive';P.mkdir(exist_ok=True)
for folder in ['originals','candidate','review','sources','prompts']:shutil.copytree(W/folder,P/folder,dirs_exist_ok=True)
for f in W.glob('*.log'):cp(f,P/'logs'/f.name)
for ext in ['*.gd','*.py','*.ps1']:
    for f in W.glob(ext):cp(f,P/'reproduction'/f.name)
for f in ['README.md','baseline.json','preinstall-protected.json','concurrent-before-install.json','audio-dependency-sync.json','asset-preparation.json']:cp(W/f,P/f)
(P/'.gdignore').write_text('')
pending=[{'path':r,'before':sha(L/r) if (L/r).exists() else None,'source':str(W/'candidate'/r),'after':sha(W/'candidate'/r)} for r in owned]
(W/'pending-install.json').write_text(json.dumps(pending,indent=2));cp(W/'pending-install.json',P/'pending-install.json')
print('Guarded',len(owned),'runtime/notes files;',len(concurrent),'concurrent changes retained;',len(current),'files protected')
