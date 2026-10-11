# Grok Build result, 2026-10-11

Lane: creature and move numbers. No story flags, scenes, art, save model, or names were changed. Nothing was committed. `tools/debug/pilot_chain_check.gd` was not run: a Godot 4.7.2 process was already open (pid 11652, started 10:48), and this session does not start a second one. The level line below is the KO count, not a played clear.

## 1. First evolution lands on the Warden

Changed in `scripts/dungeon/dungeon.gd` only:

| | Before | After |
|---|---:|---:|
| `EXP_PER_KO` | 12 | 8 |
| `EXP_PER_STAGE` | 6 | 6 |
| `EXP_BOSS` | 60 | 110 |
| `exp_to_next(lv)` | `10 * lv + 10` | `40 * lv` while `lv < 5`, then `20 * lv + 20` |
| `EVO_LEVEL` | 5, then 10 | unchanged |
| `LEVEL_HP` | 0.03 | unchanged |
| `EVO` conditions | unchanged | unchanged |

Cost to reach level 5 is 40 + 80 + 120 + 160 = 400. A quiet clear (the placed 3 wilds on each normal floor, both bosses, no Monster House) pays:

| Stop | KOs | EXP this step | Total | Level after |
|---|---:|---:|---:|---|
| Hollow Mouth, 2 floors | 6 × 8 | 48 | 48 | 2, with 8 of 80 |
| Rootbank Warren wilds, 3 floors | 9 × 8 | 72 | 120 | 3, with 0 of 120 |
| Crew boss room | minion 8, boss 8 + 110 | 126 | 246 | 4, with 6 of 160 |
| The Hollow wilds, 2 floors | 6 × 8 | 48 | 294 | 4, with 54 of 160 |
| Two Listeners, then the Warden | 16, then 8 + 2 × 6 + 110 | 146 | 440 | 5, with 40 of 120 |

The crew fight is fought at level 3. The level arrives when the boss falls. The Warden room is entered at level 4 with 54 of 160. The Listeners bring that to 70. The Warden's own 130 is what crosses 160. Level 5 is the shrine gate. The next step costs `20 * 5 + 20` = 120, so the bank is 40 of 120.

On the old curve the same quiet clear reached level 5 on Warren floor 2 (144 EXP, cost to 5 was 140), entered the Warden room at level 7, and the two Listeners could push level 8 before the Warden fell.

Monster Houses add wilds. They do not replace the floor's 3. Each house drops 4 to 7 (`MONSTER_HOUSE_WILD` 4, max 7). Three minimum houses are 12 extra KOs, 96 EXP, which leaves the level-4 bar at 150 of 160, so the Warden still dings. A fourth minimum house (128 EXP) or two maximum houses (112 EXP) crosses 160 before the Warden. That spread is accepted. It was not rolled.

Level is shared by the line for whoever is standing. It is not the whole ready check. Kithflare still needs 3 KOs and 4 flank hits. Tallowroot still needs 2 KOs and 60 damage taken. Floors need 2, which the Mouth already gives. Only the killer gets the KO count. Whether the partner has those 2 KOs by the shrine was not measured. The check script now prints `growth` after each dungeon so the next run can see it.

From level 5 the new steps are 120, 140, 160, 180, 200 (800 EXP to level 10). At 8 a KO that is about 100 KOs. The old steps from 5 to 10 were 400 EXP at 12 a KO, about 34 KOs. Later levels are slower. They were not retuned.

## 2. Bosses, held

No change to `BOSS_HP` 3.0, `BOSS_DMG` 0.9, or the crew boss `hp` 1.5.

The team fights those bosses on the stage-1 kit either way. Stage 1 learns at level 1 and level 3. Nothing is taught at 4, 5, 6, or 7, and evolution waits for the shrine. Max HP is `base * (1 + 0.03 * (level - 1))`. Level 3 is 1.06 times, level 4 is 1.09 times, the old crew entry (level 5) was 1.12 times, and the old Warden entry (level 7) was 1.18 times. That is about 5% less HP at the crew fight and about 8% less at the Warden than the overleveled clear. Damage does not scale with level. The 25×18 room and the flanking Listeners were not played. Multipliers stay until a run says otherwise.

## 3. Meetable townsfolk, proposals only

Not added to `KITS`, `PARTS`, `LEARN`, or the chart. Essences match Claude's crew and NPC tables and stay Preston's to approve. Sinew, Loam, and Murk are still neutral. A dual essence is not a chart cell. Stats sit under the worked example in `DESIGN_RULES.md` (Kithflare 78/64/56/74, Cinderhide 90/64/64/54). They were not simulated. Stage-1 town wilds stay under those starters. Gear stays on the NPC. The wild is the body.

Moves are existing ids whose current gates the proposed parts would pass. No new move id.

| Form | Stage | Essence (proposal) | HP / Atk / Def / Spd | Dungeon hp, speed | Parts (proposal) | Kit from moves that exist |
|---|---:|---|---|---|---|---|
| Grubbit | 1 | Loam | 84 / 52 / 62 / 40 | 1.05, 0.85 | claw, jaw | Rake, Grub Bite |
| Muskin | 1 | Tide | 72 / 50 / 52 / 58 | 0.90, 1.00 | jaw | Needle Bite, Lunge |
| Slipjaw | 1 | Sinew | 74 / 58 / 48 / 70 | 0.95, 1.15 | jaw, springlegs if the legs read digitigrade | Needle Bite, Lunge, and Pounce only with springlegs |
| Wayling | 1 | Gale | 68 / 50 / 46 / 72 | 0.85, 1.20 | wing | Shear, Downdraft |
| Stillwade | 2 | Tide | 98 / 64 / 70 / 48 | 1.15, 0.90 | jaw, wing | Needle Bite, Lunge, Shear |
| Wickglow | 2 | Ember | 86 / 66 / 52 / 76 | 0.90, 1.25 | sixlegs, lantern | Wick Bolt, Lantern Volley |
| Rinsepaw | 2 | Murk | 96 / 62 / 64 / 58 | 1.05, 1.00 | claw, jaw | Rake, Grub Bite |
| Swaphoard | 2 | Loam | 100 / 58 / 72 / 44 | 1.15, 0.85 | claw, jaw, hooktail if the tail hooks | Rake, Grub Bite, Play Dead only with hooktail |
| Pouchbill | 2 | Tide | 108 / 60 / 68 / 42 | 1.20, 0.80 | jaw, wing | Needle Bite, Shear, Lift |
| Inkhoot | 3 | Gale/Murk | 104 / 78 / 68 / 66 | 1.10, 1.10 | wing, claw | Shear, Downdraft, Lift, Rake |
| Cairnshell | 3 | Stone/Bloom | 118 / 60 / 98 / 28 | 1.40, 0.70 | shell, buttress only if the legs are columns | Glass Guard, and Plate Lunge only with buttress |
| Crawdukes | 3 | Sinew/Tide | 110 / 80 / 74 / 52 | 1.20, 1.00 | claw, jaw, shell | Rake, Grub Bite, Glass Guard |

Gaps, on purpose: Rinsepaw has no Murk move, because none exists. Cairnshell does not get Preostmar's jade or Tallowroot's roots, so the Bloom half has no plant move. Crawdukes does not get a paddle or a fin, so the Tide half has no water move, and the glove is gear so it does not get Punchybun's fist. Wickglow sharing `lantern` makes Wick Bolt a shared signature with Sparkwick. No ultimate: none of these bodies has a part no other line has. Other stages of these lines are not designed.

## 4. Waiting items

The five dungeon kit conflicts from 2026-10-09 are already closed. The 2026-10-10 result records 0 kit failures after Vent Barrage left Cinderhide and Clinkerhide, Molten Beam stayed on Vitrecrag, and Furnace Shard left Slagglass. That check was not re-run today.

Springvault stays Claude's draft. Not applied.

Seep's dungeon text plants roots and wells a spring. `NEEDS` currently gates Seep on `gills`, and Troughspine's learn row teaches it at level 1. Troughspine has no roots. Archroot is where roots are written to grow. The gate should be roots, not gills. Troughspine should not learn Seep. Archroot should learn it on evolving. Springvault keeps it.

Numbers kept: Spring Spit damage 10, cooldown 1.0, range 110. Seep damage 0, cooldown 9, heal 6, `SEEP_TURNS` 3. `EVO` index 10 (the roster note that said 12 is the wrong index): way healed, KOs 2 then 5, floors 2 then 4, need 40 then 100.

`muzzle`, `gills`, and `arches` are not in the confirmed part list. Prefer `roots` and `gillplate` when the sprite supports them. Do not add Mineral Brace, Vault Arch, or Headspring. Headspring is already an essence key with no move body. Leave it. If Seep needs roots alone, Tallowroot's line can learn it too. That should be decided against `se.png` before the gate changes. Apply only after `springvault_check.gd`, then `move_table_check.gd`, and only when no other Godot is open.

## Left parked

The Sinew/Loam/Murk/Blight chart cells and the health-carry re-measure were not in today's list. Grid reach, WAITING effects, the arena 24-6, and move growth stay parked.
