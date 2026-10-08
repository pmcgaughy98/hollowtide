# Roles the arena is missing, and which unbuilt lines could fill them (proposal, Claude, 2026-10-08)

**Preston, 2026-10-08:** "Make lines that complement what we already have. We already have a lot of damage dealers, tanks etc. We can redesign the ones we haven't made already for future generation, except Punchybuns."

This is a proposal. Nothing here is written into a creature file, no name is new (every name is from `creature-roster-draft.md`), and every number is Grok's. The Punchybuns line is untouched (Protector, Electric, its ultimate a guard). The roles below are arena roles for 3v3 play with keys 1 to 4; `DESIGN_RULES.md` keeps the turn-based jobs.

## What the arena has now
| Line (final) | Arena role | What it brings a team |
|---|---|---|
| Stormwick (Ember/Electric) | Skirmisher | pounce, teleports to marks, burst |
| Rampartroot (Bloom/Stone) | Tank | roots, thorns, the club, a vine field |
| Scourmaw (Tide/Hollow) | Assassin | phase, ambush, long jets |
| Ironvent (Ember/Stone) | Bruiser | rams that carry, vents, the roar's stun and seams |
| Vitrecrag (Ember) | Tank | Glass Guard, the glass field, Glassed |
| Oxbowarchon (Bloom/Stone) | Artillery | a piercing line, peel, a vault, Kingstone Rail |
| Punchybuns (Electric, reserved) | Protector | a guard ultimate (not drawn as moves yet) |

Six of seven deal damage or hold a line. Nobody heals, shields an ally, cancels a wind-up, pulls, marks for the team, builds cover, or buffs. A 3v3 today is three fighters each doing their own thing; the terrain and the marks are the only team play.

## The gaps, in the order they change team play most
1. **Healer** (sustain and cleanse): fights become about protecting the healer and bursting through heals.
2. **Controller** (interrupts, holds, slows): the counter to every telegraphed signature.
3. **Disruptor** (hooks, pulls, pits): drags a backliner into the team.
4. **Shield support** (absorbs, peels, carries an ally out).
5. **Spotter** (marks for everyone, decoys the AI's telegraph-reading): feeds Stormwick's teleports and Oxbowarchon's line shots.
6. **Builder / zoner** (cover, traps, walls): plays with the rocks, crates and marks already built.
7. **Enchanter / runner** (speed, swaps, knock-ups).
8. **Vanguard** (the engage that the team follows).
9. **Silencer** and **Lurker** (Hollow: locks and ambush traps).
10. **Bodyguard / mimic** (takes the hit, echoes an ultimate).

## The fourteen unbuilt lines, reassigned
Kits are sketches: basic (AI), 1 to 3, passive, 4. Each keeps the body the draft already describes, so the move comes off a part the creature has.

| Line | Essences | Arena role | Kit sketch | Systems it needs that do not exist |
|---|---|---|---|---|
| 12 Troughspine, Archroot, **Springvault** | Stone / Tide | **Healer** | Spring Spit; 1 Seep (a healing pool, allies only, the mirror of the glass pools); 2 Mineral Brace (a shield on the targeted ally); 3 Vault Arch (raises a stone arch that blocks shots, 5 s). Passive: allies near it recover slowly. 4 Headspring: a spring bursts under the whole team, heals, cleanses Glassed, roots, smoulder, and leaves a pool. | healing, ally targeting (LEFT/RIGHT over allies), cleanse, ally-only pools |
| 6 Cutbank Listener, Bend Caller, **Quietwater Warden** | Tide / Hollow | **Controller** | Echo Tap (short sonar pulse); 1 Interrupt Call (cancels every wind-up in a cone and stuns 0.5 s); 2 Deep Brace (takes less, cannot be pushed, reflects pushes); 3 Still Water (a zone where enemy cooldowns run at half speed). Passive: enemy telegraphs near it take longer. 4 Hush: field-wide, every wind-up is cancelled and abilities are locked 3 s. | wind-up cancel, cooldown slow, ability lock |
| 11 Ballastak, Switchhold, **Deepcut** | Stone | **Disruptor** | Spade Jab; 1 Undercut (burrows and erupts under the target, pulling it to Deepcut: a hook from below); 2 Tunnel (burrows to an ally's side); 3 Cave-in (a pit that slows and pulls everything in it to its centre). Passive: Dig In (armour while standing still). 4 Bedrock Shear: a trench across the arena enemies cannot cross for 6 s, allies can. | pulls, a pit field, an impassable enemy-only line |
| 15 Canvaswing, Windcut, **Galeshear** | Gale | **Shield support** | Shear (sail slash); 1 Sail Cover (a shield on an ally that absorbs the next 20); 2 Downdraft (a zone that knocks shots and lobs out of the air); 3 Lift (grabs the lowest ally and flies it 60 px toward the team). Passive: allies within 30 px take 10% less. 4 Gale Shear: one wing sweep throws every enemy to the arena edge and shields the team. | shields, projectile denial, carrying an ally |
| 14 Dustkite, Waywhistle, **Highsignal** | Gale | **Spotter** | Whistle Dart; 1 Signal Mark (marks the target: the whole team's hits on it land harder, and Stormwick can teleport to it); 2 Decoy Call (a false telegraph the enemy AI reads and dodges, wasting its Phase or Flashstep); 3 Vantage (perches on a rock: out of melee reach, longer range). Passive: the first enemy to come into range is marked. 4 High Signal: every enemy is marked and the team's next ability on each is doubled. | marks as team damage, decoy telegraphs, perching on rocks |
| 20 Masonsward, Thimblecomb, **Combwright** | Bloom | **Builder / zoner** | Pollen Puff (a short blind); 1 Mud Cell (builds a crate: cover, a mark target, a thing to shatter); 2 Comb Trap (a sticky cell on the floor, the first enemy in is held); 3 Repair (restores a rock or crate, or an ally's shield). Passive: its cells persist through the fight. 4 Combwright: a hex wall rises round an ally and blocks everything for 4 s, then shatters outward as shrapnel. | spawning crates, traps, repairing rocks |
| 13 Skirr, Scudder, **Stormveer** | Gale | **Enchanter / runner** | Sail Snap; 1 Tailwind (a gust that speeds every ally it passes through 4 s and bends shots); 2 Crosswind (dashes and swaps places with an ally: a save); 3 Updraft (lifts an enemy off the ground a moment: it cannot act or be hit). Passive: Slipstream (allies in its wake move faster). 4 Storm Front: a moving storm wall crosses the arena, pushing enemies and speeding allies. | speed buffs, position swap, knock-up, moving wall |
| 19 Milletusk, Threshback, **Gleanhorn** | Bloom | **Vanguard** | Tusk Shove; 1 Stampede (an unstoppable run; allies behind it in its wake get a shield, enemies hit are carried); 2 Seed Scatter (husk plates burst: a cloud that heals allies a little and blinds enemies); 3 Rally (the herd call: allies near it deal more for 3 s). Passive: cannot be slowed while moving toward an enemy. 4 Gleanhorn: the whole team charges with it. | shields in a wake, damage buff, a team-wide charge |
| 22 Echolarva, Stillshade, **Nullchorus** | Hollow | **Silencer** | Echo Bite; 1 Null Pulse (cancels wind-ups in a radius); 2 Still Field (a zone where enemy abilities cost double cooldown); 3 Chorus Step (a short teleport to the last enemy it cancelled). Passive: every cancel heals it a little. 4 Null Chorus: 4 s field-wide silence (abilities only; basics still work). | ability lock, cooldown penalty |
| 21 Hushmire, Lullfen, **Tarnreach** | Hollow | **Lurker / trapper** | Reach (a long thin strike); 1 Still (absent while it stands still; the first strike out of stillness erodes); 2 Hollow Ring (a ring trap: an enemy that steps in is held and silenced); 3 Reach Across (teleports to any held enemy). Passive: Absence, Scourmaw's. 4 Tarn: a wide still-water field; every enemy in it is pulled under 1.5 s and dropped where Tarnreach chooses. | stillness stealth, traps, a mass pull-under |
| 23 Mutecho, Unanswered, **Unspoken** | Hollow | **Bodyguard / mimic** | Hook Grip; 1 Take the Hit (damage to the chosen ally comes to it instead, 3 s); 2 Shutter (closes its back panels: blocks one signature entirely for everything behind it); 3 Pact (the linked ally's next three hits are absorbed). Passive: the first signature that hits it each fight does half. 4 Unspoken: echoes back the last signature anyone used in the fight. | damage redirect, signature blocking, mimicking a signature |
| 7 Siltcrank, Millcurrent, **Braidwake** | Tide | **Current shaper** | Silt Spit; 1 Channel (digs a current line: allies move fast along it, enemies are dragged along it); 2 Pool (a still pool: enemies in it are slowed and cannot dash); 3 Braid (its channels merge into one current that pulls enemies to a point). Passive: full speed through any slowing terrain. 4 Braidwake: a river floods across the arena and carries every enemy downstream to the far edge. | conveyor terrain, pulls, ally-only speed terrain |
| 18 Cotterseed, Canopyvein, **Floodcrown** | Bloom / Stone | **Warden / terraformer** | Seed Dart; 1 Shade (a canopy zone: allies in it regenerate and cannot be marked); 2 Root Cradle (roots an ally in place with heavy damage reduction: a plant); 3 Flood Mark (a line of risen water that slows enemies). Passive: allies near it regenerate. 4 Floodcrown: the floodplain rises across the field: enemy terrain is washed away, allies heal over 4 s, enemies are slowed. | regen zones, erasing enemy hazards, un-markable |
| 10 Flintram, Mortarback, **Cutbank Bastion** | Stone | **Flanker** (the nimble Stone) | Flint Flick (a ricochet shot that bounces off rocks and walls like the lantern balls); 1 Bank Shot (a shot aimed to bounce behind cover); 2 Vault (jumps over a rock or wall); 3 Debris Shed (drops plates behind it that slow pursuers). Passive: immune to slowing terrain. 4 Cutbank: a charge along the arena edge that slams the target into the wall under a landslide. | bouncing shots already exist; jumping over rocks; a wall-slam signature exists |

Two healers were tempting (Springvault and Floodcrown); Floodcrown became the terraformer so the roster has one true healer and one sustain-and-terrain line. Two builders were tempting too (Combwright and Bastion); Bastion became the flanker, the one Stone line that is fast.

## What a 3v3 looks like with these
- Rampartroot, Springvault, Oxbowarchon: the tank holds, the healer keeps it up, the railgun fires down the line the tank makes.
- Stormwick, Highsignal, Scourmaw: the spotter marks, the skirmisher teleports to the mark, the assassin ambushes from the other side.
- Ironvent, Quietwater Warden, Galeshear: the bruiser rams, the controller cancels the enemy's answer, the shield carries whoever gets caught.

## Essence spread after this
Ember 3 (Stormwick, Ironvent, Vitrecrag), Bloom 4 (Rampartroot, Oxbowarchon, Gleanhorn, Combwright, Floodcrown is 5), Stone 4 (Springvault, Deepcut, Bastion, plus seconds), Tide 3 (Scourmaw, Warden, Braidwake), Gale 3 (Galeshear, Highsignal, Stormveer), Hollow 3 (Nullchorus, Tarnreach, Unspoken), Electric 1 (Punchybuns, plus Stormwick's second), Ice 0. Electric and Ice are thin; a later generation could carry them (Preston: "for future generation").

## What to build first, if Preston agrees
1. **Springvault, the healer.** It needs the smallest new system (heals, ally targeting, an ally-only pool, a shield) and changes every 3v3 at once. One session for the systems with a stand-in sprite, one for the art.
2. **Quietwater Warden, the controller.** Wind-up cancel is a few lines on top of the telegraph system that exists; the cooldown-slow zone is a hazard variant.
3. **Highsignal, the spotter.** Marks already exist; the decoy telegraph is the one new trick and it is cheap.
Each line is about $3 of Retro Diffusion for the three arena forms (take, rotation, walks), plus the back views if it also goes into the turn-based game.

**Grok:** every number and every role above is for you to set or reject; the turn-based jobs in `DESIGN_RULES.md` are not changed by this. **Preston:** names are the draft's, not mine; say which roles you want and which lines carry them.
