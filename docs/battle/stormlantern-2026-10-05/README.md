# Stormlantern, Stormwick's signature (Claude, 2026-10-05, first version)

Preston approved the concept in `docs/battle/kithflare3-signature-proposal-2026-10-05.md` ("Do it"). This is the first working version, playable in battle.

How it plays: title card, the stormy ferry-dock stage, the camera pulls back, Stormwick's storm lantern swells and overloads white-hot (frames 2 to 4, strain loop), the core leaves the lantern, then crashes onto the target with afterimages, a light column, a fire-and-lightning burst (RD sheet) and amber rings.

Files:
- `data/moves/kithflare3_stormlantern.tres`: Electric, power 60, 2 uses, needs `stormlantern` (Stormwick's body parts now list stormlantern, rodcrest, throat, marking). Essence, power and uses are provisional for Grok.
- `scenes/effects/kithflare3_stormlantern.tscn`: reuses Kingstone Rail's `sky_rail_strike.gd` with amber art and an amber palette.
- Art: `orb_vfx_0.png` and `impact_vfx_0.png` (RD `rd_animation__vfx`, $0.07 each), `stage_0.png` (RD Pro 256x144, $0.18, upscaled to 448x252 as `assets/backgrounds/signature_stages/stormlantern.png`). `build_frames.py` composites orb frames onto the lantern (`assets/sprites/creatures/attacks/kithflare3_stormlantern/`), cuts the core and the title card. Kingstone's rings, core and bursts recoloured jade to amber (free) in `assets/sprites/effects/kithflare3/stormlantern/`.
- Stormwick uses Codex's texture-refined art (`starter_texture_refine_2026_10_05/`); the lantern offset (-51, -40) was measured on it.

Checked: played as the player and as the opponent, no script errors, 30 damage on Rimefin. `stormlantern_run1.png`, `stormlantern_run2.png`.

Not yet: the lightning bolt striking the rod crest at the start (the tell), poses for rearing and the tail snap (every frame is the standing pose with the lantern changing), a clearer view of the core leaving the lantern, sounds. Total spend $0.32.

## Second pass (same day, Preston: "do it")

- **Opening bolt:** `scripts/effects/stormlantern_strike.gd` extends Kingstone's effect. On the rear (frame 1) a jagged pixel lightning bolt with a fork flashes three times down onto the rod crest, with small screen shakes, then after 2.05 s (the charge) the inherited launch, fall and impact run from the lantern. The crest point flips with the attacker's facing.
- **Poses:** `pose_raise_raw.png` (rears, roars at the sky, lantern overhead) and `pose_snap2_raw.png` (whips the lantern forward over its head) are RD edits ($0.18 each; a first snap take that barely moved is kept as `pose_snap_raw.png`). The snap's lantern ran off the canvas, so it was outpainted 48 px (`pose_snap2_outpaint.png`, $0.18, flat background removed). All frames are 315 x 219 (48 px padding each side); the battle centres frames, so the feet stay put.
- **Frames:** rest, raise, glow, kindle, full (strain loop full / full_b, the orb composited on the raised lantern), snap, snap, rest x3; hit on frame 9. Release point (114, -25) on the snap pose.
- **Camera:** new shot on the snap (frame 5) leaning toward Stormwick so the throw reads; sky, fall and hit shots as before.
- **Sounds:** `tools/build_stormlantern_sounds.py` synthesizes crack (bolt), crackle (overload), throw (snap) and boom (impact) into `assets/audio/sfx/stormlantern/`, cued on frames 1, 2, 5, 9. Synthetic placeholders; ElevenLabs takes can replace them.
- Checked: played from both sides, no script errors, damage lands. `stormlantern_bolt.png`, `stormlantern_v2.png`. Sounds were not listened to (they are built and cued, not heard).
- Spend this pass: $0.72. Balance $3.26.

## Refinement pass (same day, Preston: refine and upgrade the starter signatures)
- The core now leaves the lantern on the tail-snap frame (`release_after` 2.2; it was firing ~0.1 s early, during the charge pose).
- After the throw the lantern is spent: frames 6 to 9 use `spent.png`, the rest pose with the lantern core dimmed to a dark ember (`build_frames.py`).
- Sound levels rebalanced by measured loudness (`sound_cue_db` 7, 0, 2, 8): the crack and boom were about 10 dB quieter on average than Ironvent's roar.
