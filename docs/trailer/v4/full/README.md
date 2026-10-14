# Hollowtide full pitch V4 — October14,2026

[Play the share MP4](hollowtide_pitch_v4_share.mp4) · [Full-quality MP4](hollowtide_pitch_v4.mp4)

Completed under Preston's “go” after the checked Storage-only shot. Both outputs: **99.700s,1920x1080,30fps,H.264/AAC,2991 frames**. Full 55.1MB; share 23.6MB. No external post, upload, export or commit.

## What is in the edit

Nine new native Godot Movie Maker segments: flood partner conversation using the corrected shared portrait layout; title/Continue; mail call; Job Board with actual Parcel; painted rising water; defeat and information; installed Storage room with real walking/deposit/withdraw/exit; shrine growth; awake Warden stand-off and stone carried home. The party is Kithflare, Tallowroot and Cutbank Listener in the staged main shots. The recorder sets private scene/team/story state and uses an isolated user profile/save; this is **edited staged engine footage**, not an uninterrupted playthrough or balance test.

The27-shot edit also keeps three historical cutaways: `docs/design/videos-2026-10-11/01_storm_open.mp4` (start1.6s), `03_ruin_rises.mp4` (start0.6s), and `docs/trailer/v2/hollow.avi` (start28.3s). The cold storm retains game sound. The music bed is existing `assets/audio/music/hollow_flute.mp3` (“Hollow in the Cottonwoods”, Suno origin; exact model/version unknown). The existing generated village painting, proposed V3 text cards and OFL fonts remain. Visible generated assets and narrative retain their [AI inventory classifications](../../../pitch/ai-asset-inventory.md); the new filming/editing is AI-assisted GDScript/Python/Pillow/FFmpeg work, with **no new image/audio/video model output or paid calls**.

## Verification

- Native take3: **26/26 checks**, nine segments, clean finalized log;9680 raw frames/322.667s at1152x648/30fps. Engine prints RECORDED9679 before its final frame. [Raw AVI](raw.avi), [capture log](record.log), [frame markers/checks](shot-markers.json), [actual recorded source](recorded-script.gd), [exact native command/profile](capture-process.json).
- Source ranges resolve against measured markers and segment bounds, rather than V3's timing. [Timeline/source paths](edit-timeline.json); [exact encoder commands](edit-commands.json). Planned44 bars/99.622642s; encoded duration is measured above, including frame/audio rounding.
- Full and share streams decoded end-to-end without errors; codec/FPS/frame counts checked. [Verification](verification.json), [raw ffprobe records](media-probes.json), [QA commands](verification-commands.json). Audio sample peak **-1.8dBFS**, mean-19.7dBFS; mixer loudnorm target-18LUFS/true peak-2dB. No listening-session claim: audio verified through source continuity, mix commands and numerical analysis.
- All27 final shots reviewed at start/middle/end, plus native key frames: [middle1](qa/contact-middle-1.jpg), [middle2](qa/contact-middle-2.jpg), start/end sheets and individual samples in `qa/`; native scene PNGs in `native-stills/`. Shoreline capture framing keeps the party above the bottom HUD. End fade to black is intentional.
- [Installed recorder parse check](installed-parse.log) clean. Only existing V4 recorder updated; new V4 cutter added. All581 other protected source/media files exact, including V3/four GIFs/Storage-only media; [protection receipt](protection-receipt.json), [before hashes](sources/protected.json). No core game/rule/save schema change. Original V4 and V3 cutter plus pre-edit docs retained in `sources/`.

## Capture timing repairs and evidence

The first full take exposed old fixed mail/Warden windows ending before the scenes. Take2 completed both scenes but checked the return during its deferred transition. The recorder now waits for mail completion, advances actual typed pages with a hold, allows the Warden scene to finish, and waits six frames for the town scene. Take3 passes every check. A private shore placement/camera adjustment clears the HUD; no production camera or water rule changes. The first edit's visual review caught a black Continue fade; the final edit uses two measured title/town excerpts around that transition. That review edit remains at `D:/dev/hollowtide-full-pitch-v4-20261014/delivery`; final outputs came from `delivery-final`. Diagnostic logs/source snapshots are in `diagnostics/`; failed raw takes remain at `D:/dev/hollowtide-full-pitch-v4-20261014/take1` and `take2`, not published as successful captures.

## Reproduce without overwriting this deliverable

Installed tools: [recorder](../../../../tools/trailer/record_pitch_v4.gd), [cutter](../../../../tools/trailer/cut_pitch_v4.py), derived from preserved V3. Capture with the exact command in `capture-process.json`, substituting a fresh output/profile/review directory and the installed V4 script. Use Godot4.7.2, Compatibility renderer, Dummy audio, fixed30fps; set `HT_CAPTURE_REVIEW` to that fresh directory. Keep APPDATA/LOCALAPPDATA isolated. The recorder also supports `-- --storage-only`; the earlier dedicated [Storage shot](../storage-shot/README.md) remains untouched.

For a new cut, set `HT_PITCH_ROOT` to the live repo, `HT_PITCH_OUT` to a **fresh** directory, `HT_PITCH_RAW` to this `raw.avi`, and `HT_PITCH_MARKERS` to this `shot-markers.json`, then run the installed cutter with Python/Pillow and FFmpeg/ffprobe. It refuses existing final MP4 paths. `sources/` preserves the actual preparation/record/cut/verification drivers; their D-work paths are historical execution evidence. `_work` intermediate encodes remain in the D workspace and can be regenerated. The README's measured facts and JSON evidence supersede old timing assumptions.
