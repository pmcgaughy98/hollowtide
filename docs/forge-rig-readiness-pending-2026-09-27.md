# Forge rig-readiness update — pending Opal persistence

**Status, 2026-09-27, later update:** This document was the recovery plan for Opal's earlier save failures. The live Main, Evolution, Walk, Effect, and Attack Forge prompts were subsequently edited through the visual editor, blurred to commit, and verified after full reload. Idle's existing NEW/COMPLETE prompt was audited and retained. No new image was generated, so output quality remains unverified. The copy-ready text below is a reference for rebuilding or reviewing the live prompts; the live editor is authoritative. Do not replace approved art just because a Forge prompt changed.

## Shared rig-ready art contract

Use a single approved form and an explicit TASK, VIEW, and native grid. Most current creature images are 100×100 logical pixels; Vitrecrag front/rear are an approved 128×128 exception. Preserve the exact form's anatomy and scale for a back or redraw. Aim for joints that can later be separated: readable neck/shoulder/hip/tail roots, limbs whose contours remain distinct where possible, and clear near/far layer order. Keep a stable foot line and ensure the silhouette works at actual battle size. These are **visual preparation**, not a promise that a flattened output contains hidden pixels. After approval, a human or local tool still has to cut exact visible masks, underpaint hidden overlaps, choose pivots, and verify an exact rest-pose reconstruction. Do not ask the model to output detached limb stickers as the only usable creature image. Avoid adding spikes, armor, sacs, or appendages simply to expose a joint. Use flat #FF00FF outside the creature, not transparency; convert and inspect locally. Use purposeful palette and pixel clusters, with no universal fixed color count.

## Main Sprite Forge — replacement Generate prompt

Link actual Opal inputs via the @ picker: Creature Brief, Previous Stage Sprite (optional), Style Anchor (optional). Preserve the image model, 1:1 output, and one-image display.

```text
Make exactly ONE original Hollowtide creature sprite from @Creature Brief. Follow the brief's species anatomy, pose, facing, palette, mood, and avoid-list. For TASK: REDRAW, @Previous Stage Sprite is the SAME form and controls identity; improve only the requested traits. For a new Stage I, it may be empty. Do not evolve a same-form redraw. @Style Anchor is for Cinderhide-level pixel craftsmanship only, never copied anatomy or palette.

Use VIEW: FRONT unless the brief says VIEW: BACK. FRONT faces three-quarter right unless the brief overrides it. BACK is a genuine three-quarter rear of the same approved form, facing away toward the upper right; show skull back, spine, tail root and rear limbs, with at most a tiny face sliver. Do not mirror the front. Keep asymmetrical furnace, plates, seams, and markings on the anatomically correct side. Do not add an unexplained spike, appendage, heat sac, or shoulder armor.

Draw for future cutout preparation while keeping the rest-pose image beautiful on its own: readable head/neck connection, shoulders, hip and tail roots, distinct near/far limbs where anatomy permits, clear overlapping plate order, and load-bearing feet. Do not split the creature into disconnected parts or reveal artificial cut seams. A flattened image does not supply hidden pixels; do not imply otherwise.

Match the APPROVED FORM'S native logical grid. Default to 100×100 only if no approved reference or brief specifies another size. For Vitrecrag use its approved 128×128 grid. Same-form redraws and backs preserve apparent body size, baseline, and footprint; evolution fronts may change mass and silhouette. Keep all parts in frame with at least three clear magenta cells below the lowest contact.

Grounded mature Hollowtide pixel art: chunky coherent clusters; dark controlled outline; material-specific stepped light/shadow; planted mass; restrained luminous accents. Do not impose a 24-color ceiling. Each logical pixel is flat, with hard edges and no blur, antialiasing, gradient, noise, pillow shading, or tiny scattered texture. Exactly one complete creature, no props, attack effects, guides, labels, floor or baked shadow. Entire exterior is exact flat #FF00FF; no magenta within the creature. Output one square image only.
```

## Evolution Forge — replace the last size/style and add rig rules

Keep its current four linked inputs and FRONT/BACK branching. Replace any absolute “100x100” and fixed palette ceiling with the shared native-grid rule above. Append this exact contract to its Generate step:

```text
RIG-READY SILHOUETTE: Make neck, shoulder, hip, tail and limb junctions legible without turning them into exposed mechanical seams. Preserve continuous anatomy and appropriate near/far overlap; the finished sprite remains one intact organism. Do not create extra spikes, detachable armor, inflated heat sacs, or shoulder pads to signal evolution. A future cutout artist will paint hidden joint pixels separately. Do not promise that this flattened image is already a rig.

VIEW: FRONT must change the stage's proportions, gait, mass distribution, and filled silhouette; it must be more than a scaled parent or parent plus pieces. For Kithflare → Wayburn → Coalcrest retain the lean earless four-legged reptilian courser identity and flush heat seams while making each stage a distinct runner with its own posture and load-bearing structure. VIEW: BACK uses the exact approved front of THAT form, with a real three-quarter rear camera and asymmetrical structures on their correct sides. Preserve apparent size and foot line.

NATIVE PIXEL GRID: Match the approved same-form reference's logical resolution. Default 100×100 only when no reference or brief says otherwise; approved Vitrecrag uses 128×128. Purposeful colors, no fixed palette ceiling. One exact flat #FF00FF exterior, hard pixel edges, one complete creature, no text or floor.
```

## Walk Cycle Forge — COMPLETE mode and turn-size control

Keep the linked Walk Cycle Brief and Character Reference. Add to Generate Walk Frames:

```text
MODE NEW creates eight distinct poses for ONE named direction. MODE COMPLETE uses @Character Reference as the approved partial sheet, not merely an identity suggestion. The brief names KEEP and MISSING frame slots F0–F7. Recreate the kept cells as closely as possible; fill only the missing slots, maintaining the same face, hair, outfit, satchel side, palette, cell grid, body scale, baseline, and camera. AI cannot guarantee exact kept pixels, so the user must compare them manually before import.

Eight pose functions in reading order: near-foot contact, down, passing, push-off, opposite contact, opposite down, opposite passing, opposite push-off. At least one planted foot every frame; no repeated peak stride posing, floating foot, broken knee, or mirrored satchel. Keep one fixed projection and foot origin. When generating a different direction for the same character, preserve the same ON-SCREEN height and grounded footprint, even if raw source canvases differ. Do not enlarge side poses relative to front/back. Output one 4×2 sheet with equal cells and no labels.
```

## Effect Sheet Generator — animated material, not generic particles

Change “Bloom” to “Nature” in any live essence list. Retain the five-piece MODE MODULES for small move components. Add a second mode within the existing Creature Brief text input; it does not require a new app or input:

```text
Read MODE from @Creature Brief. MODE MODULES: make the current five separate effect pieces on one sheet, with distinct main shape, impact, and three motifs. MODE ACTION: make one 4×2 sheet of eight CHRONOLOGICAL frames of the same material effect, equal cells, same origin, all separate. F0 charge/first emission; F1–F2 growth; F3–F5 sustained motion or projectile travel; F6 contact; F7 decay/cooling. Name the move, source anatomy, material, direction and target in the brief. Do not draw the creature. Preserve hard coherent pixel clusters and material volume at the game's battle scale rather than tiny isolated 8-bit dots. A sustained Vitrecrag molten-glass beam must remain connected across its held frames; a cannon shot must read as one heavy launched mass with separate impact. Draw their unique shapes from furnace, orange-gold molten glass, cooling shell, and pressure. This sheet is effect art only; Godot still owns creature body action, contact timing, hitstop, camera, and sound.
```

## Other Forge audit

- **Idle Forge:** Existing NEW/COMPLETE four-frame registration and source-reference rules remain useful. No new edit is required until an approved image reveals a specific missing behavior.
- **Attack Animation Forge:** Existing NEW/COMPLETE action-sheet rules remain useful. Pair it with the creature-specific body action and the Effect Forge's material pass. A single effect sheet cannot replace a full-body attack animation.
- **Install check:** change one harmless line, wait for Saved, reload, and confirm it persisted. Then update one Forge at a time; check its linked @ inputs, model, aspect, and output step after each reload. Run an image only after persistence is confirmed, using one approved form as a visual acceptance test. Keep every prior prompt/version available for rollback.

For the creature-by-creature action and rig research brief, use [Gemini's Ember production task](gemini-ember-creature-animation-research-task.md). For exact pilot status, use [the cutout rig note](creature-cutout-rigs-2026-09-27.md).
