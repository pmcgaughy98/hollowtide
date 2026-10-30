# cx-12 Tower foot, 2026-10-27

Five slots / six images checked. Nothing installed.

[Review sheet](review_sheet.png) | [Static assembly and stair](overview.png) | [Semantic checks](semantic-checks.json)

- town.building.hall: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C10 PASS, C11 PASS, C12 PASS
- town.building.hall.gable: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C8 PASS, C9 PASS, C12 PASS
- town.building.hall.root_foot: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C12 PASS
- town.building.hall.yard: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C12 PASS
- town.prop.hall.rise_stair: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C12 PASS

Source issues for Claude:
- The shared exported slots.json is stale after the later route.gd edit. These tools use the real candidate-only Godot export at registry 235abb6156b1, with the normal freshness check enabled. No registry was changed.
- Built-in image_gen returned larger-than-native sources. Raw files are untouched; each has its exact prompt, references, source path and hash. Native cleanup was explicitly authorized by Preston.
- prepare_slot recenters occupied bounds even for top_left and asymmetric foot art. That shifted gable/yard registration by one pixel. Exact blockout registration was restored after preparation, then final bytes were validated. See cleanup receipts and pre-restore PNGs.
- The stair generation had seven treads. Native recutting produces eight 12px tread bands, repeating one quiet middle tread; this is documented and not claimed as recovered source drawing.
- No neighbour-band reference exists for rise_stair. Its own target/grid, approved key, assembly and palette were used; it is placed separately from the Tower frame.
- Yard frame 1 is derived from painted frame 0 with only the coded handle region changed. All other frame pixels match; the unused generated second-frame body remains in raw.png.
- No in-game capture or Finish-shader/seam approval is claimed. The assembly is static art with unchanged upper-part blockouts. Future upper parts must own their three-pixel contact-shadow seams.
- No install. Key approval opens production; cx-12 slot answers remain pending Preston. cx-10 still waits for crown approval.

## Approved root revision, 2026-10-27

town.building.hall.root_foot: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C12 PASS

The root is revised per CODEX_ROOT_NOTE.md and Preston's go. Prior files archived in the slot's before-great-tree-2026-10-27 folder. The other four prepared images are exact. [Revision details and source issues](../root-revision-2026-10-27/DELIVERY.md).


Root R2 supersedes the prior root image only. [New pending packet](../root-redo-2026-10-27-r2/DELIVERY.md). Previous redo answer is preserved.


## Pass9 reference refresh,2026-10-28

[Updated Reach/stair candidate, check lines and source issues](../pass9-reach-stair-2026-10-28/DELIVERY.md). This slot image supersedes its earlier delivery; new packet pending. Other batch images and answers unchanged. Nothing installed.
