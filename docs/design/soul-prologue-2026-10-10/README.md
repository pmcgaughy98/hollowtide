# The campaign's first scene: a soul arrives in Hollowtide (Claude, 2026-10-10)

Preston: "start of game to be a human soul reincarnating into a new world which is Hollowtide as a creature, and an ultra powerful entity is talking to it out of camera while the soul, a ball of light, is floating perplexed and confused, before given the decision to choose creature to start as."

**Flow now:** title, New Game, **the soul prologue** (`scenes/soul_prologue.tscn`, `scripts/soul_prologue.gd`), then Codex's prologue opens on waking beneath the riverbank as the chosen creature (its starter buttons skipped), the companion choice, Highbank.

**Structure** from Explorers of Sky's opening (a voice in the dark, choosing who you will be, waking as a creature without memory), nothing copied. The void and the soul draw at the game's low resolution like the prologue after it, so the light is pixel light; the presence is never seen, its light falls from the top edge and brightens while it speaks; a "?" flickers over the soul when it does not understand; the river shimmers in far below at "This is Hollowtide"; the three starters show with their big front idles; the soul drifts over the one being considered, then flies into the chosen one, and a white flash carries into waking. Music: Preston's "Hollow in the Cottonwoods" (`hollow_flute`).

**The words are Claude's draft** (`LINES` and `AFTER` at the top of the script); the voice is "???" until Preston names it.

**Codex's files touched, one line each (originals in `originals/`):** `creature_opening.gd` (New Game opens the soul scene), `creature_prologue.gd` (`chosen_by_soul` skips its starter buttons).

Check: `tools/debug/soul_prologue_check.gd` (plays itself, picks Tallowroot, confirms the waking). Stills in this folder.
