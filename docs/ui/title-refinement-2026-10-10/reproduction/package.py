from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def cp(s,d):d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(s,d)
owned=[p.relative_to(W/'candidate').as_posix() for p in (W/'candidate/scripts').rglob('*') if p.is_file()]
for r in owned:
    orig=W/'originals'/r
    if orig.exists():assert sha(L/r)==sha(orig),'Concurrent edit requires rebase: '+r
    else:assert not (L/r).exists(),'Concurrent new file: '+r
for name in ['title_check','menu_check','quit_title']:
    log=(W/(name+'.log')).read_text()
    errors=[s for s in log.splitlines() if ('ERROR:' in s or 'Parse Error' in s) and 'Failed to read the root certificate store' not in s]
    assert not errors,(name,errors)
assert 'TITLE_RESULT passes=26 failures=0' in (W/'title_check.log').read_text()
assert 'CHECKS 51 FAILURES 0' in (W/'menu_check.log').read_text()
assert 'TITLE QUIT CONFIRMATION REACHED' in (W/'quit_title.log').read_text()
baseline=json.loads((W/'baseline.json').read_text())
current={r:sha(L/r) if (L/r).exists() else None for r in baseline}
(W/'preinstall-protected.json').write_text(json.dumps(current,indent=2))
concurrent={r:{'initial':h,'preinstall':current[r]} for r,h in baseline.items() if current[r]!=h}
(W/'concurrent-before-install.json').write_text(json.dumps(concurrent,indent=2))
entry='''## Codex: title-first visual and control refinement (October 10, 2026)

Preston requested main-menu hookup/refinement, clarified "Title screen first" and "visual wise too." Refined creature_opening with forest/gold launch card, framed four-choice menu (New Game, Options, How to play, Quit), selected-action descriptions and keyboard/mouse/controller hints. Added original code-drawn inset joinery, warm Options slider/focus styling, and Journey/Controls guide tabs with real Start New Game/Back actions. Both New Game routes open the existing creature story; identity/companion choices remain there. Quit confirms with Back to title focused; visible/focus order agrees, safe boot skip retained. Village, carved wordmark and removed title actors are preserved; no generated assets.

26 native title checks plus 51 full launch/menu checks pass with actual InputEvents; real title Quit closes its engine. Checked panel bounds, guide topics/focus, story return, Reduce Motion carry and current shared preferences. Runtime scope: creature_opening.gd plus title_panel_trim.gd; parent menu/boot/prologue, Claude's latest rules/learnsets/state/audio, field pages, Hall/layout and all creature art/backups preserved. Isolated test profiles; no disk-save/Continue, natural dungeon-clear claim or commit. [Native previews, original snapshots, checks and installation audit](ui/title-refinement-2026-10-10/README.md).

Title-first preference supersedes the immediate field-page visual order for this slice. Next handoff remains field-page portraits/health/evolve/item presentation, then Growth Shrine using existing rule constants. Read current notes/Claude changes first.

'''
notes=L/'docs/AI_COLLABORATION.md';original=notes.read_bytes();first,tail=original.split(b'\n',1)
target=W/'candidate/docs/AI_COLLABORATION.md';target.parent.mkdir(parents=True,exist_ok=True)
target.write_bytes(first+b'\n\n'+entry.encode()+tail)
cp(notes,W/'originals/docs/AI_COLLABORATION.md');owned.append('docs/AI_COLLABORATION.md')
P=W/'archive';P.mkdir(exist_ok=True)
for folder in ['originals','candidate','review']:shutil.copytree(W/folder,P/folder,dirs_exist_ok=True)
for f in W.glob('*.log'):cp(f,P/'logs'/f.name)
for ext in ['*.gd','*.py','*.ps1']:
    for f in W.glob(ext):cp(f,P/'reproduction'/f.name)
for f in ['README.md','baseline.json','preinstall-protected.json','concurrent-before-install.json']:cp(W/f,P/f)
(P/'.gdignore').write_text('')
pending=[{'path':r,'before':sha(L/r) if (L/r).exists() else None,'source':str(W/'candidate'/r),'after':sha(W/'candidate'/r)} for r in owned]
(W/'pending-install.json').write_text(json.dumps(pending,indent=2));cp(W/'pending-install.json',P/'pending-install.json')
print('Guarded',len(owned),'runtime/notes files;',len(concurrent),'concurrent changes retained;',len(current),'files protected')
