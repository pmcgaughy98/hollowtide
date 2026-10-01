# Hollowtide Evolution Forge — live app specification

**Historical specification:** The live Generate step was updated on 2026-09-27 for approved native grids and rig-readable anatomy, then verified after reload. See [verified live modes](forge-live-status-2026-09-27.md). The text below records the earlier install plan.

**Live app discovered 2026-09-26:** [Hollowtide Evolution Forge](https://opal.google/edit/13O5Xm_9Go-u1cKn9TUCWAZhAXDe6OKbV). The older link ending `1HOz-FJm55YbzTqqpMgI-2b23_hT2B685` currently returns an access error. The app name, four inputs, one-image `VIEW: FRONT`/`VIEW: BACK` prompt, linked input chips, Nano Banana Pro model and 1:1 aspect setting all persisted after reload on 2026-09-26. The output step now shows one image. The four input descriptions also persisted after a reload and explain which reference to attach for each view. Graph-card summary text remains stale, and Opal's image quota prevented a live creature run; no front/back result has been verified.

## Builder request

Turn this existing app into **Hollowtide Evolution Forge**. Rename it from “Hollowtide Sprite Forge 2 (Backup)”. Keep it as one image-generation run per use; do not create a second app or generate an image during this edit.

Create or rename these user inputs and link each one into the Generate step with real @ input chips:
1. **Evolution Brief** — required text. The user pastes a roster prompt beginning VIEW: FRONT or VIEW: BACK and naming Stage II or III.
2. **Previous Stage Front** — image input for FRONT evolution. This is the immediately previous *approved* stage, never the old failed candidate.
3. **Approved Evolved Front** — image input for BACK. This is the approved front of the exact same evolved form that needs a rear view.
4. **Style Anchor** — optional image. Cinderhide is used only for pixel rendering quality, not species anatomy or palette.

Keep the image model Nano Banana Pro, aspect ratio 1:1. Replace the Generate prompt with the following rules. Its card summary should describe evolution fronts and true same-form backs, not Cinderhide-only art. Keep the output display step.

GENERATION RULES:
Make exactly ONE original Hollowtide creature sprite. Read the Evolution Brief and use its anatomy, facing, palette, personality and avoid-list as authority. Use the reference images for their distinct roles below. Never copy an unrelated species from Style Anchor.

When VIEW: FRONT: use Previous Stage Front as the immediately earlier stage of this lineage. Preserve three identity anchors from it—face/eye design, one signature marking or structure, and the palette relationship specified by the brief. Transform the organism into the new stage through changed body proportions, head-to-body ratio, limb structure, torso mass, stance and silhouette. Stage II must visibly grow beyond Stage I; Stage III must visibly grow beyond Stage II. Within the fixed canvas, give the new form more body mass or extent while keeping all parts in frame and three clear magenta cells below the lowest foot. Change its pose and weight distribution; do not trace the previous stage. At 1x size, the outline must read as a new life stage even with color and glow removed. Grow new features out of continuous anatomy. Do not solve evolution by adding detachable armor, shoulder pads, sacks, extra spikes, clothing, props, or a larger glow to the old body. For Kithflare → Wayburn → Coalcrest, keep four load-bearing legs and flush inner heat seams; never add heat sacs or shoulder armor.

When VIEW: BACK: ignore Previous Stage Front as a design source; use Approved Evolved Front as the exact same stage's identity. Turn the camera to a real three-quarter REAR view facing away toward the upper right. Show back of skull, shoulders, spine, rear limbs and tail connections, with only a tiny face sliver if anatomically visible. Transfer every distinctive marking to its correct rear-facing position. Match the approved front's apparent scale, body mass, palette and stable foot baseline. Do not mirror the front, redraw a front-facing face, evolve it again, or add/remodel anatomy.

Style Anchor controls only substantial dark outline, coherent large pixel clusters, stepped directional shadow/midtone/highlight across distinct material planes, restrained focal accents and visibly load-bearing contacts at approved Cinderhide quality. Avoid pillow shading and parallel color bands. Keep contact shading inside the creature, never as a baked floor shadow. It must not transfer reptile anatomy, Ember colors or Cinderhide markings to other lines. Mature grounded folklore, never cute, chibi or toy-like.

Render on one 100x100 logical pixel grid enlarged evenly into a square output. Every logical cell is a flat color with hard edges. Use a purposeful, coherent palette with no mandatory fixed color count; no gradient, blur, fuzzy edges, accidental pixel noise or subpixel detail. Outside the single full-body creature use exact flat #FF00FF magenta, with no magenta inside it. No transparency, checkerboard, floor, shadow, frame, guides, text, props or effects. Maintain a planted contact point and at least three empty magenta logical cells under the lowest foot. Output only one image.

Before finishing, check that a FRONT has a visibly changed stage, size and pose while retaining identity, or that a BACK is a true rear view of the same approved form. If a reference required by the selected view is missing, ask for it instead of inventing continuity.

At the end of your edit, verify that the four input chips are linked in Generate and the saved card summary no longer says “unique Cinderhide sprite.”

## Use after installation

- For a Stage II or III **front**, paste the form's [roster brief](../creatures/creature-roster-draft.md) beginning `VIEW: FRONT`; attach the immediately previous **approved front** in Previous Stage Front and optional Cinderhide in Style Anchor. Leave Approved Evolved Front empty.
- For a **back**, paste the same form's brief beginning `VIEW: BACK`; attach the **approved front of that same form** in Approved Evolved Front. Previous Stage Front is unused. Do this only after approving the new front.
- Reject any front whose outline is the parent plus armor, whose stance/size barely changes, or whose lineage face disappears. Reject a back that shows a front face, mirrors the front, or changes body size.
- Save the original candidate; convert and import into Godot only after review. One output per run protects the daily image quota.
