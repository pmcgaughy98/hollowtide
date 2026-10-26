# C7 / A3 input: shared controls and safe skip

October 26, 2026. **Input slice complete/installed.** Storm and soul use UI.INPUT_ADVANCE/UI.pressed; soul left/right supports saved keys and stick. Storm requires a second press after release, ignores echo/duplicate down, and shows binding-aware Skip / Press again to skip after4s or when armed. Title prelude/back and focused buttons accept shared inputs; `_ensure_menu_inputs` and its call are gone. Project pad confirm/back already exist. Saved bindings and the title's input map are preserved. Story/flash/settings/Continue/logo reveal unchanged.

Native85/85 input checks clean, plus28/28 through the real title/Storm/soul/flood/partner/playable riverbank with an explicit first-press gate assertion. Official opening_flow/soul_prologue/input_map/rebind4 PASS, exit0, known raw exit warnings retained. Private profiles/saves only. [Evidence, previews, originals, commands and diff](../ui/opening-input-2026-10-26/README.md).

First real-flow run exposed a null viewport after Storm detached; handled marking now happens before the scene change. Failed source/log retained, final input/flow/official tests rerun. No asset/generation/paid call/rules/Route1/message/commit. Four owned opening scripts only; concurrent Claude/Grok sources preserved. New proposed hint words: Skip; Press again to skip. C6 flag remains OFF.

Source issues for Claude:

- C7 landed; no runtime UI.HEAD users, and the shared constant is already gone in Claude's pass8 source.
- UI.pressed skips neutral stick events before edge bookkeeping. Owned opening handlers feed motion into the existing UI._motion_edge first, so centre/repress works. Fold that into the shared public helper later; shared UI source untouched by Codex.
- Live opening_flow_check still sends one Enter then waits for natural completion. Minimal proposal/opening-flow-two-press.diff is staged in the evidence; equivalent private driver passes28/28. Live active check untouched; please rebase/install that small update.
- No cross-chat message sent; this file and AI_COLLABORATION are the handoff.

Next A3 slice: white-out transitions. C8 card art/sounds/hint contrast, C9 top bar/shafts and Storm pixel soul still pending. Town/exterior art stays on HOLD until slots exist.
