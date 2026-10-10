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
entry='''## Codex: Mouth of the Hollow entrance finish (October 10, 2026)

Next ferry-district slice after Crossroads. Original low broken scour recess with dark cleft, chipped limestone/clay, roots/moss and a pale south-west foothold replaces the yellow block. Same shared sel-out detail preset; terrace-coloured contact band and short worn west approach join the existing ferry lane. Exact (792,648), 48x48, activation (33,28), all four tiles walkable, ground-level sprite. No layout/paths/collision/camera/rules changes; all existing road pixels and ground outside bounded entrance/apron exact.

Built-in imagegen one call using our own Shrine as style reference, zero Retro. Original output/exact prompt and crop/uniform-nearest preparation archived. 27 native checks pass including previous five foundation/sign textures and fifteen entrance drawings exact, actual shader ink/foothold, real walking/E and scene change into dungeon with party/return flag/carried jobs/rank intact. Missing PNG or painter restores exact prior ground, nine finished views and entry. Hub/Hall checks pass. Landing's temporary label moves beside its own interaction spot only when finished Mouth exists, clearing the entrance; fallback retains its old position. [Native previews, source/prompt, originals and audit](world/hollow-mouth-finish-2026-10-10/README.md).

Installed scope: four town presentation scripts, one new PNG and this note. hub_town.gd changes only four lines of label presentation; every input/controller/jobs/evolution/state method retained. Preserve all creature refinements/Oxbowarchon jade/palettes/backups/source art, installed town views/shader/title and Claude's concurrent code. No commit or settings edit. Remaining ferry landing/dock/switchback art next; visual direction remains proposal for Preston. Entry verified, natural dungeon clear not claimed.


'''
p=L/'docs/AI_COLLABORATION.md';old=p.read_bytes();header=b'# Working Together on Hollowtide\r\n\r\n' if old.startswith(b'# Working Together on Hollowtide\r\n') else b'# Working Together on Hollowtide\n\n';assert old.startswith(header)
dest=W/'candidate/docs/AI_COLLABORATION.md';dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(header+entry.replace('\n','\r\n').encode()+old[len(header):])
(W/'originals/docs/AI_COLLABORATION-preinstall.md').write_bytes(old)
if 'docs/AI_COLLABORATION.md' not in owned:owned.append('docs/AI_COLLABORATION.md')
pending=[{'path':r,'before':sha(L/r) if (L/r).exists() else None,'after':sha(W/'candidate'/r),'source':str(W/'candidate'/r)} for r in owned]
(W/'pending-install.json').write_text(json.dumps(pending,indent=2))
protected={r:sha(L/r) for r in base if r not in owned}
for folder in ['scripts','scenes','assets','data','tools','docs']:
 for p in (L/folder).rglob('*'):
  if p.is_file() and p.suffix not in ['.uid','.import','.pyc']:
   r=p.relative_to(L).as_posix()
   if r not in owned:protected[r]=sha(p)
for p in L.glob('*.bak'):protected[p.relative_to(L).as_posix()]=sha(p)
(W/'preinstall-protected.json').write_text(json.dumps(protected,indent=2))
archive=W/'archive';archive.mkdir(exist_ok=True)
for folder in ['originals','candidate','review','sources','prompts']:shutil.copytree(W/folder,archive/folder,dirs_exist_ok=True)
for p in W.iterdir():
 if p.is_file() and p.suffix in ['.md','.gd','.py','.ps1','.json','.log']:shutil.copy2(p,archive/p.name)
print('Guarded files',len(pending),'protected',len(protected),'concurrent changes',json.dumps(changed,indent=2))
