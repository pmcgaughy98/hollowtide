# Highbank town detail — October 10, 2026

Detailed stone bench/parapet/wave marker, strapped courier crate, eight mooring posts, rope/plank dock, rooted riverbank and teal current now match the material density of the approved interiors. Lookout and landing retain their original footprints with the approved Hall native stone surface. Separate props use the shared exterior selective material rim and internal detail at native scale; the shore uses the existing masked sel-out. Collision, all layout coordinates, service/door logic, town/mission route and creature sources remain intact. New art is a visual proposal awaiting Preston's review.

## Sources and exact prompts

Built-in `image_gen.imagegen`, two calls, transparent_background=true. [Selected first prompt](prompts/prompt.txt), refs: before atlas, actual landing capture, approved Hall interior. [Fit edit prompt](prompts/fit-prompt.txt), edit target: first output. Both original PNGs are preserved in [sources](sources/); fit variant rejected because it displaced panels/posts. No CLI/API/Python bitmap repaint. Selected image 1448x1086. [Godot preparation](checks/prepare_art.gd) uses only get_region and nearest resize: lookout (0,0,564,377) to144x96; dock (886,0,562,333) to144x72; landing (0,407,1086,402) to288x108; river (0,811,1448,275) to384x72. Landing's complete fringe extends12px over the existing bank; original collision footprint288x96 is unchanged. Floor is the exact160x96 region(48,144) of the approved Hall source; repeated native pixels, no resizing.

Saved runtime assets: `assets/sprites/world/town_detail_2026_10_10/`. Originals and candidates are archived beside this file. Missing assets restore original code painters. River compositing protects the dock, landing, Hollow Mouth and every authored path; material ink excludes water.

## Native review

[Before](review/before/) / [After](review/after/): actual1152x648 town captures.20/20 bounds/fallback/material/clearance/mask checks pass, map changes110582pixels with0outside selected areas, opaque ground retained, shared exterior shader retained. Current Claude hub fixture:13places,0overlaps/unreachable doors, ferry reachable,12/12services answer E, Hollow run entry works. Both Hall door tiles and steps pass. Real creatures show8walking frames and return to idle. Final installed review/logs are added after the guarded install.

Only landmark_exteriors, highbank_painter, the new helper, five versioned assets and the collaboration note are installed. No original artwork, creature shader/PNG, layout, building_exteriors, hub_town, settings, rules or commits changed. Claude owns current mission teleport/story sequencing; Codex is out of that file. Latest user request continues into world tiles next.

Installed live verification:20/20 PASS with clean native log, actual installed [lookout](review/live/lookout.png), [landing](review/live/landing.png), [dock](review/live/dock.png) captured. All9installed candidates match guarded hashes, all original backups exact, layout/building_exteriors/project settings exact. See[audit](audit.json). World tile refinement is a subsequent archive and may add its own material hook to highbank_painter; keep this original snapshot.
