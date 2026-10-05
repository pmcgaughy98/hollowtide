> Current Coalcrest texture references now use the [October 4 tail/feet/lantern refinement](../coalcrest-refinement-2026-10-04/README.md), following further user feedback. This record and its original art/proof remain historical.

# Coalcrest tail-root correction, October 3, 2026

Preston identified the clipped tail attachment, remaining old lantern stem, rear misalignment and stray clusters after the earlier polish. This correction is installed for Coalcrest FRONT and BACK. Kithflare and Wayburn keep their previous active art unchanged.

## Changes

Front: restored the broad authored proximal tail behind the thigh, rejoined the new curl through a continuous oblique cross-section, removed both exposed old stem sections and their final black outline row between/behind the legs, and retained the actual feet and toes. The old foot rectangle was too broad: it included the old stem's bottom outline. The current guards follow the true foot regions.

Rear: retained the original rump/near leg/far foot, aligned the full lower curl with the proximal tail, replaced the leftover horizontal old-tail shelf, cleared overlay pixels outside the original upper anatomy, and removed the final dark underside overhang. Native band spacing and brown materials now follow each view's own authored tail. The completed front sail and original banded lamp pixels remain exact. Both sprites remain 160x160 with binary alpha.

## Evidence and limits

The prior connected-component check did not catch a clipped broad root or an attached old stem. Fresh native checks now cover the intended 3x3 tail cores, real foot masks, removed stem/shelf regions, smooth rear upper/lower contour profiles, fixed allowed tail regions, fin/lamp exact pixels, and one four-connected silhouette per sprite. Full source and close-up before/after images are preserved under review/. Final standalone review: review/coalcrest-final-review.png.

Actual native battle checks pass both front/rear idle views and all six available casts: Crest Signal, Furnace Bolt and Longfire Burst from both sides. Original zoom stays 2.0 front / 2.5 rear; installed textures stay active during attacks; position/texture restore and reverse state releases. Plate Rake remains excluded by its existing body gate. Final runtime stderr is empty.

Normal rear battle framing hides much of the root behind the HUD. The additional full-sprite diagnostic captures temporarily hide controls only in the isolated test fixture; production layout is unchanged. These captures show the installed sprites at their actual battle positions. Native art review and runtime proof establish the correction's inspected behavior, without claiming final aesthetic approval or a finished world.

The first probe started before asynchronous import finished, so its null-resource failure is retained in review/runtime/. The next probe passed gameplay checks but retained temporary fixture references at shutdown; review/runtime-verified/ preserves those warnings. The final isolated fixture releases its objects before deferred exit, and review/runtime-final/ contains the clean completed run. No production code was altered to hide diagnostics.

## Exact runtime files

- assets/sprites/creatures/coalcrest_tail_root_repaired_2026_10_03/coalcrest_front.png
- assets/sprites/creatures/coalcrest_tail_root_repaired_2026_10_03/coalcrest_back.png
- data/creatures/105_coalcrest.tres
- assets/sprites/creatures/coalcrest_tail_root_repaired_2026_10_03/coalcrest_front.png.import
- assets/sprites/creatures/coalcrest_tail_root_repaired_2026_10_03/coalcrest_back.png.import

Only the two texture paths in 105_coalcrest.tres changed; every other creature property is exact. Of 2165 recorded existing runtime files, 2164 remain byte-identical. All original art, prior installed PNGs, Kithflare/Wayburn resources, world scripts, battle architecture, creature/move rules, project launch and audio settings are preserved. Review/preservation-audit.json and runtime-manifest.json contain current hashes.

No new upload, generation or Retro Diffusion charge: $0.00. Only isolated owned checks were launched/stopped; the user editor was not controlled. No staging, commit, deletion or source overwrite. Broad world goal remains active.

This supersedes Coalcrest only in the [earlier six-view polish](../kithflare-tail-polish-2026-10-03/README.md); its original art and proof remain historical records. Documentation updates also include docs/AI_COLLABORATION.md and that previous review's supersession notice.
