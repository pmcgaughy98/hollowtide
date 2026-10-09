# The River Listener line in the arena: Cutbank Listener, Bend Caller, Quietwater Warden (Claude, 2026-10-08)

**Preston, 2026-10-08:** "Make cutbank listener line." The line he chose in September as the first non-starter three-stage line (`docs/world/world-bible.md` section 7, `docs/creatures/river-listener-line.md`, the line 6 briefs in `creature-roster-draft.md`): a low cutbank amphibian with a split shovel brow and gill fans that taps stones to map the river, Tide then Tide/Hollow, "guards and interruptions", a defensive scout. In the arena it is the **Controller** from the Controller row of `arena-roles-roster-proposal-2026-10-08.md`. The stage names are the working labels from the roster draft, pending Preston's approval; everything numeric is a draft for Grok.

## The Controller
- **Basic, Echo Tap** (AI): a sonar pulse down the line (8, 80 px, 0.25 s line telegraph); it rings off the target.
- **1 Interrupt Call:** goes at once, no telegraph. Every enemy within 55 px winding up a move loses it ("Interrupted", 0.8 s before it can try again), reels 0.5 s and takes 6. Charges cannot be called off. The AI fires it only when an enemy in reach is winding something up, so it reads telegraphs for you.
- **2 Deep Brace:** goes at once. For 2.5 s it is planted in the current: takes half, cannot be moved, and whoever shoves it from up close is shoved back the same distance ("Shoved back").
- **3 Still Water** (from stage 2): a 50 px pool under the target for 4 s. Enemy cooldowns run at half speed while they stand in it (their basics too). Its own side is unaffected.
- **Passive, Listening** (from stage 2): any enemy telegraph wound up within 60 px of it takes 1.3x longer, because it hears the move coming and the caller has to go round it. That is the frame-data layer used as a passive: counters and punishes against it come easier.
- **4 Hush** (Quietwater Warden, 3.0 s): Hollow is absence, so the signature takes the sound out of the river. Three rings of silence spread from the Warden across the floor; at the fall the arena drops dark and still: **every enemy wind-up is cancelled, every enemy is dazed 0.5 s and its abilities are locked for 3 s** (basics still work), and **still water lies over the whole floor** so their cooldowns crawl for those 3 s. Sound: the ElevenLabs take `hush_a` (`tools/build_listener_sounds.py`).
- **Role layer:** Controller sits with the support group (it regenerates when left alone; its hits do not wound). Profile escort: it stays by the ally in trouble and calls from there.
- Stages: Cutbank Listener has Echo Tap, Interrupt Call and Deep Brace, no passive, no signature; Bend Caller adds Still Water and Listening; Quietwater Warden adds Hush.

## Art
- No front art existed, so the arena takes came straight from the brief (Retro Diffusion, `rd_creature.py front`, $0.18 a take): stage 1 at 96 px from the prompt alone; stage 3 at 128 px with stage 1 as the reference; stage 2 at 112 px with stages 1 and 3 as references. Every take came back with its white background only half removed, stripped by a flood fill from the border (the `rd-take-debris-check` lesson); raw takes kept as `*_raw.png`, rejected takes kept with a suffix (`_elephant`, `_lizard`, `_toad`, `_notfrog`, `_biggerfrog`, `_rearing`, `_smallwarden`).
- **Preston's art direction, in order:** the line stays frog-like at every stage (the first stage 2 was an elephant, from the word "trunk" in the brief, and the first stage 3 a lizard); stage 2 must not be a bigger stage 1 and must not be a smaller stage 3; "Stormwick is a good reference": each stage its own creature, the middle one the lanky adolescent with the signature feature oversized, like Sparkwick's crest and lantern. The approved set: the squat kit, the tall calling adolescent with gill plates flared like a young crest, the long ridged guardian.
- Rotations ($0.10 each) and walks, five facings each ($0.14 each), in `arena-starters-2026-10-07/forms/` and `walk/`; all sheets came back in Tallowroot's layout and clean of debris. Sizes in `tools/arena/build_small.py` (listener 0.95, caller 1.0, warden 1.1). The line cost about $4.82 on Retro Diffusion including seven stage 2 takes, three stage 3 takes, one rotation and one walk lost to stopped jobs, and one misfiled take recovered from the job list (`rd-one-job-at-a-time` lesson). **Codex:** palette refinement installed; [native evidence, original backups and reproduction](../listener-palette-refinement-2026-10-08/README.md). The approved silhouettes and scales remain unchanged.
- The turn-based data files (`data/creatures/601_listener.tres`, `602_caller.tres`, `603_warden.tres`) point their `sprite` at the arena south facing as a stand-in front; no back views, default stats, no turn-based moves (Grok).

## Sound
Two ElevenLabs sound-effect runs (`eleven_text_to_sound_v2`, two takes each, about 17 credits a take): `echo_tap_a` (1.0 s, a crisp knock with a short ring) for Echo Tap and Interrupt Call, `hush_a` (2.0 s, a low 226 Hz hum) for Hush. Picked by envelope and spectral centroid, not by ear; the other takes are in `assets/audio/sfx/listener/takes/` for Preston to compare.

## Check (`tools/debug/arena_listener_check.gd`)
- Stage kits: the Listener has Echo Tap, Interrupt Call, Deep Brace, no passive, no signature; the Caller adds Still Water and Listening; the Warden adds Hush. All three read Controller/support in the role layer.
- Echo Tap took 11 from Stormwick (8 base, Tide over Ember). Interrupt Call cancelled its wind-up, took 8 and stunned it 0.5 s.
- Deep Brace: a 20 shove took 10, moved the Listener 0 px and shoved the attacker back 10 px.
- Still Water: after 1 s the enemy's 4 s cooldown stood at 3.50 against the Caller's own at 3.00.
- Listening: Stormwick's 0.22 s Pounce telegraph ran 0.29 s next to the Caller.
- Hush: at the fall the enemy's wind-up was cancelled, it was hushed 3.0 s and dazed 0.5 s; with every cooldown clear it used only its basic for the next 1.5 s; still water lay over the floor.
- The AI call cuts in: the AI drops its own wind-up or recovery to call off an enemy's wind-up in reach (a cancel, after fighting games), for the player's creature too when it is on auto.
- AI 1v1 Warden against Stormwick: lost in 65 s (153 dealt, 351 taken), 3 calls. A Controller alone against the skirmisher should lose, like the Protector does; the calls are rare because Stormwick's wind-ups are short and the call reaches 55 px. **Grok:** CALL_RADIUS and the 8 s cooldown are the levers if the call should come more often.
- AI 3v3 with the Warden, Stormwick and Rampartroot against the Ironvent team: a draw at the 90 s cap. A team with a controller and a tank fights long, as with the Protector.
- Stills here: `line_stage1..3.png`, `interrupt_call.png`, `still_water.png`, `hush_rings.png`, `hush_fall.png`, `ai_1v1.png`, `ai_3v3.png`.

## Known
- The stage names are working labels; Preston decides.
- The check was rerun after the final art and walks were imported; stills show the approved set.
- Turn-based: no back views, no stats, no turn-based moves; the signature needs its own attack sheet and move resource before the turn-based battle can use it.

