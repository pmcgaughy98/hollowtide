from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'baseline.json').read_text())
owned=[p.relative_to(W/'candidate').as_posix() for p in (W/'candidate').rglob('*') if p.is_file()]
for r in owned:
 assert (sha(L/r)==sha(W/'originals'/r) if (W/'originals'/r).exists() else not (L/r).exists()),r
entry='''## Codex: Sparkwick body-palette consistency (October 10, 2026)

Preston flagged brown patches in both the walking sprites and large animated preview. Inspected existing generations/locks/back fixes first. Added a Sparkwick-only display swatch correction using its approved arena-front gold/tan/copper body ramp, removing desaturated brown paint colours while retaining intentional stripe shapes, pale belly and bright lantern core. Shared sel-out follows texture changes; party art/headshot use a creature-only draw layer; evolution corrects colour before its existing whitening. Claude's moving front-idle source/order and 5 FPS stay exact. No generated redraw or PNG/source/walk/portrait/backup edits, no creature data/rules/size/foot/controller edits.

168 native rendered textures: 19,506 dull material pixels -> 0; rendered alpha/silhouette and bright lamp core exact. Other forms' native south-view finishes byte-exact, including Oxbowarchon jade. Actual town movement, dungeon, summary animation/switching and evolution checks pass. Current active field/arena/party/evolution scope; inactive legacy battle-screen renderer remains separate. [Previews, precise scope, originals, checks and audit](creatures/sparkwick-material-consistency-2026-10-10/README.md). Preserve seven-form refinements and Claude/Grok concurrent code/notes. No commit/settings edit. Material consistency implemented/reviewed, Preston's visual approval not claimed.


'''
r='docs/AI_COLLABORATION.md';b=(L/r).read_bytes();header=b'# Working Together on Hollowtide\r\n\r\n' if b.startswith(b'# Working Together on Hollowtide\r\n') else b'# Working Together on Hollowtide\n\n';assert b.startswith(header)
p=W/'originals'/r;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(b)
p=W/'candidate'/r;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(header+entry.replace('\n','\r\n').encode()+b[len(header):]);owned.append(r)
pending=[{'path':r,'before':sha(L/r) if (L/r).exists() else None,'after':sha(W/'candidate'/r),'source':str(W/'candidate'/r)} for r in owned]
(W/'pending-install.json').write_text(json.dumps(pending,indent=2))
protected={r:sha(L/r) for r in base if r not in owned and (L/r).exists()}
for folder in ['scripts','data','scenes','assets','tools']:
 for p in (L/folder).rglob('*'):
  if p.is_file() and p.suffix not in ['.uid','.import','.pyc']:
   r=p.relative_to(L).as_posix()
   if r not in owned:protected[r]=sha(p)
for p in L.glob('*.bak'):protected[p.relative_to(L).as_posix()]=sha(p)
(W/'preinstall-protected.json').write_text(json.dumps(protected,indent=2))
(W/'concurrent-before-install.json').write_text(json.dumps({r:{'before':h,'now':protected.get(r)} for r,h in base.items() if r not in owned and protected.get(r)!=h},indent=2))
A=W/'archive';A.mkdir(exist_ok=True)
for folder in ['originals','candidate','review']:shutil.copytree(W/folder,A/folder,dirs_exist_ok=True)
for p in W.iterdir():
 if p.is_file() and p.suffix in ['.md','.gd','.py','.ps1','.json','.log']:shutil.copy2(p,A/p.name)
print('Guarded',len(pending),'files; protected',len(protected),'current files.')
