# How a courier gets new creatures (Claude, 2026-10-07)

**Status: proposal for Preston.** Mechanic names here are placeholders. Grok owns creature rules, so any numbers are his to set.

## What our research covers, and what it doesn't
None of the gathered research is about how players obtain creatures. That includes the Gemini reports in Drive ("Monster Taming Game Design Research", the animation, sound and pipeline reports), `docs/research/` and the arena reference video. Those sources cover art, animation, sound and IP. The genre examples below come from general knowledge and were not checked against a source. If you want them verified, a Gemini Deep Research task on acquisition mechanics is the cheap way to do it (draft prompt at the bottom).

What we do have in our own docs:
- `THE_CONCEPT.md`: **temperament** "governs behaviour, not damage: how a creature acts in battle, what it responds to, **how easily it is caught**". The hook is already there.
- `docs/battle/battle-rules.md` (turn-based, now reference only): a weaken-then-catch chance with no items and unlimited attempts.
- The arena model: you steer the creature and choose when to fire its signature, and its AI handles the rest of the kit. **So the player's skill lives in movement and signature timing.** A good acquisition mechanic should test exactly those two things.
- The courier campaign: delivery, escort, routes, relay posts.

## How the genre does it (general knowledge)
| Approach | Examples | Fit for Hollowtide |
|---|---|---|
| Weaken, then throw a capture item | Pokemon, Temtem, Coromon | Weak fit. In a real-time arena, who throws? It also turns every fight into "chip it to red", which ignores your creature's kit. |
| Sneak up and catch outside battle | Pokemon Legends: Arceus, Palworld | Possible later for the overworld, but it skips the arena, and the arena is our best part. |
| It asks to join after you win (a chance) | Dragon Quest Monsters, Yo-kai Watch | A simple fit, but pure luck feels bad without a lever. |
| Talk it into joining | Shin Megami Tensei, Persona | A strong fantasy, but it needs heavy writing per creature. |
| Fill a meter during the fight by fighting well | Cassette Beasts | Close to what we want. |
| Eggs or dens, raise it yourself | Monster Hunter Stories, Monster Sanctuary | Fits a courier carrying something. |

## Recommendation: the Proving (placeholder name)
**A wild creature joins the courier who proves something to it, and its temperament decides what.** At the start of the fight, the wild creature's temperament shows one readable condition. Meet it before the fight ends and the creature offers to join. A plain knockout still wins the fight (it may still evolve your creature, per the existing win trigger), but the creature leaves.

Example temperaments (proposals for Grok and Preston to name and tune):
- **Proud:** land your signature on it. It respects strength shown at the right moment.
- **Skittish:** keep it from escaping. Corner it, or keep it inside a range for a few seconds. This is about movement.
- **Territorial:** hold its ground. Stand in its marked patch for a total of N seconds while it fights you off.
- **Curious:** keep your creature unhurt long enough for it to come close. Dodge rather than trade blows.
- **Wary:** win without your signature. It doesn't trust raw power.

Why this fits:
1. **It uses the player's actual inputs** (footwork and signature timing), so recruiting is skill, not grinding to low HP.
2. **It makes temperament matter**, as THE_CONCEPT already intends, and gives every wild encounter a small puzzle.
3. **No items or inventory economy** are needed (the turn-based rules had none either).
4. **It makes your kit choice matter.** A Rampartroot's roots trivialise Skittish, and a Scourmaw struggles to hold ground. That makes your team composition matter on routes too.

## Courier layer: route favours (for rare and late creatures)
Some creatures don't fight for a place; they need something carried. The examples are proposals: a nest moved off a washed-out levee, a lost young one escorted home, a relay post repaired. Finish the delivery and the creature joins. This uses the courier campaign directly, suits stage-three and Hollow creatures that a plain fight shouldn't hand out, and gives escort runs (2v2 or 3v3 with a partner courier) a reward.

## Team fights
In 2v2 or 3v3 wild encounters (a pack), each wild creature has its own temperament condition, and you can recruit only one per fight. This turns team fights into a choice about which one to court.

## Open questions for Preston
1. Do you like the Proving as the main way? Or plain win-then-chance, or something else?
2. Do creatures join at the stage you met them, or always at stage one?
3. Is there a party limit in the arena era (three a side would suit 3v3)?

## Draft Gemini Deep Research prompt (if you want the genre examples verified)
"Survey how monster-collecting games let players obtain new creatures (capture items, post-battle recruitment, negotiation, in-battle meters, eggs or breeding, quest rewards, overworld stealth). For each, give two or three games, how it works, and what players and designers say works or frustrates. Separate what is documented from opinion, and cite sources. Pay special attention to real-time or action battle systems. Honesty: say plainly where evidence is thin."
