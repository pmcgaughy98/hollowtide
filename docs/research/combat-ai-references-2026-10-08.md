# Combat AI references: what we took and what is ours (Claude, 2026-10-08)

**Preston:** "Do we have any plugins, APIs, MCPs or connectors that we can scrape game structures with to build our own mechanics? For example a combat AI that understands how to use its kit and synergise so the player doesn't have to worry too much. If not let's find one." Then: "You don't have to copy them exactly, we can take what we like from them and make our own version. Even just seeing its internal structure should be beneficial: it's a refined product over months of work that we won't have to do now."

Firecrawl is connected now and did the reading. Below is the structure we took, with sources, and the Hollowtide version built from it (`Kit Sense`, placeholder name, in `scripts/arena/arena_prototype.gd`). Nothing was copied: Valve's bot API is Lua for Dota 2 and the open-source scripts are GPL; we took the shape of the decision, not code.

## Source 1: Valve's Dota 2 bot scripting layer
[Dota Bot Scripting, Valve Developer Community](https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting). The structure that matters:
- **Two layers of choice.** *Modes* are what a bot wants to be doing overall (laning, attacking, retreating, defending an ally, roaming, farming, pushing). Each mode has a `GetDesire()` called about every 300 ms that returns 0 to 1; the highest desire is the active mode, and the active mode's `Think()` runs every frame. Above the modes sit *team-level desires* (how much the team wants each lane).
- **Ability use is its own layer.** `AbilityUsageThink()` runs separately from modes; a hero's abilities each get a "consider" function returning a desire and a target, and the highest desire fires.
- Desires are named levels, not raw numbers: none, very low, low, moderate, high, very high, absolute.
- Difficulty is a modifier on the same brain (reaction delay, a lockout after each cast), not a different brain.

## Source 2: an open-source bot built on it
[Ranked Matchmaking AI (adamqqqplay/dota2ai)](https://github.com/adamqqqplay/dota2ai), GPL v3; read `ability_item_usage_lina.lua` and `ability_item_usage_generic.lua`. The per-ability "consider" pattern, in the order it checks things:
1. **Hard gates first:** is the ability fully castable; never while retreating (except a stun on whoever hurt us recently).
2. **Global high-priority uses, before anything mode-based:** interrupt an enemy that is channeling; **kill-secure** when the target's HP is at or under the ability's damage, or under the whole kit's *combo damage* (the sum of every ability's damage) when there is mana for the combo; **a held target** (an enemy an ally has locked down, with enough lockdown left to cover the cast time) gets *very high* desire.
3. **Team-fight rule for the ultimate:** when two or more allies are attacking, spend the big one on the *scariest* enemy, measured as the enemy's estimated damage to us over the next few seconds.
4. **Mode-based uses last:** farming, pushing, laning each have their own thresholds.
5. `UseAbility` picks the single highest desire above zero across the kit, then checks cooldown and mana once more before issuing it.

## Source 3: utility scoring
[Utility Intelligence, Considerations](https://uintel-ecs.utilityworlds.com/Documentation/UtilityIntelligence/Considerations/) (after Dave Mark's *Infinite Axis Utility System*, GDC): each decision is scored by several *considerations*, each a normalised input through a response curve into 0 to 1, multiplied together; a zero anywhere vetoes the decision; the more considerations, the lower the product, so either a compensation factor or the geometric mean is used. We use few considerations per ability and multiply, with the vetoes doing the gating.

## Kit Sense: the Hollowtide version
- **Modes, per creature, every think:** `finish` (a kill is on the table: an enemy within reach whose HP is at or under our combo damage), `peel` (an ally is in trouble and we are the kind of creature that answers that: Protector, Tank, Bruiser), `kite` (a blow is coming and we are not a tank, or we are below half), `hold` (our own terrain is under us and the enemy is in it), `engage` (the default). Desires are the named levels; the highest wins, and the mode steers the movement profile for that think (kite backs off, peel escorts) and may override the target (peel targets the enemy on the ally; finish targets the one we can kill).
- **Ability desires:** each ready ability starts from its existing "wants" rule (0.5 when the rule says yes, else 0) and is multiplied by considerations: kill-secure (target HP at or under this ability's damage: 0.9), a held target (stunned, rooted, dazed, Glassed, cocooned, with more hold left than our wind-up: x1.4), the team's **called target** (x1.2), the mode (kite: mobility x1.5, damage x0.7; peel: knockbacks and shields x1.5), and a veto on anything the target would phase through. The basic attack scores 0.4, so an ability needs a reason to beat it and fires when it has one.
- **The called target (team synergy):** when any enemy is newly held by anyone, it becomes its opponents' called target for 2 s or while the hold lasts; damage dealers within reach switch to it. That is the "focus the one who got hit by the root" behaviour that makes a team feel like a team.
- **The AI explains itself:** every decision writes a line to a log ("Starward: peel: Counter Jab on Ironvent, Stormwick at 31%"); the L key shows the last lines in the arena, and the checks print them.
- Difficulty is not built yet; when it is, it will be a reaction delay and a lockout on the same brain, as Valve does it.

Check: `tools/debug/arena_kitsense_check.gd`. **Grok:** the thresholds (combo-damage kill rule, the half-HP kite rule, the 2 s call) are drafts.
