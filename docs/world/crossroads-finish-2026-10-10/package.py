from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'baseline.json').read_text())
owned=[p.relative_to(W/'candidate').as_posix() for p in (W/'candidate').rglob('*') if p.is_file()]
for r in owned:
 if r!='docs/AI_COLLABORATION.md':assert (sha(L/r)==base[r] if r in base else not (L/r).exists()),r
changed={r:{'before':h,'now':sha(L/r) if (L/r).exists() else None} for r,h in base.items() if r not in owned and r!='docs/AI_COLLABORATION.md' and (not (L/r).exists() or sha(L/r)!=h)}
(W/'concurrent-before-install.json').write_text(json.dumps(changed,indent=2))
entry='''## Codex: Crossroads plaza finish (October 10, 2026)

Next town-finish slice after Job Board. Original native packed-earth/limestone clearing, staggered chipped paving and grass-edge clusters replace the blockout rectangle. Native carved three-route floor tile extends Hall's own symbol, with the shared purposeful sel-out detail preset and three quiet response drawings tied to the existing waymark panel. Floating plaque suppressed via the finished-view hook. Code-native art only; no imagegen/Retro, external artwork or source PNG edits.

Exact (432,264) 288x144 plaza, activation (24,14), 24x24 inlay below creatures, all 72 tiles open. Full underlying authored ferry-lane paving remains exact; old blockout border crossing strokes cleared. Every ground pixel outside plaza unchanged. Existing E/quiet description/close remain; no navigation/travel/state feature added. 31 native checks pass including real walking/input, rendered interior ink, original five signs/foundations and fifteen entrance frames exact, plus Claude's new Board panel/input/feedback. Missing painter restores exact previous ground and eight finished services with Crossroads interaction. Hub/Hall checks pass. [Native previews, original scripts, checks and preservation audit](world/crossroads-finish-2026-10-10/README.md).

Only four town presentation scripts and this note installed. Board feedback additionally reads Claude's new board service signal (no place id in its panel); art/sign/frames unchanged. Preserved new jobs.gd, town/dungeon job flow and team-state keys, with retained snapshots/diffs. Preserve all creature refinements, Oxbowarchon's jade, palettes/sources/backups, shared finish, Shrine/hatch/Yard/Board, title/Hall/layout/controller/state and Claude's concurrent guild/prologue/UI work. No commit or settings edit. Remaining areas/service spots before decoration; visual direction remains proposal for Preston.


'''
p=L/'docs/AI_COLLABORATION.md';old=p.read_bytes();header=b'# Working Together on Hollowtide\r\n\r\n' if old.startswith(b'# Working Together on Hollowtide\r\n') else b'# Working Together on Hollowtide\n\n';assert old.startswith(header)
dest=W/'candidate/docs/AI_COLLABORATION.md';dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(header+entry.replace('\n','\r\n').encode()+old[len(header):])
(W/'originals/docs/AI_COLLABORATION-preinstall.md').write_bytes(old)
if 'docs/AI_COLLABORATION.md' not in owned:owned.append('docs/AI_COLLABORATION.md')
pending=[{'path':r,'before':sha(L/r) if (L/r).exists() else None,'after':sha(W/'candidate'/r),'source':str(W/'candidate'/r)} for r in owned]
(W/'pending-install.json').write_text(json.dumps(pending,indent=2))
protected={r:sha(L/r) for r in base if r not in owned}
# Include new concurrent runtime files, current source backups and every prior handoff/archive.
for folder in ['scripts','scenes','assets','data','tools','docs']:
 for p in (L/folder).rglob('*'):
  if p.is_file() and p.suffix not in ['.uid','.import','.pyc']:
   r=p.relative_to(L).as_posix()
   if r not in owned:protected[r]=sha(p)
for p in L.glob('*.bak'):protected[p.relative_to(L).as_posix()]=sha(p)
(W/'preinstall-protected.json').write_text(json.dumps(protected,indent=2))
archive=W/'archive';archive.mkdir(exist_ok=True)
for folder in ['originals','candidate','review','concurrent']:shutil.copytree(W/folder,archive/folder,dirs_exist_ok=True)
for p in W.iterdir():
 if p.is_file() and p.suffix in ['.md','.gd','.py','.ps1','.json','.log']:shutil.copy2(p,archive/p.name)
print('Guarded files',len(pending),'protected',len(protected),'concurrent changes',json.dumps(changed,indent=2))
