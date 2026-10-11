from pathlib import Path
import hashlib,json,shutil
from PIL import Image,ImageDraw
W=Path(__file__).parent;C=Path('C:/Users/pmcga/dev/hollowtide');A=C/'docs/art/crew-idles-2026-10-11'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
manifest=json.loads((W/'manifest.json').read_text());protected=json.loads((W/'protected.json').read_text())
assert 'CREW IDLES 31/31 PASS' in (W/'live-verify.log').read_text()
assert all(sha(C/r['output'])==r['output_sha'] for r in manifest)
changed=[p for p,s in protected.items() if sha(C/p)!=s];assert not changed,changed
# Review-only nearest enlargement of actual live Godot sprite captures.
native=Image.open(W/'review/live/native-pairs.png').convert('RGBA')
gallery=Image.new('RGB',(900,460),'#3f5140');draw=ImageDraw.Draw(gallery)
for k,r in enumerate(manifest):
    x=(k%3)*300;y=(k//3)*230
    draw.text((x+10,y+10),r['form']+' / IDLE PREVIEW',fill='#fff4e8')
    tile=native.crop(((k%3)*200+100,(k//3)*150,(k%3)*200+200,(k//3)*150+150));tile=tile.crop(tile.getbbox());tile=tile.resize((tile.width*3,tile.height*3),Image.Resampling.NEAREST)
    gallery.paste(tile,(x+(300-tile.width)//2,y+28+(178-tile.height)//2),tile)
    draw.text((x+10,y+212),r['object_rule'],fill='#fff4e8')
gallery.save(W/'review/live-idles.png')
shutil.copytree(W/'review',A/'review',dirs_exist_ok=True)
shutil.copytree(W/'recoloured',A/'recoloured',dirs_exist_ok=True)
for name in ['manifest.json','protected.json','install-audit.json','prepare.py','stage_import.py','run.py','verify.gd','install.py','package.py','verify.log','live-verify.log','asset-import.log','imports.json','prepared-review.png']:
    shutil.copy2(W/name,A/name)
rows='\n'.join(f'| {r["form"].title()} | {r["size"][0]} x {r["size"][1]} | {r["baseline"]} | {r["object_rule"]} |' for r in manifest)
readme=f'''# Six crew idle stills, October 11, 2026

Task 2 of Claude's [master queue](../../team/CODEX_TASKS_2026-10-11.md): prepared and installed six new `assets/sprites/arena/<form>/town/idle_s.png` files. **Assets are ready for Claude's standing swap. Production wiring is still pending and was not changed here.**

![Native live idle previews](review/live-idles.png)

| Creature | Town canvas | South baseline (zero-based y) | Retained objects/gear |
|---|---|---:|---|
{rows}

## Preparation

Each idle comes from its current chosen front in `docs/creatures/arena-starters-2026-10-07/forms/`. Those references were not included in Claude's recolour tool's file list, so the new copies receive each form's existing `recolor_creature.SCHEMES` rule, including Stillwade's current accent. No new colour scheme or generated artwork. Chosen source PNGs remain byte-exact.

Used the project's palette-locked `downscale.resample`, with the existing full-size/town canvas ratio. Held objects do not enter a new mass calculation that would shrink the creature. Hard binary alpha, the same black edge rule as task 1, centered whole silhouettes and exact current south baselines. Every solid resampled pixel fits with transparent padding; no job object is cropped. Native shared shader remains unchanged.

Grubbit's removed tag, Stillwade's removed stick/rocks and the worn-gear/held-object distinctions are preserved from the chosen sources. Muskin and Slipjaw have nothing new in their hands. Rinsepaw retains the pot, greens, ladle and steam; Wickglow retains the pole.

## Verification

**Godot 4.7.2, OpenGL compatibility: 31/31 staging and 31/31 live.** [Live log](live-verify.log), [fixture](verify.gd), [install audit](install-audit.json). All six ResourceLoader imports match prepared RGBA and exact town dimensions; south baselines and padded GPU output pass. Previewed on the real town room NPC sprite holders with the real shared shader. All 384 existing crew walk frame selections still work at the same anchors, and the preview returns to idle after walking.

The [whole Hall preview](review/live/hall-idle-preview.png) is a private fixture demonstration: each NPC's south still is replaced in memory for that check, and Grubbit is added temporarily to the lower Hall. This is not a production post/facing change. The normal game still uses Claude's current standing logic. No claim of automatic live switching until Claude wires it.

All 927 protected files remained exact, covering 918 existing crew/source PNGs plus the size/recolour tools, room/crew/scene-kit scripts, shader files and project settings. [Fresh snapshots](originals/), [manifest](manifest.json) and [protected hashes](protected.json). Only six new PNGs, their six import metadata files/derived caches and handoff evidence added. Existing walks, stills, chosen fronts, task 1 outlines, recolour backups and prior art remain intact. No generation, paid call, commit, reset, stash or revert. The final live native run has no errors or leaks; staging has the existing third-party UID fallback and sandbox certificate message.

## Claude integration contract

- File convention: `res://assets/sprites/arena/<form>/town/idle_s.png` for all six crew.
- Exact same canvas as `town/s.png`; no new sprite scale/offset needed.
- Use only while standing and facing south. Retain the current walk dictionary and other facing stills.
- Private preview assigns the idle to `e.still.s`, then calls the existing `room._place`. Current `room._process` selects the walk texture during movement and `still[facing]` on completion. Claude owns the production hook.
- Grubbit's normal post faces west and Slipjaw's east; this asset preparation does not change their post facings or invent extra idle angles.

Next Codex asset task: task 3, Hall fixtures on Claude's current corrected perspectives and solids. Tasks 3 through 6 remain pending. Re-read the master queue and current live source before work. Private preparation/native drivers: `D:/dev/hollowtide-crew-idles-20261011/`. Do not rerun the guarded snapshot/install over newer assets.
'''
(A/'README.md').write_text(readme,encoding='utf-8')
note='''Codex, October 11: task 2 asset preparation complete. Six new town/idle_s.png files installed from current chosen fronts, using each form's existing recolour rule, palette-locked downscale and black outline. Exact town canvases/south baselines; held job objects retained, no tag/stick/rocks restored. All 927 protected files exact; existing walks/stills/source fronts and scripts unchanged. Godot 31/31 staging and live, exact imported RGBA, real room preview and 384 walk selections verified. Claude still owns the production standing-south swap; native previews use it only in fixture memory. Handoff: docs/art/crew-idles-2026-10-11/README.md. Task 3 (current Hall fixtures) is next; tasks 3 through 6 remain pending. No generation or commit.'''
task=C/'docs/team/CODEX_TASKS_2026-10-11.md';text=task.read_text(encoding='utf-8');assert note not in text
text=text.replace('**Status, Codex October 11:** task 1 is installed and verified. Task 2 is next. [Outline pass evidence](../art/crew-selout-2026-10-11/README.md).','**Status, Codex October 11:** task 1 and task 2 asset preparation are installed and verified. Claude owns task 2\'s production idle swap. Task 3 is next for Codex. [Outline evidence](../art/crew-selout-2026-10-11/README.md), [idle asset handoff](../art/crew-idles-2026-10-11/README.md).',1)
task.write_text(text.rstrip()+'\n\n'+note+'\n',encoding='utf-8')
start=C/'docs/team/CODEX_START_HERE_2026-10-11.md';text=start.read_text(encoding='utf-8')
old="Preston's latest completed request: task 1 of Claude's master queue, the eight-creature sel-out pass. Installed and verified, alongside the finished Growth Shrine information screen, Highbank world sel-out and rebuilt Wayline Hall. Task 2, six crew idle stills with job objects, is next. Do not redo finished work or overwrite Claude's concurrent code."
new="Preston's latest completed request: task 2 asset preparation, six crew idle stills with job objects. Installed and verified; Claude still owns the production standing-south swap. Task 3, current Hall fixture art, is next for Codex. The earlier outline, Shrine, world and Hall work remains installed. Do not redo finished work or overwrite Claude's concurrent code."
assert old in text;text=text.replace(old,new,1)
text=text.replace('## Latest completed work','## Latest completed work\n\n**Six crew idle assets:** task 2 preparation complete; six `town/idle_s.png` files with current recolour rules, job objects, exact town canvases and south baselines. Native Godot 31/31 staging/live; original PNGs and scripts exact. `docs/art/crew-idles-2026-10-11/README.md`. Claude owns production idle wiring; task 3 is next for Codex.',1)
text=text.replace('Task 2 is next.','Task 2 assets are now complete; Claude owns their production swap.',1)
text=text.replace('2. **NEXT: NPC idle stills with job objects:**','2. **ASSETS DONE, CLAUDE WIRING PENDING: NPC idle stills with job objects:**',1)
text=text.replace('3. **Finish current Hall fixtures:**','3. **NEXT: Finish current Hall fixtures:**',1)
start.write_text(text,encoding='utf-8')
collab=C/'docs/AI_COLLABORATION.md';text=collab.read_text(encoding='utf-8');header='# Working Together on Hollowtide\n';assert text.startswith(header)
entry='''\n## Codex: six crew idle assets ready for Claude (October 11, 2026)

Task 2 asset preparation is complete. Added six `town/idle_s.png` files from the current chosen Grubbit, Muskin, Slipjaw, Stillwade, Wickglow and Rinsepaw fronts. Existing recolour rules, palette-locked resample, black edges, exact town canvases and south baselines. Parcel/pole/ladle/greens/pot/bell and worn gear retained according to the crew brief; removed tag/stick/rocks not restored. Existing 918 PNGs and nine protected code/tool/settings files exact. Native Godot 31/31 staging/live; imports exact, actual room previews and 384 walking selections intact. No production script changes, generation or commit.

**Claude owns the production standing-south swap; it remains pending.** Native previews substitute the prepared idle only inside the private fixture, with no post/facing change. [Assets, original snapshots, integration contract and evidence](art/crew-idles-2026-10-11/README.md). Task 3, current corrected Hall fixtures, is next for Codex; tasks 3 through 6 remain pending. No message sent to another chat.
'''
collab.write_text(header+entry+text[len(header):],encoding='utf-8')
print('Idle assets/evidence archived; task 2 preparation done, Claude swap pending; task 3 next.')
