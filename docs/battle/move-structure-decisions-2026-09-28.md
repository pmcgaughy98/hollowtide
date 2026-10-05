# Move structure: decisions and open questions (2026-09-28)

**Preston, 2026-10-02.** The scene-taking move is an ultimate, not a signature. A signature is a named attack another creature can learn when its body has every part that attack uses. Essence types the hit and does not grant the move. Fins do not learn claw moves. No shell, no plate move. Molten Cannon needs a heat chamber and an opening that can lob. The full rule is in `docs/creatures/DESIGN_RULES.md`. The mechanic that runs is `docs/creatures/evolution-and-signatures.md`. The code flag is still called `signature`. That flag now means ultimate. Molten Glass, Furnace Roar, and Kingstone Rail are the ultimates that exist. The "Not built yet" body-tag sentence below is the 2026-09-28 state. The notes below keep the old word where they were written on 2026-09-28. Questions 1 to 3 stay open.

Source research: `RPG Move Animation Scaling` (Gemini Deep Research, Preston's OneDrive copy of
`docs/Gemini DeepResearch(Hollowtide)/`). Prompt: `docs/research/gemini-prompt-signature-moves-2026-09-28.md`.

## Preston's decisions

- **Shared moves plus signatures.** Most moves are shared and swappable. A shared move is a body pose the creature
  already has plus the move's own effect, fired from the creature's aim point (mouth, vent, horn).
- **Signatures are rare, powerful and impactful in their own way,** not only brute damage. Rarity can come from
  requirements only a few creatures meet (a grade such as "legendary or below" or "SSS or below"; hypothetical
  names, not canon).
- **Molten Glass is Vitrecrag's signature.** It may also hit hard directly (Preston changed his mind on that for
  Molten Glass). Visual direction: a factory core meltdown, a crucible of molten metal tipping over; a signature
  may take over the whole scene and screen.
- **Plate Lunge style animations are essence physical attacks,** not every physical attack: Plate Lunge is how
  Vitrecrag performs Ember physical moves.
- **Basic physical attacks get their own animations.** If they cannot be built from existing frames, Preston
  generates the sheets in the Forge.
- **A creature's body limits its moves, regardless of essence** (like Pokemon: no arms, no claw moves). Every
  move a creature can learn should make sense for its body, so a moveset fits the creature the way Aggron's fits
  Aggron, and every move still fits its animations. Not built yet; a likely shape is body tags on creatures
  (claws, mouth, shell, heavy) and required tags on moves.
- **Aim points** (built 2026-09-28): each creature names where attacks leave its body; a shared move names the
  point it fires from.
- **Molten Beam is dropped.** Its sheets are spare poses (the cannon uses two of them).
- **Next Ember magic or projectile attack:** Molten Beam or Molten Cannon, built like Molten Glass. Claude
  recommended Cannon (see below); Preston decides.

## Open questions (Preston's call)

1. Signature on the final stage only, or one per stage?
2. How a signature is gated: turn cooldown, meter, or once per battle.
3. The grade or requirement scheme that makes a move rare.
4. How many shared moves per essence (the research suggests 10 to 15). A proposal that counts the moves already equipped, and does not invent names to fill that range, is `docs/creatures/shared-move-pool.md`. Questions 1 to 3 stay open. The 2026-10-02 split already answers which moves are teachable.

## Claude's recommendation: Cannon before Beam

Molten Glass already puts a glowing stream on the ground from the mouth to the target, so a beam would read as a
second version of it. A cannon is a different shape on screen (a glob arcing through the air, then bursting), and
the Forge Molten Glass effect sheet already gave us lob and burst art (`lob_a/b/c`, `splash`) plus working lob
code (`_lob`). It also makes a good shared Ember projectile: any creature can fire it from its own aim point.

Preston agreed: Cannon first (2026-09-28).

## Built so far

- Molten Cannon, the first move built the shared way: it reuses Molten Glass's mouth-open poses as Vitrecrag's
  fire pose and brings its own effects: `vitrecrag_cannon_muzzle.tscn` (blast, spray, smoke),
  `vitrecrag_cannon_shell.tscn` (the Forge `eruption.png` glob as the shell, drip trail),
  `vitrecrag_cannon_blast.tscn` (impact burst and splash flash). New MoveData `attack_recoil_px` kicks the body
  back when it fires. Preview: `scenes/vitrecrag_cannon_preview.tscn`. The old placeholder
  `vitrecrag_molten_cannon.tscn` and its Codex projectile/impact art are no longer referenced.

- Molten Glass signature meltdown: MoveData "Signature" group (`signature`, `signature_light`,
  `signature_effect`, `signature_linger`), `scripts/effects/glass_meltdown.gd` + `glass_flood.gdshader`, scene
  `scenes/effects/vitrecrag_meltdown.tscn`. Overheat now also works on drawn-frame moves.
