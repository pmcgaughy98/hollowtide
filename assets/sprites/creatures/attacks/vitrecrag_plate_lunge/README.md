# Vitrecrag Plate Lunge: frame library and analysis (2026-09-28)

Following `docs/battle/attack-sheet-protocol.md`. Sources (untouched): `OneDrive/Documents/HollowTide Sprites/Effect Sheets/
Vitecrag Effect/Plate Lunge Animation/Plate Lunge animation sheet 1-4.jfif`. Cut with
`python tools/cut_forge_frames.py <sheet> frames --prefix sheetN --block 4` (detection read 8, the art is drawn on 4).

Research applied: `Monster Taming 2D Animation Research` (extremes: anchor, anticipation with weight back, short
launch, held contact, recovery; unequal holds about 80/250/40/200/120 ms; planted rear foot; hit effect separate;
Vitrecrag's shell stays rigid) and `Pixel Art Combat Animation Pipeline Research`.

## Step 4: each frame

| Frame | Size | What it shows | Best use |
|---|---|---|---|
| sheet1_f00-f02 | ~83 wide (70% scale) | Rest and slight leans, idle mouth flame | Reference only (scale) |
| sheet1_f03 | 111 | Crouch, legs splayed, rear legs loaded back | Anticipation reference (has flame) |
| sheet1_f04 | 116 | Head pushed forward, lunge stance | Launch reference (has flame) |
| sheet1_f05 | 114 | Deep low stretch, head near ground, rear legs thrown back | Contact body reference (has flame) |
| sheet1_f06 | 103 | Upright rest | Recovery reference |
| sheet2_f00 | 172 | Two touching frames merged | Needs manual split |
| sheet2_f01 | 81 | Small rest | Reference only |
| sheet2_f02, f04 | 109, 113 | Forward crouch and low stretch (flame) | Same as sheet 1 lunges |
| sheet2_f03 | 83 | Turned toward viewer, head tucked behind shell | Different camera angle; brace idea only |
| sheet2_f05 | 103 | Upright rest | Recovery reference |
| sheet3_f00, sheet4_f00 | 106 | Neutral rest, no flame | Anchor match check |
| sheet3_f01, sheet4_f01 | 112-113 | Slight forward lean | Load |
| sheet3_f02, sheet4_f02 | 110 | Head drops and draws in | Anticipation (head) |
| sheet3_f03, sheet4_f03 | 112 | Wedge plate half out from under the head | Launch |
| sheet3_f04 | 113 | Plate fully extended to the ground, body level | Contact (plate donor, level body) |
| sheet4_f04 | 112 | Plate fully extended, body tips forward, rear raised | Contact (strongest pose) |
| sheet3_f05, sheet4_f05 | 108-109 | Plate retracting | Recovery |

All frames: 56-85 colours against the in-game 24, and a faint magenta rim; both need palette snap and rim trim.
Sheets 3-4 are one consistent family at about 90% of the in-game size; sheets 1-2 mix scales and keep the idle
mouth flame.

## Step 5: order

in-game rest → sheet4_f01 load → sheet4_f02 head draws in → sheet4_f03 plate half out → **sheet4_f04 contact** →
sheet3_f05 recovery → in-game rest.

## Step 6: re-analysis

The order reads as motion, but the Opal frames are a different drawing (taller dome, ~10% smaller, brighter glow),
so they pop against the in-game sprite at both ends. **Missing:** a true anticipation (weight shifted back); every
frame leans forward.

**Build plan:** keep the in-game body in every frame (as Molten Glass does); transplant the lowering head from
sheet4_f02; cut the extended plate from sheet4_f04 and slide it out from under the head for the launch and recovery
in-betweens. Anticipation from code (brace tremble plus a small backward shift) unless Preston wants a Forge frame.
Delivery CONTACT: the intact sprite travels to the target while the plate extends, hit on full extension, then it
returns and the plate retracts. Holds per the research.

## Built, v2 (2026-09-28)

Preston's review of v1 (head-only transplant on the in-game body): rogue pixels, the plate did not read, no body or
leg motion, and the retract left pixels behind. v2 uses the **whole Opal poses** so the body leans, the legs step and
the rear rises. The size mismatch that ruled this out before is fixed by cutting sheets 3-4 on their true grid:
`tools/cut_forge_frames.py ... --block 3.67` into `frames_fullsize/` (bodies 115-123 wide vs the in-game 122).

`tools/build_vitrecrag_plate_lunge.py` snaps each chosen frame to the in-game 24 colours, clears stray crumbs, and
registers it on the in-game canvas (lowest pixel on the in-game foot line, rear edge on the in-game rear edge). Frames
in `built/`: load (sheet4_f01), brace (sheet4_f02), launch (sheet4_f03), contact (sheet4_f04), recover (sheet4_f05).
Move file: holds 0.08 / 0.30 / 0.06 / 0.20 / 0.16 s, brace frame 1 draws back 4 art px and trembles, the launch frame
rides the 0.12 s charge, hit on the contact frame, `contact_reach_px = 30`. Code path `_contact_with_frames` (only for
contact moves that name a hit frame; Cinder Claw unchanged).

Verified in `scenes/vitrecrag_plate_preview.tscn`: hit at 663 ms, 60 to 48, returns home, no errors. Open for
Preston: the Opal shell is a little flatter than the in-game one, so the first and last attack frames shift slightly;
the existing star-burst hit art (`vit_burst.png`); the back view charges with the plain rear sprite. `frames/`
(block 4 cut) and v1's approach are superseded; v1 frames were deleted from `built/`.
