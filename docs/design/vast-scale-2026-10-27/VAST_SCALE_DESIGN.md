# The two giants: Wayline Tower and the great tree at vast scale

Status: **proposal, 2026-10-28.** Design and mocks only. Nothing in scripts, scenes or assets changed, Godot was not run, nothing committed.
Mocks: `final/` (each `_1x` and `_3x`), built by `final/final_mocks.py`.

Older docs: `../wayline-tower-2026-10-27/TOWER_DESIGN.md` and `../great-tree-2026-10-27/GREAT_TREE_DESIGN.md`. **Superseded** wherever they disagree with this file on size, distance, the views, the reveal or the Low Reel's place. Everything else in them stands.

## What Preston said (2026-10-27)

1. "that tree root is going to be from a huge great tree. It will be a dungeon [though] but it'll be a massive tree too."
2. "like not too far from the town. Like the tree of life kind of like its so great and vasts its at the center of the forest but its just so big its influence is everywhere around the town."
3. "the 1st left photo is what im visualizing in terms of tree vastness."
4. "for the tower its too small. Im thinking vast like the one from danmachi aka is it wrong to pick up girls in a dungeon."

## Preston's answers (2026-10-28)

- Title: layout A, the giant Stack behind the Tower we have now. The tree needs its leaves and branch top (the crown) in the title.
- Road view: liked; the tree top is a little too uneven.
- 340 tiles is not too far. The slender Tower is fine.
- Then: remove the older tower from Title A; it covers the new giant Tower, which looks better. The giant comes down to its own plinth and doors in the title.
- Later the same day, after seeing Title A in the game: the crown reached much farther left than right, so the trunk looked off to one side; it is now centred on the trunk (CROWN_OFF 0, one limb turned east). The Tower's root looked cut off and floating at its lower end; it now comes up out of the Rise at the first step's west corner, with short roots gripping the ground (scripts/art/placeholders/title_giants.gd).
- Then: the Wayline Tower has no other buildings by it. It stands alone with open ground round its foot and the town set back from it. Done on both road views (the far view's roofs moved to the bluff's ends; the cliff view's houses gathered to the west, both waylines running west to them).
- Then: "fix the cliff tree and tower and everything else so codex can go ham." Slice 1 done: the cliff view (road.backdrop.vista). In final_mocks.py the crown is centred everywhere (CROWN_OFF 0), the vista's tree is the title's tree in morning colours (title_tree with pal and tint), and Highbank's roofs sit in a clearing west of the Tower and beyond it. The game's vista placeholder is that mock (assets/placeholders/road_vista.png), and Codex's cx-10 opens for the vista. Next slices: the far view, the willow layer (road.backdrop.mid), the Tower reveal (story.backdrop.tower_sky), then the town's Tower parts at the new size. Slice 2 done: the far view (road.backdrop.highbank_far). Its placeholder is the vast-scale mock (final_mocks.py mock_road_far, assets/placeholders/road_highbank_far.png): the title's tree and the whole Tower alone over the forest band, the Tower 70 px so its foot, the band and the town stand above the scene's far hills, the land thinning into valley mist below. The willow layer already leaves the new far Tower clear at the four trail talks (road_tower_view_check), so slice 3 needed no change. Slice 4 done: the Tower reveal's sky (story.backdrop.tower_sky). Its placeholder is the hold's backdrop (final_mocks.py hold_backdrop, final/slot_tower_sky.png, assets/placeholders/tower_sky.png, 18 colours): a banded dawn, calm cool blue behind the lamp at (192, 127), the cloud sea from the horizon at y 146, and the title's tree in the morning's greens as the crown cap breaking it on the left (centred on x 100, top y 156, 180 px wide at the cloud). The scene still climbs today's 30-tile tower, so from the second leg the cloud sea shows behind its drum and Reel Deck; that waits on the town's Tower at the new size and the reveal retimed for it.
- 2026-10-28, integration: slices 1 to 4 are done. The cliff view (road.backdrop.vista), the far view (road.backdrop.highbank_far) and the Tower reveal's sky (story.backdrop.tower_sky) each have a vast-scale placeholder, anchors and brief, and Codex's cx-10 batch is open for all three with nothing in it sending Codex back to the earlier tower; the willow layer (road.backdrop.mid) needed no change. Only the town's Tower pieces remain (every town.building.hall.* and town.prop.hall.* slot and TowerParts at the new size, with the reveal retimed for 480 tiles), waiting on Preston walking the Tower.

## Recommendation

1. The Tower keeps 480 tiles to the vane, lamp at 475. It passes every view; only the cameras changed.
2. The tree stands 340 tiles north-west of the Tower at the centre of its own forest; Highbank sits inside that forest's south edge.
3. The tree is 400 tall so its crown breaks the clouds: the Tower is the taller, the tree the bigger.
4. Grafted from the other reading: the crown filling the title sky, starter-sized leaves, roots in the Street, painting only on sky.
5. One root arrives from the west-north-west, climbs the Tower and holds the lamp in its crook.
6. The Tower stays the town's (built, lit, one warm lamp); the tree stays the forest's (living, dark). Both show wherever the sky is open.

## Numbers (tiles of 24 px; all proposals)

| | |
|---|---|
| Tower | 480 to the vane; lamp 475; crown base 461 |
| Tower bands | plinth 52 wide (0 to 8), 42 (8 to 16); Stack 34 (to 114), 28 (to 210), 22 (to 296); wet collar 19 (296 to 344); neck 15 then 12 (to 458); crown 9.5 (458 to 461) |
| Stations | ring balconies at 112, 208, 292 |
| Low Reel | on today's drum, about 34 up, where the town's waylines leave |
| Cloud layer | 280 to 360; the collar sits in it |
| Tree place | 340 tiles N35W of the Tower (195 west, 278 north): 8,160 px, about 21 screens of walking |
| Tree | 400 tall; trunk 100, flaring to 260 at the ground |
| Crown | 440 across, centred 65 tiles west of the trunk; underside 140 to 165 up |
| Forest | 800 across round the tree; forest trees about 20 tiles |
| Root | 4 thick at the ground, 1.5 at the crook |

**Against his picture** (his first-left photo, measured on the 736 px copy; nothing from it is copied):

| | His picture | Hollowtide |
|---|---|---|
| Trunk across, in buildings | about 5 huts (trunk 440 px or more, hut about 90 px) | 20 houses (100 tiles, a house 5 tiles) |
| Trunk as framed at the foot | about 6 standing figures | arrival: about 8 starters (300 px against 36 px) |
| Trees at the foot | about a fifth of the visible trunk | forest trees a twentieth of the tree |
| Crown | out of frame | out of frame at arrival, a dark ceiling |

So the arrival matches the look of his picture, and the world is roomier than it in plain numbers.

## Each view

| View | What shows, and how big |
|---|---|
| Title A (cx-15) | Codex's town kept. Round Stack behind the drum at 2.6 px a tile (88 px wide), off the top, no lamp in frame. Tree at about 0.68 px a tile: crown about 300 px behind the town, trunk about 68 px. Menu box untouched (0 px changed). Calm box 6 colours and 827 edges (Codex 3 and 412): the tree adds at most 3 colours, but the box is twice as busy. |
| Title B | Camera 110 tiles back on bearing 214, tilted up 30 degrees. Whole Tower, lamp at y 7, Stack 37 px wide at its foot. Tree left: trunk 55 px, crown 137 px. Codex's houses, river and left tree kept; a dark forest edge behind the houses. Calm box exactly Codex's (3 colours, 412 edges). |
| Road far | Slot `road.backdrop.highbank_far` (160 by 96), 3,000 tiles SSW: Tower 70 px (vane row 5, foot row 75), tree 55 px (crown 60 px, trunk 14 px), both over the forest band on valley mist, Highbank's roofs in a clearing west of the Tower, one wayline from the Low Reel down to them. In the road scene at 0.82: 57 px and 45 px. (2026-10-28: the first 88 px put the Tower's foot, the forest band and the town behind the scene's far hills.) |
| Vista | Last hill, about 650 tiles SSW, looking up 20 degrees. Tower whole, foot y 200 to vane y 8; Stack 15 px. Tree left: trunk 35 px, crown 134 px; its forest canopy runs from the trunk's foot to the Tower's, trees 3 to 7 px. Hill and framing trees lowered and darkened. |
| Door and lean | Today's 72 px lean kept. The plinth's first step alone is 192 px, so this view shows footing and the main root from the left, never the Stack. The old diagonal root is painted out. |
| Street | A 60 px far band over the north rows; the map moves down 70 px under the fixed quest panels. Stack 51 px, off the top; tree trunk 42 px, crown underside 185 px wide at y 41 to 51, a cloud wisp. |
| Reveal climb | 480 tiles is 11,520 px, three minutes at today's 63 px a second. Storyboard: doors (0 to 2.5 s), Low Reel and waylines leaving (to 4.5), Stack streams with the lift (to 8.5), Station 2 passes (to 9.5), cut on cloud at the collar (to 11), hold (to 15.6). Same 15.6 s as today. |
| Top hold | Codex's crown and lamp in today's spot, cloud sea below. The tree's crown cap breaks the sea on the left: 180 px wide, 32 px tall at the true 0.79 px a tile, but composed with its top at y 156; the true lens puts it at y 205, below the frame. Slot `story.backdrop.tower_sky` (384 by 216): beacon anchor (192, 127), horizon y 146, the cap the title's tree (2026-10-28). |
| Arriving at the tree | Trunk about 300 px across filling the frame, dark crown ceiling, no cloud, buttress roots, the hollow 68 px tall and 42 px across, two starters (36 and 32 px) at the foot. |

**Visibility rule (amended):** both giants show in every outdoor view with open sky: both titles, road far, vista, the Street band, the hold. The door and the arrival are close views of one giant's foot. Inside town the tree's shape shows only from the Street's north rows; everywhere else it shows through roots, leaves and shade. The forest is the dark edge behind the title houses, the band under both giants on the road, the canopy round the trunk in the vista, and under the cloud sea in the hold.

## The Tower at the new scale

- **Stays (Codex, 14 of 16 parts):** the foot (hall, gable, yard, rise stair) on the plinth; drum, hoist, chute; the Low Reel (reel back, ring front) on the drum at about 34 tiles; the crown (galleries, the Reach, lamp, vane, bell) at 458 to 480.
- **Repeats:** one story is 4 tiles; a cornice every 3 stories; porthole windows on a spiral stair (the drum's motif); era lips at 16, 114, 210, 296, 344; the Low Reel's ring-deck art again at 461.
- **New:** two plinth steps; three Stack sections that narrow; three Stations; the wet collar (mossy, in the clouds); the neck; a low cap on the drum.
- Elevation panel B shows today's foot whole on the plinth.

## The root

One root of the great tree. It comes in from the west-north-west along the ground, half buried, 4 tiles thick, treads cut into its lower run. It climbs the plinth face, then the Stack's west side, gripping the stone, with thin rootlets along the cornices. The builders tied it with a brass band at each era lip. It thins to 1.5 tiles and ends in the crook that holds the lamp.

## The tree around town

| Place | What the player sees | Later file or slot |
|---|---|---|
| Title | The crown behind Highbank, the forest edge behind the houses | `title.backdrop.highbank` (cx-15 repaint) |
| Road | Both giants over the forest band, then the vista | `road.backdrop.highbank_far`, `road.backdrop.vista` |
| Street | Trunk and crown underside over the north roofs | new 60 px far band (proposal) |
| Crossroads | A root heaves the paving twice | new street decal (proposal) |
| Ferry Ward | Two roots come over the quay and drink; a rootlet stops a stone short of the Mouth | new ferry props (proposal) |
| Tower doors | The main root at the footing; leaves the size of a starter on the steps | Codex `root_base`; new leaf decal (proposal) |
| Summer evenings | The crown's shade reaches the Street before sunset | new light overlay (proposal) |
| The Tower | The root that holds the lamp | Codex `root_base`, `rootlet` |
| Top hold | The crown cap breaking the cloud sea | `tower_reveal.gd` `paint_sky()` |

## Dungeon hook (proposal, later, no numbers)

The way in is the dark hollow at the trunk's foot. Floors climb inside the heartwood, out along a limb, and finish in the crown above the clouds, where the player sees the Tower's lamp level with them. The root up the Tower is never a way in; the dungeon stays in the tree.

## Codex note (ready to paste)

> **Wayline Tower at 480 tiles, 2026-10-28 (proposal, Preston to confirm).** Survive as painted, 14 of 16: hall, gable, yard, rise stair, drum, hoist, chute, galleries, reel back, ring front, the Reach, lamp, vane, bell. The bell re-anchors on the neck cap at tile 461; the drum gets a low moss-lipped cap; check the chute mouth still lands. Redo 2: `root_foot` becomes `root_base` (4 tiles thick, from the WNW, half buried); `root_vein` becomes a thin `rootlet` along a cornice. The Low Reel stays on the drum (about 34 tiles up, where the town's waylines leave); its ring-deck art repeats at 461. cx-15 title: Preston picks layout A or B (`final/title_a_game_1x.png`, `final/title_b_game_1x.png`). In A, keep `shade_end` at (312,50) and put the Stack's west face at x 313 or further right; any new pixel at x 312 or more and y under 50 is painted already darkened (about x0.62) so the band does not show a seam. Keep the menu box (21,108 to 129,200) untouched. The title slot's lamp anchor (333,33) and the brief's "about 162 px tall", "vane tip near y 6" and "lamp at (333,33)" are stale; A has no lamp in frame, B has it near y 7. Road far slot anchors (160 by 96): foot (104,95), beacon (105,8), wayline_top (102,89), wayline_end (151,61). Hold: no new Stack, Station, collar or neck art until Preston confirms the size. cx-11 stays the style key. Mocks: `docs/design/vast-scale-2026-10-27/final/`.

## Defaults ("go with the defaults")

- Title layout A.
- Tower 480 to the vane, lamp 475, slender (14 to 1), bands as above.
- Tree 400 tall, 340 tiles N35W, trunk 100, crown 440, forest 800, forest trees about 20 tiles.
- Cloud layer 280 to 360.
- The tree shows no light; the Tower's lamp stays the one warm light.
- Low Reel on the drum at about 34; its art repeats at 461.
- Vista from the last hill, about 650 tiles SSW, looking up 20 degrees.
- Street far band 60 px, map moved down 70 px under the fixed panels.
- Door keeps the 72 px lean; the old diagonal root goes.
- Reveal: pan, stream, cut on cloud, hold; 15.6 s.
- Hold composes the crown cap 49 px higher than the lens.
- Root from the WNW with brass bands at each era lip.
- Names stay "the great tree" and "the Wayline Tower".
- Palettes: dawn for road, Street and hold; highbank_title for the title.

## Questions only Preston can answer

1. Title A or B: which reads vaster? A keeps Codex's town and shows the Stack's base huge and running off the top, no lamp. B pulls back to the whole Tower with its lamp and the tree's whole crown, the town smaller. Default A.
2. Is 340 tiles "not too far"? It is 8,160 px, about 21 screens of walking from the Tower to the trunk. Default yes.
3. The Tower is slender: 480 tall, 34 wide at the Stack (14 to 1). Is that the vastness you meant, or stouter, around 60 wide? Default slender.

## First build slice

**Title A as a placeholder.** After factory pass 9 lands (it has `scripts/art/slots/title.gd` open), one small painter for the title backdrop in that slot, or a new `title_highbank.gd` beside it, paints the great tree onto sky and far-hill pixels only and the round Stack behind the drum, west face at x 313, pre-darkened under the band. The slot anchors move to layout A. No menu, wordmark or town pixel changes. Checks: menu box 0 px changed; 48 colours or fewer in the backdrop; at most 4 tree colours in the calm box (90,0 to 296,52); `tools/debug/ui_fit_check.gd`; `tools/debug/run_checks.py --fixed-fps 30`; compare with `final/title_a_game_1x.png`.

Then, in order:
1. Road far slot `road.backdrop.highbank_far` at the anchors above.
2. Vista backdrop layer (no hill, party or framing trees) into `road.backdrop.vista`.
3. Street far band and the 70 px map shift.
4. Hold: the crown cap in `story.backdrop.tower_sky` (done 2026-10-28: `paint_sky()` in `scripts/story/tower_reveal.gd` loads `assets/placeholders/tower_sky.png`).
5. Codex: Stack sections, Stations, collar, neck, drum cap.
6. Codex: `root_base` and `rootlet`.
7. Reveal retimed for 480 tiles (`tools/debug/tower_reveal_check.gd` lines 250 to 252 pin the lamp 568 px over the door; that check gets new numbers in the same change).
8. Town props: crossroads root, ferry roots, leaves, crown shade.
9. Arriving at the tree, with the dungeon.

<details><summary>Corrections to the earlier version of this file</summary>

- It said the title's calm box was kept. In A it is not: 6 colours and 827 edges against Codex's 3 and 412. B keeps it exactly.
- It put the Low Reel in the crown. It stays on the drum at about 34 tiles.
- Its Codex note said 14 of 16 but named 13; the bell is the 14th.
- The road far was computed, not mocked. It is mocked now, with a higher camera, so its sizes changed.
- The Street band was 34 px with the tree's trunk and underside cramped; it is 60 px now.
- The map's title marker sat on the wrong bank; it is south of the river now.

</details>

<details><summary>How this was chosen</summary>

- **Tower:** the tower designer's 480 kept. Checked in both titles, road far, vista, door, Street, hold and the elevation. The views needed new cameras, not new numbers.
- **Tree place:** the skyline reading's 340 tiles over the boughs reading's 141. Boughs puts the crown overhead and the town under the tree; 340 keeps it "not too far" and "at the center of the forest".
- **Tree height:** grown from 360 to 400 so the cap clears the clouds and shows in the hold. The Tower stays taller by 80.
- **Grafted from boughs:** the crown in the title sky, painting only on sky and far hills, starter-sized leaves, a root in the Street.
- **Grafted from skyline:** the base (arrival), the Ferry Ward rootlet, the influence list, the map.
- **Neither swallows the other:** vista crown 134 px against the Tower's 192 px height; road far 69 px against 88 px; title B crown 137 px against the whole Tower; in the elevation the tree has the mass and the Tower the height.

</details>

<details><summary>Mocks in final/</summary>

| File | What |
|---|---|
| `title`, `title_a_game` | Layout A: Codex's cx-15 town, round Stack behind the drum, tree behind the town; `_game` adds the shade band, wordmark and menu |
| `title_b`, `title_b_game` | Layout B: whole Tower with its lamp, tree left with its whole crown |
| `road_far_slot`, `road_far` | The 160 by 96 slot on plain sky with anchors, and placed at 0.82 in the road |
| `vista` | Road home: whole Tower, tree in its forest, cloud banks, the party on its hill |
| `door_lean` | Tower Rise doors at the 72 px lean: the main root and the plinth footing |
| `street` | North rows under the 60 px band: Tower and tree over the roofs |
| `hold` | Top hold: Codex's crown and lamp, the tree's crown cap in the cloud sea |
| `arrival` | Arriving at the tree: trunk, hollow, two starters, crown ceiling |
| `elevation` | Both giants at 1 px a tile with a creature and a house; the feet at 3 px a tile with today's Tower on the plinth |
| `influence` | Crossroads, Ferry Ward, Tower doors, summer shade, painted over captures |
| `map` | Top down, 1 px for 4 tiles; title camera, vista hill and road far marked |
| `reveal` | Storyboard of the 15.6 s climb |

</details>
