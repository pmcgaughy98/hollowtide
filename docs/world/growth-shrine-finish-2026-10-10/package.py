from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
baseline=json.loads((W/'baseline.json').read_text())
owned=[p.relative_to(W/'candidate').as_posix() for p in (W/'candidate').rglob('*') if p.is_file()]
for r in owned:
    assert (sha(L/r)==baseline[r] if r in baseline else not (L/r).exists()), 'Concurrent owned edit: '+r
changed={r:{'before':h,'now':sha(L/r) if (L/r).exists() else None} for r,h in baseline.items() if r not in owned and r!='docs/AI_COLLABORATION.md' and (not (L/r).exists() or sha(L/r)!=h)}
(W/'concurrent-before-install.json').write_text(json.dumps(changed,indent=2))
entry='''## Codex: Growth Shrine exterior and evolution presentation (October 10, 2026)

Preston moved Growth Shrine ahead of Scroll Keeper: this is where creatures evolve. Inspected Claude's current shrine service, readiness/evolution helper and evolution scene first. Kept those rules/state/scene intact. New original open-air moss/root/limestone clearing with a purple leaf inlay, outlined stone joints/details and a north entrance facing Market Street. Built-in imagegen, one call, zero Retro; unmodified source, exact prompt and transparent-padding crop / uniform nearest preparation archived. Sprite below creatures preserves the fully walkable area at (96,288), 144x120, activation tile (7,12); no layout or collision change.

Uses installed purposeful building outline/detail shader, contact shadow and a worn north approach. Original small leaf entrance inlay settles between dormant/active frames with growth/evolve_ask/growth_done/evolving_now; Claude's shrine panels omit place ID, so presentation reads service/state. Floating shrine plaque suppressed through existing finished-exterior hook. Corrected HUD confirmation footer from misleading E close to E evolve / Esc not now only when the service is evolve_ask. No readiness, progression, learnset, economy or creature changes.

22 native shrine/input checks pass, including actual walking/E, not-ready/ready/cancel/from-approach, all thirty tiles walkable, all outside ground exact, unchanged Home/shop/Hall/Storage signs/foundations and twelve door textures. Missing shrine art or painter restores exact prior ground and retains evolution interaction. Claude's evolution check passes old/new scene stages, record/street form replacement, moves and pending move on next run; town/Hall checks pass. Native 1152x648 captures reviewed. [Previews, original sources/prompt, checks and preservation audit](world/growth-shrine-finish-2026-10-10/README.md).

Next exterior in prior brief order is Scroll Keeper. Claude retains evolution rules, service systems and state. No commit or settings edit.


'''
p=L/'docs/AI_COLLABORATION.md';old=p.read_bytes();header=b'# Working Together on Hollowtide\r\n\r\n' if old.startswith(b'# Working Together on Hollowtide\r\n') else b'# Working Together on Hollowtide\n\n'
assert old.startswith(header)
notes=W/'candidate/docs/AI_COLLABORATION.md';notes.parent.mkdir(parents=True,exist_ok=True)
notes.write_bytes(header+entry.replace('\n','\r\n').encode()+old[len(header):])
snapshot=W/'originals/docs/AI_COLLABORATION-preinstall.md';snapshot.parent.mkdir(parents=True,exist_ok=True);snapshot.write_bytes(old)
owned.append('docs/AI_COLLABORATION.md')
pending=[{'path':r,'before':sha(L/r) if (L/r).exists() else None,'after':sha(W/'candidate'/r),'source':str(W/'candidate'/r)} for r in owned]
(W/'pending-install.json').write_text(json.dumps(pending,indent=2))
(W/'preinstall-protected.json').write_text(json.dumps({r:sha(L/r) for r in baseline if r not in owned},indent=2))
archive=W/'archive';archive.mkdir(exist_ok=True)
for folder in ['originals','candidate','review','sources','prompts']:shutil.copytree(W/folder,archive/folder,dirs_exist_ok=True)
for p in W.iterdir():
    if p.is_file() and p.suffix in ['.md','.gd','.py','.ps1','.json','.log']:shutil.copy2(p,archive/p.name)
print('Concurrent unowned changes:',json.dumps(changed,indent=2));print('Guarded files:',len(pending))
