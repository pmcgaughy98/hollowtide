# Gemini combat animation research: Hollowtide adoption (2026-09-27)

Source: `C:\Users\pmcga\Downloads\Pixel Art Combat Animation Pipeline Research.docx`. This is external research and design input, not an instruction to overwrite the current game or an approval of unreviewed sprites.

## Adopt for the next attack animation pass

- Build creature **body motion** from approved same-form art in named poses: idle anchor, weight shift, anticipation, launch, contact, recovery. A claw strike must move the claw beyond the resting silhouette and shift weight through planted feet. The existing Ironvent sheet looks more like heavy breathing than an attack.
- Generate and review extreme poses first, then fill the missing frames. Request one pose or a short clearly labelled sequence at a time instead of a six-frame sheet that averages the motion.
- Keep the **canvas and foot line registered** within one creature's action. The logical grid is form-specific: most current creatures use 100×100; official Vitrecrag uses 128×128. Preserve its approved detail and scale.
- Let Godot handle travel, hitstop, shake, flashes, impact art, and reusable projectiles. Body frames should change anatomy and silhouette. A moving idle frame plus a slash at the target does not sell a physical claw strike.
- Give the action uneven holds: longer anticipation and contact, brief launch. The report's 80/250/40/200/120 ms sequence is a starting proposal for Ironvent, not a gamewide rule.
- Review each pose against Cinderhide's pixel treatment and the approved creature reference. Reject magenta fringe, softened edges, extra anatomy, planted-foot drift, and near-identical frames.

## Implementation order

1. Use Ironvent Cinder Claw as the first attack-sheet repair. Approve anticipation and contact poses separately before making a complete sheet.
2. Align approved frames on the same native canvas and export transparent PNGs. Keep the source images.
3. Add frame-specific timing and contact triggers in Godot only after the art is approved. Preserve the current playable attack until the replacement is reviewable.
4. Apply the same pipeline to a projectile action after the claw reads clearly, reusing existing effect sheets for projectiles and impacts.

## Research limits

The report proposes AnimationPlayer, exact frame timings, a universal 100×100 grid, and some absolute palette rules. Those are recommendations, not settled Hollowtide architecture. The universal grid conflicts with the approved 128×128 Vitrecrag. The report's visual diagnosis and citations should be checked against the actual source sheets before any art is discarded. No game animation code changed during this research review.
