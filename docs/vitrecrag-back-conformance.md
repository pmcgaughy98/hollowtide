# Vitrecrag back view: what it needs to match the front

**Preston's later direction (2026-09-28):** the small head must be visibly connected to its collar while the
overall pose reads as a true rear view. His reference is
`docs/art-review/vitrecrag_back_head_reference_2026-09-28.png`. Use the current copy-ready prompt in
`docs/vitrecrag-back-forge-prompt-2026-09-28.md`; the older prompt below is retained as history.

**2026-09-28, Claude, at Preston's request.** The approved front (`assets/sprites/creatures/vitrecrag_official.png`)
is the authority. The current rear (`vitrecrag_rear_2026_09_27.png`) was the best Forge result Preston got, and he
flagged a bulkier carapace, a wrong head connection and off proportions. Measured side by side at 128×128:

| | Front (authority) | Current back | Needs |
|---|---|---|---|
| Size | 122×93 px, aspect 1.31 | 120×91, aspect 1.32 | Already matches |
| Carapace | Tall dome, crown toward the front; a few large plates divided by orange straps with rivets at crossings; slim rim band | Lower, flatter top; thick rim "skirt" of overlapping shingles hanging over the legs (shell ≈25% of body pixels vs ≈12% on the front) | Same dome height and strap lattice; slim rim, no skirt |
| Head and collar | Shell's front edge curves down into a ring collar; small low head sits inside it at the rim's height | Front-right edge drops straight into a leg; no collar, no head | Collar ring at the front-right far end with the back of the head just visible at rim height |
| Underbody | Rust-red armoured hips and thigh plates between shell and legs | Dark grey mass | Same rust hip armour |
| Furnace window | Large lattice window, about 3×2 panes, bright | Smaller 2-pane window pushed right | Same window seen from behind: same panes and glow |
| Finish | 24 colours, clean clusters | ≈4,000 colours, soft and noisy | Snap to the front's 24-colour palette |

**What is already right:** size and aspect, six legs with clawed feet, and the furnace on the right flank. Facing away
toward the upper right, the creature shows the camera its rear and right side, so the window belongs on the viewer's
right, as drawn.

**Why the Molten Glass back view looks wrong:** from the front, the head tucks into the collar and glass heaves from
the collar, low at the front. The back has no collar, so the glass appears from the middle of the shell's side.
Once a back with a collar exists, move `attack_back_emitter_offset` in `data/moves/vitrecrag_molten_glass.tres`
down to the collar (it is currently `(36, -8)`).

## Evolution Forge brief (VIEW: BACK)

Attach the approved front `vitrecrag_official.png` as the image input. Paste as the brief:

```text
VIEW: BACK. Form: Vitrecrag (Ember, Stage III), same creature as the attached approved front, 128x128 native grid, redrawn from behind so it faces away toward the upper right, showing its rear and right flank. Keep the front's exact proportions: a tall domed carapace whose crown sits toward the front, divided by orange straps into a few large plates with rivets where straps cross, and a slim rim band, not a thick overhanging skirt of shingles. At the far front-right, the carapace edge curves down into the same ring collar as the front, with the back of the small low head just visible inside it at rim height. Between the shell and the legs show the same rust-red armoured hip and thigh plates. The large lattice furnace window, about three panes by two and glowing orange-gold, sits on the right flank facing the viewer. Six stone-grey pillar legs with rust bands and clawed feet, planted like the front. Use only the front's colours and its clean pixel clusters. Same size in frame as the front. Flat magenta background.
```

Review against the table above before import; run `tools/convert_forge_sprite.py`, then palette-check against the
front. Do not replace the linked rear until Preston approves the new one.

## Interim

`assets/sprites/creatures/vitrecrag_rear_palette_snapped_candidate.png` is the current rear snapped to the front's 24
colours (average colour shift 12 of 255). It fixes the finish only, not the shape. Unlinked; Preston's call.
