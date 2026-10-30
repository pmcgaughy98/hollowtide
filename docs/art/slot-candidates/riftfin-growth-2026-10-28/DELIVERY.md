# Riftfin growth showcase still, 2026-10-28

H9-44 / LO6-23: current-design held still PREPARED and CHECKED. NOT INSTALLED. Preston approval pending.

Check line: riftfin growth still PASS 7/7 local checks (224x224, binary alpha, current palette only, clear edges, height at least Rimefin's idle union, common 2x scale, raw preserved). Native opaque box (23,30)-(201,196), height 166, 24 colours from current sw.png's 28. One frame, not an eight-frame animation.

Audit:
- scripts/ui/creature_idle.gd rightly excludes the old Riftfin idle: it is the pre-remake spiky body, not the current sleek blue catfish/eel.
- Actual evolution_scene._pick baseline chooses assets/sprites/arena/%s/small/sw.png. Rimefin 25px high, Riftfin 26, both at 3x: 75 -> 78px. Arena sw is 77 -> 74px; dungeon sw 21 -> 19px, so those would shrink on growth. This queue item remains real.
- Current Rimefin's eight-frame large-idle union is (17,12)-(182,167), height 155 (not merely f0's 141). The new Riftfin is 166, so the actual scene's HEIGHT 380 selects the idle family at a common 2x: 310 -> 332px.

Art:
- Built-in imagegen, current Riftfin s/sw as identity references. Rimefin front idle used for finish/framing only. Exact prompt in prompt.txt, untouched generation in raw.png. No old Riftfin design used as a generation reference.
- prepare_candidate.py fits native 224x224 with hard alpha and only current Riftfin colours. The generator returned 1254x1254; the native prepared.png is 224x224. Frame copy riftfin/f0.png is byte-exact with prepared.png.

Runtime verification:
- growth_preview.gd runs the unchanged production evolution_scene.gd. The candidate enters CreatureIdle._cache only in this process. Cached preference ConfigFiles avoid preference migration writes; no town/save code runs.
- It verifies the baseline family, then the candidate texture, idle selection, old/new bounds and 2x scale; all intro, whiten, trade, reveal and done stages complete. runtime-check.json and runtime.log preserve the result. Window run exited cleanly.
- current-fallback.png is a static production-sprite preview of the selected baseline family. candidate-intro.png and candidate-reveal.png come from the actual scene's auto run. This is art-selection/scene verification, not a shrine progression or save test.
- All 718 protected source/creature files remain byte-exact. No registry/shared script/asset/team-doc edit; no install_slot.py, real save, commit or message.

Source issues / next step for Claude after Preston approves:
1. Use this new f0 in a new showcase folder. Do NOT enable assets/sprites/creatures/idle_2026_10_05/502_riftfin, whose body is obsolete.
2. The latest queue asks for a growth still; this delivery is explicitly ONE held frame. CreatureIdle.frames already accepts a folder with only f0.png (it checks each f0..f7 path before loading). A new FOLDERS row for such a folder is sufficient to expose it without fabricating seven duplicate animation frames. Choose the production folder when integrating. This will also expose the still to other CreatureIdle callers; review those views when wiring.
3. No ArtSlots entry exists for creature showcase art, so prepare_slot.py / validate_slot.py are not applicable. No fake slot or registry override was introduced; use the local art checks and actual scene fixture here. Claude can rerun the full evolution check after integration, with check outputs redirected away from shared docs and saves isolated.
4. Current artwork is proposed for Preston's look; technical checks do not approve anatomy or pose. No full animation supplied or claimed.

Review: review_sheet.png, preview-3x.png, candidate-intro.png, candidate-reveal.png. Answer pending in review.json. The title palette hold and existing candidate approvals are unchanged.

Next independent audit: Sail Slash source cuts / Hollow approach arch current-file state. Do not repeat the old six-empty-frame hold as recovered source art.
