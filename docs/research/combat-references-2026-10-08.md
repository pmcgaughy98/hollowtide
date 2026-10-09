# Combat references: what we took for the combat upgrades (Claude, 2026-10-08)

**Preston:** "Combat upgrades? Like new mechanics, animations, everything you can." And on the method: "We want to utilise this to accelerate what we're doing but also enhance the result, because as a non-experienced developer I'm taking from people who've already failed or had success. Then we'll refine if we need to, to fit what we want for Hollowtide."

So each upgrade below names the shipped structure it came from, what was taken, and the Hollowtide version. No code or data was copied.

## 1. Essence combos, after Genshin Impact's elemental reactions
Source: [Elemental Reaction, Genshin Impact Wiki](https://genshin-impact.fandom.com/wiki/Elemental_Reaction) (read through Firecrawl as a structure, not for numbers).

The structure: applying an element to a target leaves an **aura** that decays; a second element **reacts** with the aura and consumes it. Reactions come in kinds: **amplifying** (the triggering hit is multiplied, 1.5x or 2x), **transformative** (the reaction does its own thing: an explosion, a freeze, damage over time, a shield), **additive** (a flat bonus on the triggering hit). Some pairs do nothing. Which aura reacts when a target carries two follows the order they were applied.

What we took: our statuses are already auras (Glassed, rooted, smoulder, a riptide under the feet), so a reaction is "a move of essence A landing on a creature carrying the aura essence B left". We keep two kinds: amplifying (multiply the hit and consume the aura) and transformative (an effect, the aura may stay).

| Combo | Essences | Kind | Effect |
|---|---|---|---|
| Shatter | Stone on Glassed | amplifying | x1.5, the glass is gone |
| Kindle | Ember on rooted | amplifying | x1.3, the roots burn away |
| Quench | Tide on smouldering | amplifying | x1.3 (scalding steam), a 0.5 s daze, the smoulder is gone |
| Conduct | Electric on a target in a riptide | transformative | half the hit arcs to every other enemy in the water |
| Overgrow | Bloom on a target in a riptide | transformative | rooted 0.6 s: the growth takes hold in water |

Why these five: each one needs two creatures from two lines to set up (Vitrecrag's glass and Oxbowarchon's jade; Rampartroot's roots and Stormwick's embers; Ironvent's smoulder and Scourmaw's jets; Scourmaw's riptide and Oxbowarchon's rails or Starward's jabs; Scourmaw's riptide and Rampartroot's pods), which is the team play Preston asked for. Kit Sense wants a move x1.3 more when its combo is on the table, so the AI sets them up and takes them. Hollow has no combo on purpose: Hollow is absence, and Scourmaw's erosion (every hit on an eroded target does +25%) already behaves like a standing reaction. **Grok:** the multipliers are drafts.

What we did not take: elemental gauges (how much aura a hit applies and how much a reaction consumes), the dozen Dendro reactions, and reactions that make objects. Those are for a game with eight elements and three-character rotation; the arena has seven creatures and keys 1 to 4.

## 2. The animation layer, after the game-feel canon
Sources already in the project: the 2026-10-07 reference video (Pokemon Arena), the feel pass (hitstop, telegraphs, shake caps). The principles behind it are the standard ones: anticipation before an action, follow-through after, squash and stretch, and reactions on the receiving end (the "Juice it or lose it" and "The Art of Screenshake" talks). Nothing scraped; this is craft knowledge.

What we built: a single procedural layer on top of every creature's still or walk frame, no new art, so all 21 forms get it at once. A **wind-up lean** back (3 px, stretched tall) for the length of the telegraph; a **strike lunge** (7 px toward the target, squashed wide) when the move fires; a **flinch** (4 px away, squashed) when hit; a **landing squash** after a hop, vault or dash; and a **KO beat** (0.3 s hitstop, a white ring, a label, the drop). Scaled about the feet so nothing floats. Checks: `tools/debug/arena_combat_check.gd`.

## 3. Crowd control, after League of Legends' taxonomy
Source: [Crowd control, League of Legends Wiki](https://wiki.leagueoflegends.com/en-us/Crowd_control). The structure: every control effect is named by what it takes away (movement, attacking, casting, mobility spells), is hard or soft, displaces or not, and either is or is not shortened by **tenacity**. Airborne is the special one: it stops everything, displaces, ignores tenacity, and **interrupts dashes**; airborne, knockdown and stasis are the three that stop a dash in flight. CC immunity negates application outright.

What we took: a name for what we had (stun = stun; rooted = root; crippled = ground; dazzle = a short stun; Glassed = a slow with a payload) and two things we did not have. **Airborne**: a launched creature cannot move or act, its ram or tackle is cancelled, and ground hazards do not tick on it while it is in the air; Slab Vortex and Rail Recoil's blast now launch. **Tenacity**: Tanks shed stuns, roots and dazes 1.4x faster (airborne ignores it, as in the source). Not taken: suppression, silence, polymorph, nearsight, and the dozen soft types; the arena has no channels to silence yet.

## 4. Knockback that grows, after Smash
Source: craft knowledge of Super Smash Bros.: knockback scales with the target's accumulated damage, so the same hit sends a hurt fighter further, and finishing blows send them off the stage. What we took: a hit's push grows by up to 60% as the target's HP falls, so wall slams and carries happen more as a fight goes on. **Unstoppable**: a creature mid-ram ignores pushes, so a Crest Ram is not knocked off its line by a jab (League's displacement immunity on dashes, loosely).

## 5. A timed match with an objective, after Pokemon Unite
Source: the Pokemon Unite wiki's Battle page returned 404 to Firecrawl, so the structure here is the extractor's summary plus general knowledge: a timed match; points scored in goal zones; neutral objectives (wild Pokemon, Drednaw, Rotom, Zapdos) that give points and buffs; the Unite Move charging from fighting; knocked-out Pokemon respawning; at the timer, the most points wins. Treat the details as unverified.

What we took, cut to the arena's size: a **match clock** (120 s for team fights) with a **decision on points** when it runs out (the team with more total HP wins, no more draws), and **the Crest** (placeholder name), the centre circle of the pitch as the one objective: a team holding it alone charges its finals' meters faster and mends a little, contested it does nothing, so fights are pulled to the middle. Kit Sense has a crest mode: a final with an empty meter and no enemy near walks to it. Not taken: scoring zones, respawns (a knocked-out creature stays down), and neutral monsters.

## 6. Frame data, after Street Fighter (added later on 2026-10-08)
Source: [The Fighting Game Glossary](https://glossary.infil.net/?t=Frame%20Data) entries for frame data, frame advantage and counter hit (read through Firecrawl). The structure: every move is startup (before it can hit), active (it can hit) and recovery (after, before you can act again). The two numbers that matter are startup ("how fast") and how safe the move is when it lands or is blocked: if your recovery ends before the opponent's hit stun does, you are plus and get to act first; if not, you are minus, and a move that is minus enough gets punished. A counter hit is a hit that lands during the opponent's startup; it is rewarded with more damage and more advantage.

What we took: the telegraph was already startup, and every move recovered in the same flat 0.3 s. Now each move has its own **recovery** (by telegraph kind, with overrides for the slowest moves), a real hit puts the target in **hitstun** (0.25 s, cannot act), and the table of startup, recovery and advantage on hit is printed by `tools/debug/arena_frames_check.gd`: light basics (claw, jab, glass spur) are plus on hit, every heavy move is minus, so a whiffed slam or rail shot is a window. A **counter hit** (a hit during a wind-up) is x1.25 and a blow of 12 or more breaks the wind-up; charges and the two tanks' passives are armoured and keep theirs. A **punish** (a hit while the target recovers) is x1.15. Kit Sense wants a move more when it would land as a counter or a punish. Not taken: active frames (our hits are instant checks; active windows belong to the attack sheets later), block and block stun (no block button yet), and the "plus on block" layer that follows from it. **Grok:** the recovery table and both bonuses are drafts.

## 7. Role passives, after Overwatch
Source: [Roles, Overwatch Wiki](https://overwatch.fandom.com/wiki/Role). The structure: three roles, each with one passive that every hero of that role carries on top of its own kit. Tank: less ultimate charge given to enemies who damage it (and, over the years, knockback resistance, less crowd control, more health). Damage: hits wound the target so it receives 30% less healing for 3 s (and before that, a kill granted a short burst of speed and reload). Support: left unhit for a moment, the hero mends itself. In February 2026 the game split these into sub-roles; the role-wide versions are what we took.

What we took: our six roles sit on Overwatch's three. **Tank** (Rampartroot, Vitrecrag): hits on it charge the attacker's meter 40% less and move it 30% less, on top of its tenacity. **Damage** (Bruiser, Skirmisher, Assassin, Artillery): a hit wounds the target (mending cut 30% for 3 s, through the Crest, the star field and regen), and a KO grants 2.5 s of haste. **Support** (Protector): after 1.5 s without being hit, Starward mends 1 HP every 0.4 s. A line's earlier stages carry the role of their final, so Tallowroot already plays like a tank. Not taken: role queue, health per role, sub-roles. **Grok:** every number is a draft; the KO haste and the wound are the two I would watch in 3v3.

## 8. Part breaks, after Monster Hunter
Source: the Monster Hunter Wiki's page is empty and Reddit is closed to Firecrawl, so the structure comes from search excerpts (GameFAQs, Steam forums) and general knowledge; treat the details as unverified. The structure: every breakable part has its own health pool; a hit on the part damages both the part and the monster; when the pool hits its threshold the part breaks (some parts need the threshold several times), which gives a reward at the end of the hunt, removes or weakens an attack, and exposes a weak point; staggers work off the same pools with thresholds that rise after each one.

What we took, for the boulders, stones and crates: the crack stages were already thresholds (two thirds, one third, broken), so each is now a **part break** that drops a **reward shard** beside the rock (a final that walks over it gains 10 meter, anyone else mends 4; it lies 8 s) and **exposes the rock** (it takes x1.25 from then on). A broken rock already removes "an attack": it stops blocking shots and lines. Not taken: per-part hit location (our rocks are one body), rising stagger thresholds, and creature part breaks (Rampartroot's wall, Oathfen's slabs and Ironvent's vents are the obvious parts for a later pass). **Grok:** the shard values are drafts.

## 9. Next: Smite, for kit synergy and balance (Preston, 2026-10-08 evening)
Preston: "Smite I think is a great reference for how I want my kits to synergize and the balance of the game." The structures to read: the five classes and what each brings to a team fight; the crowd-control taxonomy with diminishing returns and the cleanse item; physical and magical protections as a second balance axis beside the essence chart; how ultimates and cooldowns gate the set-up-and-pay-off chains (a Guardian's hard CC into a Mage's burst). To compare against: Kit Sense's combo desires and called targets, the role layer, tenacity. Not yet read.

