# Characters in two sizes: overworld sprites and dialogue portraits

Preston, 2026-09-30, with Nexomon: Extinction character sheets as reference: a small, chunky sprite walks the map;
when a conversation or scene starts, a bigger, better-drawn picture of the speaker pops up beside the message box
while the small map view sits dimmed or blurred behind it.

**Status:** proposal. Nothing here is generated or approved. The courier image Preston made in the Character Model
Forge is saved beside this file as `courier-character-model-candidate-2026-09-30.jpg`.

## The names for these
- **Overworld sprite.** The small walking character on the map. When it is drawn with a big head on a short body it is
  called **chibi** or **super-deformed (SD)**. That is the "small, clunky" look in Pokemon, Coromon and Nexomon's map
  sprites. It reads well at a tiny size because the head carries the face.
- **Dialogue portrait** (also called a **bust** or **talking portrait**). The larger, detailed picture of the speaker
  next to the message box, usually waist-up, with an **expression set**: the same picture with a different face for
  happy, surprised, worried and so on.
- **Standing art.** The same idea full-body, for bigger scenes. Optional; portraits come first.
- **Dimming the background.** During dialogue the map behind darkens or blurs so the portrait and the words lead.

## The current problem
The Character Model Forge is built for one middle size. Its rules ask for adult proportions of about 5.5 to 6 heads
tall and forbid chibi, at about 36 pixels tall. That is too detailed for a sprite that small and too small to be a
portrait. The image Preston generated shows it: a good, realistic adult, which is the right look for a **portrait**,
not for walking the map.

## Proposed sizes (Hollowtide's map tiles are 16 pixels)

| | Overworld sprite | Dialogue portrait |
|---|---|---|
| Proportions | chibi: about 2.5 to 3 heads tall, big readable head and eyes, short body | true adult, about 6 heads, the Forge's current look |
| Size | about 24 x 32 pixels drawn, standing about 30 tall | waist-up bust on a 96 x 96 canvas, shown at 3x beside the message box |
| Views | four directions (down, up, left, right), each standing plus a 4-frame walk | facing three-quarter toward the message box |
| Detail | few colours, flat shapes, the outfit reduced to its strongest colours | full Cinderhide-level finish |
| Extras | none | an expression set: neutral, happy, surprised, worried (same pose, only the face changes) |

Make the **portrait first**: it is the identity. The overworld sprite is then drawn from it (the Forge's REDRAW mode
with the portrait as the identity reference), keeping the outfit's colours and silhouette so the two read as the same
person.

## Who is the courier? (decided)

**Preston, 2026-09-30: the original chibi teal-shirt-and-goggles model is the main character.**
It is `C:/Users/pmcga/OneDrive/Documents/HollowTide Sprites/Character/Male.jpg`, also preserved as
`assets/sprites/player/character_walk_sheet.jpg` in the project. The larger-headed, short-bodied design matters;
the taller recent walk atlases are not its anatomy reference.

Codex made an exact named copy, `Main Courier - Chibi Source.jpg`, and four unchanged direction crops in
`Main Courier - Chibi Identity - Four Views.png`, beside `Male.jpg`. Use the four-view file as the identity reference
for portraits and the map model. No repaint or generation was used to recover it. The olive-jacket candidate
is only an example of portrait-level finish, not the chosen courier.

The current game still has the taller recent walk atlases installed. Replacement chibi walks need actual passing
poses: the original side rows repeat extended strides. This identity selection is not a claim that the old walk is repaired.

## Forge changes for Codex (Character Model Forge, or the Gemini skill after Opal closes)
Replace the single SCALE paragraph with two output kinds, chosen by a line in the brief:

```text
KIND OVERWORLD: a small map sprite in chibi proportions: about 2.5 to 3 head heights, a large readable head and eyes, short torso and legs, simplified clothing reduced to its strongest colours and shapes. Drawn on a 32x32 logical cell, standing about 30 logical pixels tall, feet on one baseline. Top-down three-quarter map projection. OUTPUT TURNAROUND gives DOWN, UP / LEFT, RIGHT in a 2x2 sheet at identical size. Crisp dark outline, few colours, flat clustered shading.
KIND PORTRAIT: a dialogue portrait: the character from the waist up on a 96x96 logical canvas, adult proportions of about 6 head heights, three-quarter view turned toward the right, face clear and expressive, full Cinderhide-level finish. OUTPUT EXPRESSIONS gives NEUTRAL, HAPPY / SURPRISED, WORRIED in a 2x2 sheet: identical pose, framing, clothing and lighting in all four; only the eyebrows, eyes and mouth change.
```

## Prompts to run (after the Forge change)
1. **Portrait.** `MODE REDRAW; KIND PORTRAIT; OUTPUT SINGLE. The adult Wayline courier exactly as the identity reference: teal shirt, goggles, brown hair, the satchel on its cross-body strap. Calm, capable, a little weathered from the road.` Attach the original chibi four-view identity image as the Identity Reference and Cinderhide as the Style Reference.
2. **Expressions.** `MODE REDRAW; KIND PORTRAIT; OUTPUT EXPRESSIONS.` Attach the approved portrait as the Identity Reference.
3. **Overworld sprite.** `MODE REDRAW; KIND OVERWORLD; OUTPUT TURNAROUND.` Attach the approved portrait as the Identity Reference. The Walk Cycle Forge then makes the four-frame walks from it.

## The game side (not built)
A dialogue box that slides the speaker's portrait in beside the message, swaps the expression per line, and dims and
softly blurs the map behind it. It needs one portrait to test with; it does not need the full cast.
