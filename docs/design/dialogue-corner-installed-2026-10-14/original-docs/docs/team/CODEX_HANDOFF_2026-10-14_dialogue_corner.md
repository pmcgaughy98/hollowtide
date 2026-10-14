# Shared dialogue corner: Claude integration handoff

Task4 proposal is complete and checked. Apply only these two shared values in `scripts/ui/ui_style.gd` when integrating:

```gdscript
const PORTRAIT_INSET := 162.0
# Inside dialogue(), change the portrait position to:
portrait(c, Rect2(box.position + Vector2(42, -34), Vector2(120, 120)), portrait_tex, false, face)
```

The current values are 150.0 and (30,-34). Moving the portrait, name and text 12px right leaves the entire corner stud visible with 6px clearance, while retaining their current gaps. Same shared frame for every box; no PNG or builder changes. Standard prose width becomes 528px instead of540; native long-line paging checks pass. Vertical placement stays the same.

Live source has **not** been patched: task4 explicitly assigned applying proposed layout values to Claude. Avoid copying the whole snapshot over any later source edits. The complete proposal is a two-line diff.

Evidence: `docs/design/dialogue-corner-2026-10-14/README.md` and `candidate.diff`, `before/3_partner.png`, `after/3_partner.png`; all flood and gallery native assertions 10/10 on baseline and candidate, deterministic narration and shared-panel controls pixel-exact.814 existing protected files exact. Staged game at `D:/dev/hollowtide-world-refinement-20261008/project` can run the actual flood scene; drivers and source snapshots included.

No new frame, portrait asset, story, state, save, collision or training edits. Storage room integration is a separate pending handoff. Task5 AI inventory refresh is next. No message sent to another chat.
