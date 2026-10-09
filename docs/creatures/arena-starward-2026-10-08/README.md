# The Punchybuns line in the arena: Punchybun, Sparkjab, Starward (Claude, 2026-10-08)

Adrianna's electric ferret line (`memorial-ferret-2026-10-01/README.md`). **Preston, 2026-10-08:** Gabrielle is no longer involved; we take the line over; Claude names the stages and gets the line into the arena. Names: **Punchybun** (kept), **Sparkjab**, **Starward**. The memorial framing stays: the pink, the star, a ferret who protects the people it loves.

## The Protector
The roster's first support (the role gap at the top of `arena-roles-roster-proposal-2026-10-08.md`). **Grok:** every number is a draft. Electric.
- **Basic, Spark Jab** (AI): a quick electric punch (10, 26 px, 0.2 s melee telegraph).
- **1 Static Dance:** the ferret war dance. For 6 s its next jab is charged (x1.5 and a 0.4 s hold), and every ally within 50 px moves at x1.3 for 3 s ("Hasted").
- **2 Star Guard:** a pink star shield on the most hurt ally within 120 px (itself if nobody else): absorbs the next 25 for 4 s. Shields take damage before HP ("Shielded", "Shield broke").
- **3 Counter Jab:** it dashes to the ally in the most trouble (an enemy within 40 px of it) and punches that enemy away (12, knockback). Mobility, so roots and riptides stop it.
- **Passive, Guardian** (from stage 2): allies within 40 px take 15% less.
- **AI, escort:** it stands beside the most hurt ally, between it and the nearest enemy, and only presses when nobody needs guarding. The AI guards whoever is hurt or about to be hit, counter-jabs when an enemy is on an ally, and dances before jabbing.
- **4 Starshield** (2.4 s): the arena goes rose, the star-gem on its chest flares, a great pink five-point star draws itself over the team with sparks on its edges and snaps bright: **every ally is shielded (40 for 6 s) and cleansed** (Glassed, roots, cripple, smoulder, daze, stun), **every enemy inside the star is thrown out and held 0.6 s**; then the star sinks into the floor as a **star field** (6 s, 60 px) where allies mend 2 HP every half second: the first ally-only terrain. Sound: the regenerated ElevenLabs take (`tools/build_starward_sounds.py`), also used by Star Guard.
- Stages: Punchybun has Spark Jab, Static Dance and Star Guard, no passive and no signature; Sparkjab adds Counter Jab and Guardian; Starward adds Starshield.

## After Ravana (Preston, 2026-10-08 night: "the passive and the basic attacking punching at least")
Smite's Ravana is the model (`docs/research/smite-references-2026-10-08.md`, section 1). **Spark Jab is now a three-punch chain** (cooldown 0.7 s): two jabs, then a **Hook** that goes through everyone in front within reach (x1.3, a push); the chain lapses after 2 s without a punch. **The Chain** replaces Guardian as the passive on Sparkjab and Starward: every hit the line lands counts, and at eight it pays out a shield worth 7% of max HP on the ferret and on every ally within 40 px (stacking to three), plus 2 s of haste. Punchybun counts and hooks but has no payout (the stage rule). Static Dance, Star Guard, Counter Jab and Starshield are unchanged; Ravana's four abilities are listed in the research doc as options for a later pass. Check (`tools/debug/arena_chain_check.gd`): three jabs on Ironvent took 36 from the target and 14 from the enemy beside it (the hook went through both, chain count 4); at eight hits Sparkjab's shield read 17 (7% of 236 HP), the ally beside it 17, haste 2.0 s; Punchybun's chain counted without a payout; four fresh 1 s stuns on Stormwick held 0.97, 0.77 and 0.58 s as its diminishing-returns stacks rose. **Grok:** every number is a draft.

## Art
- Arena takes from the three fronts (96, 112, 128 px, $0.54), faithful first time: the round kit, the upright boxer, the S-curve guardian. Rotations ($0.30), all three in Tallowroot's layout. Walks, five facings each ($2.10). Retro Diffusion: Preston topped up to $6.47 before the walks. **Codex:** palette lock pending, like the other new lines.
- Raw takes, sheets and receipts in `arena-starters-2026-10-07/forms/` and `walk/`.

## Check (`tools/debug/arena_protector_check.gd`)
- Star Guard: shield 25 on the hurt ally; a 20-blow left its HP untouched and the shield at 5.
- Guardian: a 20-blow on the Rampartroot beside Starward took 13 (Guardian's 0.85 and Rampart's own guard).
- Counter Jab: Starward landed 23 px from the hurt ally; the enemy on it took 15 and was thrown 26 px.
- Static Dance: one ally hasted (the other was out of range); the charged jab did 20 against a cold 13 and held the enemy 0.4 s.
- Starshield: 3 of 3 allies shielded for 40; the ally's glass and roots cleansed; the enemy inside the star thrown 58 px; one star field; the hurt ally in it went 108 to 116 in 2 s.
- Punchybun (stage 1): 2 abilities, no meter.
- AI 3v3 with Starward's team against the Rampartroot line (final run, with the size fix): still undecided at the 80 s cap, shields raised 15 times; an earlier run won in 77 s. A team with a protector fights long. AI 1v1 against Rampartroot: lost in 79 s (310 dealt, 338 taken): a protector alone against the tank should lose. **Grok:** the shield numbers and the mend rate are the pacing levers.
- Stills here: `line_stage1..3.png`, `star_guard.png`, `counter_jab.png`, `starshield_forming.png`, `starshield_snap.png`, `star_field.png`, `match_3v3.png`. (The first `star_field.png` caught the rival Ironvent's Furnace Roar card instead, because the jab test had freed it; the check now holds the enemies again.)

## Known
- Turn-based data: Punchybun still has no back view; Sparkjab and Starward have finished backs; none has a kit for the turn-based battle (Grok).
- The shield star is drawn in code; no painted sheet yet.
