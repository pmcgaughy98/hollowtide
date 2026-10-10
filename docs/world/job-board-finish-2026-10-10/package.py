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
entry='''## Codex: Job Board exterior (October 10, 2026)

Next town-finish slice after Training Yard. Original compact moss/root timber notice stand, four parchment silhouettes and limestone feet, same shared sel-out details. Exact (624,168) 48x24 and reading tile (26,8); all original spot/reading tiles open. Ground-coloured shadow and packed-earth reading pad join Market Street; board paint precedes Hall to preserve its contact band. Inset pad corners respond in three frames to the existing jobs panel, replacing the floating plaque via existing hook. E/paper-rustle/close unchanged. No job generation/acceptance/reward/dispatch/state system added.

Built-in imagegen one call with our Hall as style reference, zero Retro. Unmodified source/exact prompt and padding-crop/uniform-nearest preparation archived. 27 native checks pass (actual walking/E/sound/from-approach/closing, detail ink, depth ordering, exact previous five foundations/signs and fifteen entrance frames, all outside ground exact). Missing PNG or painter restores exact prior ground and seven services with jobs interaction retained; hub/Hall checks pass. [Native previews, source, prompt, originals and audit](world/job-board-finish-2026-10-10/README.md).

Only three presentation scripts, one new PNG and this note installed. Preserve all creature/backups/palette assets, shared shader, shrine/hatch/Yard, Hall/layout/controller/state and Claude's title/soul-prologue work. No commit/settings edit. Next remaining areas and service spots before decorative buildings.


'''
p=L/'docs/AI_COLLABORATION.md';old=p.read_bytes();header=b'# Working Together on Hollowtide\r\n\r\n' if old.startswith(b'# Working Together on Hollowtide\r\n') else b'# Working Together on Hollowtide\n\n';assert old.startswith(header)
dest=W/'candidate/docs/AI_COLLABORATION.md';dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(header+entry.replace('\n','\r\n').encode()+old[len(header):])
(W/'originals/docs/AI_COLLABORATION-preinstall.md').write_bytes(old)
if 'docs/AI_COLLABORATION.md' not in owned:owned.append('docs/AI_COLLABORATION.md')
pending=[{'path':r,'before':sha(L/r) if (L/r).exists() else None,'after':sha(W/'candidate'/r),'source':str(W/'candidate'/r)} for r in owned]
(W/'pending-install.json').write_text(json.dumps(pending,indent=2));(W/'preinstall-protected.json').write_text(json.dumps({r:sha(L/r) for r in base if r not in owned},indent=2))
for name in ['install.ps1','audit.py']:
 p=W/name;p.write_text(p.read_text().replace('hollowtide-training-yard-20261010','hollowtide-job-board-20261010').replace('training-yard-finish-2026-10-10','job-board-finish-2026-10-10').replace('Training Yard finish','Job Board finish'))
archive=W/'archive';archive.mkdir(exist_ok=True)
for folder in ['originals','candidate','review','sources','prompts']:shutil.copytree(W/folder,archive/folder,dirs_exist_ok=True)
for p in W.iterdir():
 if p.is_file() and p.suffix in ['.md','.gd','.py','.ps1','.json','.log']:shutil.copy2(p,archive/p.name)
print('Guarded files',len(pending),'concurrent unowned changes',json.dumps(changed,indent=2))
