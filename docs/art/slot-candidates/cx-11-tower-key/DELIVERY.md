# cx-11 Tower key, final contract delivery, 2026-10-27

town.building.hall.key: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C12 PASS

Native 216x360, 29 colors, binary alpha. Raw unchanged. References only, never install.

[Review sheet](review_sheet.png) | [Prepared preview](town.building.hall.key/prepared-preview-2x.png) | [Check report](town.building.hall.key/prepared.png.check.json)

Source issues for Claude:
- The official docs/design slots.json remains stale after a later route.gd edit (138737d30d2b vs live 235abb6156b1). The unchanged Godot exporter wrote the real current 185-slot snapshot into final-contract-check/slots.json. Unchanged Python tools used this snapshot path with normal freshness checks enabled. Claude should re-export the shared snapshot when ready.
- Key is references only and must never be installed. No key approval or completed Preston blockout walk is inferred.
- No capture.png was supplied; the review sheet explicitly leaves its in-game column empty. This is scripted asset validation, not visual approval or a runtime seam check.
- Raw generation is larger than native size. Raw was preserved; the provided prepare tool and explicitly authorized pixel cleanup produced exact native size.
- The approved key must travel with future part references and neighbour bands. cx-12 through cx-15 await Preston's walk/key yes; cx-10 awaits crown approval.

Preston answers remain pending. No install or game/registry edit. Previous stale-refusal logs remain as history.
