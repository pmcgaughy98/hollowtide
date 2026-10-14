from pathlib import Path
import json,re,shutil,hashlib
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');P=R/'docs/pitch/ai-asset-inventory.md'
raw=P.read_bytes();original=raw.decode('utf-8-sig').replace('\r\n','\n')
(W/'original-inventory.md').write_bytes(raw)
text=original
old='Checked October 11, 2026, against the current `C:/Users/pmcga/dev/hollowtide` source. Prepared by Codex for Preston\'s pitch and eventual Steam disclosure. Task 5 of [Claude\'s queue](../team/CODEX_TASKS_2026-10-11.md).'
new='Refreshed October 14, 2026, against `C:/Users/pmcga/dev/hollowtide` for Preston\'s pitch and eventual store disclosure: task 5 of [the current queue](../team/CODEX_TASKS_2026-10-14.md). The original full census is dated October 11; this update verifies the October 12–14 additions and their installed, promotional or proposal status. [Refresh evidence and limits](ai-asset-inventory-2026-10-14/README.md).'
assert old in text;text=text.replace(old,new,1)
text=text.replace('F5 currently starts `scenes/dungeon.tscn`; the campaign title starts at `scenes/creature_opening.tscn`.','The current `project.godot` starts `scenes/creature_opening.tscn` (the campaign title); `scenes/dungeon.tscn` remains the dungeon scene.')
text=text.replace('The [group register]','The **October 11 snapshot** [group register]',1)
text=text.replace('The crew pass generated no new expressions.','The October 11 normal-portrait pass generated no expressions. On October 12, Claude added **twelve Retro Diffusion `image_edit` expressions on Codex\'s exact crops**: Grubbit surprised/happy; Stillwade worried/determined; Wickglow mischievous/happy; Muskin surprised/worried; Slipjaw angry/determined; Rinsepaw happy/sad. [Crew expression builder](../../tools/ui/rd_crew_expressions.py) and [raw edits/review sheets](../ui/crew-expressions-2026-10-12/). All twelve installed PNGs are 40x40; the six normals still match the October 11 prepared files. Palette locking, edge cleanup and resizing retain generated classification. The `image_edit` tool ID is recorded; its exact underlying model/version is unknown.')
text=text.replace('Includes the crew\'s recorded “Wayline!” effect, not general spoken dialogue.','Includes the retained generated “Wayline!” effect, not general spoken dialogue. The October 12 mail call explicitly has no cheer; do not describe this retained take as used by that scene.')
text=text.replace('Steam\'s current survey distinguishes development efficiency tools from content players consume, and separately asks about live generation.','The October 11 policy read distinguished development efficiency tools from content players consume, and separately covered live generation; that policy was not rechecked in this asset-only refresh.')
anchor='## Retained modes, fallbacks and unresolved sources'
section='''## Additions checked October 12–14

| Content / status | Classification, preparation and evidence |
|---|---|
| **Installed Parcel icon**, `assets/sprites/ui/item/parcel.png`; delivery cargo on the Job Board and Bag page. | **AI-assisted code-painted art**, native pixel grid/Python/Pillow, existing Scroll paper/wax palette; no image-model output. [Recipe, originals and native integration checks](../ui/parcel-icon-2026-10-14/README.md). The delivery-only Board presentation hook does not change item rules. |
| **Installed rising-water shoreline/ripples**, `assets/sprites/world/rising_water_2026_10_14/`; The Hollow B1F. | **AI-assisted code-painted art**, Godot Image drawing, native atlas preparation and four timed frames over the original translucent wash. [Originals, builder and native checks](../design/rising-water-finish-2026-10-14/README.md). No image generation. The textured terrain remains active (`USE_TILE_ART=false`); save/turn rules unchanged. |
| **Dialogue corner layout proposal**; the shared frame PNGs and builder remain unchanged. | **AI-assisted layout correction**, no generated art. Proposed `PORTRAIT_INSET=162.0`, portrait offset `(42,-34)`; [two-line patch and native flood comparison](../design/dialogue-corner-2026-10-14/README.md). **Staged only: Claude still applies the values.** It is not an installed frame variant. |

### Pitch capture and feedback GIFs

These are **recordings of real game rendering, with AI-assisted recording/editing**, not generative video. Their visible sprites, scenery, UI, dialogue, music and sound keep the classifications above. The recorder sets up scenes and team/save state for the shots; this is edited, staged gameplay footage, not a continuous player playthrough.

| Promotional output | Verified file and source record |
|---|---|
| **Pitch capture v3**, full and `_share` copies | [Full MP4](../trailer/v3/hollowtide_pitch_v3.mp4), [share MP4](../trailer/v3/hollowtide_pitch_v3_share.mp4): each **101.967s, 1920x1080, 30fps, H.264/AAC**, measured with ffprobe. [Godot Movie Maker recorder](../../tools/trailer/record_pitch_v3.gd), [segment log](../trailer/v3/segments.txt) and [Python/Pillow/FFmpeg cutter](../../tools/trailer/cut_pitch_v3.py) trace the shots to `v3/raw.avi`, October 11 scene recordings and the v2 Hollow fight. Proposal text cards, generated title painting/end card and Suno-origin `hollow_flute` music are composited into the edit; the opening retains game audio. |
| **Four feedback GIFs** | [Mail call](feedback-post-2026-10-12/mail_call.gif), [water rises](feedback-post-2026-10-12/water_rises.gif), [carried home](feedback-post-2026-10-12/carried_home.gif), [stand-off](feedback-post-2026-10-12/standoff.gif): each **576x324, 98 frames, 6.54s**, measured by Pillow. [Feedback draft](feedback-post-2026-10-12.md) identifies their gameplay subjects. Exact per-GIF cut timestamps/encoding commands are **not archived in the reviewed tools**; do not invent them or imply a new video model. |

These October 12 recordings predate the October 14 Parcel icon and shoreline/ripple finish; they also do not demonstrate installation of the staged Storage room or dialogue offset. The feedback draft is an unpublished proposal: inventorying it does not authorize posting. Its short AI note is not a per-file provenance register and omits providers recorded here; use this inventory to make a specific disclosure for the media actually posted.

### Development proposals excluded from current gameplay integration

“Not shipped” here means **not installed in the reviewed current gameplay**, not certified excluded from an export; no release package was inspected. Keep development docs and training/model material out of any future shipped-content claim until the export is audited.

| Proposal | Recorded provenance / status |
|---|---|
| **Ballastak**, `docs/design/new-creature-ballastak-2026-10-13/` | **AI-generated.** Nano Banana 2.1 through SpriteCook: master and eight-direction grid; later east-profile edits use GPT-Image-2, west mirrored. [Dated proposal/source record](../design/new-creature-ballastak-2026-10-13/README.md), [SpriteCook IDs](../art/spritecook-assets.json). Raw views sliced/registered on 128px canvases; the rejected palette-finished sheet is preserved. The model labels are those recorded by the tools, not independently verified checkpoint versions. No Ballastak art folder or literal resource consumer was found under the current assets/game sources. |
| **Switchhold**, the proposal's `switchhold/` folder | **AI-generated**, PixelLab Pro Flash character tool, Ballastak master as style reference; eight rotations registered without changing their pixels. [Source record and character ID](../design/new-creature-ballastak-2026-10-13/switchhold/README.md). No installed Switchhold art folder or literal resource consumer found. Names/briefs in the roster do not establish installed art. |
| **Palette/parts variants**, `parts_kit/` | **AI-generated source art with AI-assisted deterministic edits**, hue-family palette swaps and crest planting on Ballastak/Switchhold copies. [Proposal README](../design/new-creature-ballastak-2026-10-13/parts_kit/README.md), [parts tool](../../tools/art/parts_kit.py). Clay/moss/night variants and donor crest examples remain proposals; a palette swap does not make generated source art human-drawn. |
| **Local sprite style model and exams**, outside repo at `D:/ai/hollowtide-sprite-lora` | **Development experiment, not gameplay or a shipped model.** The [dated skill-up notes](../design/sprite-generator-skillup-2026-10-13.md) record Stable Diffusion 1.5 plus a LoRA trained on 339 existing generated creature views (47 forms), with Kithflare southeast held out. October 14's recorded result says training finished at 1200 steps, failed the identity/palette exam and was **parked**. This is that document's status, not a new process/training audit. Exact base checkpoint/version and training-data commercial rights are not established by this inventory. Any exam outputs remain generated from generated-source training material. |
| **Kithflare 3D/paintover studies** | AI-assisted model/render plus **AI-generated repaint** where the recorded SpriteCook GPT-Image-2 exam applies; [skill-up record](../design/sprite-generator-skillup-2026-10-13.md). Docs-only experiments, not replacement gameplay sprites. Later proposed tools/models in those notes do not prove outputs were generated or installed. |
| **Storage interior, October 14**, `docs/world/storage-art-proposal-2026-10-14/` | **AI-generated shell and six-prop source sheet**, two built-in `image_gen.imagegen` edits on guides/Hall references; exact model/version **unknown**. [Generation ledger](../world/storage-art-proposal-2026-10-14/generation-ledger.json) preserves prompts and originals. Native crops, uniform nearest fit, alpha cleanup and shared code finish retain this classification; the floor reuses the existing generated Hall floor. [Standalone preview/package](../world/storage-art-proposal-2026-10-14/README.md). **Art staged only: Claude room/door/collision/panel integration is pending.** The existing exterior and door-opened Storage panel are separate installed content. |

The October 11 whole-repository register was preserved as dated evidence, not relabelled as a fresh full census. [October 14 facts](ai-asset-inventory-2026-10-14/facts.json) records the twelve portrait files/raw edits, unchanged normal hashes, media measurements, proposal scans and current title entry point; [source hashes](ai-asset-inventory-2026-10-14/evidence-sha256.json) identify the reviewed files. Unknown legacy provenance and rights questions below remain unresolved.

'''
assert anchor in text;text=text.replace(anchor,section+anchor,1)
old='Static review found no HTTP/LLM generation call in first-party `scripts/`, `scenes/`, `resources/` or `dialogue/`.'
new='The October 14 static marker scan found no HTTP/API-generation markers in first-party `scripts/`, `scenes/`, `data/` or `dialogue/`; there is no current `resources/` folder. This supplements the October 11 source review and does not prove absence of all possible network behavior.'
assert old in text;text=text.replace(old,new,1)
assert text!=original
(W/'ai-asset-inventory.md').write_text(text,encoding='utf-8')
broken=[];links=[]
for label,ref in re.findall(r'\[([^\]]+)\]\(([^)]+)\)',text):
    if ref.startswith(('https://','http://')):continue
    path=(P.parent/ref.split('#')[0]).resolve()
    if 'ai-asset-inventory-2026-10-14' not in ref and not path.exists():broken.append(ref)
    links.append(ref)
assert not broken,broken
facts=json.loads((W/'facts.json').read_text(encoding='utf-8'))
assert len(facts['expressions'])==12 and len(facts['gifs'])==4 and len(facts['videos'])==2
assert not facts['source_scan']['matches']
validation={'local_links_checked':len(links),'broken_local_links':broken,'expressions':12,'normal_portraits_exact':6,'gifs_measured':4,'videos_probed':2,'new_generation_calls':0,'game_content_changes':0,'policy_or_provider_terms_researched':False}
(W/'validation.json').write_text(json.dumps(validation,indent=2),encoding='utf-8')
print(json.dumps(validation,indent=2));print('Prepared inventory:',len(text),'characters')
