# Where the big front idles can work (Claude, 2026-10-10)

Preston: "we're going to use the front view idle animations from when we were first trying to make the game with bigger models and in more detail... creature summary, evolving, or whatever ideas it would be good for." `scripts/ui/creature_idle.gd` knows where they are. In use now: Kithflare, Sparkwick, Stormwick, Tallowroot, Huskward, Rampartroot, Rimefin. Left out: Riftfin and Scourmaw (their idles show the designs from before the October 9 remake); Vitrecrag and Cinderhide have older idle sheets not yet checked against their current art. Everything else has none yet.

Built: the party screen's stage plays the idle (Menu, Team).

Proposals, each from how a hand-made game uses its big front sprite (structure only):
1. **Evolution scene.** pokeemerald's evolution scene shows the old front sprite, then the old and new shapes flicker as white silhouettes faster and faster, then the new one is revealed with its name. Ours: the dungeon's evolve banner becomes a short scene with the two idles.
2. **Recruit card.** Explorers of Sky shows "X joined the team!" with the newcomer's portrait. Ours: the idle on a parchment card with its name, essences and level when a creature joins.
3. **Level up.** pokeemerald's level-up box lists what grew. Ours: the idle beside the new level, health gained and any move learned.
4. **Journal.** A Pokédex-style courier's journal: every creature met, its idle, its line and where it was found.
5. **Boss and scene cards.** The boss floor's dialogue scene with the guardian's idle beside its lines, like Explorers of Sky's portraits in dialogue.
6. **Title and opening.** Codex's companion choice already uses the starters' idles; the others can join once they exist.
