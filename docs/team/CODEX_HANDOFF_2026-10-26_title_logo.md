# L7-20: one title logo at a time

October 26, 2026. **Installed and verified.** The fresh Claude pass 7 handoff adds section 10 to the task queue. Its first three title items are closed by existing C2-C4 work/current UI-fit; this slice completes item4, L7-20, ahead of the older Storm order.

`opening_flow.gd::_finish_boot` now fades the launch card fully away before revealing the menu wordmark, buttons and key hint over 0.25 s. Reduced motion makes an instant swap. The old prelude ends hidden at alpha0. Skip input stays consumed during the whole transition. The first focus grab is quiet and ends on the first menu button; later Options opens normally. No new player-facing words.

Native baseline36/36 clean measured 14 overlapping frames for normal automatic/Enter/A/mouse entry. Installed campaign66/66 clean measures **zero overlapping frames** in all six cases; reduced entry adds no fade. Automatic launch last visible frame67, menu first visible70, ready77; old menu was visible from54. Legacy normal/reduced20/20 also zero overlap, retaining its existing101-instance ObjectDB exit warning. Official opening_flow and ui_fit both PASS, exit0; known raw exit warnings retained. [Before/after, commands, frame logs, originals and diff](../ui/title-logo-2026-10-26/README.md).

Only this one shared launch method was edited. Every other baseline source/scene/data/dialogue/tool/project file is preserved unless a concurrent path is explicitly listed in the evidence receipt. Main/creature scripts, title C1 safe save, C6 disabled prompt, TeamState, shared UI, Storm and soul remain exact. No art/generation/paid call/rules/Route1/message/commit or real save.

The initial baseline fixture over-injected Enter after the reduced menu was ready; failed attempt archived, driver corrected before final baseline/installed checks. This was a fixture error, not a production input bug.

Still pending: C5 return-visit skip and splash auto-dismiss/key wording mismatch; the rest of LV-24; C6 wording choice (flag OFF); the C1 shared prefs recovery candidate is staged only. Next newest-queue slice is ACC-10 reduced-motion lightning (section10 item5), followed by ACC-14 soul flash (item6), then the Storm/soul C7-C9/white-out rows (item7). No cross-chat message was sent.
