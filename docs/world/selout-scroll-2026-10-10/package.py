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
entry='''## Codex: shared sel-out detail preset, shrine seams and Scroll Keeper (October 10, 2026)

Preston: make building-detail outlines part of sel-out, shrine needs them too, then continue next task. Moved silhouette/cluster cleanup and optional internal ink into scripts/arena/sel_out.gdshaderinc. creature_finish.gd.apply(sprite,true) enables the purposeful detail preset (dark joints, material boundaries, narrow pale carved seams including diagonals). Existing creature default is preserved. Building shader remains a compatibility wrapper of the same recipe. Town purposeful sprites and Growth Shrine call the shared preset directly; art-direction.md records this as the reusable integration rule. Shrine source, ground, feedback and Claude's evolution rules/scene are intact, with stronger rendered stone/carving contours.

Continued Scroll Keeper: original north-facing moss/root/limestone workshop and purple parchment accents; exact (744,288) 144x120 and door (33,12), porch toward Market Street. Separate sprite, same detailed sel-out, contact band/worn north approach, original scroll sign and three source-masked door textures. Initial mask that caught adjacent trim was rejected and replaced by a confined original-leaf mask. Existing service/sound/E/close path works, no teaching/relearning rules or interior added. Built-in imagegen one call, zero Retro; original source and exact prompt archived, crop/nearest native preparation only.

Native shared-render proof preserves all 33 south-facing creature forms byte-exact to old finish; shrine sample ink pixels 1057 -> 1614; compatibility/direct preset exact. 23 Scroll Keeper and 22 shrine/input checks pass; all previous four sign/foundation textures and twelve door drawings exact, all ground outside bounded Scroll Keeper exact (shrine ground included). Missing new PNG or painter restores exact old ground and scroll interaction. [Previews, shader originals, sources/prompt, checks and preservation audit](world/selout-scroll-2026-10-10/README.md).

Nine runtime files plus art/collaboration notes only. Preserve source PNGs/palette locks/backups, Claude state/rules/UI/VFX, title, layout/collision/camera. Next remaining purposeful services/areas, then decoration. No commit/settings edit.


'''
p=L/'docs/AI_COLLABORATION.md';old=p.read_bytes();header=b'# Working Together on Hollowtide\r\n\r\n' if old.startswith(b'# Working Together on Hollowtide\r\n') else b'# Working Together on Hollowtide\n\n';assert old.startswith(header)
notes=W/'candidate/docs/AI_COLLABORATION.md';notes.parent.mkdir(parents=True,exist_ok=True);notes.write_bytes(header+entry.replace('\n','\r\n').encode()+old[len(header):])
(W/'originals/docs/AI_COLLABORATION-preinstall.md').write_bytes(old)
owned.append('docs/AI_COLLABORATION.md')
pending=[{'path':r,'before':sha(L/r) if (L/r).exists() else None,'after':sha(W/'candidate'/r),'source':str(W/'candidate'/r)} for r in owned]
(W/'pending-install.json').write_text(json.dumps(pending,indent=2));(W/'preinstall-protected.json').write_text(json.dumps({r:sha(L/r) for r in baseline if r not in owned},indent=2))
archive=W/'archive';archive.mkdir(exist_ok=True)
for folder in ['originals','candidate','review','sources','prompts']:shutil.copytree(W/folder,archive/folder,dirs_exist_ok=True)
for p in W.iterdir():
    if p.is_file() and p.suffix in ['.md','.gd','.py','.ps1','.json','.log']:shutil.copy2(p,archive/p.name)
print('Concurrent unowned changes:',json.dumps(changed,indent=2));print('Guarded files:',len(pending))
