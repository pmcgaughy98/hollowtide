# VFX pass 2: painted sheets for every kit (Claude, 2026-10-08)

**Preston:** "VFX pass and upgrades, we can use diffusion to upgrade all kits." Retro Diffusion's `rd_animation__vfx` style again (`tools/arena/rd_vfx.py`, then `slice_vfx.py`: 16 frames, shrunk by half), 24 sheets ordered at $0.07 each, 23 delivered ($1.61; `gale_streak` failed on Retro Diffusion's side with a 502 and nothing drew it anyway). Zones were ordered at 96 px (48 px frames), the rest at 64 (32 px frames).

## What plays where
| Sheet | Where |
|---|---|
| `sonar_ring` | Echo Tap's landing, Interrupt Call (x2.5), Deep Brace (and a faint loop while braced) |
| `sail_slash` | Shear; every enemy swept by Gale Shear |
| `gust_lift` | Sail Cover on the ally, both ends of Lift, the tailwind on allies at Gale Shear |
| `jade_burst` | every jade break: Jade Lance landing, slabs shattering, the cocoon bursting (x2) |
| `slam_shock` | under Club Slam and Plate Lunge |
| `steam_puff` | the Quench combo |
| `spark_bolt` | where Wick Bolt lands, every Conduct arc, the Chain payout |
| `jade_spikes` | Ground Spikes |
| `ember_patch` (loop) | Ember Feint's patches |
| `star_shield` (loop) | every star shield (Star Guard, Starshield, the Chain payout) |
| `sail_cover` (loop) | a sail shield from Sail Cover (shields now remember which sheet to wear) |
| `molten_drip` (loop) | over a Glassed creature |
| `smoulder` (loop) | over a smouldering creature |
| `cocoon_stone` (loop) | over a Stone Cocoon |
| `seed_pod` (loop) | the seed lob in flight (molten lobs keep the coded glass) |
| `root_snare` (loop) | under a snared creature, with the coded roots over it |
| `slab_vortex` (loop) | Slab Vortex |
| `riptide_whirl`, `still_water`, `downdraft_column`, `glass_pool`, `star_field` (loops) | the zones, through `_draw_zone`, scaled to each zone's radius |

Code: `_draw_sheet` took a `scale`; `_draw_zone` draws one looping frame stretched to a zone's radius and flattened by the camera; impacts carry an optional `scale`; the loader skips any sheet not on disk, so the arena runs with or without them.

## What was learned
- One sheet (`hush_ring`, "a dark ring of silence") came back with an opaque dark background (58% of its frame, 46% of its border) and painted a box over the arena; it is dropped and Hush keeps its coded rings. Every other sheet is clean (0% border opacity, bar a few pixels on the sail slash and star field). Measure the border before wiring a dark-themed sheet.
- Dark, "calm" prompts (still water, the downdraft column) come back as dim blobs rather than readable water or air at 48 px; they sit under the coded rings, which carry the read. If a later pass wants them stronger, prompt for bright edges.

## Check
`tools/debug/arena_vfx2_check.gd`: 34 of 34 listed sheets load; stills `zones.png`, `statuses.png`, `oneshots.png`, `projectiles.png` here. **Codex:** these sheets were not palette-locked; if the line palettes get a pass, the sheets are in `assets/sprites/arena/vfx/`.
