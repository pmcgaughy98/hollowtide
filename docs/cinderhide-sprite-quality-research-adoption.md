# Cinderhide sprite quality research adoption

**Source reviewed:** `C:/Users/pmcga/Downloads/Cinderhide Sprite Quality Standard.docx`, supplied by Preston on 2026-09-26. This file is research and interpretation, not approved art canon. I compared its claims with the current Cinderhide, Slagglass and Vitrecrag Forge originals in `docs/HollowTide Sprites/Creatures/`. Do not overwrite any approved creature from this report alone.

## What transfers to Hollowtide

- **Shape before texture.** Cinderhide reads through a long wedge of torso and head, planted limbs, a broken dorsal rhythm and clear leg gaps. Judge a new form as a flat silhouette at battle size before deciding that more detail will fix it.
- **Large material clusters.** Use contiguous dark, middle and light shapes to make shell, hide, glass, silt or membrane read as a material. Keep texture localized. The approved Cinderhide has richer shading than the older low-detail brief requested; the shared standard is its controlled density, not a sparse interior.
- **Directional volume.** Pick one clear light direction for each asset and put dark values under overlapping masses. Avoid pillow shading and bands that simply trace the outline. Interior lines can use a neighboring dark color rather than black everywhere.
- **Restrained accents.** Cinderhide's orange vents are small relative to its dark body. Other essences need their own focal colors and materials; no species should inherit Ember orange or Turbo Green merely because Cinderhide is the style anchor.
- **Visible support.** Cinderhide's feet have width and contact pixels. Slagglass's thin distal legs and Vitrecrag's large upper body would benefit from closer review of weight-bearing connections. Preserve Vitrecrag's face, crest, layered shell and furnace lattice, which Preston likes.
- **Review at two scales.** Reject a sprite if the head and torso disappear at battle size or if the zoomed logical pixels contain accidental single-pixel noise. A purposeful one-pixel eye or sparkle can be valid; a field of unrelated confetti is not.

These choices agree with [Pedro Medeiros's cluster sketching guidance](https://saint11.art/pixel_art_articles/article2/) and [shading guidance](https://saint11.art/pixel_art_articles/article4/). Those primary tutorials allow deliberate exceptions to one-pixel clusters and sometimes use controlled antialiasing or dithering; the report's absolute bans overstate the source. Hollowtide's current pipeline still chooses a crisp logical grid because that is the established project look.

## Corrections to the report

1. **Do not impose a mandatory 24-color ceiling.** The report itself says 24–32 is a practical range rather than a universal rule. Review cluster separation, material hierarchy and palette cohesion in the output instead of failing an otherwise good sprite on a raw count.
2. **Do not add a floor shadow to Forge art.** The export needs flat #FF00FF outside the creature for clean conversion. Show weight with broad planted feet, dark contact pixels inside the body, and a stable baseline. Godot's battle scene may add its own shadow.
3. **Do not require a universal top-down light or warm highlights/cool shadows.** Choose light directions and hue shifts that fit the scene and material; keep them consistent within a sprite and line. The future color-system research should settle shared lighting conventions.
4. **Do not treat the report's 12–15 m Vitrecrag field scale as verified canon.** Existing scale proposals are review material. The user values Vitrecrag's present creature type and major design. Any change to its flame-like forelimb, shell, or crest needs visual comparison and Preston's choice.
5. **Do not confuse JFIF source with final Godot PNG.** The exact logical grid and transparency are checked after conversion. A prompt alone cannot certify pixel-grid integrity or zero fringe pixels.
6. **Do not apply the report's species-shape shorthand universally.** Nature is not required to be a bottom-heavy wedge, Hollow can have feet or other contact, and Tide need not always have fins. The line brief governs anatomy.

## Small prompt addition for both creature Forges

Use this as a quality paragraph, with species anatomy supplied by the brief:

> Use Cinderhide's **craft**, not its reptile shape or Ember palette: a decisive silhouette readable at battle size, substantial dark contour, coherent large color clusters, stepped directional shading across distinct material planes, sparse focal accents, and visibly load-bearing contacts. Keep any fine detail attached to larger structures. Avoid pillow shading, repeated parallel bands, random single-pixel confetti, fuzzy edges and an external floor shadow. Use a purposeful palette; do not force a fixed color count at the cost of clear materials.

## Review order

1. Check requested form, true front or back camera, line anatomy and pose.
2. Check silhouette, body mass, foot/contact baseline and face at battle size.
3. Check material planes and accent placement at nearest-neighbor zoom.
4. Check logical grid, edge quality and magenta isolation in the converter comparison.
5. Only then approve import or ask for one targeted redraw.

**Status:** no new sprite was approved from this review. An earlier Stage I turtle generation was attempted with its ready brief and Cinderhide style anchor, but Opal returned `You have reached the image generation quota`. No Preostmar image exists yet.
