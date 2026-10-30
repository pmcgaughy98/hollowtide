# Current task continuation, 2026-10-27

37 candidates PASS against real current registry 235abb6156b1. Nothing installed; every review answer pending.

[Tower key review](cx-11-tower-key/review_sheet.png) | [Tower check/source issues](cx-11-tower-key/DELIVERY.md) | [Full current check receipt](final-contract-check/result.json)

The new Tower key is now officially prepared and checked. All 36 earlier candidates were revalidated and their nine review sheets refreshed. Claude's registry files were preserved.

Source issues for Claude:
- The official docs/design slots.json remains stale after a later route.gd edit (138737d30d2b vs live 235abb6156b1). The unchanged Godot exporter wrote the real current 185-slot snapshot into final-contract-check/slots.json. Unchanged Python tools used this snapshot path with normal freshness checks enabled. Claude should re-export the shared snapshot when ready.
- Key is references only and must never be installed. No key approval or completed Preston blockout walk is inferred.
- No capture.png was supplied; the review sheet explicitly leaves its in-game column empty. This is scripted asset validation, not visual approval or a runtime seam check.
- Raw generation is larger than native size. Raw was preserved; the provided prepare tool and explicitly authorized pixel cleanup produced exact native size.
- The approved key must travel with future part references and neighbour bands. cx-12 through cx-15 await Preston's walk/key yes; cx-10 awaits crown approval.

## Current check lines

- town.building.home: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C10 PASS, C11 PASS, C12 PASS
- town.building.shop: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C10 PASS, C11 PASS, C12 PASS
- town.building.storage: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C10 PASS, C11 PASS, C12 PASS
- town.building.scrolls: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C10 PASS, C11 PASS, C12 PASS
- town.building.lot_before_stall: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C12 PASS
- town.building.lot_before_shop: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C12 PASS
- town.landmark.lot_before_plot: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C9 PASS, C12 WARN
- town.room.shop.floor: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C9 PASS
- town.room.shop.north: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C9 PASS
- town.room.shop.south: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C9 PASS
- town.room.shop.west: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C9 PASS
- town.room.shop.east: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C9 PASS
- town.room.scrolls_cellar.floor: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C9 PASS
- town.room.scrolls_cellar.north: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C9 PASS
- town.room.scrolls_cellar.south: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C9 PASS
- town.room.scrolls_cellar.west: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C9 PASS
- town.room.scrolls_cellar.east: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C9 PASS
- town.prop.chamber.rug: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C8 PASS, C9 PASS, C12 WARN
- town.prop.chamber.window_wide: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C12 PASS
- town.prop.runners.window: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C12 PASS
- town.prop.runners.river_map: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C12 PASS
- title.backdrop.launch: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C9 PASS
- story.backdrop.dawn_bank: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C9 PASS
- story.backdrop.river_below: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C6 PASS, C9 PASS
- ui.backdrop.stage_blight: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C9 PASS
- ui.backdrop.stage_hollow: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C9 PASS
- ui.backdrop.stage_ice: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C9 PASS
- ui.backdrop.stage_loam: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C9 PASS
- ui.backdrop.stage_murk: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C9 PASS
- ui.backdrop.stage_sinew: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C9 PASS
- road.backdrop.sky: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C9 PASS
- road.backdrop.far: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C6 PASS, C9 PASS
- road.backdrop.river: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C6 PASS, C9 PASS
- road.backdrop.mid: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C6 PASS, C9 PASS
- road.backdrop.near: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C6 PASS, C9 PASS
- road.ground.path: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C6 PASS, C9 PASS
- town.building.hall.key: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C12 PASS

## cx-12 complete after key approval

Preston: "approval go". Five Tower-foot slots now pass, six images including the two-frame yard. Key is approved; all five new slot answers remain pending. Nothing installed. [Check lines and source issues](cx-12-tower-foot/DELIVERY.md). [Static art assembly](cx-12-tower-foot/overview.png). Next cx-13-tower-body.

## cx-13 complete

Five Tower-body slots pass, six images including the two-frame hoist. Exact alpha registration for all five parts; three root runs and chute endpoints measured. [Every check line and source issue](cx-13-tower-body/DELIVERY.md). [Static assembly](cx-13-tower-body/overview.png). Raw files unchanged, slot answers pending, nothing installed. Next cx-14-tower-crown.

## Approved great-tree root revisions complete

Preston: go after the two-root revision question. Both current root candidates pass, originals archived, other eight foot/body images exact. [Check lines, comparison and source issues](root-revision-2026-10-27/DELIVERY.md). Nothing installed. Next cx-14 crown, silhouette unchanged per root note.

## cx-14 crown complete

Six crown slots pass, including 17 active cells and six unused padding holds. Exact active masks, fixed hardware, state order, animation phases and coded anchors measured. Ten foot/body prepared images, including both root revisions, are exact. [Every check line, animated previews and source issues](cx-14-tower-crown/DELIVERY.md). Nothing installed; crown answers pending. Next cx-15 title Highbank; cx-10 remains held pending crown approval.

## cx-15 title complete; all unheld batches prepared

title.backdrop.highbank: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C9 PASS. Native384x216,47colours. Lamp/door and shade boundary measured; original village PNG exact to HEAD. [Review, static shader preview, exact prompt and source issues](cx-15-title-highbank/DELIVERY.md). Aggregate54current passing candidates across14batches, raw hashes verified. Nothing installed; cx-10's3slots remain held for crown approval/current re-brief.

## Current review decisions remain authoritative

Inventory: 54 scripted PASS, 51 pending answers, 2 redo, 1 approved reference key. The two current redo records are root_foot and root_vein (CODEX_ROOT_NOTE.md); they were not reset or interpreted as approval. [Current check and answer inventory](candidate-check-inventory-2026-10-27.json). Title preparation complete; root review feedback remains follow-up work.

## Root redo R2 submitted

Two revised roots pass. Nothing installed. Prior candidates archived; the other52 candidate images are byte-exact.

[New pending review sheet](root-redo-r2-review/review_sheet.png) | [Before/after](comparison.png) | [Static Tower assembly](assembly-2x.png)

- town.building.hall.root_foot: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C12 PASS
- town.building.hall.root_vein: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C8 PASS, C9 PASS, C12 PASS

Foot: smooth elbow,39px west bark entry; fixed join and right leg retained. Vein: irregular masonry shoulders up to6px beyond the old mask, with the woody centre and all three run breaks preserved. Two resampling omissions restored at rows208 and209.

Earlier redo answers are preserved verbatim. New R2 images await Preston in the versioned packet. Approval to revise is not approval of the result.

Source issues for Claude:

- Shared registry/export changed concurrently; checks use the genuine f4423acc8832 export and matching copied registry sources with the normal hash guard. No shared source was edited.
- Root note overrides old protruding-root/footing-stone art wording; Claude should reconcile references/brief text.
- Launch backdrop tint changed to #18172c and road.backdrop.mid now requires the Tower gap. Their existing candidates need a separate follow-up. Other 52 PNGs are byte-exact; their older reports are not promoted to this contract version.
- No in-game captures, Finish shader or runtime seam approval. This is a static art submission.
- cx-10 remains held pending crown approval/current re-brief; no installs.


## Launch tint and road Tower clearance submitted

- title.backdrop.launch: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C9 PASS
- road.backdrop.mid: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C6 PASS, C9 PASS

[Review, exact prompts, before/after and source issues](launch-road-refresh-2026-10-27/DELIVERY.md). Updated night palette; two willows grouped within60..225; forbidden corridor alpha0, wrap RGBA exact. Other52 candidate PNGs exact. Previous candidates and answers retained. No installs or runtime candidate captures. Next: pending visual reviews; cx-10 remains gated.


## Pass9 Reach/stair refresh submitted,2026-10-28

- town.building.hall.reach: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C8 PASS, C9 PASS, C12 PASS
- town.prop.hall.rise_stair: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C12 PASS

[Review, before/after, prompts and source issues](pass9-reach-stair-2026-10-28/DELIVERY.md). Exact current reference masks, Reach lower190rows/hook protected; eight12px stairs, root/crack geometry verified. Other52 candidate PNGs exact. Prior candidates archived and answers preserved. Nothing installed. Crown/updated art awaits Preston; cx-10 held, future title repaint waits for great-tree answer. Candidate-only scope continues.


## cx-10vast-scale views submitted,2026-10-28

- road.backdrop.highbank_far: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C9 PASS
- road.backdrop.vista: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C9 PASS
- story.backdrop.tower_sky: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C9 PASS

[Review, corrected side trees, exact prompts and source issues](cx-10-road-far/DELIVERY.md). Current explicit re-brief removes crown gate. Vista now has natural hanging willow framing; source middle860columns and native prepared centre retained. Far Tower100%clear at4talks/60post-talk looks in current numeric runtime check. Other54PNGs exact, source files exact, no install. Quit retains5ObjectDB/3resource diagnostics. Next title layoutA redo, existing small-Tower title superseded but retained. Town parts/new assembly remain pending exported contracts.


## Title layoutA art prepared, source palette hold,2026-10-28

title.backdrop.highbank: SOURCE HOLD; C1 PASS, C2 PASS, C3 PASS, C5 FAIL, C9 PASS

[Before/after, review, exact prompt and source palette evidence](cx-15-title-highbank/DELIVERY.md). Actual painter PALETTE47 diagnosticPASS; published34strip omits16protected colours, so main report remainsFAILC5.36980old pixels exact, other56PNGs exact. Source47correction supplied under candidate folder; no source/registry/palette/runtime edits. Old smallTower retired; new centred crown, grounded root, giant Stack and waylines prepared. No installation or visual approval. Next source fix belongs to Claude; independently audit remaining legacy art queue.
