# Title layoutA redo,2026-10-28

Painted and ready for visual review; shared palette check is held for Claude. Nothing installed.

[New title3x](layout-a-2026-10-28/preview-3x.png) | [Before/after](layout-a-2026-10-28/comparison.png) | [Static canopy/wash preview](layout-a-2026-10-28/shading-preview-3x.png) | [Review sheet](layout-a-2026-10-28/layout-a-review/review_sheet.png)

- title.backdrop.highbank: SOURCE HOLD; C1 PASS, C2 PASS, C3 PASS, C5 FAIL, C9 PASS
- Separate real-source47palette diagnostic: all5checksPASS. This does not replace the shared C5FAIL.

36,980protected pixels unchanged, including menu, all4houses, left tree and river/road. Other56candidate images exact. Untouched raw, exact prompt and references are in layout-a-2026-10-28/.

Source issues for Claude:

- Published highbank_title strip has34colours; current title_highbank.gd PALETTE has47. Sixteen existing protected colours exceed C5tolerance20. Requantizing to34would change28019protected pixels. Exact source47strip is supplied for Claude under layout-a-2026-10-28/source-palette-contract/refs/palettes/highbank_title.png. No shared palette, registry or source file edited.
- Main prepared.png.check.json correctly records C5FAIL. The separate source-palette diagnostic passes; it is labelled and is not an install approval. Claude should fix/re-export the palette and rerun default prepare/validate before installation.
- Raw generation was larger than native. Native registration/recutting, source masks for the centred crown, grounded root and waylines, top pre-shade and quiet wordmark are documented in cleanup.json. Source bodies include precise coded detail and are not claimed as perfect generator output.
- Menu, houses, river/road and left tree are byte-exact. New canopy only replaces sky/far hills; Stack runs off top/right and comes to its plinth. Old small Tower/crook/lamp removed. Lamp anchor333,33is retired; door333,160and shade312,50are current.
- No in-game capture or visual approval. Static canopy/wash preview supplied; all review answers pending. No install.
- Other art still named in the handoff for later audit: Punchybun/Sparkjab dialogue faces, Team-page backdrop, Riftfin growth still and Sail Slash source cuts. Their old queue labels need comparison with current files; no claim all are still missing. Town giant-Tower assembly/new-part contracts remain pending.

Next safe step: re-export/fix highbank_title palette from the actual47source colours, rerun standard checks and then request Preston visual approval. Continue candidate-only scope; no automatic install.

## 2026-10-29: houses painted out (Claude)

Preston: "get rid of the buildings in title screen photo" (the Tower stands alone, his 2026-10-28 rule). Claude edited
the installed layout A: the four street houses and the bush after them (x 88 to 283, rows 141 to 181) are covered with
the lower woods from the strip west of them, laid in random 7 to 13 px chunks; the three waylines keep their ends and drop
onto tall timber posts on the lane at x 180, 242 and 254. Script: layout-a-no-houses/title_no_houses.py (seed 29).
Result: layout-a-no-houses/candidate.png, C1 to C9 pass (47 colours, 0 off-palette), installed (sha256 d5ef26821bde).
The brief in scripts/art/slots/title.gd and the placeholder painter (title_highbank.gd) now say no buildings and draw
lane posts. Checks: art_slots, opening_flow, ui_fit, opening_launch (window) all pass.
