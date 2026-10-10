# The rival crew's stage 1s, and the second dungeon (Claude, 2026-10-10)

Preston: "make rival crew line, with attack, hurt, sleep, and the rest for stage 1's. VFX up their moves.
Then second dungeon." Design and story: `docs/creatures/antagonist-crew-proposal-2026-10-10.md`.

## Mirekit and Whinet
- **Art (Retro Diffusion):** two front takes each; Preston chose Mirekit take 1 (the grin); Whinet take 2
  came out with two faces, so take 1. Mirekit's white background was stripped with
  `tools/arena/strip_take_bg.py --strict` (only near-pure white goes, so its white fur stays).
  Rotations sliced by eye (`slice_rotations.py`; Mirekit's south-west mirrors south-east). Walks for five
  facings each (the rest mirrored); attack (s, e, n), hurt (s, e) and sleep (s), built to all eight
  facings by `build_actions.py`. Dungeon and small sets built; dialogue portraits cut from the takes.
- **Data:** `data/creatures/2201_mirekit.tres` (Blight), `2301_whinet.tres` (Gale). They are **dungeon-only
  lines** (`CREW_LINES` in `dungeon.gd`, numbered 100 and 101), so the arena and everything that loops over
  its lines never meets them until their later stages exist. Bodies in `move_body.gd`.
- **Moves (numbers drafts for Grok):** Mirekit: Grub Bite, Rot Spit (Blights: healing halved for 3 turns,
  and no slow recovery); Play Dead waits for the boss slice. Whinet: Needle Jab, Drain Bite (heals half the
  damage it deals), Buzz Dart (Lv 3).
- **Effects, drawn in code:** Rot Spit throws a green glob down the line and splashes; a Blighted creature
  turns sickly green with rot bubbles rising off its head while it lasts; Drain Bite pulls a stream of red
  motes back into Whinet with a "+N"; Buzz Dart leaves wing streaks; the bites snap two rows of teeth.

## Two dungeons
- `DUNGEONS` in `dungeon.gd`: each dungeon has its floors, wild creatures by floor, the look of each floor
  and its boss. The town sends a run to the first one whose boss is not beaten (`beaten`, carried by the
  team record). One way down from town for now; separate entrances are Codex's town layout.
- **The first dungeon, Rootbank Warren** (Preston asked Claude to name it; tunnels through a river bank,
  painted by `scripts/dungeon/riverbank_painter.gd`: clay, pebbles, rippled sand, grass, roots, banded banks): three floors as before; the boss floor is Mirekit with Whinet
  (1.5x health, no escort), their own short talk, no pond, the camera framing both sides while they talk.
- **The Hollow** (Preston: "a small, sheltered valley or dip between hills"; the structure that rose from
  the river): B1F the valley (`scripts/dungeon/valley_painter.gd`: meadow clearings between wooded hills, the stone
  pathway of stepping stones through the halls), B2F inside the risen structure, then the Warden's pond
  garden. Wild: Listeners, Rimefin, Dustkite, then Troughspine and Punchybun.
- **The Hollow's stone** (`scripts/dungeon/ruin_painter.gd`), drawn in code like the pond: river-washed
  flagstones in uneven running rows, silt stains, moss clumps out of the seams (more under the walls),
  shallow pools; walls of dark carved blocks with a green water line at their foot.

## Checks and stills
- `tools/debug/dungeons_check.gd`: the crew boss floor, Rot Spit and Drain Bite, the Hollow's looks and
  Warden scene, the town's choice. All pass.
- `tools/debug/crew_capture.gd`: `rot_spit`, `blighted`, `drain_bite`, `buzz_dart`, `crew_boss`,
  `hollow_stone`, `hollow_valley` in this folder.

## Open
- Play Dead and the crew's real boss scene (the parcel, the flop, "the boss'll hear about this").
- The artifact that rises from the pond after the Warden falls.

## The crew's scene (2026-10-10, later)
`scripts/dungeon/crew_scene.gd`, on Rootbank Warren's boss floor (`"scene": "crew"` in DUNGEONS):
- Entrance: Mirekit and Whinet, backs turned, tugging at the stolen parcel (drawn in code) and arguing;
  the team walks in; a "!" over the partner; they spin round and Mirekit drags the parcel behind it; the
  talk; the streak wipe; the fight.
- Finish: Mirekit flops belly up with green stink wisps (playing dead); Whinet panics; a "!" and it
  springs up, "the boss'll hear about this"; both run; the parcel hops to the leader, held up while the
  partner speaks; then the dungeon is cleared.
- New face "mischievous" (purple background, a dark sparkle) for the crew's bullying lines; $0.36.
- Check and video: `tools/debug/crew_scene_capture.gd`, `crew_scene/crew_scene.mp4` and stills.
- The lines are proposals for Preston to rewrite (ARGUE, FLOP, FLEE, GOT_IT in crew_scene.gd).
