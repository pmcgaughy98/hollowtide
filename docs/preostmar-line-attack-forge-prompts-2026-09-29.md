# Attack Forge briefs for the Preostmar line (Stone, Line 9)

Same format and rules as `attack-forge-creature-prompts-2026-09-27.md`: one-run-at-a-time **Motion Briefs** for the [Hollowtide Attack Animation Forge](https://opal.google/edit/1mcPSsql5N9rj53Nbg0FFqFEh-e39c_f-). Each run makes a 3×2, six-pose **creature body** sheet. F0 is the approved rest, F4 is the named event, and F5 returns toward rest. Keep one camera, one native grid, one fixed foot origin, a flat magenta exterior, and no labels or target creature. Anything that flies, erupts or hits the target belongs to the Effect Forge.

**Move names are proposals.** They come from the move directions in `personal-stone-line-proposal.md` (Jade Lance, Stone Cocoon, Slab Vortex, Ground Spikes, railgun signature), plus one placeholder, "Anvil Ram", for a physical move. Preston names and balances the real kit. None of these moves exists in `data/moves/` yet.

**Sources:** Preston's fronts from 2026-09-29, in OneDrive `Documents/HollowTide Sprites/Creatures/`: `Proestmar.jfif`, `Oathfen.png` and `Oxbowarchon.jfif`, all 1024×1024. None is converted into the game yet. Upload the file itself as Source Sprite.

**Hip slabs stay out of the body sheets.** The detachable jade spikes are separate art (`Effect Sheets/Proestmar Effect/`), so every prompt keeps the hips and flanks clear. The body only shows the power that sends them.

## Preostmar

Source: `Proestmar.jfif`. Stocky, neckless stone quadruped. It has:
- a broad anvil skull set low, with two emerald eye-points under a heavy brow and a blocky three-part stone jaw;
- charcoal-brown hide cracked like dried stone, with emerald-mint light in the cracks;
- four pillar legs with three blunt talons each, and a short tail ending in a flat stone wedge;
- on its back, overlapping jade slabs on brown earth-stone, rising into one big forward-pointing jade arrowhead with a faceted emerald core.

It faces right. Its power comes from the emerald core and the glowing cracks, never from a mouth beam.

1. **Jade Lance — BODY, priority.** `MODE: NEW; VIEW: FRONT; ACTION CLASS: RANGED; FORM: Preostmar; MOVE: Jade Lance. F0 approved rest; F1 all four pillar legs brace wide; F2 the emerald core inside the big back slab brightens; F3 mint light runs from the core down the cracks of the hide toward the hips; F4 the body kicks back with a sharp flare along the cracks at both hips as if something was launched from there; F5 cracks dim and the stance settles. Draw nothing at the hips: the jade spikes are separate effect art. Keep the anvil skull, three-part jaw and back formation unchanged. No mouth beam, cannon, loose floating pieces, turtle shell, beak or neck.`
2. **Ground Spikes — BODY.** `MODE: NEW; VIEW: FRONT; ACTION CLASS: RANGED; FORM: Preostmar; MOVE: Ground Spikes. F0 approved rest; F1 weight shifts onto the hind legs; F2 near foreleg lifts, cracks glowing brighter down that leg; F3 the leg is raised highest and the back formation tilts back with the effort; F4 the foreleg stamps down, three talons driving light into the ground at its foot; F5 light drains back up and the foot stays planted. The jade erupting under the target is separate effect art. Feet stay on the same baseline. No shockwave ring, dust cloud or spikes drawn in this sheet.`
3. **Stone Cocoon — BODY.** `MODE: NEW; VIEW: FRONT; ACTION CLASS: RANGED; FORM: Preostmar; MOVE: Stone Cocoon. F0 approved rest; F1 body lowers and legs tuck in; F2 the back slabs pull tighter together over the spine with seams glowing brighter; F3 head draws down under the brow and the whole body compacts into a braced stone mass; F4 the slabs push one or two pixels outward from the body on a burst of emerald seam-light, still visibly bound to it; F5 slabs snap back into place and the stance recovers. The flying shrapnel is separate effect art. Slabs never fully detach or change shape.`
4. **Anvil Ram (placeholder name) — CONTACT, optional.** `MODE: NEW; VIEW: FRONT; ACTION CLASS: MELEE; FORM: Preostmar; MOVE: Anvil Ram. F0 approved rest; F1 hind legs load; F2 anvil skull lowers level with the forelegs and the brow shields the eyes; F3 shoulders drive forward within the fixed cell, the big back slab angled forward like a spearhead; F4 compressed impact pose with the flat skull front leading; F5 legs take the weight back. Godot carries the whole sprite to the target and plays the hit. No leap, horn, new spike or moving foot origin.`

## Oathfen (one priority run)

Source: `Oathfen.png`. Heavier adult body. It has:
- a large domed formation of jade slabs with a blazing emerald core in the middle;
- a horned stone skull with emerald eyes;
- jade plates with gold-amber gems on the shoulders and forelegs;
- cracked glowing hide, and a long tail ending in a stone wedge.

1. **Slab Vortex — BODY, priority.** `MODE: NEW; VIEW: FRONT; ACTION CLASS: RANGED; FORM: Oathfen; MOVE: Slab Vortex. F0 approved rest; F1 hind legs brace; F2 the emerald core flares through the dome seams; F3 the forebody rears up on the hind legs, forelegs lifting, the pale unarmored underbelly showing; F4 at the top of the rear the dome slabs shift around the core on bright seam-light, as if turning, while staying bound to the body; F5 forelegs come down heavily and the slabs settle. The spinning slab storm is separate effect art. Keep the horned skull, gold gems and tail wedge. No turtle shell rolling, no spinning whole body, no detached plates.`

## Oxbowarchon (signature)

Source: `Oxbowarchon.jfif`. The final titan. It has:
- a dark jagged jade and obsidian formation with gold-amber gems;
- two long jade rails above the back, angled forward, with the big Kingstone emerald at their base;
- a spiked stone skull with emerald eyes and green crystal spines along the jaw and chest;
- armored pillar legs, and a long curling tail ending in a stone wedge.

A signature move should be rare and big (Preston's 2026-09-28 decision). This sheet gives the body its build-up and recoil. The rail charge, the slug and the scene takeover come later as effect art and code.

**The charge (Preston, 2026-09-29, revised):**
- **Sky-aimed rails.** The rails swing up to point at the sky.
- **Growing sphere.** A sphere of power forms between them. Like a lightning railgun charging in the gap between its rails, but the power is Oxbowarchon's own: the Kingstone's green binding pull, the same force that holds its armor on. It uses no lightning bolts, electric blue or crackle.
- **Brace and release.** Oxbowarchon has to brace harder as the power builds around the sphere, then it releases.
- **Slug sheets stay for now.** The earlier jade-slug idea is kept, so the slug can still be what the release carries.
- **Still open:** what happens after the shot leaves the sky (for example, coming down on the target) is Preston's call. So is the energy's in-world name.

1. **Kingstone Rail (placeholder name) — BODY, signature.** `MODE: NEW; VIEW: FRONT; ACTION CLASS: BEAM; FORM: Oxbowarchon; MOVE: Kingstone Rail. F0 approved rest; F1 the two jade rails swing up from their forward angle to point nearly straight at the sky, still parallel and held above the back by green light, while all four armored legs spread; F2 the Kingstone at the rails' base brightens and a small emerald-mint sphere of light forms in the gap between the upright rails; F3 the sphere has grown large and dense, mint light swirling around it and thin strands bridging rail to rail, and the whole body sinks into a deep brace under the weight, talons dug in, every seam and hide crack blazing; F4 release: the gap between the rails is suddenly empty and a bright flash bursts at the rail tips pointing skyward, the body driven down and back by recoil within the cell; F5 faint mint afterglow lingers between the rails as light drains back into the Kingstone and the rails begin lowering toward their forward angle. The shot leaving the rails and anything in the sky are separate effect art. Keep both rails straight, parallel and attached by light. The charge is emerald-mint binding light, not lightning: no electric blue, white-yellow bolts or zigzag arcs. No metal, barrels, bolts or machine parts.`

For the in-game build, the Effect Forge should make a separate **between-rails charge** sheet with the rails upright. It should show the sphere growing from small to full over 4 to 6 frames, then 2 or 3 frames of a full-charge loop with the power swirling around it. Godot can hold that loop for suspense, like the Molten Glass hush, and deepen the brace while it holds. The charge then lasts as long as the signature needs instead of being fixed to one body frame.

## Selection and review

Run Preostmar's Jade Lance first: it is the line's identity move and it tests whether the Forge keeps the body stable. A sheet passes only if:
- F0 matches the approved front;
- F1 to F5 keep the same camera and foot origin;
- F4 reads as the named event;
- no frame invents a neck, a beak, a turtle shell or loose pieces.

The Opal sheets are candidates until they are cut and reviewed with `docs/attack-sheet-protocol.md`.
