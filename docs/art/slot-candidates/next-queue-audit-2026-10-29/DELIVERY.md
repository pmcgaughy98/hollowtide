# Next art queue audit, 2026-10-29

Completed a read-only source audit after the approved trading-post installation. No new eligible batch: all16 CODEX_ART_TASKS batches have DELIVERY.md. The explicit skip rule remains in force; no batch was silently reopened, generated or installed.

Confirmed remaining source work:

1. **Sail Slash**: source sail_slash_sheet.png is256x256,16cells of64x64. Cells f04,f08,f12 are truly transparent. All16 runtime32x32 frames are nonempty; those three are exact preceding-frame holds, matching the already-completed FX-01 fix. Recutting cannot recover missing drawings. Several source cells also touch their cell edges; contact is measured in audit.json and is not by itself proof of a bad cut. New source drawings/motion approval are needed for further visual repair. No cutter or assets/sprites/arena file was executed for writing or changed.
2. **Hollow approach arch variant**: both modes call the same story.backdrop.hollow_entrance slot. The flood mode leads into mouth; the teleport mode leads into hollow. This confirms the previously noted shared painting, rather than a missing image file. The slot is still status keep,384x216, registered as finished existing art. No separate arch-variant slot or newly opened Codex batch is listed. Claude needs to settle the distinct variant brief/slot and export its references before a new generation batch.
3. **Home** is the next approved building idea (dug into the bluff), but the current exported contract still says cottage132x144 and describes a low river-stone cottage with a moss roof. It is not a burrow contract yet. Claude should wire/export/rebrief the keeper-shaped Home rather than regenerate the superseded cottage brief. Pouchbill's boathouse follows it.

Already prepared, not missing source work: Punchybun/Sparkjab face candidates and the held Riftfin showcase candidate. Their own visual approvals/wiring remain separate; this audit did not access the forbidden Riftfin redo folder or alter any creature art/data. The trading post is installed and has six post-install check passes; no additional approval inferred for other candidates.

Evidence: audit.json and sail-slash-source-audit.png. Read-only source pixel/dimension comparisons ran successfully. No Godot run, generation, spend, new code/assets, approvals, commit or cross-chat message in this audit. All writes are this report/evidence under docs/art/slot-candidates/.

Resume: add/reopen a non-delivered batch with a current brief and matching refs; obtain generation-spend approval where needed. Do not delete an old delivery marker to evade the skip rule. Existing pending batches can instead proceed through Preston's visual review, one named batch at a time.
