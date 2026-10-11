from pathlib import Path
import hashlib,json,shutil
from PIL import Image,ImageDraw
W=Path(__file__).parent;C=Path('C:/Users/pmcga/dev/hollowtide');A=C/'docs/art/crew-selout-2026-10-11'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
records=json.loads((W/'manifest.json').read_text());stats=json.loads((W/'stats.json').read_text())
assert 'CREW SELOUT 37/37 PASS' in (W/'live-verify.log').read_text()
assert all(sha(C/r['path'])==r['after'] for r in records)
assert all(sha(A/'originals'/r['path'])==r['before'] for r in records)
# Compact gallery from actual live OpenGL captures, nearest 3x for review only.
out=Image.new('RGB',(1024,512),'#3f5140');draw=ImageDraw.Draw(out)
for k,name in enumerate(stats):
    im=Image.open(W/f'review/live/{name}_town.png').convert('RGBA').crop((0,0,232,232))
    im=im.crop(im.getbbox());im=im.resize((im.width*3,im.height*3),Image.Resampling.NEAREST)
    x=(k%4)*256;y=(k//4)*256
    draw.text((x+12,y+12),name+' / live town',fill='#fff4e8')
    out.paste(im,(x+(256-im.width)//2,y+28+(228-im.height)//2),im)
out.save(W/'review/live-overview.png')
shutil.copytree(W/'review',A/'review',dirs_exist_ok=True)
for name in ['manifest.json','stats.json','install-audit.json','prepare.py','stage.py','run.py','verify.gd','import_assets.py','import-manifest.json','install.py','finish_install.py','review_fix.py','package.py','verify.log','live-verify.log','asset-import.log','protected-cache-baseline.json']:
    shutil.copy2(W/name,A/name)
rows='\n'.join(f'| {name.title()} | {s["images"]} | {s["changed_pixels"]:,} |' for name,s in stats.items())
readme=f'''# Eight-creature outline pass, October 11, 2026

Task 1 of Claude's [master queue](../../team/CODEX_TASKS_2026-10-11.md) is installed. Grubbit, Muskin, Slipjaw, Stillwade, Wickglow, Rinsepaw, Cairnshell and Crawdukes use the same deterministic black sel-out rule as `tools/arena/selout.py --black`.

![Live Godot town sprites](review/live-overview.png)

## Installed scope

1,224 current PNGs: 64 full-size facings, 128 town/dungeon stills, 1,024 walk frames, and eight chosen NPC fronts in `docs/creatures/arena-starters-2026-10-07/forms/`. No resizing, frame movement, peeling or repainting of interiors. All source alpha and dimensions are exact. Worn gear, job objects in the chosen fronts, recolours and rebuilt 208px Cairnshell/Crawdukes game sets are retained. This does not create `town/idle_s.png` or dialogue portraits; those are tasks 2 and 4.

Only opaque pixels bordering transparency in four directions and at least 12 luma above the form's existing darkest line colour change. That line is black for seven forms and (7,0,0) for Crawdukes, as the named tool derives it. 139,652 selected edge pixels changed. Every other RGBA pixel stays exact. The pass is idempotent.

Fresh pre-pass PNGs are byte-exact in [originals/](originals/); [manifest](manifest.json) records before/after SHA-256, dimensions and changed-pixel count for each asset. Older sel-out/recolour/clipped-walk backups remain intact. The normal tool was not run against its historical backup tree because that could restore older colours and clipped sets.

| Form | PNGs | Edge pixels changed |
|---|---:|---:|
{rows}

## Review and verification

Inspected all 16 numbered walk sheets, one facing per row and frames 0 through 7: all 1,024 town/dungeon walk frames. The pass changes neither anatomy nor registration; no additional canvas clipping or missing body parts were introduced. Before/after sheets are in [review/](review/). Chosen source fronts keep their existing canvas boundaries, including the historical bottom/side cuts in the Cairnshell/Crawdukes chosen references; their rebuilt game facings are the current padded 208px versions. This pass does not outpaint source references.

Godot 4.7.2, OpenGL compatibility, GTX 1660 SUPER: **37/37 staging and 37/37 live checks pass**. [Live log](live-verify.log), [fixture](verify.gd). ResourceLoader verifies opaque RGB, alpha and dimensions for all 1,216 game PNGs against prepared pixels. Actual shared shaders render every walk and full facing in padded cells. Real Hall crew posts/facings remain correct; the room animation selects every facing/frame for all six crew with identical sprite anchors (384 selections).

Whole actual world-layer captures show [lower Hall](review/live/hall_low_whole.png) and [upper Hall](review/live/hall_whole.png). These fixture-only captures expand the room viewport after logic checks so all posts can be reviewed. Native per-form walk/facing captures are in [review/live/](review/live/).

The full staging editor import stalled while creating autoloads; a separate texture-only Godot project imported these exact PNGs using existing per-file settings. Derived caches were copied only for the owned textures. 296 newly created runtime textures lacked live `.import` metadata; their generated metadata was added. Existing import settings and metadata were preserved. The final live run has no errors or leak warnings. The staging run logged a sandbox certificate error and a third-party UID fallback, neither present in the final live run.

No game scripts, shaders, scenes, rules, palettes beyond selected edges, room fixtures, solids, story wiring, save data or `project.godot` were edited. All 1,018 protected code/settings files stayed exact during cache installation. [Install audit](install-audit.json). No generation, paid Retro call, commit, reset, stash or revert.

## Next

Task 2: prepare six crew `town/idle_s.png` stills from these now-outlined chosen fronts, preserving held job objects and matching each current town set's size and palette. Claude owns the standing/walking swap in `guild_crew.gd`. Continue from the current live project and re-read the master queue. Private work and native drivers: `D:/dev/hollowtide-crew-selout-20261011/`. Archived scripts preserve evidence of this pass; do not rerun snapshot/install over a newer live set.
'''
(A/'README.md').write_text(readme,encoding='utf-8')
note='''Codex, October 11: task 1 complete. Installed black sel-out on all eight forms using current recoloured/unclipped assets: 1,224 PNGs including 1,024 walk frames and chosen fronts. Alpha, dimensions, registration and interior RGBA exact; fresh originals saved. All walk frames reviewed in numbered facing rows; native Godot 37/37 staging and live, all 1,216 runtime imports exact, actual crew posts and 384 animation selections intact. Added missing imports for 296 new textures; existing settings preserved. No code/shader/room/rule changes, generation or commit. Evidence: docs/art/crew-selout-2026-10-11/README.md. Task 2 (six idle_s stills with job objects) is next; tasks 2 through 6 remain pending.'''
task=C/'docs/team/CODEX_TASKS_2026-10-11.md';text=task.read_text(encoding='utf-8')
assert note not in text
text=text.replace('## Tasks, in order','## Tasks, in order\n\n**Status, Codex October 11:** task 1 is installed and verified. Task 2 is next. [Outline pass evidence](../art/crew-selout-2026-10-11/README.md).',1)
task.write_text(text.rstrip()+'\n\n'+note+'\n',encoding='utf-8')
start=C/'docs/team/CODEX_START_HERE_2026-10-11.md';text=start.read_text(encoding='utf-8')
text=text.replace("Preston's latest completed request: continue from this handoff and finish the Growth Shrine information screen (job4). It is installed and verified, alongside the finished Highbank world sel-out and rebuilt Wayline Hall. Do not redo finished work or overwrite Claude's concurrent code.","Preston's latest completed request: task 1 of Claude's master queue, the eight-creature sel-out pass. Installed and verified, alongside the finished Growth Shrine information screen, Highbank world sel-out and rebuilt Wayline Hall. Task 2, six crew idle stills with job objects, is next. Do not redo finished work or overwrite Claude's concurrent code.",1)
text=text.replace('## Latest completed work','## Latest completed work\n\n**Eight-creature sel-out:** task 1 complete, including Rinsepaw and rebuilt Cairnshell/Crawdukes. 1,224 PNGs; all 1,024 walk frames inspected. Fresh originals, exact alpha/dimensions/interiors, native Godot 37/37 staging/live and all 1,216 runtime textures verified. No game code or shader changes. `docs/art/crew-selout-2026-10-11/README.md`. Task 2 is next.',1)
text=text.replace('1. **Sel-out eight new/remade creatures:**','1. **DONE: Sel-out eight new/remade creatures:**',1)
text=text.replace('2. **NPC idle stills with job objects:**','2. **NEXT: NPC idle stills with job objects:**',1)
start.write_text(text,encoding='utf-8')
collab=C/'docs/AI_COLLABORATION.md';text=collab.read_text(encoding='utf-8')
header='# Working Together on Hollowtide\n'
assert text.startswith(header)
entry='''\n## Codex: eight new/remade creatures outlined (October 11, 2026)

Task 1 of Claude's current master queue is installed for Grubbit, Muskin, Slipjaw, Stillwade, Wickglow, Rinsepaw, Cairnshell and Crawdukes. Same black sel-out rule applied to current recoloured PNGs and rebuilt unclipped game sets, using fresh originals instead of the old tool backup tree. All 1,224 PNGs covered; alpha, dimensions, frame registration and interior RGBA exact. Reviewed all 1,024 walk frames in numbered eight-frame facing rows. Native Godot 37/37 staging and live, all 1,216 runtime textures verified; actual Hall posts and 384 crew animation selections preserved. Added missing native imports for 296 new textures; existing settings unchanged. No game code/shader/room/rule/settings changes, generation or commit.

Originals, manifest, walk sheets, live captures, audit and drivers: [Eight-creature sel-out](art/crew-selout-2026-10-11/README.md). Preserve these current outlined assets and all prior recolour/remake backups. **Task 2 is next:** six `town/idle_s.png` stills with job objects from chosen fronts; Claude wires the standing swap. Tasks 2 through 6 remain pending. Codex is out of the creature PNGs for this slice; no message sent to another chat.
'''
collab.write_text(header+entry+text[len(header):],encoding='utf-8')
print('Evidence archived; master task 1 complete, task 2 next; source/original hashes remain exact.')
