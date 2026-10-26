# Placeholder factory, part 3: the art slot spec, the drop-in pipeline, the task lists (Claude, 2026-10-26)

Preston, 2026-10-26: "mass manufacture placeholder additions for grok and codex to generate and go over as tasks. You
also should wire a lot of it with code ... Rewire whole map and town buildings too."

**The short version.** Every non-creature picture in the game becomes a named **art slot**. Claude writes the slot in
code first: its exact size, where its feet touch the ground, its colours, its light and outline, and a coded
placeholder that already plays correctly. A tool renders that placeholder to a reference picture with the grid and
the anchor marked. Codex (buildings, rooms, ground, scenes) or Grok (props, lamps, HUD pieces, non-creature figures)
paints to that reference. A script checks the result before Preston sees it, Preston picks, and only then does it
install. The game loads the generated file when it is there and the right size, and the coded placeholder otherwise.

This file is the format. It does not build anything yet. Read-only research; no game file was edited.

---

## 0. Why a spec: what went wrong before (measured 2026-10-26)

**The town buildings were the right size for their contract. The contract was missing the creatures.**

| What | Measured | Where |
|---|---|---|
| Building PNG vs footprint | All 5 exact: hall 240x144 (10x6 tiles), home 120x120 (5x5), shop, storage, scroll keeper 144x120 (6x5) | `scripts/town/town_layout.gd:46-58`; the game refuses any other size at `scripts/town/building_exteriors.gd:39` |
| Door width | 24 px (one tile); the hall's is 48 px (two tiles) | `town_layout.gd:46`, `:52` |
| Creatures that walk the town (1.5x town set, `town/s.png` content box) | Stage 1: 27 to 34 px tall (Cinderhide 27, Kithflare 33, Mirekit 34). Stage 2: 40 to 54 (Clinkerhide 40, Sparkjab 45, Windcut 54, 56 wide). Stage 3: 55 to 69 (Vitrecrag 55x57, Starward 56, Galeshear 62x63, Stormwick 69) | `assets/sprites/arena/<form>/town/s.png`; dungeon set is two thirds of that (Cinderhide 18, Galeshear 41) |
| Result | A stage 3 stands 2.3 to 2.9 tiles tall beside a 5-tile house with a 1-tile door. Nothing in the brief tied door or wall height to the creatures | `docs/team/CODEX_TOWN_FINISH_BRIEF_2026-10-10.md` (no scale line) |
| Colours per building | 7,842 (storage) to 22,826 (hall). Rooms: home 37,131, storage shell 39,758, hall 65,412 | measured with PIL, opaque pixels |
| Canvas-edge contact | 4 of 5 buildings touch the canvas edge (hall, home, shop on all four sides; scroll keeper the top). The rim shader treats outside-the-canvas as transparent, so the border row gets rimmed as silhouette | `scripts/art/selout_rim.gdshaderinc:7` |
| Partial alpha | Dock 7,371 soft-edged pixels of 10,368; river strip 27,648 of 27,648; Mouth 1,296 of 2,304 | `assets/sprites/world/town_detail_2026_10_10/`, `hollow_mouth_2026_10_10/` |
| "The Board is too small" | Fixed by a second, doubled file (48x24 and a 96x48 display copy) and a scale on the sprite, not a new spec | `scripts/town/job_board_painter.gd:6-7`, `:72` |
| Where art paths live | 114 distinct art paths written into 43 scripts (202 occurrences). No single list of what art exists or is missing | grep of `res://assets/sprites/(world\|ui\|menu\|player\|effects)` under `scripts/` |
| Codex generated animation | Canvaswing's walk job: 5 of 8 frames broken (outline-only ghosts of 121 and 87 px against about 265; a 525 px one-colour slab; a tan square touching all edges) | `docs/team/CODEX_TASKS_2026-10-22.md` task 1 |
| Grok Imagine in Hollowtide | Frame study 17,378 colours, icon sheet 60,737, both JPEG; not installed | `docs/design/imagine-look-2026-10-16.md:15` |

**What already passes, for scale.** Claude's hand-coded art meets every check below by construction: the 9-slice frames
are 4 to 13 colours (panel 84x84 at 12, nameplate 42x36 at 6, portrait 60x60 at 10, arrow 21x15 at 4;
`assets/sprites/ui/frame/`), the icons are a 16x16 grid of outline plus three tones plus accents saved at 32x32
(`tools/ui/build_icons.py`), the Guildmaster's desk is 192x52 in about 18 locked colours (`tools/art/guild_desk.py`).
Creature runtime frames sit at 18 to 23 colours (`docs/art/canvaswing-diagonal-walk-2026-10-22/README.md:11`).

---

## 1. The measuring stick every slot uses

- **Screen:** 1152x648. **World view:** 384x216 world pixels drawn at **3x** (`scripts/dungeon/dungeon.gd:41-42`,
  `scripts/town/hub_town.gd:29-30`, `scripts/town/town_room.gd:21-22`). One world pixel is a 3x3 block on screen.
- **Tile:** 24 world px in the town and the dungeon (`town_layout.gd:13`, `dungeon.gd:40`). The view is 16 x 9 tiles.
  The town is 48 x 32 tiles = 1152 x 768 world px.
- **Creature size per stage:** dungeon visual mass targets 15.5 / 21 / 30 (`tools/arena/build_dungeon_set.py:23`),
  town set 1.5x that. The measured heights are in the table above. A slot near creatures names which creature it
  must fit (see `pass_creature`).
- **UI pixels:** 9-slice frames are drawn at 1x and saved at 3x, so a UI pixel is a world pixel; margins in screen
  pixels are panel 24, nameplate 12, portrait 21 (`scripts/ui/ui_style.gd:160-176`). Icons: 16x16 drawn, saved 2x
  (32x32). Text is never art: fonts by role come from `UI.TYPE` (`ui_style.gd:22-36`).
- **Light:** upper left; shadows fall to the lower right (`building_exteriors.gd:48`, the town brief section 2,
  `scripts/dungeon/riverbank_painter.gd:286`).
- **Inks:** purposeful building detail `#0b0e11` (`building_exteriors.gd:12`); icon outline `#1a1410`
  (`build_icons.py`, `OUTLINE = (26, 20, 16)`); UI brass and moss `PANEL #242b25`, `EDGE #b69b6d`, `EDGE_LIGHT
  #e4ca8e`, `FOCUS #3f5140`, `TEXT #fff4e8`, lantern `#f2c14e` (`ui_style.gd:145-158`).
- **House rules this spec enforces:** dungeon terrain stays painted in code (`USE_TILE_ART := false` at
  `riverbank_painter.gd:6`, `ruin_painter.gd:5`, `valley_painter.gd:5`), so no generator gets a dungeon floor or
  wall tile slot; panels and buttons are pixel 9-slices through `UI.frame`/`UI.panel`, never `StyleBoxFlat`
  (11 `StyleBoxFlat` uses remain in `scripts/` and are slot candidates for the inventory part); purposeful
  buildings wear the shared sel-out (`docs/art/art-direction.md:5`, `scripts/town/exterior_finish.gd:2-8`).

---

## 2. The SPEC FORMAT: one art slot

### 2.1 Fields

| Field | Meaning | Example |
|---|---|---|
| `id` | `<area>.<kind>.<name>`, lower case, unique, never reused | `town.building.home` |
| `owner` | `codex`, `grok` or `claude` (coded only; no generator) | `codex` |
| `kind` | one of the kinds in 2.2; sets the default checks | `building` |
| `status` | `placeholder`, `candidate`, `approved`, `installed` | `placeholder` |
| `file` | where the finished art goes. A new tree, one file per slot, so a drop never overwrites the dated folders | `res://assets/slots/town/building/home.png` |
| `size` | exact native size of **one cell** in world pixels (or UI 1x pixels) | `[144, 168]` |
| `drawn_at` | on-screen scale: 3 for world and UI frames, 2 for icons, 1 for full-screen menu art | `3` |
| `footprint` | world slots: the solid tile rect from the layout, and the door tiles | `Rect2i(3, 3, 6, 5)`, door `(5, 7)` |
| `anchor` | the pixel the game places: `[x, foot_row]`. `foot_row` is the last row that touches the ground; the y-sort pivot | `[72, 167]` |
| `door_px` | the opening in the art, in px inside the cell; the doorway must read dark against the wall | `Rect2i(60, 112, 30, 56)` |
| `pass_creature` | the town creature the doorway and eaves must clear, measured from its `town/s.png` | `windcut` (54 px tall) |
| `states` | name to frame count and fps; one row per state, frames left to right, every cell `size` | `{"closed": [1, 0], "open": [3, 12]}` |
| `palette` | `{"source": res path of a swatch strip, "max": colour budget, "lock": true/false}` | `{"source": ".../palettes/town_stone.png", "max": 32, "lock": true}` |
| `light` | always `upper_left` unless the slot says otherwise | `upper_left` |
| `outline` | `runtime_rim` (the finish shader recolours the silhouette edge; the art draws no outer line, only internal `#0b0e11` detail), `drawn` (the art carries a 1 px outline, its own darkest ramp tone; icons `#1a1410`), `none` (quiet decorative scenery) | `runtime_rim` |
| `edges` | canvas sides the art may touch: `none`, `bottom`, `all` | `bottom` |
| `alpha` | `binary` (0 or 255 only) or `opaque` (no transparency: backdrops, ground) | `binary` |
| `tiling` | `none`, `h`, `v`, `hv`; for `frame9`, the 1x margins `[l, t, r, b]` | `none` |
| `ref` | the reference render (section 3.3) | `docs/design/placeholder-factory-2026-10-26/refs/town.building.home.png` |
| `brief` | one or two plain sentences: what it is, materials, mood, in Hollowtide's words | "The team's home: a low river-stone cottage with a moss roof, a framed door with a warm lamp inside, a step at the door." |
| `forbid` | always `text`, `creature`, `franchise`; add more per slot | `["text", "creature", "franchise", "people"]` |
| `checks` | check ids from 2.3; the kind's defaults unless overridden | `["C1", "C2", ...]` |
| `placeholder` | the coded painter that draws it today | `TownPlaceholders.building` |

### 2.2 Kinds and their defaults

Budgets are proposals from the measured references (section 0) and the pixel anchor in
`docs/team/SYNTHESIS_FROM_MECH_RPG_2026-10-20.md:68-80` (32 to 48 colours for a 320x180 screen, 16 to 32 for a UI
panel). Preston's look decides.

| Kind | Default owner | Size rule | Colours max | Alpha | Edges | Outline | Tiling |
|---|---|---|---|---|---|---|---|
| `building` (exterior) | codex | footprint x 24 wide; height = footprint rows x 24 plus roof rows above, so walls clear `pass_creature` | 32 | binary | bottom | runtime_rim | none |
| `room` (interior shell) | codex | room tiles x 24 (hall 22x14 = 528x336 today) | 48 | opaque | all | none | none |
| `ground` (town terrain set) | codex | 24x24 cells, or 192x192 sheets as today | 24 per material | opaque | all | none | hv |
| `backdrop` (map scene, menu or cut-scene background) | codex | 384x216 | 48 | opaque | all | none | none or h |
| `prop` (furniture, crates, signs, wall decor) | grok | content to fit; 1 px clear margin except the bottom | 24 | binary | bottom | drawn | none |
| `lamp` (light sources) | grok | as prop; states `unlit`, `lit` as separate stills; flicker and glow are coded | 24 | binary | bottom | drawn | none |
| `character` (non-creature figures only: the soul's light, statues, silhouettes) | grok | cell square, 2 px clear margin on all sides, `foot_row` fixed per frame | 24 | binary | none | drawn | none |
| `hud_piece` (lantern, gauges, badges, chips) | grok | 1x pixels, `drawn_at` 3 | 16 | binary | none | drawn | none |
| `hud_icon` | grok or claude | 16x16, `drawn_at` 2 | 8 | binary | none | drawn (`#1a1410`) | none |
| `frame9` (panels, buttons, plates) | claude | 1x, margins declared | 16 | binary | all | drawn | 9-slice |
| `effect` (non-creature: dust, water, door glints) | claude | coded unless Preston says otherwise | 12 | binary | none | none | none |

Creatures, creature portraits and dialogue faces are not slots. Nothing in this pipeline touches them.

### 2.3 Acceptance checks a script can run

`tools/art/validate_slot.py <slot_id> <candidate.png>` runs these and prints one line each, PASS, FAIL or WARN with
the number. Checks marked *review* cannot be scripted and go on Preston's review sheet.

| Id | Check | Pass rule |
|---|---|---|
| C1 | **Size** | image is exactly `size.x * max_frames` by `size.y * len(states)` |
| C2 | **Colour count** | distinct opaque colours `<= palette.max`, per cell and for the whole sheet |
| C3 | **Alpha** | `binary`: zero pixels with alpha between 1 and 254. `opaque`: every pixel alpha 255 |
| C4 | **Edge contact** | zero opaque pixels on canvas sides the slot does not allow (catches the four buildings above) |
| C5 | **Palette distance** | `lock`: every opaque colour is in the source palette (distance 0 after preparation). Not locked: every colour within 20 RGB units of a palette colour. The raw candidate's mean distance is reported; above 40 is a WARN that the generator ignored the style |
| C6 | **Seam match** (tiles, `h`/`v` slots, 9-slice edges) | mean absolute difference between the left and right edge columns (and top and bottom rows) `<= 10` per channel, max `<= 48`; the same against the neighbouring set's edge when one is named |
| C7 | **Foot row** | the lowest opaque row of every cell equals `anchor.foot_row` (characters 0 px drift; lamps and props 0; flicker frames 1) |
| C8 | **Frame health** | every cell's opaque pixel count within 25% of the median cell; the largest single-colour connected block under 25% of a cell's opaque pixels (catches the ghost and slab frames from the Canvaswing job) |
| C9 | **Specks and orphans** | single pixels with no same-colour 4-neighbour `<= 1%` of opaque pixels; light specks (all four neighbours 50+ darker) counted and reported (the mech skill-up's speck count) |
| C10 | **Doorway reads as a door** (`building`) | `door_px` is fully opaque and its mean brightness is at least 15% under the wall band beside it |
| C11 | **Scale** (`building`, `room`, `prop` near walkways) | `door_px` height `>= pass_creature` height and width `>= 0.75 x` its width, both read from `assets/sprites/arena/<form>/town/s.png` at check time, so a new creature set re-checks every door |
| C12 | **Light side** | WARN only: the silhouette's upper-left edge pixels average brighter than its lower-right edge pixels |
| C13 | **9-slice** (`frame9`) | margins as declared; the edge strips between the margins pass C6 when tiled twice; corners do not repeat |
| R1 | *review*: no text, letters, numbers or signage lettering anywhere |
| R2 | *review*: nothing that reads as another game or franchise (the synthesis's failure mode, `docs/design/imagine-look-2026-10-16.md:8`) |
| R3 | *review*: no creature, animal or person unless the slot asks for one |
| R4 | *review*: sits in the scene: placeholder, candidate and the in-game capture side by side |

`tools/art/finish_sprite.py` already measures partial alpha, orphan pixels, outline gaps and border contact (its
docstring, lines 1-16); the validator imports those measurements instead of writing them again.

### 2.4 A worked example, as it would sit in the registry

```gdscript
"town.building.home": {
	"owner": "codex", "kind": "building", "status": "placeholder",
	"file": "res://assets/slots/town/building/home.png",
	"size": Vector2i(144, 168), "drawn_at": 3,
	"footprint": Rect2i(3, 3, 6, 5), "door_tiles": [Vector2i(5, 7)],
	"anchor": Vector2i(72, 167), "door_px": Rect2i(60, 112, 30, 56), "pass_creature": "windcut",
	"states": {"closed": [1, 0], "open": [3, 12]},
	"palette": {"source": "res://assets/slots/palettes/town_stone.png", "max": 32, "lock": true},
	"light": "upper_left", "outline": "runtime_rim", "edges": "bottom", "alpha": "binary", "tiling": "none",
	"brief": "The team's home: a low river-stone cottage with a moss roof, a framed door with a warm lamp inside and a step in front.",
	"forbid": ["text", "creature", "franchise", "people"],
	"placeholder": "building",
},
```

The numbers in this example (6x5 footprint, 168 px height, a 56 px door) are illustrations of the format, not the
new layout. The rewired town and its footprints are the layout part of this factory.

---

## 3. The DROP-IN PIPELINE in code

### 3.1 The registry: one list the game and the tools both read

- **`scripts/art/art_slots.gd`**, a `const SLOTS := {...}` dictionary like 2.4, split by area into
  `scripts/art/slots/<area>.gd` once it grows. GDScript, not JSON, because it is parse-checked, it exports with the
  game without an export filter, and it can hold `Rect2i` and `Vector2i` directly. The alternative was
  `data/art_slots/*.json`, read by both Godot and Python; it needs an export include rule and loses the types.
- Python tools read **`docs/design/placeholder-factory-2026-10-26/slots.json`**, which the reference renderer writes
  from the registry with the registry file's hash inside; a tool refuses a dump whose hash does not match the
  current registry. One source of truth, never two lists that drift.

### 3.2 The loader: generated file when present, coded placeholder otherwise

`ArtSlots.texture(id) -> Texture2D` (static, cached for the session the way `hub_town.gd` already holds sprites):
1. If `file` exists **and** its size matches the slot, return it. This is the same guard as
   `building_exteriors.gd:39`, moved into one place.
2. If the file exists at the wrong size, print one warning naming the slot and the two sizes, and fall through.
3. Otherwise build the placeholder: `Placeholders.<area>.paint(id, spec) -> Image`, wrapped in an `ImageTexture`.
4. Placeholders are drawn **only** when the art is missing. Nothing paints a placeholder or label over a slot's art
   (the mech lesson at `SYNTHESIS_FROM_MECH_RPG_2026-10-20.md:75-76`).
5. A debug key (and a `--force-placeholders` command line flag for checks and captures) shows every slot's
   placeholder, so Preston can flip between the two.

Painters stop holding paths: `const ART := "res://assets/sprites/world/..."` becomes
`ArtSlots.texture("town.building.home")`. The 114 hard-coded paths move into the registry area by area; the old dated
folders stay where they are as the current art until a slot replaces them.

### 3.3 The reference renderer: what the generator is shown

`tools/art/render_slot_refs.gd`, run headless with the project's own Godot (one Godot at a time), writes per slot
into `docs/design/placeholder-factory-2026-10-26/refs/` (`docs/` has a `.gdignore`, so nothing here is imported):
- `<id>.png`: the placeholder at its exact native size. This is the target.
- `<id>_grid.png`: the same, enlarged with nearest sampling (8x up to 64 px, 4x up to 256, 2x above), with a faint
  line per pixel at 4x and up, a strong line every 24 px tile, the foot row in one colour, `door_px` boxed,
  9-slice margins ruled, and, beside buildings and rooms, the `pass_creature` content box as a flat grey block for
  scale. Flat block, never the creature's art.
- `<id>_card.png`: the single image Grok is given (it takes one): a style sample from installed house art, the
  placeholder, and the palette swatch strip, laid side by side. **No text on any card or reference**, since Grok
  copies labels (`SYNTHESIS_FROM_MECH_RPG_2026-10-20.md:57-58`). Labels live in the spec JSON, not in pictures.
- `<id>.json`: the slot's spec.
- `palettes/<family>.png`: one swatch strip per palette family (town stone, town timber, hall interior, brass UI,
  lantern light), cut from the approved art and coded placeholders of that area with a fixed median cut and no
  dithering.

### 3.4 Preparing a raw generation into a candidate

`tools/art/prepare_slot.py <slot_id> <raw.png> <out.png>`: key the flat magenta background conservatively (Codex's
standing method), crop to the slot's aspect, box-downscale to `size`, harden alpha to 0 or 255, snap to the slot
palette with no dithering (the `reduce` step of `tools/grok_image.py:60-75`, given the slot's numbers), and place
the content so its lowest row sits on `foot_row`. It does not repaint, sharpen or re-outline: Preston's 2026-10-13
call was that heavy finishing made generated art worse.

### 3.5 The validator, the install and the check

- `tools/art/validate_slot.py` (2.3) writes `<candidate>.check.json` beside the candidate; exit 0 only when every
  scripted check passes.
- `tools/art/install_slot.py <slot_id> <candidate.png>` refuses when: a `CODEX_IN_PROGRESS` lock file sits in the
  batch folder or the slot's asset folder; the validator does not pass; or the batch's `review.json` does not hold
  Preston's yes for that slot. It copies the file to `file`, keeps the replaced file under
  `docs/art/slot-backups/<date>/`, records the SHA-256 in `docs/design/placeholder-factory-2026-10-26/installed.json`,
  and sets the slot's status.
- `tools/debug/art_slots_check.gd`, run through `tools/debug/run_checks.py --fixed-fps 30`: every slot resolves to a
  texture of its declared size; every installed file's hash matches; no two slots share a file; and it prints the
  progress number Preston can watch: slots installed out of slots total, per area.

---

## 4. The TASK LIST FORMAT

### 4.1 Files

- `docs/team/CODEX_ART_TASKS_2026-10-26.md` and `docs/team/GROK_ART_TASKS_2026-10-26.md` (the Grok path is the one
  already promised at `docs/team/GROK_TASKS_2026-10-26.md:78`).
- Both are written by `tools/art/write_art_tasks.py` from the registry, so a task can never disagree with the code.
  Hand edits go in the registry, then the list is written again.

### 4.2 Batches

- **One batch is one area**, so a finished batch is something Preston can walk into: the town exteriors, Wayline
  Hall's interior, Home, the Item Shop, Storage, the Scroll Keeper, the Growth Shrine, the landing and dock, the HUD,
  the menus.
- Codex: up to 6 slots a batch. Grok: up to 8 slots a batch, **one image per run** (`tools/grok_image.py`), about
  $0.06 to $0.13 each on the Grok Lite login (`SYNTHESIS_FROM_MECH_RPG_2026-10-20.md:54-55`).
- Every batch delivers into `docs/art/slot-candidates/<batch_id>/<slot_id>/`: `raw.png` (untouched output),
  `prompt.txt`, `ledger.json` (tool, references, cost, date), `prepared.png`, `prepared.png.check.json`.
  Nothing installs from a batch folder until the review.

### 4.3 A Grok task block

```
### GB-<area>-<n>: <slot_id>
Card: docs/design/placeholder-factory-2026-10-26/refs/<slot_id>_card.png
Size: <w>x<h> world px, aspect <a:b>; colours <= <max>; light from the upper left
Make: <brief>, one object only, filling the box, on a flat pure magenta (#FF00FF) background.
Run:  python tools/grok_image.py make <card> docs/art/slot-candidates/<batch>/<slot_id>/raw.png "<make line>" --aspect <a:b>
Then: python tools/art/prepare_slot.py <slot_id> raw.png prepared.png
      python tools/art/validate_slot.py <slot_id> prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

What every Grok prompt must say (most of it is already built into `tools/grok_image.py:26` and `:33-38`):
1. The honesty line first: "if a step fails, or you cannot see the attached image, say so plainly instead of guessing."
2. Read the attached card for style and colours.
3. The make line: what it is, its materials, the game's three-quarter top-down view, one object, flat magenta
   background, the aspect.
4. Clean pixel art: flat colour areas, hard-edged clusters, no gradients or soft blur, light from the upper left.
5. Nothing from any existing franchise.
6. No text, words or letters anywhere, **said twice** (it added labels when told once).
7. No creatures, animals or people unless the slot asks for a figure.

Grok runs in a sealed temporary folder that holds only the card; never from the Preston Hub or the repo
(`SYNTHESIS_FROM_MECH_RPG_2026-10-20.md:52-53`). No AmFam material goes near any prompt.

### 4.4 A Codex task block

```
### CX-<area>-<n>: <slot_id> (<kind>)
Spec:  docs/design/placeholder-factory-2026-10-26/refs/<slot_id>.json
Ref:   refs/<slot_id>.png (target), refs/<slot_id>_grid.png (grid, foot row, door, scale block)
Brief: <brief>
Must:  exact <w>x<h>; colours <= <max> from palettes/<family>.png; <outline rule>; edges <edges>;
       door_px <rect> dark and open to the path; clears <pass_creature> (<h> px)
Deliver to docs/art/slot-candidates/<batch>/<slot_id>/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

This keeps what Codex already does well (originals, prepared files, receipts, hash-guarded scope, native checks at
fixed 30 fps) and moves the install step to after Preston's look.

### 4.5 How Preston reviews a batch before anything installs

1. `tools/art/review_sheet.py <batch_id>` makes one picture for the batch: one row per slot, showing the placeholder,
   the prepared candidate, and a 1152x648 in-game capture with the candidate swapped in (rendered with
   `--force-placeholders` off for that slot only), plus each slot's check results. The review sheet is for Preston,
   so it may carry words; it is never given to a generator.
2. Preston answers per slot in chat: **yes**, **redo** (one line why), or **keep the placeholder**.
3. Claude writes those answers to `docs/art/slot-candidates/<batch_id>/review.json`.
4. `install_slot.py` installs only the yes slots; `art_slots_check` and the area's own checks run
   (`hub_town_check`, `hall_door_check`, `town_room_check`, `ui_fit_check`, through `run_checks.py --fixed-fps 30`).
5. A redo goes back as the same slot id with Preston's reason added to its brief.

---

## 5. What each generator is best and worst at, from the evidence

| | Best at | Worst at | Evidence |
|---|---|---|---|
| **Codex** | Hitting an exact stated size (5 of 5 buildings to the pixel; Canvaswing sets kept at 39, 59 and 41 px). Careful installs: originals kept, scoped hash receipts, native checks (64/64 on Canvaswing). Edits from references with its built-in image tool. Code-native detail painted into the existing ground (Lookout masonry, Dock beams, with no image generation). Finding source bugs and listing them | Colour discipline on generated art (7,842 to 65,412 colours). Soft alpha. Art that fills its canvas to the edge. Scale against creatures when the brief does not state it. Multi-frame generated animation (5 of 8 frames broken). Long evidence write-ups that cost reading time | building measurements above; `docs/AI_COLLABORATION.md:435`; `CODEX_TASKS_2026-10-22.md` task 1; `canvaswing-diagonal-walk-2026-10-22/README.md:25-38` |
| **Grok (Build, Imagine)** | World and UI stills in an existing style from one reference: in the mech RPG Preston installed 6 of 7 (a canyon field, menu and pause panels, title and opening screens). True flat views. Cheap and sealed | Creatures (an armoured gorilla stood upright, a mech bird grew feathers, a kangaroo went cartoon). Lettering unless told twice. Exact pixel sizes and palettes: its output is soft full-resolution art (15,000 to 28,000 colours in the mech screens, 17,378 and 60,737 in Hollowtide's studies) and always needs the prepare step. Type and 9-slice frames ("Imagine cannot set menu type, and it cannot replace the pixel 9-slice frames") | `SYNTHESIS_FROM_MECH_RPG_2026-10-20.md:56-64`, `:70-71`; `imagine-look-2026-10-16.md:13-15`; agent charter line 16 (Grok leads non-creature environment, UI and prop exploration) |
| **Claude, coded** | Exact by construction: frames 4 to 13 colours, icons on a 16 grid, the desk in 18 locked colours, all placeholders | Slower per piece and plainer; not the painterly finish Preston wants long term | `tools/ui/build_frames.py`, `tools/ui/build_icons.py`, `tools/art/guild_desk.py` |

**What follows for the split.** Codex gets the slots where exact size, footprint, doors and integration matter
most: buildings, rooms, town ground, backdrops. Grok gets single stills where a style reference carries the look and
the prepare step can enforce the numbers: props, lamps (the lit and unlit stills; flicker and glow stay coded), HUD
pieces and icons, non-creature figures. Animation frames from either generator get C7 and C8 on every frame before
anyone looks. Frames, type and anything with words stay Claude's coded work unless Preston moves them.

---

## 6. Open questions for Preston

1. **Door and wall scale.** Should a building's doorway clear a stage 2 town creature (Windcut, 54 px, about 2.25
   tiles) or a stage 3 (Stormwick, 69 px)? This sets every building's height in the rewired town.
2. **"Character sprites" for Grok.** Almost every character in Hollowtide is a creature, which stays out. Does
   "character sprites" mean non-creature figures only (the soul's light, statues, signs of people), or job gear drawn
   as separate overlays on creatures (satchels, caps)? Overlays touch creature art, so they need your yes.
3. **UI frames.** The standing rule keeps panels as hand-placed 9-slices. Should Grok be allowed to propose frame
   designs that Claude then redraws by hand, or should frames stay out of the Grok list?
4. **Colour budgets** in 2.2 are proposals (buildings 32, rooms 48, props 24, HUD 16, icons 8). Tighter reads more
   hand-made; looser keeps more of the generator's detail.
5. **Town ground.** The dungeon stays painted in code. Does the same go for the town's ground, or may Codex propose
   town ground sets as slots?
