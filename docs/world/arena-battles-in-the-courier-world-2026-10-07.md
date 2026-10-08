# Arena battles in the courier world (Claude, 2026-10-07)

**Status: proposal for Preston.** Names below that are not already in the world docs are placeholders; world and story are Preston's authorship. Preston (2026-10-07): the game keeps a campaign, and it is mainly about couriers. How do arena battles fit?

## The core idea: the arena is the battle system, not a building
A fight happens **where you are**. The arena engine (real-time, top-down, your creature's AI using its kit, you choosing the signature) runs on whatever ground the courier is standing on: the Route 1 meadow, a cutbank, a ferry deck, a Highbank street, a relay yard. The two arena maps built so far are just two such places. A stadium is one venue among many, used for organised events.

## Why couriers fight (each fits a mode)
| In the story | Mode | What it is |
|---|---|---|
| A wild creature blocks the route, has knocked down a relay post, or is guarding a nest by the road | 1v1 | the everyday encounter; also where catching happens |
| A rival carrier contests your route or your delivery | 1v1 | a duel over who carries it |
| A run too risky to make alone: you and a partner courier escort a delivery | 2v2 | pairs; support kits shine here |
| Three carriers race for one unclaimed relay post | 1v1v1 | free-for-all; the post goes to whoever holds the ground |
| The Wayline Compact's relay contest between the wards (Highbank, Siltward Reach, Old Ferry Ward, the far bank) | 2v2v2v2 | the big event, in a grandstand or showground; the stadium map fits here |

**Wayline trials** give a reason to keep fighting: couriers earn route licences or ranks by winning sanctioned trials in the relay yard behind the Wayline office, so the campaign has a ladder without becoming "a gym leader in every town".

## Creatures as courier partners
A creature's body is also its job on the route, which ties kits to the story: Stormwick's lantern lights night routes, Rampartroot shores up washed-out levees and blocks a path, Scourmaw scouts the river bottom and the old crossings. Field use can later reuse the same physiology the arena already shows.

## How it shapes the build
- Battles start from the overworld: encounter, then the arena on a map made from the local ground (the "floor" rect and an art pass per location).
- Kits follow "no dead moves" (every support move works alone and scales with allies), because the same creature fights 1v1 on the road and 2v2 on escort runs.
- Balance per mode with `tools/debug/arena_sim.gd`, once the arena supports more than two fighters.

## Questions for Preston
1. Is the Wayline Compact the body that runs trials and the ward contest, or someone else?
2. Is catching still a thing in the arena system, and how (weaken then capture during the fight, as before)?
3. Which mode is the main one the campaign is built around (proposal: 1v1 on routes, 2v2 for escort runs and story set pieces)?
