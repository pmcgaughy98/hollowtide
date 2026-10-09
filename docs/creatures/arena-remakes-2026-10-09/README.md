# Remakes: Highsignal and Scourmaw, and the Warden's walk (Claude, 2026-10-09)

**Preston, 2026-10-09:** "Warden still looks like it's floating or some of its body doesn't touch the ground when it's walking from different angles. Remake Highsignal and use Stormwick's evolution as the example of how stage 3 should enhance the physiology. Remake Scourmaw too: the only reason its kit is that way is that its animation made it look like it was floating on its tail. Use Smite kits to synthesize onto the Scourmaw line; whatever the new design comes out looking like, its physiology and the class it looks like will determine the whole line's kit and class."

## The Warden's walk (fixed)
The first floating pass anchored every texture on its own lowest pixel. In a walk cycle that is wrong: when a foot lifts, the frame's lowest pixel is the other foot, drawn higher, so the whole body dropped two or three pixels and rose again every stride. On a long low frog that reads as hovering, worst from the diagonals. Now a walk cycle stands on one planted row (the deepest foot among the frames near the cycle's median, so a glider's wing tip dipping far below in one frame does not lift the body for the other seven), and long low bodies (wider than tall) cast their shadow under the body, lifted toward its middle, instead of a disc hanging off the toes. `tools/debug/arena_anchor_check.gd` checks the planted rule across all 1968 textures: a lifted foot up to 8 px above the stance, two wing-tip frames dipping under it, nothing wrong; `arena-anchor-2026-10-09/warden_walk_se_baseline.png` shows the eight south-east frames on one baseline.

## Highsignal, two takes ($0.36)
`highsignal_remake_2x.png`: Dustkite, Waywhistle, then the two takes. The Stormwick principle as read from its line (Kithflare, Sparkwick, Stormwick): stage 3 is the same animal grown powerful, not a new one: the chest and limbs heavier, the signature feature (the lantern tail, the mane) larger and armed, the mouth open, still clearly the stage 2 creature. Applied: the same gliding lizard on all fours, rearing to watch, the throat chamber huge, the flank membranes grown into tall ribbed sails with spar tips, a forked tail vane. Take 1 is the cleaner sentinel; take 2 is bulkier. Preston picks; the earlier crest take is kept as `_crest`.

## Scourmaw, two takes ($0.36)
`scourmaw_remake_2x.png`: Rimefin (the catfish starter), the current Riftfin, then the two takes from the roster brief (line 5, stage III: a heavy river predator shaped by erosion, worn stepped plates, blade fins grown into heavy walking fins, a broad flat scoop-jaw head, long low body, calm and dominant). Both stand on four walking fins with the whole body on the ground; take 1 is tighter, take 2 larger with the plates more pronounced. The serpent take is kept as `scourmaw_serpent`.

**What the physiology says (my reading, for Preston to confirm):** a low, heavy, plated river walker with a scoop jaw and barbels reads as a front-line bruiser or juggernaut (Smite's Warrior: Hercules, Chaac, Sun Wukong), not an assassin and not a hovering kite. Erosion fits Hollow as absence: scour, silt, worn plates, not ghosts. A Smite-synthesized draft for the line, numbers for Grok:
- Basic: a scoop bite (melee).
- 1 Scour Pull (after Hercules' Earthbreaker and Chaac's hook): a short rush that drags the target back toward the line it came from.
- 2 Silt Cloud (Hollow): a drifting cloud that blinds enemy aim (telegraphs hidden, cone target lost) and heals the line's creatures standing in it a little (Mitigate Wounds' sustain in Hollowtide clothes).
- 3 Bank Brace: plates set, damage taken down and a knockback shrug for a moment (Chaac's Overflow rhythm: a cooldown refund when the next bite lands after it).
- Passive Scoured: each hit taken wears a plate off (visible), each plate lost raises the next bite; plates grow back out of combat.
- Signature Scour Hollow: the riverbed opens under every enemy in a line (the existing sinkhole and hollow shader), pulling them to the centre and holding them in silt.
- Rimefin and Riftfin keep the Tide basics (Beam, Riptide) and lose Dive; Riftfin gets the Pull. Phase goes: nothing in this physiology passes through things.
This is not built; it waits for Preston's take choice and his word on the class.

## Next
Preston picks a Highsignal take and a Scourmaw take. Then: shrink the 160 px takes to 128 (`downscale.resample`), rotations ($0.10 each) and walks ($0.70 a creature), slice and build, the Scourmaw kit rework with a check, and the Dustkite line's rotations and walks that still wait.

## Flat on the floor (the second complaint, same evening)
Preston: "Warden and Vitrecrag still don't touch flat on the ground of the arena map at all angles." The cause is the rotation sheets themselves: Retro Diffusion draws the south view from high above and the side views from near ground level, so on the arena's overhead floor a frog or a tortoise seen from the side stands on edge. For creatures that are flat on the ground, the seven turned facings and their walks are now the south view and the south walk turned in the image plane and squashed a little (`tools/arena/flat_facings.py`, hooked into `build_small.py` for the names in `FLAT`: warden, vitrecrag). The perspective originals are kept under `arena-anchor-2026-10-09/perspective_backup/`; `flat_before_after.png` shows six facings each, before and after. Trade-off: a turned south view shows the back more than the face; the listener and caller, the quadrupeds and the new Scourmaw are candidates if Preston likes it. The anchor check still passes.

**Reverted the same evening.** Preston: "change it back, that doesn't look right." The perspective facings are restored for both and `FLAT` is empty; the tool stays for reference. The real fix for side views on an overhead floor is regenerating those rotations from a higher camera, paid per creature, or hand-fixed facings.

## The Rimefin line, rekit from its physiology (built the same night)
Preston chose the ambusher direction as the new stage 2 (now Riftfin) and the first epic take as the new stage 3 (Scourmaw, bigger than stage 2: arena size 1.35 against 1.05). A long low pike-catfish lying flat, then a plated, spined leviathan: an ambush predator that lies in the silt, lunges, grips and drags. Smite's Fenrir (the lunge and the grip) is the source for the shape; Hollow stays absence as silt and scour. Built in `scripts/arena/arena_prototype.gd`; every number is a draft for Grok.
- **Role Ambusher**, damage group, profile skirmish (circles at mid range, darts in). Beads as the AI's charm.
- **Basic, Needle Bite** (11, 30 px, 0.2 s melee telegraph): a snap of needle teeth.
- **1 Lunge** (12, 110 px, 0.3 s charge telegraph, 6 s): a low fast rush; on contact it bites, seizes the target and flings it back the way it came (the grab verb), so the enemy is dragged behind the ambusher. A rampart cannot be gripped, by design.
- **2 Silt Dive** (the old Sinkhole, 5 s): under the riverbed, up behind the target, and the next bite inside 3 s is sharpened through the passive.
- **3 Riptide** (from stage 2): the current pulls them toward the silt.
- **Passive Ambush** (from stage 2): the first damaging hit out of the silt, or on an enemy that is not watching it (its target is someone else), lands 1.3 times, then the window is spent.
- **4 Undertow** stays: the jaws from below already were the ambush.
- Gone: Phase (nothing in this physiology passes through things), Deep Jet and Pressure Jet (no water cannon), the Absence shader and the hover (it stands on the ground now). The moves stay defined for old data and the superseded check.
- Stage kits: Rimefin has Needle Bite, Lunge and Silt Dive; Riftfin adds Riptide and the passive; Scourmaw adds Undertow. HP 1.0 and 1.15 for the two upper stages (was 0.85 for the glass cannon); speed 1.1 and 1.0.

Check `tools/debug/arena_ambusher_check.gd` (against Ironvent, which Tide hits for double, so the numbers read high): stage kits as above with the shadow shown and no hover; Needle Bite from 24 px took 29; Lunge from 80 px bit for 79 with the wall slam, gripped the target and ended it 69 px back behind the ambusher; Silt Dive surfaced 14 px from the target with 2.7 s of ambush, a bite then 30 against 23 plain and 30 on an enemy not watching; Undertow fires; AI 1v1 Scourmaw against Stormwick lost in 53 s dealing 228 with five Lunges. `arena_scourmaw_check.gd` is superseded and says so.

**Art complete the same night:** Riftfin and Scourmaw rotations ($0.20) and ten walks ($1.40) made, sliced in the standard layout, built (riftfin 1.05, scourmaw 1.35, no mirror exceptions), imported. Debris check clean. With the real art: the anchor check passes (2160 textures), the ambusher check passes as above, the picker shows the line. `ambusher_stage3.png` shows Scourmaw on the floor against Ironvent.
