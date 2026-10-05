# Creature and attack design rules

Preston assigned this file to Grok on 2026-10-02. Future creatures and moves are designed here before art, data, or Retro Diffusion. A sprite does not invent a moveset. The battle comes first, then the creature that fits it.

`THE_CONCEPT.md` still decides the world: three stages, no branching, the six essences, and the chart as written. Electric and Ice are in the essence list. Their matchups stay the proposal in `electric-ice-essences-2026-10-01.md` until Preston approves them. This file does not change that chart to save a stat line.

Codex has Route 1. Claude has battle presentation. This file has the creature's job, its numbers, and its moves.

## Punchybuns stays

The electric ferret line for Adrianna ("Punchybuns") is reserved. It is not a generic Electric slot, and it is not dropped when the roster is rebalanced.

Gabrielle's direction stands: three stages, a ferret, Electric, Pikachu's spirit without Pikachu's look, Steven Universe in the star and the pink. The battle idea is a ferret who protects the people it loves.

What Claude actually put in the project:

- The design: `docs/creatures/memorial-ferret-2026-10-01/README.md`
- The Stage I prompt: `stage1_prompt.json`
- The Stage I front: `stage1_front_128_take1.png` (proposal name Punchybun)

Stage I is a round kit, cream fur, pink ferret mask, pink forehead star, boxer fists, puffy cheeks, sparking bottle-brush tail, ferret war dance. Stage II is the longer boxer, name still open. Stage III is the guardian whose body flows like a lightning bolt, pink star-gem on the chest, name still open. Its ultimate is a star-shaped electric shield that protects. That is a guard. No other line holds the protector job.

There is no Stage II image, no Stage III image, and no creature data file yet. Do not invent those names. Do not generate the next stage until Gabrielle's open questions in that README are answered. When they are, the line still has to pass the tests below against the creatures it will meet. Electric's proposed chart, if approved, makes it strong into Tide and weak into Stone. That is a lesson, not a problem to stat away.

## One job each

Two forms in the same essence do not share a job.

| Job | What it is | What it is not |
|---|---|---|
| Starter | Wins neutral fights against other stage 1s. Loses to its own later stages, to other stage 2s and 3s, and to a strong essence matchup. | A smaller copy of its final. |
| Stage 2 | Beats its stage 1 and other stage 1s. Loses to its own stage 3. | The same spread with more HP. |
| Stage 3 | Beats its own line. | Automatically the answer to every other final. |
| Runner | Highest speed in its band. Acts first. Lower HP. | Also the highest attack. |
| Cannon | High attack, low speed. The one that breaks a wall. | Also the highest defense. |
| Wall | High HP and defense, modest attack. Its ultimate is the only hard hit, and it has 2 uses. | A cannon that also refuses to die. |
| Protector | Punchybuns only. Its ultimate is a guard, not a nuke. | A second cannon with a cute face. |

## Numbers, before the picture

Damage is `attack × power ÷ (defense × 4) × essence`, rounded down, never below 1. No misses, no crits, no damage rolls. Speed is compared once. Ties go to the player, so two creatures that can meet do not share a speed.

When attack equals defense, power 60 deals 15. Plan HP from that.

- A 2-use move does not KO by itself. The target's HP is greater than twice that hit.
- A duel between creatures that can meet lasts 4 to 12 turns.
- A ×2 matchup may be as short as 4 turns. It is not a 2-turn delete, and it is not a 15-turn grind.
- Strong versus weak is a ×4 gap. Do not try to stat a weak-side starter into beating its predator. The answer is a switch, or a later coverage move whose essence is not the user's. The move's essence is what the chart reads.
- The Ember ladder 32 unlimited, 40×6, 50×4, 60×2 is a template, not a law. The unlimited move is the weak chip. The hardest limited move has 2 uses. An ultimate, when the line has one, is that hardest move.

## Ultimates and signatures

Preston, 2026-10-02. These are two different things. The battle code still names the scene-taking flag `signature`. In design that flag means ultimate. Leave the code name alone until a battle pass renames it.

**Ultimate.** One on the final stage of a line, and only when that body has a part no other line has. It takes over the scene. It is that creature's hardest hit, and it has 2 uses. Another creature does not learn it.

Already marked in the move files:

- Molten Glass, Vitrecrag. Needs the furnace heart and the mouth that pours it.
- Furnace Roar, Ironvent. Needs that crest of vents.
- Kingstone Rail, Oxbowarchon. Needs the bound rails and the Kingstone.

Punchybuns' star shield will be its ultimate. It is a guard. No other line gets a guard ultimate.

A line with no ultimate yet still has a hardest attack at 2 uses. That attack is a signature until it is given a scene and a part only that line has.

**Signature.** A named attack tied to a body plan. Another creature can learn it when it has every part the move requires. This is the same idea as a Pokemon move that stays characteristic and is still teachable.

Essence is the move's typing. The chart reads the move, not the user. Essence is not permission. A creature may learn a move of another essence when the action is honest for its body. A match of essence does not excuse a missing part.

The test, before any art:

1. List the parts the move uses. If the list is one organ that only one line has, it is an ultimate.
2. Name the essence of the hit. Same as the user, unless the body is honestly doing something else.
3. Reject a learner that is missing a part.
4. Accept a learner of another essence when every part is there.

The parts each live creature has, and the parts each equipped move needs, are in `move-body-gate.md`. A kit that fails that list does not get a new animation. One failure is live: Coalcrest's Plate Rake. Molten Beam stays equipped. Vitrecrag has the chamber and the mouth, so the gate leaves it selectable. That file also lists the names that overclaim a part. Shoulder is not a part. Oxbowarchon's bound jade is not a kiln shell.

Who may learn each passing signature is `shared-move-pool.md`. The same list, turned around per creature, is `legal-learnsets.md`. How a win evolves a creature, and how a signature is learned, is `evolution-and-signatures.md`. That gate is in the game. The proposed stat table and the kit swaps are not. A creature still equips four moves.

## What a line is allowed to answer

Every signature in that pool is Ember. Teaching one does not change the chart. A body does not get a coverage move of another essence unless the action is honest for a part it has.

- The Cinderhide line loses to Tide. Those bodies have vents and claws. Cinderhide and Ironvent also have mouths. None of them have a fin, or a jaw that holds water. They do not get a Tide move. The answer is a switch to Stone. In the worked example, Oxbowarchon already beats Rimefin in 4 turns.
- Rimefin loses to Stone. It has a fin and a jaw. It does not have a rail or a shell, so it does not learn Kingstone Rail or Plate Lunge. The chart answer to a Tide final is the Ballastak line, which is not in this number set. Do not raise Rimefin's stats to beat the wall.
- Oxbowarchon loses to Vitrecrag by stats, and Bloom beats Stone on the chart. It has a rail. It does not have a kiln chamber or a plant part. It does not get an Ember or Bloom move. The Bloom answer is Tallowroot's line. Later stages of that line stay unnamed.
- Vitrecrag is the stat answer to the wall. Molten Cannon is its signature and Molten Glass is its ultimate. It does not need Coal Spit.

Do not invent a coverage move to close a ×4 gap on a body that lacks the part.

Parts already in use:

- Claws, for Cinder Claw. Fins do not qualify. The kiln line has legs and plates, not claws, so it does not qualify.
- A front plate on buttress legs, for Plate Lunge. A hex edge does not qualify. A lifting shelf does not qualify. No shell, no plate move.
- A split signal tail, for Tail Brake. A heavy tail that sheds a clinker, for Clinker Toss. Punchybun's tail is neither.
- A vent that spits a coal-sized clinker, for Coal Spit. The live move leaves a heat break, not a mouth. Vitrecrag's mouth pours glass and casts the cannon, so it does not learn Coal Spit. Another vented body can.
- An internal heat chamber plus an opening that can lob a heavy mass, for Molten Cannon. The opening is a mouth, a bore, or a vent. Fins, paddles, wings, and plain claws do not qualify. Molten Cannon stays a signature, so a body that has those parts may learn it. Molten Beam stays equipped on Vitrecrag. It needs the chamber and the mouth, which that body has.

## A new form is not approved until

1. Its job is one row in the job table, and the line job below. No other form in its essence already has that job. Punchybuns already has Protector.
2. Its body has every part listed on every move it learns. See Ultimates and signatures below.
3. `tools/balance_sim.gd` has been run on the proposal, with overrides, not on the live data. The report passes the turn and win rules in this file.
4. Preston has said those numbers are in the game.

Art comes after that. Codex has the map and the St. Joseph research. This file does not place a creature in the city.

## Every line's job

Taken from the roster that already exists. No new species, and no new names. Tallowroot's later stages and Punchybuns' later stages stay unnamed. A line gets numbers only when it is the one being built, and those numbers have to pass the tests in its row. Inside a line, stage 2 beats stage 1 and stage 3 beats stage 2, in 5 to 8 turns.

| Line | Job | The test, when numbers are written |
|---|---|---|
| Cinderhide, Clinkerhide, Ironvent | Ember starter, then bulk, then closer | Done. See the worked example. |
| Kithflare, Wayburn, Coalcrest | Ember runner, then fast mid, then endurance | Done. Signal line: marking, throat, and tail. Claws are unconfirmed, so this line does not learn a claw move until a sprite shows one. No muzzle bites. |
| Fusern, Slagglass, Vitrecrag | Ember kiln, then armor, then the cannon | Done. Six legs and a shell. No claw moves. Molten Glass is the ultimate. |
| Rimefin, Riftfin, Scourmaw | Tide hunter | Stage 1 is done. Riftfin is faster and still loses to Scourmaw. Scourmaw is the heavy jaw, not a wall. The line beats Ember by the chart. |
| Cutbank Listener, Bend Caller, Quietwater Warden | Tide caller | The interrupt line. Paddles and gill plates, so calls and braces, not bites. Not a shield. Loses to the hunter's later stages. |
| Siltcrank, Millcurrent, Braidwake | Tide shaper | Low and steady. The 6-use move wins the fight. Not a shark and not a guardian. Loses to Scourmaw. |
| Preostmar, Oathfen, Oxbowarchon | Stone wall | Preston's line. Oxbowarchon is the wall below. Moves come off the rails and the slabs, not claws. Preostmar beats the other Stone stage 1s and loses to Oathfen. The soft underbelly is a later hook, not a rule yet. |
| Flintram, Mortarback, Cutbank Bastion | Stone path | The nimble Stone. Flintram is fast for Stone and still loses to Preostmar. Bastion does not pass Oxbowarchon's defense. |
| Ballastak, Switchhold, Deepcut | Stone digger | Slow, high attack, shovel and claws. This is the chart answer to a Tide final. It does not beat Oxbowarchon. |
| Troughspine, Archroot, Springvault | Stone keeper | Open arches, not a closed wall. Longest Stone fights, weakest ultimate. Loses to the wall and to Deepcut. |
| Skirr, Scudder, Stormveer | Gale runner | Gale is neutral, so this line wins by speed. Skirr beats the other Gale stage 1s. Stormveer is the fastest final, not a cannon. |
| Dustkite, Waywhistle, Highsignal | Gale signal | Watchful. Not the interrupt, and not the runner. Loses to Stormveer. |
| Canvaswing, Windcut, Galeshear | Gale shelter | More HP than the runner, less speed. No guard ultimate. Loses to Stormveer. |
| Tallowroot, unnamed, unnamed | Bloom starter | The chart answer to Stone. Do not name the later stages here. The final beats Oxbowarchon by Bloom against Stone in 4 to 8 turns, and loses to Ember. Tallowroot beats the other Bloom stage 1s. |
| Cotterseed, Canopyvein, Floodcrown | Bloom root | Slow and rooted. Not the wall-breaker. Loses to Tallowroot's line and to Ember. |
| Milletusk, Threshback, Gleanhorn | Bloom tusks | Contact only. Loses to the Bloom starter's later stages. |
| Masonsward, Thimblecomb, Combwright | Bloom builder | Starts quick, ends slower and stepped. Wings and clay paddles, not a stinger. Loses to Tallowroot. |
| Hushmire, Lullfen, Tarnreach | Hollow starter | Hollow is ×2 both ways, so those fights last 4 to 6 turns, not 2. Hushmire beats the other Hollow stage 1s. It does not win every ×2 fight. |
| Echolarva, Stillshade, Nullchorus | Hollow echo | The cancel. Interrupt only, and only against a move the battle already marks interruptible. |
| Mutecho, Unanswered, Unspoken | Hollow keep | High HP, low attack, slow. It lives through one ultimate. It does not delete. |
| Punchybun, unnamed, unnamed | Electric protector | Reserved for Adrianna. The star shield is the only guard ultimate. No other line gets one. |

The first Ice line is not designed. When Preston wants one, its job is the chart answer to Bloom, and it loses to Ember. Do not invent a creature to fill that seat.

## Worked example, not in the game

These are the current eleven, retuned so the jobs above are true in a duel where both sides play their strongest move. PROPOSAL only. Live files are still all 60s. Full tables: `docs/battle/balance/sim-report-grok-proposal.md`. Overrides: `docs/team/grok-pack-2026-10-01/RESULT_task1_overrides.json`.

| Creature | Job | HP | Atk | Def | Spd | What the duels said |
|---|---|---:|---:|---:|---:|---|
| Cinderhide | Starter | 90 | 64 | 64 | 54 | Beats Kithflare and Fusern. Loses to every later stage, to Rimefin in 6, and to the wall. |
| Clinkerhide | Bulky mid | 104 | 70 | 86 | 46 | Beats Cinderhide. Loses to Ironvent. |
| Ironvent | Line closer | 112 | 84 | 76 | 38 | Beats its line. Does not break the wall. |
| Kithflare | Runner, stage 1 | 78 | 64 | 56 | 74 | Beats Fusern in 6 by going first. Loses to Cinderhide and to every later stage. Attack ties the starter. It does not pass it. |
| Wayburn | Fast mid | 92 | 68 | 64 | 70 | Beats Kithflare and Cinderhide. Loses to Coalcrest. |
| Coalcrest | Endurance final | 108 | 72 | 74 | 62 | Beats Wayburn. Does not break the wall. |
| Fusern | Sharp stage 1 | 90 | 62 | 56 | 66 | Loses to Kithflare and to Cinderhide. Loses to Slagglass. |
| Slagglass | Armored mid | 100 | 74 | 80 | 50 | Beats Fusern. Loses to Vitrecrag. |
| Vitrecrag | Cannon | 116 | 92 | 72 | 34 | The only one of these eleven that beats Oxbowarchon. Molten Glass is 62 power, 2 uses. |
| Rimefin | Tide lesson | 96 | 54 | 66 | 58 | Strike only. Beats every Ember here, in 5 to 9 turns. Its own mirror ends in 12. Loses to the wall in 4. |
| Oxbowarchon | Wall | 100 | 82 | 96 | 42 | Kingstone Rail is 54 power, 2 uses. Loses only to Vitrecrag. |

Punchybuns is not in that table. It has no battle data yet, and it does not get Ember-ladder numbers pasted on. When Gabrielle answers, its first test is a guard ultimate that keeps an ally or itself up, against a cannon and against a wall, inside 4 to 12 turns.

Nothing in the table is live until Preston says so.
