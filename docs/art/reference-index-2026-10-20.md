# Hollowtide sprite and model reference index (2026-10-20)

Built by Claude on 2026-10-20 from a read-only scan. Counts come from Python globbing and hashing, not from opening images one by one.
Nothing was moved, edited or generated. The scan script lives outside the repo, in the session scratchpad.

Scope: `assets/sprites`, `docs/design`, `docs/art`, `docs/creatures`, `docs/forges`, every 3D model file in the repo, and the shared Opal folder `C:\Users\pmcga\OneDrive\Documents\HollowTide Sprites` (read only).

"Referenced" below means the path string appears in `scripts/`, `scenes/`, `data/`, `dialogue/`, `addons/` or `project.godot`. Arena creature folders are loaded by pattern (`arena/%s/dungeon/...`), so they were checked by folder name. Every arena folder name appears as a string literal in code.

---

## 1. Summary counts

| Area | Images | Notes |
|---|---|---|
| `assets/sprites` (all) | 16,332 | 16,321 PNG, 3 JPG, 8 SVG |
| `assets/sprites/arena` | 14,919 | 51 creature folders plus 35 VFX effects (16 frames each, 560 frames) |
| `assets/sprites/creatures` (legacy battle art) | 756 | front/back stills, idles, attack cut-ins |
| `assets/sprites/effects` | 236 | 17 folders and loose files |
| `assets/sprites/world` | 187 | 41 dated folders |
| `assets/sprites/ui` | 134 | dialogue 109, essence 12, frame 6, item 6, one JPG sheet |
| `assets/sprites/player` | 55 | courier walk sheets, rig pilot |
| `assets/sprites/menu` | 37 | title layers and atlases |
| `docs/design` | 1,084 | 1,053 PNG, 24 JPG, 7 GIF |
| `docs/art` | 7,420 | mostly review and selout working folders |
| `docs/creatures` | 25,256 | 15,539 of these are recolor "before" backups |
| 3D model files in repo | 2 | both `.glb`, both Kithflare, in the sprite3d workshop |
| OneDrive Opal folder | 217 files | 170 images, 29 MP3, 14 files with no extension, 1 ZIP, 1 EXE, 2 MD |

Creature completeness at a glance:

- 51 creature folders under `assets/sprites/arena`: 39 match a `data/creatures/*.tres` file, 12 are town NPCs or crew.
- Every set that exists has all 8 directions (s, se, e, ne, n, nw, w, sw). No set is missing a single direction. No frame is fully transparent.
- 11 of the 39 data creatures are complete (top stills, portrait, small, dungeon still, walk, attack, hurt, sleep).
- 21 of the 39 have no dungeon attack, hurt or sleep frames. Starward has attack but no hurt or sleep.
- 6 of the 39 have no `portrait.png`. 4 of the 39 have no `small` set.
- Every `res://` path inside the 39 creature `.tres` files exists on disk.

---

## 2. Installed creatures: direction completeness

How to read a cell. "8" is a still set with 8 of 8 directions. "8x8" is 8 directions of 8 walk frames. "8x6" is 8 directions of 6 frames (attack, hurt). "8x4" is sleep. "-" means that animation is absent.
Top stills are the arena-size views in `arena/<folder>/*.png`. "Dungeon s.png" is the width of the dungeon still, which shows stage sizing.

What uses each set (from the code):
- Top stills: arena. `portrait.png`: party screen, pause menu, dungeon, hub town. Missing portraits fall back to a dialogue portrait.
- `small`: arena, move preview, creature prologue, riverbank journey, hollow approach.
- `dungeon`: dungeon floors; town and scene kit fall back to it when `town` is missing. Missing attack, hurt or sleep frames mean the still is shown during that action.
- `town`: hub town, town rooms, board scene, scene kit.

### In the creature data (39)

| Folder | Data file (name) | Top stills | Portrait | Small: still / walk | Dungeon: still / walk / attack / hurt / sleep | Dungeon s.png | Town: still / walk / attack / hurt / sleep | Extra sets | Gaps |
|---|---|---|---|---|---|---|---|---|---|
| archroot | 1202_archroot.tres (Archroot) | 8/8 160px | yes | 8 / 8x8 | 8 / 8x8 / - / - / - | 40px | 8 / 8x8 / - / - / - | - | no dungeon attack/hurt/sleep |
| caller | 602_caller.tres (Bend Caller) | 8/8 144px | yes | 8 / 8x8 | 8 / 8x8 / - / - / - | 56px | 8 / 8x8 / - / - / - | - | no dungeon attack/hurt/sleep |
| canvaswing | 1501_canvaswing.tres (Canvaswing) | 8/8 128px | yes | 8 / 8x8 | 8 / 8x8 / 8x6 / 8x6 / 8x4 | 39px | 8 / 8x8 / 8x6 / 8x6 / 8x4 | - | complete |
| cinderhide | 002_cinderhide.tres (Cinderhide) | 8/8 128px | yes | 8 / 8x8 | 8 / 8x8 / 8x6 / 8x6 / 8x4 | 32px | 8 / 8x8 / 8x6 / 8x6 / 8x4 | - | complete |
| clinkerhide | 101_clinkerhide.tres (Clinkerhide) | 8/8 144px | yes | 8 / 8x8 | 8 / 8x8 / - / - / - | 39px | 8 / 8x8 / - / - / - | - | no dungeon attack/hurt/sleep |
| dustkite | 1401_dustkite.tres (Dustkite) | 8/8 128px | yes | 8 / 8x8 | 8 / 8x8 / 8x6 / 8x6 / 8x4 | 43px | 8 / 8x8 / 8x6 / 8x6 / 8x4 | - | complete |
| fusern | 106_fusern.tres (Fusern) | 8/8 128px | yes | 8 / 8x8 | 8 / 8x8 / 8x6 / 8x6 / 8x4 | 33px | 8 / 8x8 / 8x6 / 8x6 / 8x4 | - | complete |
| galeshear | 1503_galeshear.tres (Galeshear) | 8/8 192px | yes | 8 / 8x8 | 8 / 8x8 / - / - / - | 62px | 8 / 8x8 / - / - / - | - | no dungeon attack/hurt/sleep |
| gruntle | 2401_gruntle.tres (Gruntle) | 8/8 128px | **no** | **none** | 8 / 8x8 / 8x6 / 8x6 / 8x4 | 40px | 8 / 8x8 / 8x6 / 8x6 / 8x4 | - | no portrait; no small set |
| highsignal | 1403_highsignal.tres (Highsignal) | 8/8 160px | yes | 8 / 8x8 | 8 / 8x8 / - / - / - | 63px | 8 / 8x8 / - / - / - | - | no dungeon attack/hurt/sleep |
| huskward | 1702_tallowroot2.tres (Huskward) | 8/8 144px | yes | 8 / 8x8 | 8 / 8x8 / - / - / - | 44px | 8 / 8x8 / - / - / - | - | no dungeon attack/hurt/sleep |
| ironvent | 102_ironvent.tres (Ironvent) | 8/8 160px | yes | 8 / 8x8 | 8 / 8x8 / - / - / - | 56px | 8 / 8x8 / - / - / - | - | no dungeon attack/hurt/sleep |
| kithflare | 103_kithflare.tres (Kithflare) | 8/8 128px | yes | 8 / 8x8 | 8 / 8x8 / 8x6 / 8x6 / 8x4 | 37px | 8 / 8x8 / 8x6 / 8x6 / 8x4 | - | complete |
| listener | 601_listener.tres (Cutbank Listener) | 8/8 128px | yes | 8 / 8x8 | 8 / 8x8 / 8x6 / 8x6 / 8x4 | 41px | 8 / 8x8 / 8x6 / 8x6 / 8x4 | escort (full 200) | complete |
| mirekit | 2201_mirekit.tres (Mirekit) | 8/8 128px | **no** | 8 / 8x8 | 8 / 8x8 / 8x6 / 8x6 / 8x4 | 39px | 8 / 8x8 / - / - / - | - | no portrait |
| oathfen | 902_oathfen.tres (Oathfen) | 8/8 144px | yes | 8 / 8x8 | 8 / 8x8 / - / - / - | 47px | 8 / 8x8 / - / - / - | - | no dungeon attack/hurt/sleep |
| oxbowarchon | 903_oxbowarchon.tres (Oxbowarchon) | 8/8 160px | yes | 8 / 8x8 | 8 / 8x8 / - / - / - | 57px | 8 / 8x8 / - / - / - | - | no dungeon attack/hurt/sleep |
| ozbender | 2601_ozbender.tres (Ozbender) | 8/8 128px | **no** | **none** | 8 / 8x8 / 8x6 / 8x6 / 8x4 | 34px | 8 / 8x8 / 8x6 / 8x6 / 8x4 | - | no portrait; no small set |
| preostmar | 901_preostmar.tres (Preostmar) | 8/8 128px | yes | 8 / 8x8 | 8 / 8x8 / 8x6 / 8x6 / 8x4 | 38px | 8 / 8x8 / 8x6 / 8x6 / 8x4 | - | complete |
| punchybun | 2101_punchybun.tres (Punchybun) | 8/8 128px | yes | 8 / 8x8 | 8 / 8x8 / 8x6 / 8x6 / 8x4 | 33px | 8 / 8x8 / 8x6 / 8x6 / 8x4 | - | complete |
| rampartroot | 1703_tallowroot3.tres (Rampartroot) | 8/8 160px | yes | 8 / 8x8 | 8 / 8x8 / - / - / - | 62px | 8 / 8x8 / - / - / - | - | no dungeon attack/hurt/sleep |
| riftfin | 502_riftfin.tres (Riftfin) | 8/8 160px | yes | 8 / 8x8 | 8 / 8x8 / - / - / - | 43px | 8 / 8x8 / - / - / - | - | no dungeon attack/hurt/sleep |
| rimefin | 001_rimefin.tres (Rimefin) | 8/8 128px | yes | 8 / 8x8 | 8 / 8x8 / 8x6 / 8x6 / 8x4 | 35px | 8 / 8x8 / 8x6 / 8x6 / 8x4 | - | complete |
| scourmaw | 503_scourmaw.tres (Scourmaw) | 8/8 160px | yes | 8 / 8x8 | 8 / 8x8 / - / - / - | 60px | 8 / 8x8 / - / - / - | - | no dungeon attack/hurt/sleep |
| skimlet | 2501_skimlet.tres (Skimlet) | 8/8 128px | **no** | **none** | 8 / 8x8 / 8x6 / 8x6 / 8x4 | 55px | 8 / 8x8 / 8x6 / 8x6 / 8x4 | - | no portrait; no small set |
| slagglass | 107_slagglass.tres (Slagglass) | 8/8 144px | yes | 8 / 8x8 | 8 / 8x8 / - / - / - | 42px | 8 / 8x8 / - / - / - | - | no dungeon attack/hurt/sleep |
| sparkjab | 2102_sparkjab.tres (Sparkjab) | 8/8 144px | yes | 8 / 8x8 | 8 / 8x8 / - / - / - | 45px | 8 / 8x8 / - / - / - | - | no dungeon attack/hurt/sleep |
| sparkwick | 109_kithflare2.tres (Sparkwick) | 8/8 144px | yes | 8 / 8x8 | 8 / 8x8 / - / - / - | 55px | 8 / 8x8 / - / - / - | - | no dungeon attack/hurt/sleep |
| springvault | 1203_springvault.tres (Springvault) | 8/8 192px | yes | 8 / 8x8 | 8 / 8x8 / - / - / - | 54px | 8 / 8x8 / - / - / - | - | no dungeon attack/hurt/sleep |
| starward | 2103_starward.tres (Starward) | 8/8 160px | yes | 8 / 8x8 | 8 / 8x8 / 8x6 / - / - | 57px | 8 / 8x8 / 8x6 / - / - | - | dungeon lacks hurt/sleep |
| stormwick | 110_kithflare3.tres (Stormwick) | 8/8 160px | yes | 8 / 8x8 | 8 / 8x8 / - / - / - | 82px | 8 / 8x8 / - / - / - | - | no dungeon attack/hurt/sleep |
| tallowroot | 1701_tallowroot.tres (Tallowroot) | 8/8 128px | yes | 8 / 8x8 | 8 / 8x8 / 8x6 / 8x6 / 8x4 | 34px | 8 / 8x8 / 8x6 / 8x6 / 8x4 | - | complete |
| troughspine | 1201_troughspine.tres (Troughspine) | 8/8 128px | yes | 8 / 8x8 | 8 / 8x8 / 8x6 / 8x6 / 8x4 | 46px | 8 / 8x8 / - / - / - | - | complete (town has no actions) |
| valvekin | 2701_valvekin.tres (Valvekin) | 8/8 128px | **no** | **none** | 8 / 8x8 / 8x6 / 8x6 / 8x4 | 32px | 8 / 8x8 / 8x6 / 8x6 / 8x4 | - | no portrait; no small set |
| vitrecrag | 108_vitrecrag.tres (Vitrecrag) | 8/8 160px | yes | 8 / 8x8 | 8 / 8x8 / - / - / - | 55px | 8 / 8x8 / - / - / - | - | no dungeon attack/hurt/sleep |
| warden | 603_warden.tres (Quietwater Warden) | 8/8 160px | yes | 8 / 8x8 | 8 / 8x8 / - / - / - | 58px | 8 / 8x8 / - / - / - | boss (8 / 8x8, 110px) | no dungeon attack/hurt/sleep |
| waywhistle | 1402_waywhistle.tres (Waywhistle) | 8/8 144px | yes | 8 / 8x8 | 8 / 8x8 / - / - / - | 57px | 8 / 8x8 / - / - / - | - | no dungeon attack/hurt/sleep |
| whinet | 2301_whinet.tres (Whinet) | 8/8 128px | **no** | 8 / 8x8 | 8 / 8x8 / 8x6 / 8x6 / 8x4 | 40px | 8 / 8x8 / - / - / - | - | no portrait |
| windcut | 1502_windcut.tres (Windcut) | 8/8 144px | yes | 8 / 8x8 | 8 / 8x8 / - / - / - | 45px | 8 / 8x8 / - / - / - | - | no dungeon attack/hurt/sleep |

The 21 data creatures with no dungeon actions: archroot, caller, clinkerhide, galeshear, highsignal, huskward, ironvent, oathfen, oxbowarchon, rampartroot, riftfin, scourmaw, slagglass, sparkjab, sparkwick, springvault, stormwick, vitrecrag, warden, waywhistle, windcut.

<details><summary>Not in the creature data: town NPCs and guild/rival crew (12 folders)</summary>

These do not need a `small` set or attack frames unless they fight. "Town only" means no dungeon set, so they cannot appear as dungeon wilds.

| Folder | Top stills | Portrait | Dungeon: still / walk | Dungeon s.png | Town: still / walk | Extra | Gaps |
|---|---|---|---|---|---|---|---|
| cairnshell | 8/8 208px | no | 8 / 8x8 | 56px | 8 / 8x8 | - | no portrait; no dungeon actions |
| crawdukes | 8/8 208px | no | 8 / 8x8 | 53px | 8 / 8x8 | - | no portrait; no dungeon actions |
| grubbit | 8/8 128px | no | 8 / 8x8 | 35px | 8 / 8x8 | town `idle_s` | no portrait; no dungeon actions |
| inkhoot | 8/8 160px | no | none | - | 8 / 8x8 | - | no portrait; town only |
| muskin | 8/8 128px | no | 8 / 8x8 | 37px | 8 / 8x8 | town `idle_s` | no portrait; no dungeon actions |
| pouchbill | 8/8 144px | no | none | - | 8 / 8x8 | - | no portrait; town only |
| rinsepaw | 8/8 144px | no | 8 / 8x8 | 48px | 8 / 8x8 | town `idle_s` | no portrait; no dungeon actions |
| slipjaw | 8/8 128px | no | 8 / 8x8 | 48px | 8 / 8x8 | town `idle_s` | no portrait; no dungeon actions |
| stillwade | 8/8 144px | no | 8 / 8x8 | 59px | 8 / 8x8 | town `idle_s` | no portrait; no dungeon actions |
| swaphoard | 8/8 144px | no | none | - | 8 / 8x8 | - | no portrait; town only |
| wayling | 8/8 128px | no | none | - | 8 / 8x8 | - | no portrait; town only |
| wickglow | 8/8 144px | no | 8 / 8x8 | 47px | 8 / 8x8 | town `idle_s` | no portrait; no dungeon actions |

</details>

<details><summary>Arena VFX (35 effects, 16 frames each)</summary>

cocoon_stone, downdraft_column, earth_burst, ember_patch, fire_burst, glass_pool, glass_splash, gust_lift, hush_ring, jade_burst, jade_spikes, lantern_ball, lantern_flash, light_slash, mark_glyph, molten_drip, riptide_whirl, rock_dust, root_burst, root_snare, sail_cover, sail_slash, seed_pod, shock_burst, slab_vortex, slam_shock, smoulder, sonar_ring, spark_bolt, star_field, star_shield, steam_puff, still_water, vent_flame, water_burst. All complete at 16 frames. Loaded by pattern `arena/vfx/%s/f%02d.png`.

</details>

### Legacy battle art: `assets/sprites/creatures` (756 images)

The 2026-09 and early 2026-10 battle screen art. 21 of the 39 `.tres` files still point their front and back here (idle frames, material-detail fronts, Retro Diffusion matches, stone line, punchybun stages). The other 18 point at `arena/<folder>/s.png`.

- 77 top-level entries: 25 referenced by the game, 5 only by tools, 20 only by docs, 27 not referenced anywhere.
- Attack cut-in folders (`attacks/`, 9 moves) are loaded by `battle_screen.gd` and the move data.
- Retired creatures Coalcrest and Wayburn (see `data/retired_creatures`) still have 17 entries (21 images) here.

<details><summary>Unreferenced legacy creature files (27, no code, tool or doc mentions)</summary>

Mostly the Retro Diffusion sheets from 2026-10-01:
clinkerhide_rd_8dir, clinkerhide_rd_back, coalcrest_rd_8dir, coalcrest_rd_back, coalcrest_rd_front, coalcrest_rear_2026_09_27, fusern_rd_8dir, fusern_rd_back, fusern_rd_front, kithflare_back, kithflare_rd_8dir, kithflare_rd_back, kithflare_rd_front, kithflare_redesign_back, rimefin_rd_8dir, rimefin_rd_back, slagglass_back, slagglass_rd_8dir, slagglass_rd_back, slagglass_rd_front, vitrecrag_rd_8dir, vitrecrag_rd_back, vitrecrag_rd_front, wayburn_rd_8dir, wayburn_rd_back, wayburn_rd_front, wayburn_rear_2026_09_27.

Docs-only (20): coalcrest back-head, fin-complete, rechecked, refined, tail-root folders and redesign front; fusern.png; kithflare.png, kithflare_redesign_front, kithflare tail-attached and tail-polish folders; rimefin.png; slagglass.png, slagglass_head_right, slagglass_redo_2026_10_08, slagglass_true_rear; tallowroot_2026_10_05; vitrecrag_back_official_2026_09_30, vitrecrag_rear_palette_snapped_candidate; wayburn_front_2026_09_27.

Tools-only (5): `idle/` (vitrecrag flame), ironvent.png, oxbowarchon_style_candidate_2026_09_29, vitrecrag_official, vitrecrag_rear_2026_09_27.

</details>

### Effects, world, UI, menu, player

- `effects/` (236): 14 of 22 entries are used. Not referenced: folders cinderhide (1), clinkerhide (10), coalcrest (6), fusern (5), slagglass (2), wayburn (2), and `fire_ember_1.png`. `preostmar/` (6) is docs-only. Their names and most counts line up with the OneDrive effect sheet folders, so they look like imports that were never wired in (not checked by hash, since the formats differ).
- `world/` (187 in 41 folders): 39 used. `courtyard_home_linework_2026_10_04` (4) is unreferenced. `scroll_keeper_2026_10_10` (1) is docs-only.
- `ui/` (134): dialogue and frame are used directly. essence (12) and item (6) are loaded by name through `ui_style.gd` `icon()`. `main_hud_sheet.jpg` is docs-only.
- `menu/` (37): all loose layers are loaded by `main_menu.gd`. `retro_diffusion_idle_2026_10_01` atlases are loaded by `main_menu_art_preview.gd`. `village_actors_2026_10_09` is used.
- `player/` (55): courier walk sheets, chibi eight-direction walks from Retro Diffusion, and the rig pilot. The courier is not in `arena/`.
- Loose SVGs at `assets/sprites/` root: 8 placeholders and studies. Only `river_call_placeholder.svg` is referenced.

---

## 3. Proposal art not installed

None of these names (Flintram, Mortarback, Cutbank Bastion, Ballastak, Switchhold, the agile line) exist in `assets/sprites/arena`, in `data/creatures`, or in game code. Each README says the art waits on Grok's numbers and Preston's approval.

| Folder | Creature / stage | 8-view sets (cut) | Raw sheets | Walk | Dungeon / town / small | Notes |
|---|---|---|---|---|---|---|
| `docs/design/new-creature-agile-line-2026-10-14` (49 images) | Agile blade line, Stage I | `stage1_views_128` 8/8 | step1, ear edit, ears 8dir | none | none | No name or essence yet |
| same | Stage II | `stage2_views_144` 8/8 | step1, step2 front, step3 | none | none | |
| same | Stage III take 1 (chosen) | `stage3_views_160` 8/8 | step1, step2 front, step3 | none | none | Memory: ne and nw still show the face |
| same | Stage III take 2 (not chosen) | `stage3_take2_views_160` 8/8 | take2 8dir | none | none | Superseded by take 1 |
| `docs/design/new-creature-ballastak-2026-10-13` (69) | Ballastak, Stone digger Stage I | `views_128` 8/8 | 8dir, se master, e profile | none | none | Plus `_three_quarter_e_w` (e, w) and contact sheets |
| same, `parts_kit/` | Ballastak palette and part variants | crest_from_switchhold 8/8, palette_clay 8/8, palette_moss 8/8, palette_night 8/8 | - | none | none | Variant study, not a stage |
| same, `switchhold/` | Switchhold, Stage II | `views_128` 8/8 | `raw_pixellab` 8/8 | none | none | PixelLab character tool |
| (none) | Digger Stage III | none | none | none | none | Not started |
| `docs/design/new-creature-flintram-2026-10-14` (44) | Flintram, line 10 Stage I | `views_128` 8/8 | `flintram_8dir_raw.jpg` (canon sheet) | none | none | Canon is the Opal eight-view sheet |
| same, `mortarback/` | Mortarback, Stage II | `views` 8/8 | second 8dir sheet | none | none | `_superseded/views_144_first_sheet` 8/8 kept |
| same, `cutbank_bastion/` | Cutbank Bastion (compared with Mortarback, likely Stage III) | **none** | takes 1, 3, 4, 5 and take 6 steps 1 to 3 | none | none | No cut views yet |
| `docs/design/sprite3d-workshop-2026-10-12` (117 + 2 GLB) | Kithflare rendered from 3D | `pixel_128` 8/8, `pixel_dungeon` 8/8, `renders_rd_lite` 8/8, `model_kithflare/views_128` 8/8, `model_kithflare/views_dungeon` 8/8 | turntable, render, walk sheet | `renders_walk` 8x6; `pixel_walk` **only s and e** (6 frames) | - | Experiment; the game Kithflare uses the drawn set |
| `docs/design/refinement-pass-2026-10-14` (4) | UI screenshots | - | - | - | - | Before/after evidence, not sprite art |

<details><summary>Other docs/design folders with images (scene and UI captures, not creature references)</summary>

pilot-waking 179, waking-art 100, rootbank-warren-finish 81, opening-checks 38, rising-water-finish 28, world-tiles 26, rival-crew 25, dialogue-corner 24, town-detail 24, village-actors 21, board-scene 19, dungeon-tiles 18, creature-player-opening 17, boss-intro 15, flood-waking-finish 14, guild-morning 14, flood-opening 11, pond-stone 11, plus 36 folders with 1 to 9 images and a few with none. `imagine-look-2026-10-16` holds 3 JPG look references.

</details>

<details><summary>docs/creatures and docs/art working folders (largest first)</summary>

docs/creatures (25,256 images): recolor-2026-10-11 15,539 (the "before" backups), gale-recolor 1,959, handoff-palette-locks 1,594, arena-vitrecrag 1,210, arena-starters 1,122, selout 801, arena-material-consistency 770, arena-ironvent 375, listener-palette-refinement 323, floaters 321, starward-resize 240, actions 113, galeshear-wing-repair 110, starter-lines-rd 100, riftfin-back 75, arena-feel 65, plus 40 more folders (24 of them under 10 images). `source-art/` holds 9 original Opal fronts (Cinderhide, Clinkerhide, Coalcrest, Fusern, Ironvent, Slagglass, Vitrecrag, Wayburn, Vitrecrag inhale). `riftfin-3d-test-2026-10-06` holds 6 renders and no model file.

docs/art (7,420 images): new-scene-selout 1,981, world 1,509, crew-selout 1,313, review 1,250, crew-idles 930, characters 131, crew-dungeon-selout 56, menu 38, new-creatures-selout 37, palettes 9, wayling-source-margin 2, plus 2 loose Vitrecrag style reviews.

Other: docs/trailer 457, docs/ui 424, docs/world 586, docs/Codex 90, docs/battle 57, `docs/HollowTide Sprites/Attack Sheets/Vitrecrag Lava Pour` 8 (copies of OneDrive Vitrecrag sheets).

</details>

---

## 4. 3D models

Searched the whole repo (not `.git` or `.godot`) for .blend, .glb, .gltf, .obj, .fbx, .vox, .dae, .stl, .ply, .bbmodel, .usd.

| File | Size | What it is |
|---|---|---|
| `docs/design/sprite3d-workshop-2026-10-12/model/kithflare_rd_lite.glb` | 191,260 B | Retro Diffusion low-poly Kithflare |
| `docs/design/sprite3d-workshop-2026-10-12/model/kithflare_rd_lite_walk.glb` | 244,588 B | Same model with a walk animation |

No .blend file exists in the repo. Memory says a hand-built Kithflare was modelled on 2026-10-13 and matched the drawn views at 0.56 to 0.58. Its model file is not in the repo; only its renders and `model_kithflare/scores.json` are. The Unity port parked on D: was not scanned.

---

## 5. OneDrive Opal sheets

`C:\Users\pmcga\OneDrive\Documents\HollowTide Sprites` (read only, permission to use, never modify). 217 files.

| Folder | Files | Contents |
|---|---|---|
| `Creatures/Creature-Effect Sheets` | 76 JFIF | Cinderhide 1, Clinkerhide 10, Coalcrest 6, Fusern 5, IronVent 11, Kithflare 1, Oxbowarchon 11, Preostmar 1 ("Proestmar" folder), Slagglass 4, Vitrecrag 24 (5 attack subfolders: Molten Beam 4, Molten Cannon 4, Molten Glass 5, Plate Lunge 4, Projectile Effects 5; plus Lava Pour and a title card candidate), Wayburn 2 |
| `Creatures/Creatures-Back` | 10 | Cinderhide, Clinkerhide, Coalcrest, Fusern, Ironvent, Oxbowarchon, Slagglass, Vitrecrag, Wayburn, one unnamed WEBP |
| `Creatures/Creatures-Front` | 8 | Cinderhide, Clinkerhide, Ironvent, Oxbowarchon, ferret1_view; `Candidates/` holds 2 outside reference images and a README |
| `Creatures/Signature-Titlecards` | 3 | Ironvent title card PNG, Oxbowarchon title card (no extension), and `GeminiSetup.exe` (13.3 MB) |
| `Creatures/Creature-Sounds` | 20 MP3 | |
| `Creatures/` root | 1 | `Sootblack_Endurance_Courser.png` |
| `Character` | 27 | Courier and female walk sheets, chibi sources, menu sprites, a third-party Nexomon image |
| `Idle Animation Sheets` | 19 | Ironvent claw 4, Vitrecrag inhale 3, 2 unnamed; `Character/` 10 (8 are exact copies of `Character/`) |
| `Opal` | 15 | 9 Forge exports (no extension), "Untitled Opal app", River Listener Stage I approved original, Vitrecrag rear candidate 2, 3 untitled PNGs |
| `Game-Ideas` | 18 | Coromon and Nexomon screenshots and maps (structure-only references) |
| `Assets` | 7 | Grok tile and prop sheets, Cutbank tiles, map tile, tilemap, bluff-top grass |
| `Hollowtide Music` | 9 MP3 | |
| `Old` | 1 | Kithflare pose 2 |
| root | 3 | `.gdignore`, an AVIF, `Opal-Forges folder.zip` (4.4 MB, 15 entries, same sizes as `Opal/`) |

Links to the repo (by SHA-256, byte-identical):
- 36 OneDrive files have an exact copy in the repo. Examples: the 9 `Opal/` Forge exports equal `docs/forges/opal-export/*.json`; 3 fronts equal `docs/creatures/source-art/`; 5 Vitrecrag sheets equal `docs/HollowTide Sprites/Attack Sheets/Vitrecrag Lava Pour/`; the courier source equals `assets/sprites/player/character_walk_sheet.jpg`.
- The effect sheet folders for Cinderhide, Clinkerhide, Coalcrest, Fusern, Slagglass, Wayburn and Preostmar have same-named folders in `assets/sprites/effects/`, and those folders are not used by the game.
- The current Forges (Sprite Forge v5, Evolution Forge v5 and v5.1 in `docs/art/opal-forges`) are not in OneDrive. OneDrive and `docs/forges/opal-export` hold the older 2026-09-30 exports.

Inside OneDrive: 12 duplicate groups, 13 extra copies (the `Idle Animation Sheets/Character` mirror, `back` / `back.png`, `right` / `right.png`, the AVIF and its PNG twin, `Male.jpg` = `Main Courier - Chibi Source.jpg`, and two identical Ironvent roar MP3s).

---

## 6. Manifests

| File | What it records | State |
|---|---|---|
| `docs/art/spritecook-assets.json` | 13 SpriteCook asset IDs with sha12 and label. No URLs or tokens. | 12 of 13 match a local file by sha12 (Kithflare 3D se render, 6 style refs from `arena/*`, the gpt-image-2 Kithflare repaint, 4 Ballastak files). **1 has no local file:** "ballastak e, second profile edit (used for e, mirrored for w)", sha12 `c746322a21b5`. |
| `docs/art/opal-forges/` | `hollowtide-sprite-forge-v5.json`, `hollowtide-evolution-forge-v5.json`, `hollowtide-evolution-forge-v5.1.json`, two builder scripts, README | Current Forge definitions (5 or 6 nodes each) |
| `docs/forges/opal-export/` | 9 older Forge exports (Attack, Back View, Character Model, Effect Sheet, Evolution, Idle, Sprite, Walk Cycle, World Asset) | Same bytes as OneDrive `Opal/` |
| `docs/forges/records/` | `forge-audit-prompts`, `forge-installed-prompts`, `verified-export-revisions` JSON, 2 install screenshots | 2026-09-30 records |
| `assets/sprites/**.json` (17) | Frame-slice maps for Oxbowarchon rail, Vitrecrag lava pour and plate lunge, molten cannon effects; `village_actors/animations.json`; `player/rig_pilot/manifest.json` | In use with their sheets |
| `docs/design/sprite3d-workshop-2026-10-12/` | `measure_rd_128.json`, `measure_rd_dungeon.json`, `model_kithflare/scores.json` | Workshop scores |

There is no single manifest of creature sprite sets. This index is the closest thing.

---

## 7. Gaps worth fixing

Ranked by how much the player would notice.

1. **Dungeon actions missing for 21 of 39 creatures.** They hold a still while attacking, getting hit or sleeping. Starward also lacks hurt and sleep. Mirekit, Troughspine and Whinet have dungeon actions but none in town (minor).
2. **Proposal lines have stills only.** Agile line (3 stages), Ballastak and Switchhold, Flintram and Mortarback all have 8 cut views but no walk, dungeon, town or small sets, and no data. Cutbank Bastion has raw sheets only and no cut views. The digger line has no Stage III. These wait on Grok's numbers and Preston's approval, so this is a queue, not a fault.
3. **Portraits missing for 6 data creatures:** gruntle, mirekit, ozbender, skimlet, valvekin, whinet. The party screen and pause menu fall back to the dialogue portrait. All 12 NPC folders also lack portraits.
4. **Small set missing for 4 data creatures:** gruntle, ozbender, skimlet, valvekin. They cannot appear in the arena, move preview or hollow approach without a fallback.
5. **Orphans and clutter.**
   - 27 unreferenced legacy creature files (mostly 2026-10-01 Retro Diffusion sheets), 8 of them for retired Coalcrest and Wayburn.
   - 6 unreferenced effect folders plus `fire_ember_1.png` (cut from OneDrive sheets, never wired in).
   - 7 unreferenced placeholder SVGs at the `assets/sprites` root; `world/courtyard_home_linework_2026_10_04`.
   - 15,539 recolor "before" backups in `docs/creatures/recolor-2026-10-11`.
   - Agile Stage III take 2 and Mortarback `_superseded` are kept but not chosen.
   - Sprite3d workshop `pixel_walk` has only 2 of 8 directions.
   - SpriteCook manifest entry `c746322a21b5` has no local file.
   - OneDrive: 13 duplicate copies, and a 13.3 MB `GeminiSetup.exe` sitting in `Signature-Titlecards`. It was not opened or run; Preston should decide whether it belongs there.

Not checked: image content quality (palette, outline, stage size rules), the `.godot` import cache, the Unity project on D:, and the mech-zoids repo.
