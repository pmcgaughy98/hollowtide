# Pass 9, rooms lane (R): the record

Claude, 2026-10-27. Every run below was windowed at 1152x648, `--fixed-fps 30 --max-fps 30`, Dummy audio, with APPDATA
pointed at a scratch folder (never Preston's). The saves are copies of the audit's (`s7_post`).

## What is here

- `method/rooms9_probe.gd`: R1 to R3 walks (phases `rooms9`, `late9`, `cold9`; extends the audit probe).
- `method/rooms9_r5_probe.gd`: R5 captures (phases `places9`, `east9`, `nest60`, `road9`, with `--reduce`).
- `method/cast_probe.gd`: how long the mail call's 582 pictures take to read. `method/run.sh` runs one phase.
- `measure_strip.py`: the room key strip's contrast on stills. `motion.py`: what moves between stills.
- `shots/`: the stills and sheets named below. The full runs stay in the session scratch folder.

## R1 to R4 in numbers

| Item | Before | After |
|---|---|---|
| R1 Grubbit's talk box | box over Grubbit; 0.56 of him hidden at (17, 11) | box at the top for him, clear of both; Grubbit at (17, 12), 0.00 hidden (`r1_grubbit_T09_T11.png`) |
| R2 Hall door, worst frame | 501 ms (audit), 324 ms (cold) | 42 ms cold, 38 ms warm |
| R2 stairs down, worst frame | 1751 ms (audit), 894 ms (cold) | 18 ms cold, 19 ms warm |
| R2 audit town walk rerun | 2 town_room hitches | none in town_room |
| R3 key strip words, worst ratio | 4.22 Hall, 4.26 storage, 5.14 home | 5.29 Hall, 5.28 storage, 6.50 home |
| R4 a second stick push the same way | dropped (stick_edge 7 FAILED) | kept (all ok) |

R2 had two causes. A room the street's warm-up had not painted was painted in the frame of the scene change; it is
now painted on a worker behind a black curtain. With that fixed the stairs still held one frame 1.4 to 1.9 s: the mail
call spawned eight creatures in one frame and waited for their 582 pictures. The Hall now reads them a creature a
frame as it is built, and hall_low holds its curtain until they are in (read on threads: about 0.4 s for all).

## R5: every place, seen or not

| Place | Result | Still |
|---|---|---|
| Item Shop (v1) | Seen, shut: boards across the door, its card read on E | `r5_places.png` P04 |
| Training Yard (v1) | Seen from its gate (41, 11), shut: the rope and board read on E. The audit's "unreached" was its walker refusing a walk of no steps | `r5_places.png` P06 |
| Bluff Lookout (v1) | Seen, its view read on E | `r5_places.png` P08 |
| East Quarter (v2) | Seen in the debug scene only: empty lots, lamps, no townsfolk. In play its road needs `east_quarter_open`, which nothing sets | `r5_places.png` E02, E03 |
| v2 street chat | Not reachable: v2 has no townsfolk (0 counted on the street, East Quarter and Tower Rise; every area file has `"npcs": []`) | none |
| Nest banner, 60 frames | Seen, seed 41: alpha 0.32 at frame 0, 1.00 by frame 10, 0.73 at 30, 0.00 at 59 | `nest_banner_60.png` |
| Tower parts, reveal | Lamp swing and vane flag measured moving in held frames. Flood bell, galleries and waylines seen on the descent. Hoist basket, cradles, chute parcels and smoke move during the camera's legs, which the frame measure cannot tell from the camera: not verified | `tower_reveal_motion.png`, `tower_reveal_legs.png` |
| Tower from the Rise | 40 frames after the reveal: nothing on the Tower moved past the measure's threshold | `tower_rise_motion.png` |
| Road, D-pad | Seen: D-pad right held walked the party from x 44 to 3500; 74 lines read with the pad | `road_pad.png` |
| Road, frame times | 2400 frames: median 17 ms, 95th 18 ms. One frame of 281 to 364 ms after a line advance in 3 of 3 runs; the first frame 1.4 to 1.5 s (the scene's load) | log |
| Road, Reduce motion | Opening veil: 36 frames plain, 9 with Reduce motion. Closing veil: 27 frames plain, 7 with it | log |
