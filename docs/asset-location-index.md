# Hollowtide file sweep and synthesis

**Swept 2026-09-26; updated 2026-09-27.** The live game is at C:/Users/pmcga/dev/hollowtide. This is a location map and review queue. The original inventory is at C:/Users/pmcga/Documents/Codex/Hollowtide/asset-sweep-manifest.json. Eight later file moves, including before/after hashes, are recorded in C:/Users/pmcga/Documents/Codex/Hollowtide/hollowtide-moves-2026-09-27.json. No file was deleted.

## What the sweep changed in our understanding

- The project already has nine Ember front sprites, seven Ember backs, their raw Forge originals, converted move effects, and creature resources. Cinderhide's current resource chain reaches Clinkerhide and Ironvent.
- A wholly different Coalcrest design sits in the OneDrive Desktop Hollowtide folder. The shared name does not mean it should replace the current game art.
- A named River Listener image in the Codex folder is an exact duplicate of a GUID-named file in the project's archive. It is not a production sprite. Preston previously requested a River Listener redo, so the old filename “Approved Original” does not settle the current choice.
- Two unlabeled Stone-like creature images are in the central `Incoming/Needs Review/Stone candidates` folder. Both are 1024x1024 and fully opaque, with the checkerboard visible in the picture. They need identity and cleanup before Godot.
- The fuller battle HUD sheet already exists at C:/Users/pmcga/dev/hollowtide/docs/palettes/Hud 2.png. The three gauge-view PNGs in that folder are byte-identical cropped mockups. This remains a visual source for later battle framing and buttons; Preston now prefers one continuous HP bar.
- Most of the Codex Move work staging folder is already in the game. It is a prior snapshot, not a queue to merge wholesale.

## Locations to check every session

| Place | What it holds | How to use it |
|---|---|---|
| C:/Users/pmcga/dev/hollowtide | Live Godot project, current concept, living bible, scenes, resources | Source of truth for what is wired into the game. |
| Project docs/HollowTide Sprites/Creatures and Creatures-Back | Original Forge Ember fronts and backs | Compare with reviewed transparent PNGs in assets/sprites/creatures. |
| Project docs/HollowTide Sprites/Effect Sheets | Raw creature and universal move sheets | Compare with assets/sprites/effects, data/moves, and scenes/effects. |
| Project docs/HollowTide Sprites/Assets | Cutbank and Grok environment/prop studies | Candidates requiring slicing, background removal, and route-scale review. |
| Project docs/palettes | HUD raw sheet and cropped mockups | Use Hud 2.png as the fuller source; avoid redoing art already there. |
| Project docs/Gemini DeepResearch(Hollowtide) | Consolidated Gemini research reports | Research inputs; compare with Preston's current decisions and project adoption notes before changing game content. |
| Project docs/archive/legacy-source-packs | Preserved sound-effect source package and its license link | Local library, ignored by Godot and Git; see its README before using sounds. |
| C:/Users/pmcga/Documents/Codex/Hollowtide | Move staging, alternate conversions, River Listener source, route preview | Review/staging, not an automatic replacement for live project files. |
| C:/Users/pmcga/Documents/Codex/Hollowtide/Reference Images/Overworld | Two overworld perspective screenshots formerly in Downloads | Reference only; do not import another game's art. |
| C:/Users/pmcga/Documents/Codex/Hollowtide/Incoming/Needs Review/Stone candidates | Two unnamed opaque Stone creature images formerly in Downloads | Unapproved; identify before any Godot conversion. |
| C:/Users/pmcga/OneDrive/Desktop/Preston Hub/06 Creative Projects/Hollowtide | Older concept/art notes and alternate Coalcrest | Historical notes; current THE_CONCEPT.md is in the Godot project. |
| C:/Users/pmcga/Downloads and Downloads/Images/2026-H2 | Unnamed art, research documents, old shark, external programs | Triage identity, provenance, background, and size before importing. |

## Newly surfaced art and conflicts

| Find | Location | Evidence | Action |
|---|---|---|---|
| Coalcrest alternate | C:/Users/pmcga/OneDrive/Desktop/Preston Hub/06 Creative Projects/Hollowtide/Coalcrest.jfif | Visually different from project docs/HollowTide Sprites/Creatures/Coalcrest.jfif. Their SHA-256 hashes start 6b9c1b16 and 1dc95550. | Preserve both; Preston chooses a design before any replacement. |
| River Listener source | C:/Users/pmcga/Documents/Codex/Hollowtide/Sprite Sources/River Listener - Stage I - Approved Original.jfif | Exact byte match to project docs/archive/d62f2a2e-c9e6-442b-a56b-994118ea4339.jfif. Not imported into the game. | Keep as archive/reference pending the requested redo. |
| Stone-like picture A | C:/Users/pmcga/Documents/Codex/Hollowtide/Incoming/Needs Review/Stone candidates/stone-candidate-a.png | Distinct 1024x1024 opaque image with baked checkerboard. | Decide creature identity, then clean and convert. |
| Stone-like picture B | C:/Users/pmcga/Documents/Codex/Hollowtide/Incoming/Needs Review/Stone candidates/stone-candidate-b.png | Second distinct 1024x1024 opaque image with baked checkerboard. | Review separately; do not infer an evolution link. |
| Ironvent conversion variant | C:/Users/pmcga/Documents/Codex/Hollowtide/Godot-ready sprites/ironvent.png | Different color and bytes from live assets/sprites/creatures/ironvent.png. | Compare at battle scale before choosing. |
| Old shark close-up | C:/Users/pmcga/Documents/Codex/Hollowtide/Reference Images/Historical Creatures/legacy-shark-rimefin-reference.png | Legacy blue shark art, distinct from the planned Forge redraw. An exact duplicate is held in `Incoming/Potential Duplicates`. | Historical Rimefin reference only. |

## Art already in the project that can help

- `docs/HollowTide Sprites/Character/Character.jpg` is a 1408x1408, four-direction, four-frame walking sheet (down, left, right, up). It is now copied byte-for-byte to `assets/sprites/player/character_walk_sheet.jpg` and shown by `scenes/player.tscn`. The grid spacing is uneven, so `scripts/player.gd` uses measured source crops rather than dividing the sheet into equal cells. A Godot shader hides the magenta JPEG background at draw time; the original source is intact. This is a playable visual study, pending a route-scale and edge review.
- `docs/HollowTide Sprites/Assets/Map Tile.jpg` is a 4x3 collection of terrain and prop swatches, not a ready 16x16 TileSet. Grass, dirt, river ripple, wall, roof, bushes, crystal, planks, and reeds need separate scale/seam checks before route use.
- `docs/HollowTide Sprites/Effect Sheets/Universal Attack Effect/Earth effect sheet.png` and `Ice effect sheet.png` are new composite move-effect studies. They include large impact frames and magenta/white sheet backgrounds; they are not wired to moves yet. Associate each with a creature brief and slice only chosen actions after scale review.
- Project docs/HollowTide Sprites/Assets/Cutbank tiles.png contains bank, water, grass, reeds, and stone studies. Its apparent pixel density differs from the current 16x16 route terrain. Slice and review in context before use.
- Customer grok asset.png in the same folder contains a wall, pipe, rope post, lantern, and mossy rock. The post and rock may strengthen the ferry approach, but perspective and scale need a look.
- CustomeAssets(Made by grok imagine).png is a mixed item/icon sheet. Pick only props that fit Hollowtide; the sheet as a whole is not a game asset.
- Project docs/palettes/Hud 2.png visibly contains two long gauge wells and FIGHT/REST buttons on magenta. The six-cell study is now a reference only: Preston chose a continuous rounded HP bar instead. Hud 2.png remains a source for a later frame and button pass. Its buttons differ from the mockup's STRIKE/VENT labels.
- Project docs/HollowTide Sprites/Creatures has nine Ember fronts; Creatures-Back has seven backs. Ironvent and Vitrecrag still lack back originals. Their production resources and moves should be judged independently of the raw image count.

## Staging, packages, and older material

- C:/Users/pmcga/Documents/Codex/Hollowtide/Move work/staged has 130 files. Matching the same project paths, 117 are byte-identical, 13 differ, and none are missing from the live project. Differences include creature resources and the battle script, so copying this staged tree back would undo current work.
- C:/Users/pmcga/Documents/Codex/Hollowtide/party-ownership-stage has one script identical to the game and two differing versions. The project versions are current.
- The newer `St. Joseph Creaturedex Design.docx` download is preserved as `C:/Users/pmcga/Documents/Codex/Hollowtide/Research Originals/St. Joseph Creaturedex Design - downloaded 2026-09-27.docx`; it differs from the older research copy, so neither was overwritten. `Godot Pixel Art Animation Workflow.docx` already has a verified research copy.
- CreatureCollectorV2.zip contains only an empty directory. The Pokémon-style map generator and Monster Sanctuary ZIPs contain compiled Unity builds, not exposed PNG tile or sprite packs. They are references or tools rather than ready Hollowtide source art.
- `C:/Users/pmcga/Documents/Codex/Hollowtide/Reference Images/Overworld/emberville-external-reference.webp` is a screenshot of another game; use as visual reference only.
- The project's docs/crystal-creatures-concept tree and the Hub's older concept files are historical. On 2026-09-27, the only unique reusable package identified there, `Sound FX Starter Pack Vol. 1`, was moved intact to `docs/archive/legacy-source-packs/` with its license link. The live project already has the nested tree's sole referenced tile image byte-for-byte and a newer Godot AI addon (4.2.3 versus 3.2.1). The old gem roster, essence count, scripts, scenes, and platformer art should not be restored. The nested tree can be removed after its owner reviews the archive README.
- D:/Program Files (x86)/new-game-project is the earlier near-empty Godot stub, not the current game.
- OneDrive Desktop/Preston Hub/07 Research/Themes/06_Creative_Hollowtide.md is a September 21 research synthesis. Its then-current single-stage plan is superseded. Its real-animal-anatomy method could still help future designs; its market and name claims need fresh verification before public use.

## Synthesis for the game

Keep **raw generated source**, **reviewed transparent game PNG**, and **wired Godot resource** as three separate states. A picture in Downloads or docs is a candidate even if its filename says “approved.” A form becomes ready when its identity, front/back views, evolution continuity, pixel scale, and actual in-game look have been reviewed.

The river-side prop studies can give the sparse first route more place-specific texture while keeping its courier landmarks original. The Stone downloads are not yet a named roster line. The River Listener file remains an archived visual reference until the requested redo is chosen. The battle now shows one continuous HP fill per side, with exact numeric HP underneath. The fuller Hud 2.png sheet remains a lead for future framing and buttons; coordinate that work with the battle-screen owners.

For the next sweep, compare both filenames **and hashes**. Coalcrest shows that an identical name can hide different designs; River Listener shows that an opaque GUID filename can hide an exact duplicate. Update the project's sprite production board after each approved import with the form, view, raw source and prompt, conversion comparison, game PNG, and creature resource.

**Scope:** I scanned filenames across the OneDrive Desktop and Downloads (2,771 entries), then inspected the Hollowtide Hub folder, recent Downloads images, Codex staging, and the live game. Older personal image archives and unrelated folders elsewhere on the computer were not visually reviewed. The machine-readable snapshot remains at C:/Users/pmcga/Documents/Codex/Hollowtide/asset-sweep-manifest.json. This index is now saved in the live project's docs folder.

## Synthesis: build order from the sweep

1. **Use the current route as the test bed.** Preserve its courier choices and river-height observation. Review the rope post, lantern, and one bank/stone detail at the existing tile scale; place only pieces that make the ferry approach or high-water evidence easier to read. The first route needs a few purposeful landmarks more than a filled background.
2. **Finish the active starter's missing view.** Cinderhide → Clinkerhide → Ironvent is linked in resources, but Ironvent lacks a reviewed back original. A complete front/back set and an actual battle-scale look matter before treating the visual evolution as finished. Keep the Codex Ironvent conversion as a comparison image until Preston selects it.
3. **Resume Forge from approved parents.** Complete Vitrecrag's back, then redraw Rimefin and Cutbank Listener from their current roster briefs. Grow each later stage from its approved previous-stage image. The archived shark-like River Listener is a palette reference only; its filename should not steer the new anatomy.
4. **Treat loose art as candidates.** The two Stone downloads and the alternate Coalcrest have different anatomy from current briefs. Assign them only after a visual choice, then retain raw source, cleaned transparent PNG, and Godot resource as separate review steps.
5. **Review the continuous HP bar in motion.** It now tracks the exact remaining percentage and eases on damage, with no SP display. Check its layout and timing during the next play review. Save the fuller Hud 2.png housing and button study for the dedicated battle-camera and UI pass.

The full 20-line queue and one-image-at-a-time Forge sequence live in [sprite-production-board.md](sprite-production-board.md). This is a production order from the files and current project state, not new creature canon.

## Brief-to-art comparison

- **Coalcrest:** the current project source is a right-facing, low four-legged runner with a plated chest, high signal crest, and balancing tail. That is much closer to the Kithflare → Wayburn → Coalcrest roster brief. The Hub alternate faces left and reads as a taller, more dragon-like multi-limbed creature; the brief explicitly avoids a generic dragon. Keep the in-project design as the working line for now, while leaving the final art choice to Preston.
- **River Listener:** the archived teal image reads primarily as a broad shark-like creature. The current Cutbank Listener brief instead calls for a low cutbank amphibian with split shovel brow paddles, three gill fans, and open space beneath the brow, explicitly avoiding a shark. This explains why a redraw is needed; the archived image can inform palette but should not anchor evolution continuity.
- **Unnamed Stone pictures:** both suggest sturdy quadrupeds and a slate palette, but their mass reads as a closed rock shell. Marlward, Flintram, and Troughspine briefs deliberately ask for visible leg gaps, open arches, or a low wedge, and avoid turtle shells or boulder bodies. Treat these as mood references unless a revised brief gives them a distinct role.
- **Route props:** the rope post and cutbank marks connect directly to the first route's courier and river-height observations. Integrating one or two carefully scaled props would carry more world meaning than filling every empty grass tile.

## Main HUD sheet (2026-09-26)

- Source: `docs/palettes/Main Hud.jpg` (1168x784 JPEG with a magenta cutout backdrop). Live byte-identical copy: `assets/sprites/ui/main_hud_sheet.jpg`; magenta-key shader: `assets/sprites/ui/hud_key.gdshader`.
- In battle, `scripts/battle_screen.gd` crops the hollow dark panel, empty HP frame, and square controls. The painted green/yellow/red sample bars are references, not the live health display. The live bar keeps the continuous exact-percentage fill and Turbo Green color progression.
- The layout has editor diagnostics only; visually inspect the crop boundaries, JPEG fringes, and readability in a battle before calling the art final.

## River-landing battle backdrop (2026-09-26)

- `assets/backgrounds/river_landing_battle.svg`: original 288×162 cutbank battle-study asset, imported by Godot and displayed at 4× with nearest filtering. It includes foreground silt, diagonal water, distant bank, reeds, worn stone, and a small height marker. The implementation is in `scripts/battle_screen.gd` behind the moving creature stage and fixed Main HUD.
- This is a layout study, not a tile set or final environment approval. Review creature feet against both banks and the HUD overlap in a played battle; refine colors and props after that visual pass.

## Battle HUD typefaces (2026-09-26)

- `assets/fonts/Silkscreen-Bold.ttf` is the working creature-name face; `assets/fonts/Silkscreen-Regular.ttf` is the numeric HP face. Both came from the Google Fonts Silkscreen family. `assets/fonts/OFL-Silkscreen.txt` is the accompanying Open Font License.
- `scripts/battle_screen.gd` loads these directly for the two battle status headers. The HUD sheet still supplies the surrounding frames; live ProgressBars supply the exact HP fill and color changes.

## First-route focused environment pass (2026-09-26)

- [First-route environment art brief](first-route-art-pass-brief.md) records the saved-scene visual read and three specific non-creature asset needs for Grok: landing tie-off, cutbank/reed pieces, and an empty return-mark detail. `docs/HollowTide Sprites/Assets/Customer grok asset.png` is a style/silhouette reference, not a game-ready import.
- Preserve the currently placed office, marker, retaining wall, cottonwoods, relay post, and height marker. Integrate only reviewed assets at route scale, keeping the path and interaction spaces clear.
