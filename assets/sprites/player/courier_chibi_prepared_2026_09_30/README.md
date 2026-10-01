# Prepared original chibi courier

Preston selected this earlier chibi design. Codex cut all16 source poses, removed magenta, repainted magenta-contaminated outline pixels and aligned head/foot anchors. The full-detail source cuts are the main integration handoff.

## Main handoff: source_detail

- `source_detail/source_pose_atlas_4x4.png`:1088x1088,272x272 cells, rows DOWN, LEFT, RIGHT, UP and original columns0-3.
- `source_detail/{direction}/source_pose_00..03.png`: individual full-detail transparent poses.
- `source_detail/{direction}_source_poses_4x1.png`:1088x272 directional rows.
- Each cell has head-center x136 and lowest boot y260. Keep one common display scale. See CLAUDE_HANDOFF for placement.

## Optional32px map size study (not visually approved)

- `source_pose_atlas_4x4.png`:128x128,32x32 cells. Rows DOWN, LEFT, RIGHT, UP; original column order0-3.
- `down/`, `left/`, `right/`, `up/`: individual transparent32x32 frames.
- `{direction}_source_poses_4x1.png`:128x32 directional rows.

All versions are **source pose candidates**, not a repaired gait. The original side rows hold the same extended stride. See both contact sheets, review GIF and CLAUDE_HANDOFF in `docs/art/characters/chibi-courier-preparation-2026-09-30/` before choosing frames.

The32px set uses a shared32-color character palette but loses some face and goggle detail. Do not substitute it as an approved redraw. Full-detail source masters are also retained in the review folder. Avoid changing direction-specific scales; compare at actual play size before changing the current player.
