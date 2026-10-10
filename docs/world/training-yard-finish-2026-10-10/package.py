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
entry='''## Codex: Training Yard exterior (October 10, 2026)

Preston requested Training Yard next. New original low-relief packed-earth practice ring with two opposing positions, woven pads, limestone/root/moss edging and a north entrance. Same shared sel-out detail preset, near-black internal contours, ground-coloured contact shadow and worn approach. Original target sign has dormant / settling / active drawings responding to the existing Yard panel; floating Yard plaque suppressed through existing hook. Built-in imagegen one call using our Growth Shrine as style reference; zero Retro. Unmodified source, exact prompt and native padding-crop / uniform-nearest preparation archived.

Exact (912,288) 168x120, activation (41,12), all 35 tiles walkable and sprite beneath creatures. Existing arena description/E/door sound/close remains; no new arena dispatch, practice rules or state changes. 27 native Yard checks pass, including actual walking/input/sign transition, shader ink, unchanged five signs/foundations and all fifteen prior entrance frames (Scroll Keeper cellar hatch included), ground outside bounded Yard exact. Missing PNG or painter restores exact prior ground and six finished services with Yard interaction retained; hub/Hall checks pass. [Native previews, sources, prompt, originals and preservation audit](world/training-yard-finish-2026-10-10/README.md).

Only three town presentation scripts, one new PNG and this note installed. Preserve title, layout/collision/camera, shader/shrine/hatch, original art and Claude's concurrent code/state/rules. Next remaining services/areas in the town brief; no commit/settings edit.


'''
p=L/'docs/AI_COLLABORATION.md';old=p.read_bytes();header=b'# Working Together on Hollowtide\r\n\r\n' if old.startswith(b'# Working Together on Hollowtide\r\n') else b'# Working Together on Hollowtide\n\n';assert old.startswith(header)
dest=W/'candidate/docs/AI_COLLABORATION.md';dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(header+entry.replace('\n','\r\n').encode()+old[len(header):])
(W/'originals/docs/AI_COLLABORATION-preinstall.md').write_bytes(old)
if 'docs/AI_COLLABORATION.md' not in owned:owned.append('docs/AI_COLLABORATION.md')
pending=[{'path':r,'before':sha(L/r) if (L/r).exists() else None,'after':sha(W/'candidate'/r),'source':str(W/'candidate'/r)} for r in owned]
(W/'pending-install.json').write_text(json.dumps(pending,indent=2));(W/'preinstall-protected.json').write_text(json.dumps({r:sha(L/r) for r in base if r not in owned},indent=2))
for name in ['install.ps1','audit.py']:
 p=W/name;p.write_text(p.read_text().replace('hollowtide-scroll-cellar-20261010','hollowtide-training-yard-20261010').replace('scroll-cellar-2026-10-10','training-yard-finish-2026-10-10').replace('Scroll Keeper cellar hatch','Training Yard finish'))
archive=W/'archive';archive.mkdir(exist_ok=True)
for folder in ['originals','candidate','review','sources','prompts']:shutil.copytree(W/folder,archive/folder,dirs_exist_ok=True)
for p in W.iterdir():
 if p.is_file() and p.suffix in ['.md','.gd','.py','.ps1','.json','.log']:shutil.copy2(p,archive/p.name)
print('Guarded files',len(pending),'concurrent unowned changes',json.dumps(changed,indent=2))
