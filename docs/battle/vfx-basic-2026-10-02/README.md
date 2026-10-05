# Basic move VFX, October 2, 2026

Ordinary moves now play 16-frame Retro Diffusion sheets. The shared ember particle trail and burst stay off on these scenes. Damage, delivery, equipped moves, and the `signature` flag are unchanged. Ultimates are unchanged: Furnace Roar, Kingstone Rail, Molten Glass, Molten Beam, Molten Cannon's drawn frames, Cinder Claw, and Plate Lunge.

A battle was not played. `tools/basic_vfx_check.gd` printed `BASIC_VFX_OK` (exit 0, empty stderr) after the sheets imported. It loads an ember shot, a coal shot, a slash pop, a shaped pop, the Strike pop, and four ultimate scenes, then frees them.

## Sheets

Installed under `assets/sprites/effects/vfx_basic_2026_10_02/`. Each file is 192x192, a 4x4 of 48px frames, drawn at scale 2. Raw downloads stay in this folder.

| Installed | Raw | Request | Balance after the call |
| --- | --- | --- | --- |
| `hit_pop_4x4.png` | `a_6693.png` | `138a67e2-f4eb-4961-a320-df60536ef170` | $1.58 |
| `coal_shot_4x4.png` | `b_6697_144.png` | `220276b1-c0ef-4ba5-aa64-039d06e5135a` | $1.44 |
| `ember_shot_4x4.png` | `c_6697_151.png` | `dd6c8428-0a66-4821-bbc4-6a18f9170522` | $1.51 |
| `slash_4x4.png` | `d_6698.png` | `bc8ece43-3394-4948-b6dc-a9d411287af1` | $1.37 |

Four calls, $0.07 each, $0.28. No fifth call. The last balance on that fourth call was $1.37.

The ember prompt came back as a campfire on a dark log. The log colors were deleted and the flame kept. The coal prompt had a gray ground line. That line was deleted and the chunk kept. The pop and the slash only had leftover white pixels cleared. The slash opens with sunburst frames, then claw marks. No paw and no face.

## Where they play

`Shot` loops at 14 fps and replaces the still ball. `Pop` plays once at 16 fps on the hit. A hidden pop does not advance during the flight (`VfxSprite` returns early while `visible` is false).

Ember shot, plus the hit pop: Ember Flick, Seam Spark, Signal Spark, Vent Barrage, Crest Signal, Longfire Burst, Window Flare, Ember Pellet.

Coal shot, plus the hit pop: Coal Spit, Clinker Toss, Kilnburst, Furnace Shard, Club Cinder, Fracture Dart, Kiln Star, Slagburst. Clinker Toss, Club Cinder, and Slagburst used to fly the large rock still. They now fly this smaller coal.

Shaped still kept, hit pop on contact: Spineflare, Vent Row, Furnace Bolt, Shoulder Kindle, Shield Flare, Glass Spur, Glassburst, Wayflare, Relay Arc.

Shaped still kept, slash on contact: Vent Rake, Brow Shear, Crest Ram, Hex Cut, Plate Rake, Tail Brake, Handoff Dash, Shoulder Drive, Tail Shutter.

Strike uses `scenes/effects/basic_hit_pop.tscn` because a Strike has no effect scene.
