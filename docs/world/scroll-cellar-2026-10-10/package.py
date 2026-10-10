from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'baseline.json').read_text())
owned=[p.relative_to(W/'candidate').as_posix() for p in (W/'candidate').rglob('*') if p.is_file()]
for r in owned:assert (sha(L/r)==base[r] if r in base else not (L/r).exists()),r
changed={r:{'before':h,'now':sha(L/r) if (L/r).exists() else None} for r,h in base.items() if r not in owned and r!='docs/AI_COLLABORATION.md' and (not (L/r).exists() or sha(L/r)!=h)}
(W/'concurrent-before-install.json').write_text(json.dumps(changed,indent=2))
entry='''## Codex: Scroll Keeper cellar hatch correction (October 10, 2026)

Preston flagged the upright north door as leading nowhere and asked for a trapdoor into the mostly-roof building. Replaced that entrance with a low limestone stairwell: bright north landing, descending treads darkening beneath the moss roof. Built-in imagegen edit plus one direction correction; both generated sources, exact prompts and prior runtime script are archived. Native preparation is padding crop / uniform nearest scaling only. New sibling sprite leaves the original Scroll Keeper PNG and all earlier archives intact.

Scroll-only lid frames now close over the recess, lift and fold back south toward the roof, revealing the source steps. Moved the original cross-stair sill to the north landing. Kept (744,288), 144x120, activation tile (33,12), scroll sign, sel-out detail preset, existing E/service/sound/close behavior. Presentation only: existing Scroll Keeper description remains, no basement scene or teaching/relearning rules added. Other four foundation/sign textures and twelve door drawings compare exact; native interaction/render checks pass. [Source, prompts, previews and preservation audit](world/scroll-cellar-2026-10-10/README.md).

Only building_exteriors.gd, one new PNG and this note installed. Claude's concurrent state/UI/dungeon/assets and existing shader/shrine/title/layout preserved. No commit/settings edit.


'''
p=L/'docs/AI_COLLABORATION.md';old=p.read_bytes();header=b'# Working Together on Hollowtide\r\n\r\n' if old.startswith(b'# Working Together on Hollowtide\r\n') else b'# Working Together on Hollowtide\n\n';assert old.startswith(header)
dest=W/'candidate/docs/AI_COLLABORATION.md';dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(header+entry.replace('\n','\r\n').encode()+old[len(header):])
(W/'originals/docs/AI_COLLABORATION-preinstall.md').write_bytes(old)
if 'docs/AI_COLLABORATION.md' not in owned:owned.append('docs/AI_COLLABORATION.md')
pending=[{'path':r,'before':sha(L/r) if (L/r).exists() else None,'after':sha(W/'candidate'/r),'source':str(W/'candidate'/r)} for r in owned]
(W/'pending-install.json').write_text(json.dumps(pending,indent=2));(W/'preinstall-protected.json').write_text(json.dumps({r:sha(L/r) for r in base if r not in owned},indent=2))
for name in ['install.ps1','audit.py']:
 p=W/name;p.write_text(p.read_text().replace('hollowtide-selout-scroll-20261010','hollowtide-scroll-cellar-20261010').replace('selout-scroll-2026-10-10','scroll-cellar-2026-10-10').replace('shared sel-out and Scroll Keeper','Scroll Keeper cellar hatch'))
shutil.copy2(W/'prompt-record.json',W/'prompts/exact-built-in-prompts.json')
archive=W/'archive';archive.mkdir(exist_ok=True)
for folder in ['originals','candidate','review','sources','prompts']:shutil.copytree(W/folder,archive/folder,dirs_exist_ok=True)
for p in W.iterdir():
 if p.is_file() and p.suffix in ['.md','.gd','.py','.ps1','.json','.log']:shutil.copy2(p,archive/p.name)
print('Guarded files',len(pending),'concurrent changes',changed)
