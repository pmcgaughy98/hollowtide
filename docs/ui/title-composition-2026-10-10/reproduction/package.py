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
assert 'TITLE_RESULT passes=29 failures=0' in (W/'title_check.log').read_text()
assert 'CHECKS 51 FAILURES 0' in (W/'menu_check.log').read_text()
assert 'TITLE QUIT CONFIRMATION REACHED' in (W/'quit_title.log').read_text()
baseline=json.loads((W/'baseline.json').read_text())
current={r:sha(L/r) if (L/r).exists() else None for r in baseline}
(W/'preinstall-protected.json').write_text(json.dumps(current,indent=2))
concurrent={r:{'initial':h,'preinstall':current[r]} for r,h in baseline.items() if current[r]!=h}
(W/'concurrent-before-install.json').write_text(json.dumps(concurrent,indent=2))
entry="## Codex: authored title composition pass (October 10, 2026)\n\nPreston asked for a further visual upgrade so the title looks like an authored game menu. Replaced the large main frame/header/copy card with four serif text choices, stationary pixel pointer, warm focus underline and small control footer. Existing Vollkorn/Silkscreen/regular body fonts establish typography hierarchy. A code-only lower-left forest wash provides contrast over the original village; bitmap and wordmark pixels are untouched. Options/Help have restrained frames, serif headings/actions and lighter text. Kept 16:9 window composition, raised Help to fit the type, footer hidden on subpages. No new generated art or imagegen/Retro calls.\n\n29 actual-input native title checks and 51 full launch/menu checks pass, including wide-window rendered aspect, guide/footer/Back behavior, both New Game routes, selected team arrival and existing preferences/pause flow. Real title Quit closes its engine. Runtime scope: creature_opening.gd and title_legibility.gdshader; original script archived. Claude state/levels/learnsets/combat/audio, field pages, maps/Hall, all creature art/finishes/palettes and previous backups preserved. Isolated test profiles; no save/Continue or natural dungeon-clear claim; no commit. [Native previews, original snapshots, checks and preservation audit](ui/title-composition-2026-10-10/README.md).\n\nVisual direction remains a proposal for Preston's review. Preserve all title routes during further art work. Field pages/Growth Shrine remain later handoff work, rules/state with Claude.\n\n"
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
