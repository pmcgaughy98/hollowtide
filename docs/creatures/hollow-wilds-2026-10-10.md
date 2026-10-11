# The Hollow's wild creatures: proposal (Claude, 2026-10-10)

Preston: "Start the 3 creatures that will also be in warden's dungeon. Also rimefin's line obviously won't
be obtainable in that one." Earlier the same day: Troughspine belongs in the Warden's dungeon, which leans
Tide, stocked "however mystery dungeon did it" with others only where they make sense.

Synthesis (structure only): Explorers of Sky's water caves hold water creatures plus the bugs, burrowers
and shellfish that live at the water's edge. The Hollow is a river structure with a pond garden at its
heart, so its wilds are pond and river-bottom creatures of Missouri. They are full three-stage lines (met
and recruited in the dungeon); only the stage 1s are made now. **Names, looks and essences are proposals
for Preston; kits and numbers go to Grok.**

The Hollow's pool: Listener (the Warden's frogs), Troughspine (Preston's pick), and these three. Rimefin
is out (a starter's line is not met here).

| Working name | Creature | Essence | Role it fills |
|---|---|---|---|
| Skimlet | water strider (pond skater) | Gale/Tide | a fast hit-and-run skater that glides over water tiles |
| Ozbender | Ozark hellbender (Missouri's giant salamander) | Tide/Loam | a slimy, loose-skinned bottom-dweller, a tough ambusher |
| Valvekin | freshwater pearl mussel | Tide/Stone | a shell defender that clamps shut and spits pearls |

Art: two Retro Diffusion front takes each at 96 px ($0.18 a take), Mirekit as the style reference, saved
as `docs/creatures/arena-starters-2026-10-07/forms/<name>_arena_front_take{1,2}.png`. Preston picks; then
the turn, walks and actions as for the crew, and the spawns go in `DUNGEONS["hollow"]`.

## Built (2026-10-10, later)
Preston picked Skimlet 1, Ozbender 2, Valvekin 2. Turns, walks (five facings), attack, hurt and sleep, dungeon and town
sets. Skimlet's south hurt take came back on white with a painted burst; it is in `actions-2026-10-09/rejected/` and the
south hurt uses the side one. Data `data/creatures/2501_skimlet.tres`, `2601_ozbender.tres`, `2701_valvekin.tres`; lines
103 to 105 in `scripts/creatures/lines.gd` (the one lookup the town, Team page, shrine and jobs use); placeholder kits in
`arena_prototype.gd` KITS and `dungeon.gd` LEARN for Grok. Spawns: B1F Listener, Troughspine, Skimlet; B2F Listener,
Troughspine, Ozbender, Valvekin. Check: `tools/debug/hollow_wilds_check.gd` (spawns, and a recruited Skimlet in town and
back in a dungeon).
