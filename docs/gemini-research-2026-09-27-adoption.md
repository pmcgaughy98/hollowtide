# Gemini research intake — 2026-09-27

These four documents are research inputs, not new Hollowtide canon or instructions to overwrite the game. Preston's decisions and the approved art remain authoritative.

## Sources received

- `C:/Users/pmcga/Downloads/Hollowtide Color System Proposal.docx`
- `C:/Users/pmcga/Downloads/Creature Scale Proposal Audit.docx`
- `C:/Users/pmcga/Downloads/Large 2D Creature Battle Presentation.docx`
- `C:/Users/pmcga/Downloads/St. Joseph History And Lore.docx`

## Adopt for the next design passes

**Color:** Keep Turbo Green as a *UI health/focus signal*, separate from Nature. Use creature-specific material ramps and a quieter soil/timber/river environment. The proposed six essence ramps and the peat/olive/silt/slate Preostmar colors are useful contact-sheet candidates, especially the distinction between Nature reeds and the HP bar. Compare them against approved Cinderhide and generated sprite candidates before changing Forge prompts or recoloring existing art. A single mandatory global palette or indiscriminate screen tint would flatten the material finish Preston chose.

**Scale:** Separate height, body length, shell extent and wingspan when recording future physical dimensions. Keep game-world size, source-art dimensions and `battle_size` as different concepts. A large creature needs broad planted contact, dense readable material detail and slow internal motion; a larger engine multiplier alone does not supply those cues. Do not import Gemini's revised tonnage or meter figures as facts. Rows 040–042 in the old CSV still need a dedicated Preostmar-line draft.

**Battle presentation:** Use the camera and foreground/background composition to communicate a giant's mass while keeping the fixed HUD readable. The research's best near-term suggestions are foreground overlap, contact shadow, restrained heavy idle, and an attack wind-up that visibly carries inertia. Our 2026-09-27 Vitrecrag preview showed that the current 1.75 size reads large, but its feet run behind the lower dialogue HUD and the shell approaches the upper HUD. A dedicated battle-stage framing pass should set creature ground lines and HUD-safe bounds before further scaling. Preserve nearest-neighbor sprite filtering and integer-aligned placement.

**Regional texture:** The history report offers leads on the river, relay stations, a contested public memory of the flood, and the difference between a documented event and an accusation. These are research leads for the fictional Wayline and river route, not automatic lore. Preserve Preston's local recollection alongside the report. Verify dates, names, and contested claims against primary records before putting them in dialogue or marketing copy; keep the game's fictional flood cause open until Preston chooses it.

## Do not adopt directly

- Fixed physical measurements or a claim that a particular creature's mass is biologically proven. Vitrecrag is a fantasy kiln arthropod; the report's 800–1,100-ton revision is still a speculative number.
- The report's proposed hexes as mandatory global law. They are palette trials. The current Cinderhide image and full-health HUD are established visual references.
- Camera2D instructions verbatim. `battle_screen.gd` currently builds its own battle-stage and HUD layers; fit any camera change to those actual nodes and preview it with both normal and giant creatures.
- Absolute historical conclusions or sensational flood details without checking cited primary material. Local memory and documentary evidence should be clearly distinguished.
- Any automatic 60-creature resource migration from the scale audit. Its row IDs are CSV row labels, not Godot creature IDs.

## Current asset and battle work

Ironvent's six-frame Cinder Claw uses its character atlas plus the newly supplied slash and impact art. Vitrecrag's four moves now include Molten Glass, Molten Beam, Plate Lunge and Molten Cannon; three projectile/impact pairs came from the new effect sheets. These changes were loaded and played in Summer Engine with no reported game errors. The generated `Vitre crage inhale.jfif` is an additional **candidate** continuation sheet. Its top cells did not preserve the prior frames exactly, and one cell has a pale smoke artifact, so the approved 12-frame idle remains unchanged pending a cleaner continuation.
