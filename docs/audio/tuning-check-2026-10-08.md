# Tuning check, A = 432 Hz (Claude, 2026-10-08)

Preston: "do the 432 Hz check." Every shipped sound, with where it came from and what its spectrum says.
Provenance is the real check: the retune is a 432/440 resample inside each build script. The measurement only means
something for tonal files (synth hums, chimes, the music); a rock crack has no A. The two grids are 32 cents apart,
so a tonal file reads "unclear" when its partials fall between them. Run: `python tools/audio_432_check.py`.

| File | Spectrum says | Strongest peaks, Hz (cents off 432 grid / 440 grid) | Built by | Retuned |
|---|---|---|---|---|
| assets/audio/music/battle_theme.mp3 | tonal, unclear | 65 Hz (21/10), 70 Hz (49/17), 60 Hz (16/48) | tools/retune_432.sh | yes |
| assets/audio/music/boss_scene.mp3 | tonal, nearer 440 | 101 Hz (9/41), 99 Hz (42/10), 98 Hz (27/4) | tools/retune_432.sh | yes |
| assets/audio/music/boss_thunderous_motif.mp3 | tonal, nearer 432 | 64 Hz (1/33), 64 Hz (0/32), 75 Hz (33/34) | tools/retune_432.sh | yes |
| assets/audio/music/deep_hollow.mp3 | tonal, nearer 432 | 60 Hz (15/47), 257 Hz (4/27), 258 Hz (5/26) | tools/retune_432.sh | yes |
| assets/audio/music/evolution.mp3 | tonal, nearer 432 | 98 Hz (29/1), 194 Hz (10/20), 115 Hz (11/20) | tools/retune_432.sh | yes |
| assets/audio/music/evolution_rising_shimmer.mp3 | tonal, nearer 432 | 974 Hz (7/24), 974 Hz (7/24), 974 Hz (7/24) | tools/retune_432.sh | yes |
| assets/audio/music/fainted.mp3 | tonal, nearer 432 | 386 Hz (3/28), 385 Hz (0/31), 95 Hz (14/45) | tools/retune_432.sh | yes |
| assets/audio/music/ferry_landing.mp3 | tonal, nearer 440 | 78 Hz (31/0), 78 Hz (32/0), 85 Hz (10/42) | tools/retune_432.sh | yes |
| assets/audio/music/guardian.mp3 | tonal, nearer 440 | 87 Hz (20/11), 64 Hz (5/37), 75 Hz (37/30) | tools/retune_432.sh | yes |
| assets/audio/music/highbank.mp3 | tonal, unclear | 65 Hz (20/10), 63 Hz (24/44), 67 Hz (35/33) | tools/retune_432.sh | yes |
| assets/audio/music/highbank_courier_guild_blues.mp3 | tonal, nearer 432 | 62 Hz (30/1), 577 Hz (0/30), 578 Hz (4/27) | tools/retune_432.sh | yes |
| assets/audio/music/hollow.mp3 | tonal, nearer 440 | 65 Hz (33/1), 65 Hz (28/3), 65 Hz (31/0) | tools/retune_432.sh | yes |
| assets/audio/music/hollow_flute.mp3 | tonal, nearer 432 | 771 Hz (2/29), 62 Hz (34/2), 580 Hz (10/20) | tools/retune_432.sh | yes |
| assets/audio/music/lookout_flute.mp3 | tonal, nearer 432 | 96 Hz (10/42), 97 Hz (6/25), 96 Hz (8/40) | tools/retune_432.sh | yes |
| assets/audio/music/main_menu_pixel_rain.mp3 | tonal, nearer 440 | 65 Hz (20/11), 65 Hz (23/8), 65 Hz (33/2) | tools/retune_432.sh | yes |
| assets/audio/music/monster_house.mp3 | tonal, unclear | 73 Hz (22/8), 61 Hz (21/10), 64 Hz (1/30) | tools/retune_432.sh | yes |
| assets/audio/music/morning_call.mp3 | tonal, nearer 432 | 612 Hz (2/28), 308 Hz (15/16), 513 Hz (3/35) | tools/retune_432.sh | yes |
| assets/audio/music/old_ferry_ward_mist.mp3 | tonal, nearer 440 | 78 Hz (28/3), 78 Hz (29/2), 78 Hz (26/5) | tools/retune_432.sh | yes |
| assets/audio/music/recruit.mp3 | tonal, nearer 432 | 514 Hz (0/32), 513 Hz (1/33), 512 Hz (4/36) | tools/retune_432.sh | yes |
| assets/audio/music/rest_floor.mp3 | tonal, nearer 432 | 108 Hz (0/32), 108 Hz (0/30), 108 Hz (1/33) | tools/retune_432.sh | yes |
| assets/audio/music/route1_two_note_call.mp3 | tonal, unclear | 61 Hz (23/8), 61 Hz (0/31), 62 Hz (45/13) | tools/retune_432.sh | yes |
| assets/audio/music/setting_out.mp3 | noise, no pitch to check |  | tools/retune_432.sh | yes |
| assets/audio/music/signature_build.wav | tonal, nearer 432 | 771 Hz (3/27), 71 Hz (32/35), 80 Hz (17/48) | tools/retune_432.sh | yes |
| assets/audio/music/signature_hit.wav | tonal, unclear | 193 Hz (7/24), 130 Hz (22/9), 132 Hz (47/15) | tools/retune_432.sh | yes |
| assets/audio/music/signature_move_full.mp3 | tonal, nearer 440 | 73 Hz (24/7), 78 Hz (30/1), 154 Hz (16/14) | tools/retune_432.sh | yes |
| assets/audio/music/title.mp3 | tonal, nearer 432 | 386 Hz (6/24), 385 Hz (1/30), 288 Hz (0/32) | tools/retune_432.sh | yes |
| assets/audio/music/training_yard.mp3 | noise, no pitch to check |  | tools/retune_432.sh | yes |
| assets/audio/music/victory.mp3 | noise, no pitch to check |  | tools/retune_432.sh | yes |
| assets/audio/music/victory_triumph_resolved.mp3 | tonal, nearer 432 | 386 Hz (3/28), 386 Hz (2/28), 772 Hz (4/26) | tools/retune_432.sh | yes |
| assets/audio/music/wayline_hall.mp3 | tonal, nearer 432 | 76 Hz (17/49), 76 Hz (16/48), 517 Hz (10/21) | tools/retune_432.sh | yes |
| assets/audio/sfx/arena/cinder_claw.wav | noise, no pitch to check |  | tools/build_arena_takes.py and tools/build_arena_sounds.py | yes |
| assets/audio/sfx/arena/crest_ram.wav | noise, no pitch to check |  | tools/build_arena_takes.py and tools/build_arena_sounds.py | yes |
| assets/audio/sfx/arena/match_start.wav | noise, no pitch to check |  | tools/build_arena_takes.py and tools/build_arena_sounds.py | yes |
| assets/audio/sfx/arena/rock_break.wav | noise, no pitch to check |  | tools/build_arena_takes.py and tools/build_arena_sounds.py | yes |
| assets/audio/sfx/arena/rock_crack.wav | noise, no pitch to check |  | tools/build_arena_takes.py and tools/build_arena_sounds.py | yes |
| assets/audio/sfx/arena/synth_cinder_claw.wav | noise, no pitch to check |  | tools/build_arena_takes.py and tools/build_arena_sounds.py | yes |
| assets/audio/sfx/arena/synth_crest_ram.wav | noise, no pitch to check |  | tools/build_arena_takes.py and tools/build_arena_sounds.py | yes |
| assets/audio/sfx/arena/synth_rock_break.wav | noise, no pitch to check |  | tools/build_arena_takes.py and tools/build_arena_sounds.py | yes |
| assets/audio/sfx/arena/synth_rock_crack.wav | noise, no pitch to check |  | tools/build_arena_takes.py and tools/build_arena_sounds.py | yes |
| assets/audio/sfx/arena/synth_wall_slam.wav | noise, no pitch to check |  | tools/build_arena_takes.py and tools/build_arena_sounds.py | yes |
| assets/audio/sfx/arena/telegraph.wav | tonal, nearer 432 | 216 Hz (0/31) | tools/build_arena_takes.py and tools/build_arena_sounds.py | yes |
| assets/audio/sfx/arena/wall_slam.wav | tonal, nearer 440 | 94 Hz (47/20), 74 Hz (43/25), 69 Hz (26/5) | tools/build_arena_takes.py and tools/build_arena_sounds.py | yes |
| assets/audio/sfx/canvaswing/gale.wav | tonal, nearer 440 | 68 Hz (9/41), 99 Hz (48/19), 83 Hz (36/5) | tools/build_canvaswing_sounds.py | yes |
| assets/audio/sfx/canvaswing/shear.wav | tonal, unclear | 140 Hz (45/13), 136 Hz (5/37), 237 Hz (36/31) | tools/build_canvaswing_sounds.py | yes |
| assets/audio/sfx/dustkite/high_signal.wav | tonal, nearer 432 | 2019 Hz (30/37), 2022 Hz (27/40), 2028 Hz (23/44) | tools/build_dustkite_sounds.py | yes |
| assets/audio/sfx/dustkite/whistle_dart.wav | tonal, unclear | 2008 Hz (40/28), 2012 Hz (36/31), 2017 Hz (32/35) | tools/build_dustkite_sounds.py | yes |
| assets/audio/sfx/ironvent/blowdown.wav | tonal, nearer 440 | 63 Hz (34/34), 65 Hz (10/20), 70 Hz (42/10) | synth, then tools/retune_sfx_432.py | yes |
| assets/audio/sfx/ironvent/buildup.wav | tonal, unclear | 121 Hz (6/37), 80 Hz (28/39), 83 Hz (33/2) | synth, then tools/retune_sfx_432.py | yes |
| assets/audio/sfx/ironvent/cool.wav | noise, no pitch to check |  | synth, then tools/retune_sfx_432.py | yes |
| assets/audio/sfx/ironvent/cry.wav | tonal, unclear | 80 Hz (18/49), 78 Hz (41/10), 86 Hz (12/19) | synth, then tools/retune_sfx_432.py | yes |
| assets/audio/sfx/ironvent/roar.wav | tonal, unclear | 91 Hz (2/34), 93 Hz (37/6), 60 Hz (8/40) | synth, then tools/retune_sfx_432.py | yes |
| assets/audio/sfx/ironvent/vent_hiss.wav | noise, no pitch to check |  | synth, then tools/retune_sfx_432.py | yes |
| assets/audio/sfx/ironvent/vent_jet.wav | noise, no pitch to check |  | synth, then tools/retune_sfx_432.py | yes |
| assets/audio/sfx/listener/echo_tap.wav | tonal, unclear | 617 Hz (17/13), 606 Hz (13/44), 613 Hz (4/26) | tools/build_listener_sounds.py | yes |
| assets/audio/sfx/listener/hush.wav | tonal, nearer 440 | 94 Hz (35/32), 69 Hz (27/4), 83 Hz (36/4) | tools/build_listener_sounds.py | yes |
| assets/audio/sfx/oxbowarchon/rail_charge.wav | tonal, nearer 432 | 108 Hz (1/33), 143 Hz (11/43), 73 Hz (14/16) | tools/build_oxbowarchon_sounds.py | yes |
| assets/audio/sfx/oxbowarchon/rail_impact.wav | tonal, unclear | 76 Hz (19/49), 98 Hz (37/5), 88 Hz (48/20) | tools/build_oxbowarchon_sounds.py | yes |
| assets/audio/sfx/root_rampart/eruption.wav | noise, no pitch to check |  | synth, then tools/retune_sfx_432.py | yes |
| assets/audio/sfx/root_rampart/rootwave.wav | tonal, unclear | 168 Hz (31/36), 175 Hz (31/0), 161 Hz (11/43) | synth, then tools/retune_sfx_432.py | yes |
| assets/audio/sfx/root_rampart/slam.wav | noise, no pitch to check |  | synth, then tools/retune_sfx_432.py | yes |
| assets/audio/sfx/root_rampart/strain.wav | tonal, nearer 440 | 130 Hz (14/17), 131 Hz (29/1), 124 Hz (41/9) | synth, then tools/retune_sfx_432.py | yes |
| assets/audio/sfx/starward/star_guard.wav | noise, no pitch to check |  | tools/build_starward_sounds.py | yes |
| assets/audio/sfx/stormlantern/boom.wav | noise, no pitch to check |  | synth, then tools/retune_sfx_432.py | yes |
| assets/audio/sfx/stormlantern/crack.wav | tonal, nearer 440 | 99 Hz (42/10), 96 Hz (1/33), 70 Hz (41/27) | synth, then tools/retune_sfx_432.py | yes |
| assets/audio/sfx/stormlantern/crackle.wav | noise, no pitch to check |  | synth, then tools/retune_sfx_432.py | yes |
| assets/audio/sfx/stormlantern/throw.wav | noise, no pitch to check |  | synth, then tools/retune_sfx_432.py | yes |
| assets/audio/sfx/ui/cancel.wav | tonal, unclear | 242 Hz (4/36), 264 Hz (46/15) | tools/build_ui_sounds.py (A = 432 in the synth) | yes |
| assets/audio/sfx/ui/catch_fail.wav | tonal, nearer 432 | 432 Hz (0/31), 864 Hz (0/31), 450 Hz (28/39) | tools/build_ui_sounds.py (A = 432 in the synth) | yes |
| assets/audio/sfx/ui/catch_reach.wav | noise, no pitch to check |  | tools/build_ui_sounds.py (A = 432 in the synth) | yes |
| assets/audio/sfx/ui/catch_success.wav | tonal, nearer 432 | 192 Hz (0/31), 1540 Hz (0/31), 385 Hz (0/31) | tools/build_ui_sounds.py (A = 432 in the synth) | yes |
| assets/audio/sfx/ui/confirm.wav | tonal, nearer 432 | 647 Hz (0/31) | tools/build_ui_sounds.py (A = 432 in the synth) | yes |
| assets/audio/sfx/ui/cursor.wav | tonal, nearer 432 | 320 Hz (19/48), 330 Hz (35/3), 345 Hz (8/23) | tools/build_ui_sounds.py (A = 432 in the synth) | yes |
| assets/audio/sfx/ui/encounter.wav | tonal, nearer 432 | 970 Hz (0/31), 1939 Hz (0/31), 770 Hz (0/31) | tools/build_ui_sounds.py (A = 432 in the synth) | yes |
| assets/audio/sfx/ui/faint.wav | tonal, nearer 440 | 348 Hz (23/8), 296 Hz (42/11), 404 Hz (16/48) | tools/build_ui_sounds.py (A = 432 in the synth) | yes |
| assets/audio/sfx/ui/hit.wav | tonal, unclear | 128 Hz (5/37), 145 Hz (10/20), 157 Hz (47/16) | tools/build_ui_sounds.py (A = 432 in the synth) | yes |
| assets/audio/sfx/ui/hit_strong.wav | tonal, nearer 432 | 970 Hz (0/31), 770 Hz (0/30), 1939 Hz (0/32) | tools/build_ui_sounds.py (A = 432 in the synth) | yes |
| assets/audio/sfx/ui/hit_weak.wav | tonal, nearer 440 | 267 Hz (32/35), 280 Hz (49/17), 547 Hz (7/23) | tools/build_ui_sounds.py (A = 432 in the synth) | yes |
| assets/audio/sfx/ui/hp_drain.wav | tonal, nearer 440 | 435 Hz (10/21), 332 Hz (43/11), 375 Hz (45/22) | tools/build_ui_sounds.py (A = 432 in the synth) | yes |
| assets/audio/sfx/ui/text.wav | tonal, nearer 432 | 385 Hz (0/31) | tools/build_ui_sounds.py (A = 432 in the synth) | yes |
| assets/audio/sfx/undertow/burst.wav | tonal, nearer 432 | 162 Hz (1/29), 163 Hz (14/17) | synth, then tools/retune_sfx_432.py | yes |
| assets/audio/sfx/undertow/plunge.wav | noise, no pitch to check |  | synth, then tools/retune_sfx_432.py | yes |
| assets/audio/sfx/undertow/surge.wav | tonal, unclear | 324 Hz (1/29), 326 Hz (14/17), 160 Hz (24/43) | synth, then tools/retune_sfx_432.py | yes |
| assets/audio/sfx/undertow/whirlpool.wav | tonal, nearer 432 | 216 Hz (0/32), 217 Hz (11/19) | synth, then tools/retune_sfx_432.py | yes |
| assets/audio/sfx/vitrecrag/buildup.wav | noise, no pitch to check |  | tools/build_vitrecrag_takes.py | yes |
| assets/audio/sfx/vitrecrag/cry.wav | tonal, unclear | 80 Hz (27/40), 83 Hz (46/15), 85 Hz (21/47) | tools/build_vitrecrag_takes.py | yes |
| assets/audio/sfx/vitrecrag/rupture.wav | noise, no pitch to check |  | tools/build_vitrecrag_takes.py | yes |

Retune provenance: yes 86.
Tonal verdicts: noise, no pitch to check 26, tonal, nearer 432 27, tonal, nearer 440 16, tonal, unclear 17.
