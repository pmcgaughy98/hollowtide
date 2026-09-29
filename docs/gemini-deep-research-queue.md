# Gemini Deep Research queue for Hollowtide

**Preston's role order, 2026-09-27:** Gemini owns evidence gathering and production-method research. Use `docs/agent-role-charter-2026-09-27.md`; research does not approve canon or change Godot files.

**Role:** Gemini gathers and checks outside evidence. Its reports are inputs for Preston, Claude, Grok and Codex to judge; they do not override the project files or directly change Godot. Cite primary sources where possible, distinguish fact from inference and design proposal, and call out unsupported claims in earlier reports. Read `THE_CONCEPT.md`, `docs/creature-roster-draft.md`, `docs/forge-production-standard.md`, `docs/creature-scale-research-adoption.md`, and the relevant images before each task.

## Task 1 — Vitrecrag's giant scale and silhouette (do first)

**Copy to Gemini:**

> Study how Hollowtide can depict Vitrecrag as a truly enormous, grounded kiln arthropod in a 100x100 logical-pixel creature sprite and a 1152x648 Godot battle view. Use the attached Complete Creature Dex Generation report as a proposal, then audit it rather than accepting its numbers. Inspect the approved Cinderhide front as the rendering-quality standard, the current Vitrecrag front as the **same-form design to preserve**, and Slagglass as an earlier lineage form that may need revision toward it. Recommend a distinctive *range* for field height and shell extent, a credible fantasy ecology, and 6–8 specific pixel-art scale cues that do not require more pixels or a fire plume. Explain which existing `battle_size = 1.75` and perspective assumptions need an in-game view to judge. Do not reuse Wailord's exact height by default. Separate sourced facts, visual-design inference, and original Hollowtide proposals. Return a one-page art brief and a short table of claims that the dex report overstates.

**Useful result:** a better rendered, heavier version of Vitrecrag's existing silhouette and grounded lore, without importing speculative mass or camera code.

## Task 2 — Cinderhide-quality sprite standard across the 60 forms

**Research received 2026-09-26:** `Cinderhide Sprite Quality Standard.docx` is in Downloads. Its useful findings and overstatements are reviewed in [the adoption note](cinderhide-sprite-quality-research-adoption.md). Do not rerun this task before using that review.

**Copy to Gemini:**

> Using Hollowtide's approved Cinderhide sprite as the visual finish benchmark, identify what makes it read as mature, detailed pixel art at 100x100: outline weight, light and shadow cluster structure, internal material texture, accent density, silhouette hierarchy, and grounded contact. Compare it with the current Slagglass and Vitrecrag fronts. Research practical pixel-art guidance from experienced artists or primary game-art documentation, cite direct sources, and give a concise acceptance rubric that works for Tide, Stone, Gale, Nature and Hollow without copying Cinderhide's reptile anatomy or Ember palette. Include five failure examples and how a Forge prompt or human review can catch each. Do not recommend a fixed color count unless evidence supports it.

**Useful result:** a review rubric and prompt guidance for the Sprite Forge and future creature approvals.

## Task 3 — Large-creature battle framing and idle motion

**Copy to Gemini:**

> Research 2D monster-battle presentation for very large creatures compressed to fit a fixed camera. Hollowtide's battle viewport is 1152x648, the creature art uses a 100x100 logical grid, and the current foe perspective factor is about 0.72. Vitrecrag already has `battle_size = 1.75`; its current image still feels small and visually weak. Find methods to communicate physical scale through relative silhouettes, overlap, ground contact, camera framing, environmental cues and restrained idle motion while preserving readable HUD and move effects. Cite official engine documentation for technical claims and original artist/developer sources for art claims. Give a design option matrix with tradeoffs and a review sequence; do not prescribe code changes before seeing the new art in battle.

**Useful result:** evidence-backed composition options for Claude and Codex after the art redraw.

## Task 4 — River/flood history and ethical adaptation

**Copy to Gemini:**

> Verify firsthand historical records for the 1993–1994 Missouri River flooding around St. Joseph, Missouri and Elwood, Kansas, including the account that a levee was intentionally cut to protect St. Joseph. Distinguish documented facts, local memory, disputed accounts and later retellings; cite primary records, contemporaneous reporting and public archives with dates. Also study the Pony Express's local role and Jesse James history with the same care. Propose original Hollowtide motifs for a relay guild and a river-adjacent exploration area that capture the region's texture without presenting invented history as fact or treating flood loss as spectacle. Mark each motif as direct inspiration, transformation or invention.

**Useful result:** historically grounded story material for the living design bible, with corrections to any earlier unsourced claim.

## Task 5 — Audit the rest of the dex scale table

**Copy to Gemini:**

> Audit all 60 rows in Hollowtide's `docs/creature-scale-proposals.csv` against the 20 three-stage line briefs. Flag outlier height, extent, mass, battle_size and idle_breath progressions; distinguish body length from shell extent and wingspan; identify any values that would undermine each line's anatomy or battle readability. Treat the table's source row IDs as unrelated to Godot IDs. Return a compact change list grouped as keep, revise, and defer, with reasoning. Avoid pretending speculative density calculations are verified biology. Do not alter the roster or project files.

**Useful result:** a reviewable scale proposal before numerical values enter creature resources.

## Task 6 — Hollowtide color system beyond Turbo Green

**Copy to Gemini:**

> Research and propose a coherent color system for Hollowtide's mature, grounded pixel-art world. Read `THE_CONCEPT.md`, `docs/art-direction.md`, `docs/world-bible.md`, `docs/creature-roster-draft.md`, `docs/forge-production-standard.md`, and `docs/personal-stone-line-proposal.md`. Inspect the **approved Cinderhide sprite**, current player sprite, route art, river battle backdrop, and current HUD art rather than judging descriptions alone. Turbo Green is already the full-health UI accent; determine where it belongs in interface feedback, but do not spread it across every creature, plant, building, and route. Nature is the new name for the former Bloom essence and covers floodplain plants, roots, silt, fungi, seed, and shelter—not just saturated leaf green.
>
> Find primary guidance from working pixel artists, original studio/developer art breakdowns, and official accessibility documentation. Explain value grouping, warm/cool balance, limited but flexible ramps, materials, local color versus light color, outline treatment, and how sprites remain legible over day, dusk, rain, and river backgrounds. Do not copy a commercial game's exact palette. Propose **two or three distinct Hollowtide palette directions** with tradeoffs, then recommend one. For the recommended direction, supply small provisional hex palettes for Ember, Tide, Stone, Gale, Nature, and Hollow; a neutral world-material set for soil, timber, brick, river, foliage, and UI; and a separate palette for Preostmar → Oathfen → Oxbowarchon that is recognizably Nature without borrowing Turbo Green. Show all palettes as a contact-sheet specification that Preston can compare on the same sample sprites and backgrounds. Include grayscale and common color-vision-deficiency checks, contrast targets for name/HP text, and explicit rules for preserving Cinderhide's material-detail standard across the roster.
>
> Mark direct source findings, visual inferences, and original Hollowtide design proposals separately. Audit any claim that a specific number of colors, hue angle, or hex value is mandatory. Do not change approved art or project files. End with five concrete review questions for Preston and an implementation order for Forge prompts, environment art, battle presentation, and UI.

**Useful result:** a color language for the whole game, with Turbo Green confined to the UI role Preston chose and the personal Nature turtle visually distinct.

## Task 7 — Combat action animation and Ironvent Cinder Claw

**Copy to Gemini:** [the complete attack-animation research task](gemini-attack-animation-research-task.md). It uses Ironvent's weak claw action as the concrete case, compares single-sheet and staged pose generation, and asks how to connect body poses, hit timing, effects, and Godot without changing approved creature art. The current Attack Animation Forge is a provisional six-frame 3×2 workflow with contact at F4; Gemini should audit that choice.

**Useful result:** a tested production method and a repair plan for Ironvent that can later support guards, interruptions, and hit reactions.

## Task 8 — Existing-sprite cutout rig and exact-pixel extraction

**Research received 2026-09-27:** `Godot 2D Pixel Cutout Rigging.docx` is in Downloads. See [the adoption note](gemini-cutout-rig-research-adoption.md) for measured corrections and the first exact-pixel two-part courier pilot. Do not reuse the report's sample hash, bounding boxes or underpaint counts as production values.

**Copy to Gemini:** [the complete cutout-rig research task](gemini-cutout-rig-research-task.md). Start with the current courier side frame, then assess Cinderhide and Vitrecrag. It requires an executable layer manifest, a pixel-identical rest recomposition check, and an explicit inventory of hidden joint art before any rig replaces approved sprites.

**Useful result:** a reversible Godot 4.7.2 pilot that Codex can build without silently changing approved visible pixels.

## Task 9 — Nine generated Ember forms: physiology, lore, complete animation

**Ready 2026-09-27:** [Copy the complete Gemini Deep Research prompt](gemini-ember-creature-animation-research-task.md). Scope is only Cinderhide → Clinkerhide → Ironvent, Kithflare → Wayburn → Coalcrest, and Fusern → Slagglass → Vitrecrag. It asks for anatomy- and lore-derived four-move cards, full-body cutout/hand-frame production, per-view Godot action timing, and distinct Vitrecrag molten orange-gold glass beam and cannon actions. It treats Kithflare's line as heat-and-momentum relay coursers rather than generic fire creatures.

**Useful result:** one implementable production plan per generated creature, with the smallest reversible full-body battle pilot and explicit art-approval gates.

## Handoff format

Each report should include: source links and dates; directly observed facts; uncertain or contradicted claims; design recommendations; exact project files affected; and questions requiring Preston's creative decision. Gemini should not silently rename species, add evolutions, change creature IDs, replace approved art, or write implementation code.
