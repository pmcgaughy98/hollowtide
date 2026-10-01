# Vitrecrag true back: Evolution Forge prompt

Use the [Evolution Forge](https://opal.google/edit/13O5Xm_9Go-u1cKn9TUCWAZhAXDe6OKbV).

## Version 3 (Claude, 2026-09-29): current

**Why a new version:** Claude compared the twelve rear attempts saved across Codex's folders and the Sprites folder (11 generated drafts plus the 09-27 rear in the game) with the approved front and with backs that worked (Oxbowarchon, Ironvent, Cinderhide). Three causes:
1. **Every attempt is the front pose again.** The head and mouth flame are on the right and the long side of the shell faces the camera. "Three-quarter rear" was not enough, because the model copies the attached front's pose. The backs that worked all show the hindquarters and tail nearest the viewer, with the head hidden toward the upper right. So this version says what is nearest, what is hidden, and that the long side must not face us.
2. **The legs.** Version 2 told the model that all six legs end in three-toed feet ("exactly like the close-up"). Preston: only the two FRONT legs have three toes, and the middle and hind legs are single broad pillar feet. From behind, the front legs are hidden, so no visible foot should have toes.
3. **The shell.** "Walnut" and "folded" still produced one smooth connected dome. This version describes the stepped outline and the overhang shadow under each plate, which is what makes plates read as separate.

**Attach two images:**
- **Approved Evolved Front:** `docs/art/review/vitrecrag_front_IDENTITY_1024.png`. This is the identity: shell, legs, palette and pixel style.
- **Previous Stage Front** (unused in BACK mode, so it is borrowed here): `docs/art/review/vitrecrag_back_POSE_GUIDE_1024.png`. This is PixelLab's 2026-09-29 rotation of the approved front: the "east" view of 8 (all 8 are in `docs/art/review/vitrecrag_back_pixellab/`). It has the right camera (the hindquarters nearest, turned away to the right, the furnace on the right flank) but the wrong shell (a smooth dome) and the wrong feet (toes on every leg). Use it for the pose only.

**Add as the first line of the brief:** `The Previous Stage Front image is a POSE GUIDE ONLY: copy its camera angle, body placement and where each leg stands. Do NOT copy its smooth shell or its toed feet; take the shell, feet, colours and pixel style from the Approved Evolved Front and this brief.`

**Paste into Evolution Brief:**

```text
VIEW: BACK. SINGLE SPRITE.

Vitrecrag, the same creature as the attached image, seen from BEHIND as it walks away from us toward the upper right. The camera is behind its rear end and a little above. The long side of its shell must NOT face the viewer; we look at its back end.

NEAREST TO US (lower left and lower centre): the rear end of the shell and the two hind legs, the biggest things in the image.
AT THE SIDES: the two middle legs, partly visible, smaller.
HIDDEN: the head, the face, the mouth flame and both front legs are out of sight beyond the far side of the shell. At most a faint orange glow shows past the shell at the upper right.

LEGS: every visible leg is a thick grey stone pillar with a rust-red armour plate over the thigh and an orange band at the knee, ending in ONE broad flat blunt foot pad like the base of a stone column. No toes, no claws, no split feet on any visible leg. (Only the hidden front legs have three toes.)

SHELL: the dark plum shell is built from several thick, separate, angular armour slabs stacked over one another from the ridge down, like heavy overlapping slate shingles. Each slab's lower edge overhangs the slab beneath it with a hard dark shadow line under it, and each slab has its own flat facets and orange edge seam with rivets. Because the slabs overlap, the shell's outline is stepped and jagged at every slab edge. It is not one smooth rounded dome, and the slabs do not melt into each other.

FURNACE: from behind, only a thin sliver of the orange-gold furnace glow shows low on the right flank, or none.

STYLE: native 128x128 pixel sprite, the same palette, chunky clean pixel clusters and dark outline as the attached image; the same size in frame. One complete creature, fully in frame, feet on one flat baseline, on flat solid #FF00FF magenta. Every pixel is either the creature or pure magenta: no soft glow into the background. No ground, shadow or text.

AVOID: a side view, the head or face visible, the shell's long side facing us, a smooth dome, toes or claws on the visible legs, a turtle, a mirrored copy of the front.
```

**Review before importing:** at 128x128 beside the official front, check three things first:
- the hindquarters are nearest and the head is hidden;
- every visible foot is a single pad;
- the shell's outline steps at each slab.

It stays a candidate until Preston approves it.

## Version 2 (Claude, 2026-09-28, superseded: it wrongly asked for three-toed feet on all legs)

**Why a new version:** every candidate so far missed the same two things. The shell came out as a smooth dome or as
horizontal armadillo bands, not the walnut of folded plates Preston describes. The legs came out as six identical
grey cones with orange cuffs in a straight row (or four turtle stumps walking), not the front's armored columns with
three-toed feet. Version 1 mostly listed what to avoid; this one describes the shell and each leg part by part,
because image models follow a concrete description better than a list of prohibitions.

**Attach:** `docs/art/review/vitrecrag_back_reference_board_2026-09-28.png` (the approved front at 5x with a leg
close-up underneath). If the Forge takes only one image, use this board instead of the plain front.

**Paste into Creature Brief:**

```text
VIEW: BACK. SINGLE SPRITE, not an animation sheet.

Creature: Vitrecrag, the same creature as the attached image (the approved front, with a close-up of its legs below it). Redraw it from behind: a three-quarter rear view, camera behind its left hip and a little above. It faces away toward the upper right.

SHELL: shaped like a walnut, not a dome. Longer than it is wide, lumpy and uneven, with a raised ridge seam running down the middle from front to back. It is built from five to seven thick, bulging armor plates that fold over and overlap each other like stacked, rumpled layers, each plate edged by the orange seams and rivets from the front. The outline dips between plates, so the top edge is bumpy, not a smooth curve. Dark plum colour, slim rim.

LEGS: six legs in three pairs, exactly like the close-up. Each leg has a large rust-red riveted armor plate over the hip and thigh, an orange band at the knee, then a thick grey stone column that stays wide all the way down like an elephant's leg, ending in a broad foot with three blunt rounded toes, each toe capped in orange. The legs splay outward from under the shell and plant wide. From behind, the two hind legs are the biggest and closest to the viewer, the middle pair shows partly at the sides, and the front pair is mostly hidden.

HEAD: a small low head at the far upper-right end, sitting in a ring collar under the front of the shell; the back of the head shows, facing away.

FURNACE: the glowing orange-gold lattice window stays on the viewer's right flank.

Style: native 128x128 pixel sprite with the same palette, clean chunky pixel clusters and dark outline as the attached image. One complete creature, fully in frame, on a flat solid magenta background. No ground, shadow or text.

Avoid: smooth round dome, turtle shell, horizontal armadillo bands, pointed or tapering cone legs, four legs, walking pose, legs lined up in a straight row, a front-facing face.
```

**Review before importing:** at 128x128 beside the official front, check three things first: walnut silhouette
with a bumpy top edge, rust-red thighs, and three-toed feet on thick columns. The result stays a candidate until
Preston approves it.

## Version 1 (Codex, retained as history)

Attach `assets/sprites/creatures/vitrecrag_official.png` as the exact-form image. Preston's head-placement reference is
`docs/art/review/vitrecrag_back_head_reference_2026-09-28.png`; inspect it for the visible head and right-side
furnace, but do not copy its side-heavy camera.

```text
VIEW: BACK. SINGLE SPRITE, not an animation sheet.

Creature: Vitrecrag, the same Ember Stage III creature in the attached approved front image. Draw a true three-quarter REAR battle view, not a mirrored front or a side profile. The camera is behind its left hindquarter, slightly above it. Vitrecrag faces AWAY toward the upper right. Its broad rear shell and the backs of its near hind legs are closest to the viewer; the low front of the body and smaller far front legs recede toward the upper right.

The head MUST be visibly present at the far upper-right end: a small beetle head emerging from a distinct ring collar beneath the shell, with its back/top and a narrow side silhouette showing. Show an actual head and mandible shape, not only an orange flame or an eye-shaped blob. The face and gaze point away from the viewer. Keep the head lower than the rear shell.

Match the attached approved front exactly in creature identity: six thick stone-grey beetle legs, rust-orange joint armor, dark plum volcanic shell, and a substantial orange-gold molten-glass furnace window under the shell on the viewer's RIGHT flank. The window has a dark lattice and must read as a body furnace, not an eye. The shell is a high-rear-to-low-front wedge made from a few LARGE asymmetrically stacked, overlapping armor plates with bold orange seams and occasional rivets. Keep its rim slim.

Native 128x128 battle-sprite grid. Match the approved front's coarse clean pixel clusters, restricted palette, strong dark contour, and restrained highlights. Exactly one complete creature, fully in frame, on a flat solid magenta background for later transparent conversion. No ground, shadow, labels or effects.

Avoid: front-facing claws or face, side-profile pose, hidden or detached head, new horn or dorsal spike, turtle dome, neat armor tile grid, shingle skirt, tiny or centered furnace, high front posture, fine noisy pixels, gradients, soft antialiasing, extra limbs or duplicate creature.
```

## v4 changes, 2026-09-30 (after Preston's best candidate so far)

The 2026-09-30 candidate got the camera right for the first time (rear three-quarter, head hidden, only the mouth
flame showing), with four visible legs and one blunt foot each. Still wrong: the shell came out as a smooth rounded
turtle dome with curved scutes, and the legs are short dark boots instead of tall grey stone pillars.

Likely cause: v3 names the things to avoid ("dome", "turtle", "smooth"), and image models tend to draw what is named.
v4 removes those words and describes only what is wanted. Swap these three paragraphs into the v3 prompt and delete
the AVOID line's "a smooth dome" and "a turtle".

```text
SHELL: the dark plum shell is a stack of five or six separate flat armour slabs, like the overlapping roof tiles of a pagoda or the plates of a pinecone seen from behind. The top slab is the smallest and sits on the ridge; each slab below it is wider and sticks out past the one above. Every slab has a straight lower edge with a hard black shadow line under it and an orange riveted seam along it. The shell's outline goes down in clear stair-steps, one step per slab, with corners.

LEGS: tall legs, as long as the shell is high, so the shell is carried well off the ground with clear space under it. Each visible leg is a thick pale grey stone column, the same pale grey as the legs in the attached image, with a rust-red armour plate over the thigh and an orange band at the knee. Each column ends in one broad flat pale grey foot pad.

AVOID: a side view, the head or face visible, the shell's long side facing us, toes or claws on the visible legs, dark boots, short legs, a mirrored copy of the front.
```

If the next rolls still round the shell, stop rolling: have Codex retouch the 2026-09-30 candidate (step the shell
outline into slabs and repaint the legs from the front sprite's pillars), since the camera and layout are already right.
