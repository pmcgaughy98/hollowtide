# Wayline Tower: The Reach and the Waiting Lamp (design, 2026-10-27)

Status: **approved with the defaults, 2026-10-27 (Preston: "go with the defaults and build it").** The crook holds the lamp; 720 px (30 tiles); the 72 px look-up lean; town.building.hall pulled out of cx-01-buildings; v1 keeps the legacy Hall until Preston walks v2; the new names stay working labels. Same day: the title screen town becomes Highbank with the Tower prominent, and today's title village is kept as the reference for a future town on another map. Built the same day as a coded blockout (no painting, nothing committed): `scripts/town/tower_parts.gd`, slot rows in `scripts/art/slots/town_tower.gd`; what that build verified is in section 13.

Earlier status: proposal for Preston. Nothing here was canon or wired yet. Ids stay `hall` (place, slot `town.building.hall`, rooms `hall` and `hall_low`, area `hall_rise`, flag `tower_seen`). Mocks: `mock_tower_1x.png`, `mock_tower_3x_crop.png`, `mock_far_view.png`, `mock_parts_sheet.png`, all drawn by `mock_tower.py` in this folder (Python flat blockout, not Godot).

## 1. The idea
A rooted river-stone tower, 30 tiles tall, built up in eras around a living root older than Highbank. The root (the Reach) climbs the tower's left side, comes up through the top deck and curls over like a crook to hold the runner's lantern (the Waiting Lamp) right above the door where every route starts. Waylines (cables) run from the deck down to posts all over town, so the company's name is something you can see.

Why it beat the other two concepts (judges 41, 42, 41 against 35 to 37 and 31 to 34): it is the only silhouette that stays readable from full size down to a 16 px icon (a hooked column with one lit dot), its crown is not a lighthouse, and it speaks Highbank's own root-and-moss house style at landmark scale. Grafted in: the Knot's wiring (hall id stays on the door part, half-size key, ring split around the crown, Route Board, ground yard, look-up lean, parcel story in the reveal) and the Spine's map ideas (the Climb, painted rise stair, far art painted for its own size).

## 2. What it says about couriers
- **The lamp is the runner's lantern at town scale**, the twin of the dungeon run's clock. Lit while any runner is out ("somebody's waiting up on 'em", draft line).
- **It works like a mail elevator:** parcels come in at the depot porch, ride the hoist up the right side, get sorted in the cubby wall, slide back down the chute, and leave on waylines.
- **Every opened route adds a line, a post and a lantern** on the deck rim. One lantern stays dark over a slack line for the route that went quiet: Hollow shown as absence, never a ghost.
- **Built for many bodies, always shown empty:** the 48x64 double door clears Galeshear, flyer landing boards and a ring perch, a burrow hatch for the dark sorting room, root treads for climbers.
- **The approved crew's jobs sit on the walls** without drawing a creature: Wayling's Route Board over the gate, Grubbit's hatch and cubbies, Stillwade's flood bell and high-water cuts, Wickglow's lanterns and lamp, Rinsepaw's mess chimney, the juniors' hoist yard.
- **No one runs a route alone:** partners touch the First Post (the original relay stone in the left jamb, worn pale) before a run.

## 3. Silhouette and tiers, bottom to top
Wide and rooted at the foot (the Great Root sweeps out of the turf on the left, the hoist yard spreads right), then round tiers that step in, mostly on the right. Working parts stick out at alternating heights: hoist jib (right, low), perches (left, middle), flood bell (left, high), then the crook and lamp on top. Each band has its own focal job and its own window language, so nothing repeats in a pan.
- **T0 Roots and yard (ground):** Great Root buttress (left), hoist yard with winch and parcels (right), painted rise stair, wayline posts.
- **T1 Depot (frame y 528 to 719):** limestone and loess brick on a boulder footing. Grand brick arch with a fan-light whose mullions form the three-route mark, the 48x64 double door, the First Post, runners' porch with teal satchels and a bench (left), loading bay, chute bin and burrow hatch (right), high-water cuts. Roof deck seen from above with skylight, crates, oilcloth parcels and the mess chimney. The **Route Board** gable sits over the arch.
- **T2 Sorting Drum (368 to 600):** cream river-stone drum, root-beam ring, three round lit windows, the 6x3 cubby wall (two dark and empty), hoist door, a working landing on its right-hand deck.
- **T3 Galleries (252 to 456):** narrower timber-and-plaster drum shifted left, 2-1-2 round shuttered windows, timber walkway wrapping the front right with the chute mouth, empty flyer boards and a ring perch on the left.
- **T4 Reel Deck (198 to 346):** a timber ring deck (224 wide) with a brass rim and 7 sheaves where the waylines tie off, route lanterns hung below; the dispatcher's loft in the middle (one big round lit window, moss dome); Stillwade's bell gallows off the left end.
- **T5 The Reach and the Waiting Lamp (0 to 320):** the root rises through a moss collar, binds the loft with rootlets, wears three brass bands, curls right; the lamp hangs on a short chain on the door axis; a three-arm route vane and a teal pennant on the apex.

## 4. Size
- Assembly frame **432x720 px = 18x30 tiles**. Foot to vane tip **718 px = 3.3 screens** of the 384x216 view (about 2150 px on the 648 px window at 3x). Body widths 300 / 216 / 168 / ring 224 / loft 108.
- Scale: 11 courier figures (66 px), 11.6 Galeshears (62), 21 to 27 starters (27 to 34), 5x the old Hall (144), 1.25x today's 576 px placeholder.
- On Tower Rise: frame origin world (96,-504), foot (312,215), door world (288,150) **unchanged from today**, beacon (lamp glass) world (312,-386) on the door axis, apex world (279,-503).

## 5. Parts (frame px; world = frame + (96,-504))
Body draw order is the row order; the body is one group at z 192 (door row 8). Courier teal sampled from the courier walk sheet: #2d9e9f #12837f #07515c #00313a.

| # | Slot id | What | Size, frame pos | Variants, states | Motion | Z | Codex paints |
|---|---|---|---|---|---|---|---|
| 0 | town.building.hall.key | whole tower style key, refs only, never installed | 216x360 | 1 | no | none | one low-detail pass over the assembled blockout |
| 1 | town.building.hall | depot, door part (keeps door_px 126,126,48,64, foot 150,191, C10, C11, Galeshear) | 300x192 @66,528 | closed; open 3 cut in code | door | 1 | footing, arch, fan-light, First Post, porches, bay, hatch, deck |
| 2 | .drum | Sorting Drum, owns the seam on the depot deck | 225x236 @104,368 | 1 | no | 2 | cylinder stone, root ring, cubbies, hoist door, landing |
| 3 | .hoist | jib, brace, pulley block | 88x56 @304,460 | 2 frames | sheave turns | 3 | timber arm, iron straps, brass block |
| 4 | .galleries | plaster drum, walkway, perches | 217x206 @88,252 | 1 | no | 4 | framing, shutters, walkway top, empty boards |
| 5 | .root_vein | overlay root up the left face (the Climb), one unbroken root over both seams | 60x296 @80,326 | 1 | no | 5 | bark, worn treads, rootlets, moss |
| 6 | .chute | overlay parcel chute, hides 2 seams | 88x290 @244,336 | 1 | parcels slide (code) | 6 | trough, brass edges, brackets, spout |
| 7 | .gable | Route Board gable over the arch | 104x53 @164,560 | 1 | 8 pegs lit in code | 7 | arched stone, moss lip, brass plate, waymark arms, sockets |
| 8 | .reel_back | back half of the ring deck plus the loft | 225x93 @88,198 | 1 | no | 8 | planks, back rail, loft, big window, moss dome |
| 9 | .reach | living root crook, rootlets on the loft | 104x300 @128,24 | 1 | no | 9 | bark (3 tones), knots, brass bands, moss, 2 leaf tufts |
| 10 | .ring_front | front half annulus, rim, 7 sheaves, root collar | 232x60 @84,286 | 1 | sheaves turn (code) | 10 | planks, rim face with brass band, rail, collar |
| 11 | .route_lantern | one per route under the rim | 12x20, x7 | lit (3 frames), dark, quiet | flicker | 11 | brass hand lantern; quiet = dusty, no wick |
| 12 | .bell | flood bell gallows | 56x90 @40,232 | rest; swing 4 | flood flag, reveal | 12 | timber gallows, small hood, bronze bell, rope |
| 13 | .lamp | the Waiting Lamp and chain | 32x42 @200,92 | lit 4, dark 1 | flicker; sway coded | 13 | bail, vented cap, 4 amber panes, drip pan |
| 14 | .vane | three-arm vane and pennant | 48x44 @164,0 | 4 frames | pennant | 14 | brass arms (route glyph), teal cloth with a fold |
| 15 | .root_foot | Great Root buttress, ground | 96x120 @0,600 | 1 | no | row 8 +1 | arching root, rootlets into turf, treads |
| 16 | .yard | hoist yard, ground | 72x104 @360,616 | winch 2 frames | winch | row 8 +1 | dock top, capstan, parcels, barrow, barrel |
| 17 | town.prop.hall.wayline_post | end of each wayline (Grok) | 24x64, foot 12,63 | ground/rooftop; strung, waiting, quiet | lantern | its row | post, pulley, glyph plate, lantern hook |
| 18 | town.prop.hall.rise_stair | replaces the coded steps at (12,9) | 48x96 | 1 | no | ground | worn steps, roots in risers, inlaid glyph |
| 19 | .basket | hoist basket (Grok) | 16x16 | full, empty | rides rope | 3 + | wicker, oilcloth parcel |
| 20 | .cradle | rides a wayline (Grok) | 12x14 | 2 sway; loaded, empty | slides | lines | trolley wheel, sling, parcel |
| 21 | .parcel | chute and cradle parcel (Grok) | 10x8 | 2 variants | slides | any | oilcloth and twine |
| re | road.backdrop.highbank_far, road.backdrop.vista, story.backdrop.tower_sky | new briefs, same sizes | 160x96, 384x216, 384x216 | 1 | coded glints | as today | see section 9 |

Coded, never painted: waylines (Line2D catenaries, 1 px ink plus 1 px brass-light top, teal tags every 40 px, z above the world), hoist rope, lamp chain sway, beacon glow (today's Glint), chimney smoke, long shadow, Route Board pegs, parcel and cradle motion, cloud shadows in the reveal.

## 6. How it is assembled in code
- New `scripts/town/tower_parts.gd` (TowerParts): `FRAME 432x720`, `PARTS` table (id, frame rect, layer body/ground/prop, order, foot row), anchors (beacon 216,118; apex 183,1; door), a coded placeholder painter per part (ported from `mock_tower.py`), and `place(area)` building one Node2D "WaylineTower" (z 192) with one Sprite2D per body part in order, plus y-sorted ground wings, props, Line2D waylines and the life nodes.
- `BuildingTemplate.place()` hands class `hall` to TowerParts; every other building is untouched. Each sprite uses `ArtSlots.texture(id)` when a file of the exact size exists, otherwise its coded blockout, so Codex parts drop in one at a time.
- New slot rows go in a new file `scripts/art/slots/town_tower.gd` (auto-discovered; `art_slots.gd` stays frozen). The existing hall row changes to the depot (300x192, anchor 150,191, door_px 126,126,48,64).
- No repeated stacked modules on purpose: identical floors are what made the first painting read as wallpaper. Variation lives in small repeats only (7 lanterns, posts, cubbies).
- Life: AnimatedSprite2D for painted frames; tweens for basket (about 10 s cycle), cradles (one per strung line about every 12 s), chute parcels (12 to 20 s); story flags drive lantern, post and line states. All loops stay on under Reduce motion; only the reveal cuts.

## 7. Where it stands
- **Tower Rise (v2):** base stays 12x3 at (7,6), door tiles (12,8),(13,8), return (12,9). Solid block grows from cols 7 to 18 to **cols 4 to 21, rows 0 to 8** (root and yard sit on cols 4-6 and 19-21, rows 7-8). The well (8,10), lamps (11,9),(14,9) and Job Board (16,9) stay. Wayline posts at (2,10) and (24,10); two more lines run off the south cliff toward the Street. Sky allowance 480 to **528**.
- **Camera lean (proposal):** within cols 11 to 14, rows 9 to 11, facing north, the view eases up to 72 px (0.4 s), capped so the leader's feet stay 30 px above the bottom edge. At the door the view top goes from 120 to 48: the Route Board, the deck, the cubby wall's lower rows, the hoist basket and four waylines dropping in from above. It stays inside today's clamp, so no sky is ever shown in normal play. While the view leans, the place and "Next:" panels slide up out of it (104 px at the full lean) and come back as it lets go. Walking up the side lanes (cols 0-3, 22-25) shows about three quarters of the depot's width (the view stops at the area's edge) and, from the top rows, the cubby wall's lower rows; measured in the 2026-10-27 look pass, which corrected this sentence (it used to say the whole depot and cubby wall).
- **Long shadow (coded):** the assembled silhouette sheared down-right (x + 0.30h, y = foot + 0.13h) at about 24% black, clipped above the cliff row. It reads as height; the hook only reads as a flattened curl (measured in the mock), so tune it in code.
- **Street, Ferry Ward, East Quarter:** the tower is never drawn above an area's top. Lines enter from the edge facing the tower (taken from the area index) and end at rooftop or pier posts; one line per opened route.
- **v1 (today's default game):** keep the legacy 240x144 Hall until Preston switches v2 on. A v1 crop (depot and gable only) would need cols 18-29 and loses both wings (Bluff Lookout and Item Shop are in the way).

## 8. The reveal pan ("ride the climb", same scene, retimed)
Settle 0.7 s at the doors (top 90: the lean view's 48 plus 42 px, so the first line's talk box sits under the doors and the two instead of over them; changed in the 2026-10-27 fix pass). Then four legs with short pauses, view tops: **L1 to -84** (1.9 s; the hoist basket rises alongside with a parcel; pause 0.4 s as it swings in at the hoist door), **L2 to -226** (1.9 s; galleries, a parcel slides down the chute the other way; the "Every route on the river starts at that door down there" line; pause 0.4), **L3 to -322** (1.4 s; Reel Deck, lanterns with one dark, a cradle leaves a sheave and slides out of frame toward town, the bell; pause 0.5), **L4 to -513** (2.4 s; the Reach and the lamp). Hold 1.5 s with the apex 10 px below the top edge and the lamp 127 px down, with no talk box up; the "top" line comes after the hold (2026-10-27 fix pass). Down in 4.5 s. Climb 561 px; up 8.9 s, whole scene 15.6 s (today 13.4). Beacon x equals door x (312), and door to beacon is 568 px, so the existing asserts hold. The hold frame is derived from the apex anchor, not BEACON_DROP. Reduce motion: cut to the hold for 2.5 s, cut back. Dialogue titles start, climb, top, down are unchanged.

## 9. Far view and vista
- `road.backdrop.highbank_far` (160x96, scale 0.82 to 1.0, haze 0.5 to 0.3): tower about 70 px tall on the bluff, **painted for its own size**: 2 to 3 px crook stroke, 2x3 amber lamp under the hook, 2 px ticks for the hoist (right, low) and bell (left, high), a 3 px ring bar with lantern specks (one gap), root slope left, yard nub right. Broken 1 px waylines are a bonus, never the read. Beacon anchor **(92,6) to (92,14)**; a second coded glint runs slowly down one wayline.
- `road.backdrop.vista`: tower about 176 px tall at cx 268, beacon anchor to about (268,36), lines to the roofs with cradle specks; the Waiting Lamp stays lit while house lamps go out. `story.backdrop.tower_sky`: banded dawn, emptier at the top so the lamp stands out; no tower painted in.
- The flat fill at 25% and 10% (bottom of `mock_far_view.png`) still reads as a hooked column with a dot; that shape doubles as a map or menu icon later.

## 10. Placeholder blockout spec (every part)
- **Projection:** parallel top-down three-quarter. Verticals never converge. Every top plane visible from above (decks, sills, dome, deck rails), no undersides. Plan ellipses at about 0.4 height to width (drum 108/44, galleries 84/34, ring 112/44, loft 54/22) so each setback shows a 6 to 14 px deck band; **check against the Growth Shrine before Codex paints** (house study guessed 0.5 to 0.6).
- **Value structure:** flat 3 to 4 tone clusters per material. Cylinder bands fixed at absolute frame x so every painted drum shades on the same columns: drum lit 108-176 (highlight 121-133), mid 177-250, shade 251-302, dark 303-324; galleries 116-169 / 170-226 / 227-267 / 268-284; loft 142-175 / 176-212 / 213-239 / 240-250. Light from the upper left, cast shadows down-right, grime darker toward the ground and under every lip, moss on every top plane, thinning with height.
- **Materials by era:** boulder footing, limestone with loess brick, cream river stone, timber and lime plaster, timber and brass, living root. Palette: locked `wayline_tower` family of about 41 colours (town_stone 30, brass #f2d27a #d4a94c #a37a32 #6b4f1f, the four courier teals above, bronze #b8793e #7c4a26, ink #0b0e11); 32 or fewer per part, C5 lock on. The blockout uses 36 colours assembled.
- **Features are blocked as their own shapes** at final size and place: arch, door, fan-light mullions, First Post with touch patch, satchels, windows (12 to 14 px round with sills), cubbies (10x9), hatch, cuts, Route Board pegs, sheaves, lantern hooks, bell, lamp panes. Codex paints over a real design, not a blob.
- **Line rules:** no outer outline (runtime rim draws it once); 1 px #0b0e11 only at material joins and under lips. Anything that sticks out of the silhouette is 2 px or wider; 1 px cables, ropes and the chain are coded and drawn after the Finish pass.
- **Seams:** cut only under a lip or at a root or moss band. The upper part owns each overlap with a 3 px contact shadow; overlays (root_vein, chute, gable, ring_front) cover the joins.

## 11. Codex batches (judge early, paint late)
1. **Gate (Claude, no painting):** wire the coded blockout on Tower Rise v2 and in building_lineup; Preston walks it and judges the 25% flat fill.
2. **cx-11 tower key:** town.building.hall.key, one pass. Preston approves palette, light and eras.
3. **cx-12 tower foot (seen every day):** town.building.hall, .gable, .root_foot, .yard, town.prop.hall.rise_stair.
4. **cx-13 tower body:** .drum, .hoist, .chute, .root_vein, .galleries.
5. **cx-14 tower crown:** .reel_back, .ring_front, .reach, .lamp, .vane, .bell.
6. **Grok small set:** .route_lantern, wayline_post, .basket, .cradle, .parcel.
7. **cx-10 re-brief** (existing batch): highbank_far, vista, tower_sky, after the crown is approved.
8. **cx-15 title Highbank** (added in the build, 2026-10-27): `title.backdrop.highbank`, Highbank from the river with the Tower as the hero, after the key's yes so its tower matches.
Every request carries the assembled blockout, the approved key, the neighbour's 24 px edge band and the part's own ref; native 1:1 at exact size, binary alpha. First pull town.building.hall out of cx-01-buildings (its rejected candidate is superseded).

## 12. Checks to update or add
building_template_check (hall canvas becomes the 300x192 depot; door asserts unchanged; TOWER_STAGES replaced by TowerParts names and order; assembled height at least 540), tower_reveal_check (legs, pauses, apex margin at least 8 px, nodes freed, Reduce motion), new tower_parts_check (rects inside the frame, slot rows complete, overlaps owned by the upper part, 2 px rule at the silhouette, 32 colours a part, C6 on shared seams once painted, shadow clipped, line entry edges from the area index, lean keeps the leader on screen), plus hall_door, hub_town, art_slots, area_data, town_walk, road. Run tools/debug/run_checks.py --fixed-fps 30 with HT_HIGHBANK_V2=1.

## 13. Risks
- Scope: 21 painted slots plus 3 re-briefs is many sessions. Slice it as in section 11; nothing is painted before Preston walks the blockout.
- The crook could read as a cane, gallows or question mark at far size, and the root could drift into a great-tree look. Keep it thick, banded and tended; forbid canopies, faces and creature shapes. Fallback crown: hang the lamp from a timber-and-brass spar off the ring.
- The round body could still read as a lighthouse or a tiered cake if Codex flattens the asymmetry. The root, chute, hoist, bell and yard must stay in every pass.
- Normal play sees the base only. The marvel depends on the lean, the waylines, the shadow and the reveal; Preston should know that before judging.
- Seams and palette drift across 14 body parts. Mitigated by the locked palette, fixed shading columns, overlays and C6 checks.
- Contract ripple (settled in the 2026-10-27 build): the TOWER_* constants, building_template_check, the reveal's geometry, hall_rise's sky and solids, roof_rows, the palette family in `placeholder_painter.gd`, the slots.json export and the refs were all updated in the build; the art task lists are written by `tools/art/write_art_tasks.py` (cx-11 onward and gb-08).
- **Verified in the 2026-10-27 build** (headless at fixed 30 fps unless noted; the integrator's suite on the whole tree):
  - The parts: 21 parts plus the key fit one 432x720 frame; the assembled blockout matches `mock_tower.py` on 96.6% of its drawn px (the rest is the random moss, bark and boulder scatter and the edges of 2 to 3 px lines). Each stand-in is its exact size with binary alpha and family colours only; the upper part owns every overlap; no hairlines at the silhouette.
  - The far views: at 70 and 170 px the far views read as one hooked shape with the lamp lit.
  - Tower Rise (v2): the Tower stands at (96,-504) with the doors at (288,150). The lean reaches 72 px at row 9 (55 at row 10, 31 at row 11) with the leader's feet 30 px clear and no sky shown. The four Rise lines meet their post pulleys. The rise stair draws at (12,9) under anyone on it. Street, Ferry Ward (slack, quiet) and East Quarter (only once open) hang their lines from the edge facing the Tower to their posts.
  - The reveal: its legs, pauses, hold (apex 10 px under the top, lamp 127 px down) and pan down time out as designed. Camera time measures 15.1 to 15.4 s against this doc's 15.6 s. Reduce motion cuts to the top and back, and a town freed mid-climb leaves nothing behind.
  - The road: the far lamp is visible at 90 of 90 looks.
  - The title: it shows Highbank with the Tower as the hero, judged by eye from one window screenshot.
  - v1: shows the legacy Hall and no lean.
  - The suites:
    - v2 suite: 71 PASS, 0 real FAIL. hollow_check's autopilot stalled once and passed on two reruns; that is dungeon code, not the Tower.
    - v1 suite: 72 PASS, 0 FAIL.
    - Both suites: the 6 WINDOW checks need a window.
    - opening_launch: PASS in a window.
    - pilot_chain_check: PASS end to end on v1, and on v2 too. The v2 chain waits on the Tower scene but does not log it.
- **Still unverified:**
  - Nothing has been watched in a real window except the title: not the moving parts (lamp, basket, cradles, chute parcels, smoke), not the draw order in motion, not a walk on Tower Rise.
  - No part is painted yet, so the Finish shader on painted parts and the C6 seam checks are untested.
  - Untested: the ellipse ratio against the Growth Shrine (only Codex's design-review compare), the day/night cycle, and the 25% flat fill.
  - Look calls Preston has not seen: the Rise's outer solid strips (solid turf painted as grass since the fix pass; they were hedge), the ground posts in place of rooftop posts (a prop on a roof sorts behind its building), and the title's invented composition.
- **Fix pass after the round 1 look pass (2026-10-27):**
  - The Rise's two 3 x 9 hedge blocks are now open turf that stays solid (a ground rect's "solid" flag), with a soft contact shadow under the root foot and the yard.
  - The Climb is one unbroken root over the depot's roof deck and the drum's top, bending over each lip with a 3 px shadow under it; its treads are short, uneven and bark-coloured.
  - The Waiting Lamp's panes have a bright core and a deeper foot, its pan is no wider than its glass, and its glow is three added steps of warm light behind it.
  - The waylines' lit top is brass-light. The Street's route 1 post moved from (45,6) to (44,10), so its cable crosses the rows the player walks.
  - The road vista's tower is the whole tower shrunk (TowerParts.small), as on the title, not paint_far blown up; the vista's colour budget went from 48 to 64 for it.
  - The reveal settles 42 px lower at the doors and holds at the top before its line; the HUD panels slide up while the camera leans.
  - building_lineup works with HT_HIGHBANK_V2=1.

## 14. Proposals awaiting Preston (not canon)
The Reach and its legend (a root older than Highbank that the first runner tied a rope to), the Waiting Lamp name, the First Post touch ritual, the Route Board, waylines and posts, the quiet route's dark lantern, crew stations placed on the tower, the eras, the camera lean, the retimed reveal and any new line about the dark lantern. Every name here is a working label; nothing installs without his yes in review.json.

## 14. The root's source (Preston, 2026-10-27, after the build)

Preston: "that tree root is going to be from a huge great tree. It will be a dungeon [though] but it'll be a massive tree too."
So the Reach, the root vein and the root foot are not the Tower's own tree. They are one root of a separate, massive great tree that
stands somewhere beyond the Tower, and that tree is a future dungeon. Working label only: "the great tree" (the name is Preston's).
Placement, scale, the root's path and how it shows in each view are being designed in docs/design/great-tree-2026-10-27/.
Codex's cx-12 root foot was already in progress when this landed; the design says whether it needs a change.
