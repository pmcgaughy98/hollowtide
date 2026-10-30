# cx-09-road candidate delivery, 2026-10-27

road.backdrop.sky: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C9 PASS
road.backdrop.far: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C6 PASS, C9 PASS
road.backdrop.river: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C6 PASS, C9 PASS
road.backdrop.mid: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C6 PASS, C9 PASS
road.backdrop.near: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C6 PASS, C9 PASS
road.ground.path: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C6 PASS, C9 PASS

Source issues for Claude:
- road.backdrop.sky: image_gen returned [1672, 941] raw; requested native [384, 216]. Untouched raw preserved; provided prepare_slot produced exact-size candidate.
- road.backdrop.far: image_gen returned [2172, 724] raw; requested native [384, 88]. Untouched raw preserved; provided prepare_slot produced exact-size candidate.
- road.backdrop.river: image_gen returned [1586, 992] raw; requested native [384, 24]. Untouched raw preserved; provided prepare_slot produced exact-size candidate.
- road.backdrop.mid: image_gen returned [2172, 724] raw; requested native [384, 112]. Untouched raw preserved; provided prepare_slot produced exact-size candidate.
- road.backdrop.near: image_gen returned [2172, 724] raw; requested native [384, 56]. Untouched raw preserved; provided prepare_slot produced exact-size candidate.
- road.ground.path: image_gen returned [1942, 809] raw; requested native [192, 80]. Untouched raw preserved; provided prepare_slot produced exact-size candidate.
- C6 measures RGB only. This delivery additionally checks exact RGBA endpoints for all five repeating strips and the foreground12-row alpha clearance (semantic-checks.json).
- Static art-only layer layout uses the current place_at positions; it is not an in-game capture, omits held far-town/Tower art, scene haze, props and actors.
- Generated opaque-black river padding and translucent hill holes were corrected in native inputs; raw originals and first-layout attempts retained.
- In-game capture absent: no candidate installed or runtime wiring changed; R4 remains pending Preston/Claude review.

No install. Answers pending Preston. Old Tower candidate excluded. New Tower batches await Claude's exported contracts. cx-10-road-far remains held pending its revised brief / approved crown.

## Final contract recheck, 2026-10-27

Registry 235abb6156b1 via candidate-only official export. All checks current; answers unchanged.

road.backdrop.sky: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C9 PASS
road.backdrop.far: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C6 PASS, C9 PASS
road.backdrop.river: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C6 PASS, C9 PASS
road.backdrop.mid: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C6 PASS, C9 PASS
road.backdrop.near: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C6 PASS, C9 PASS
road.ground.path: PASS; C1 PASS, C2 PASS, C3 PASS, C5 PASS, C6 PASS, C9 PASS


## Latest candidate revision, 2026-10-27

[Launch tint / road Tower clearance delivery](../launch-road-refresh-2026-10-27/DELIVERY.md) supersedes this slot image and its older art notes. Old candidate archived; review pending; no install.
