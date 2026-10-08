# Hollowtide file sweep and synthesis

> **2026-09-27 update:** This is a historical sweep. Use [START HERE](START%20HERE.md) and the live project `docs/asset-location-index.md` for current paths. The two unnamed Stone originals are now in `Incoming/Needs Review/Stone candidates/`; overworld screenshots and the old shark reference are in `Reference Images/`; a newer St. Joseph Creaturedex report is in `Research Originals/` beside the older version. Eight moves and hashes are recorded in `hollowtide-moves-2026-09-27.json`. No old staging folder should overwrite the live game.

**Swept 2026-09-26.** The live game is at C:/Users/pmcga/dev/hollowtide. This is a location map and review queue. No source file was moved, deleted, or replaced. A machine-readable snapshot is beside this report at asset-sweep-manifest.json.

## What the sweep changed in our understanding

- The project already has nine Ember front sprites, seven Ember backs, their raw Forge originals, converted move effects, and creature resources. Cinderhide's current resource chain reaches Clinkerhide and Ironvent.
- A wholly different Coalcrest design sits in the OneDrive Desktop Hollowtide folder. The shared name does not mean it should replace the current game art.
- A named River Listener image in the Codex folder is an exact duplicate of a GUID-named file in the project's archive. It is not a production sprite. Preston previously requested a River Listener redo, so the old filename “Approved Original” does not settle the current choice.
- Two unlabeled Stone-like creature images sit loose in Downloads. Both are 1024x1024 and fully opaque, with the checkerboard visible in the picture. They need identity and cleanup before Godot.
- The fuller battle HUD sheet already exists at C:/Users/pmcga/dev/hollowtide/docs/palettes/image.png. The three gauge-view PNGs in that folder are byte-identical cropped mockups. This is a useful lead for HP well art that the latest battle handoff did not identify.
- Most of the Codex Move work staging folder is already in the game. It is a prior snapshot, not a queue to merge wholesale.

## Locations to check every session

| Place | What it holds | How to use it |
|---|---|---|
| C:/Users/pmcga/dev/hollowtide | Live Godot project, current concept, living bible, scenes, resources | Source of truth for what is wired into the game. |
| Project docs/HollowTide Sprites/Creatures and Creatures-Back | Original Forge Ember fronts and backs | Compare with reviewed transparent PNGs in assets/sprites/creatures. |
| Project docs/HollowTide Sprites/Effect Sheets | Raw creature and universal move sheets | Compare with assets/sprites/effects, data/moves, and scenes/effects. |
| Project docs/HollowTide Sprites/Assets | Cutbank and Grok environment/prop studies | Candidates requiring slicing, background removal, and route-scale review. |
| Project docs/palettes | HUD raw sheet and cropped mockups | Use image.png as the fuller source; avoid redoing art already there. |
| C:/Users/pmcga/Documents/Codex/Hollowtide | Move staging, alternate conversions, River Listener source, route preview | Review/staging, not an automatic replacement for live project files. |
| C:/Users/pmcga/OneDrive/Desktop/Preston Hub/06 Creative Projects/Hollowtide | Older concept/art notes and alternate Coalcrest | Historical notes; current THE_CONCEPT.md is in the Godot project. |
| C:/Users/pmcga/Downloads and Downloads/Images/2026-H2 | Unnamed art, research documents, old shark, external programs | Triage identity, provenance, background, and size before importing. |

## Newly surfaced art and conflicts

| Find | Location | Evidence | Action |
|---|---|---|---|
| Coalcrest alternate | C:/Users/pmcga/OneDrive/Desktop/Preston Hub/06 Creative Projects/Hollowtide/Coalcrest.jfif | Visually different from project docs/HollowTide Sprites/Creatures/Coalcrest.jfif. Their SHA-256 hashes start 6b9c1b16 and 1dc95550. | Preserve both; Preston chooses a design before any replacement. |
| River Listener source | C:/Users/pmcga/Documents/Codex/Hollowtide/Sprite Sources/River Listener - Stage I - Approved Original.jfif | Exact byte match to project docs/archive/d62f2a2e-c9e6-442b-a56b-994118ea4339.jfif. Not imported into the game. | Keep as archive/reference pending the requested redo. |
| Stone-like picture A | C:/Users/pmcga/Downloads/Image.png | Distinct 1024x1024 opaque image with baked checkerboard. | Decide creature identity, then clean and convert. |
| Stone-like picture B | C:/Users/pmcga/Downloads/Image (1).png | Second distinct 1024x1024 opaque image with baked checkerboard. | Review separately; do not infer an evolution link. |
| Ironvent conversion variant | C:/Users/pmcga/Documents/Codex/Hollowtide/Godot-ready sprites/ironvent.png | Different color and bytes from live assets/sprites/creatures/ironvent.png. | Compare at battle scale before choosing. |
| Old shark close-up | C:/Users/pmcga/Downloads/Images/2026-H2/shark_zoom.png | Legacy blue shark art, distinct from the planned Forge redraw. | Historical Rimefin reference only. |

## Art already in the project that can help

- Project docs/HollowTide Sprites/Assets/Cutbank tiles.png contains bank, water, grass, reeds, and stone studies. Its apparent pixel density differs from the current 16x16 route terrain. Slice and review in context before use.
- Customer grok asset.png in the same folder contains a wall, pipe, rope post, lantern, and mossy rock. The post and rock may strengthen the ferry approach, but perspective and scale need a look.
- CustomeAssets(Made by grok imagine).png is a mixed item/icon sheet. Pick only props that fit Hollowtide; the sheet as a whole is not a game asset.
- Project docs/palettes/image.png visibly contains two long gauge wells and FIGHT/REST buttons on magenta. It may supply HP well pieces. The mockup's STRIKE/VENT buttons are different, so this is a source to slice and adapt, not an exact final HUD.
- Project docs/HollowTide Sprites/Creatures has nine Ember fronts; Creatures-Back has seven backs. Ironvent and Vitrecrag still lack back originals. Their production resources and moves should be judged independently of the raw image count.

## Staging, packages, and older material

- C:/Users/pmcga/Documents/Codex/Hollowtide/Move work/staged has 130 files. Matching the same project paths, 117 are byte-identical, 13 differ, and none are missing from the live project. Differences include creature resources and the battle script, so copying this staged tree back would undo current work.
- C:/Users/pmcga/Documents/Codex/Hollowtide/party-ownership-stage has one script identical to the game and two differing versions. The project versions are current.
- C:/Users/pmcga/Downloads/St. Joseph Creaturedex Design.docx and Godot Pixel Art Animation Workflow.docx are external research originals. Relevant conclusions were discussed or recorded in project notes, but the documents remain in Downloads.
- CreatureCollectorV2.zip contains only an empty directory. The Pokémon-style map generator and Monster Sanctuary ZIPs contain compiled Unity builds, not exposed PNG tile or sprite packs. They are references or tools rather than ready Hollowtide source art.
- Downloads/Images/2026-H2/Emberville.webp is a screenshot of another game; use as visual reference only.
- The project's docs/crystal-creatures-concept tree and the Hub's older concept files are historical. The old gem roster, old essence count, and stale implementation step should not be restored.
- D:/Program Files (x86)/new-game-project is the earlier near-empty Godot stub, not the current game.
- OneDrive Desktop/Preston Hub/07 Research/Themes/06_Creative_Hollowtide.md is a September 21 research synthesis. Its then-current single-stage plan is superseded. Its real-animal-anatomy method could still help future designs; its market and name claims need fresh verification before public use.

## Synthesis for the game

Keep **raw generated source**, **reviewed transparent game PNG**, and **wired Godot resource** as three separate states. A picture in Downloads or docs is a candidate even if its filename says “approved.” A form becomes ready when its identity, front/back views, evolution continuity, pixel scale, and actual in-game look have been reviewed.

The river-side prop studies can give the sparse first route more place-specific texture while keeping its courier landmarks original. The Stone downloads are not yet a named roster line. The River Listener file remains an archived visual reference until the requested redo is chosen. The fuller HUD sheet is the strongest newly found lead for the current battle presentation, but Claude and Summer Engine are working in the battle area, so coordinate before changing it.

For the next sweep, compare both filenames **and hashes**. Coalcrest shows that an identical name can hide different designs; River Listener shows that an opaque GUID filename can hide an exact duplicate. Update the project's sprite production board after each approved import with the form, view, raw source and prompt, conversion comparison, game PNG, and creature resource.

**Scope:** I scanned filenames across the OneDrive Desktop and Downloads (2,771 entries), then inspected the Hollowtide Hub folder, recent Downloads images, Codex staging, and the live game. Older personal image archives and unrelated folders elsewhere on the computer were not visually reviewed. The Godot and Summer Engine editor bridges were offline, so this report is saved in the Codex Hollowtide folder and the live project was not changed.

## Brief-to-art comparison

- **Coalcrest:** the current project source is a right-facing, low four-legged runner with a plated chest, high signal crest, and balancing tail. That is much closer to the Kithflare → Wayburn → Coalcrest roster brief. The Hub alternate faces left and reads as a taller, more dragon-like multi-limbed creature; the brief explicitly avoids a generic dragon. Keep the in-project design as the working line for now, while leaving the final art choice to Preston.
- **River Listener:** the archived teal image reads primarily as a broad shark-like creature. The current Cutbank Listener brief instead calls for a low cutbank amphibian with split shovel brow paddles, three gill fans, and open space beneath the brow, explicitly avoiding a shark. This explains why a redraw is needed; the archived image can inform palette but should not anchor evolution continuity.
- **Unnamed Stone pictures:** both suggest sturdy quadrupeds and a slate palette, but their mass reads as a closed rock shell. Marlward, Flintram, and Troughspine briefs deliberately ask for visible leg gaps, open arches, or a low wedge, and avoid turtle shells or boulder bodies. Treat these as mood references unless a revised brief gives them a distinct role.
- **Route props:** the rope post and cutbank marks connect directly to the first route's courier and river-height observations. Integrating one or two carefully scaled props would carry more world meaning than filling every empty grass tile.
