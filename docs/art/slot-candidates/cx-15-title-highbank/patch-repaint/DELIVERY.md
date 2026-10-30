# Highbank title woods repaint, 2026-10-29

Candidate ready for Preston's review. **Not installed.**

- Candidate: [candidate.png](candidate.png), 384x216, 47 colours.
- [3x before/after of x0..310, y60..195](before-after-3x.png), before above, after below.
- [Full candidate at 3x](candidate-3x.png).
- Check line: `title.backdrop.highbank: C1 PASS, C2 PASS, C3 PASS, C5 PASS, C9 PASS`.
- C5: zero off-palette colours, exact shared 47-colour strip. C9: 190 orphan pixels, 0.23%, below 1% limit.

One approved built-in image_gen edit repainted the foliage. Its untouched 1672x941 output is raw.png, exact prompt in prompt.txt. The native pass reduces once, composites through edit-mask.png, snaps to the shared palette and joins isolated pixels with the existing cleanup rule. No mirrored or cloned foliage. This is generated painting with authorized pixel cleanup, not a claim of wholly manual brushwork.

7,427 pixels changed inside the allowed woods and former wire/post areas. All 70,660 pixels outside the stricter edit mask are exact. Great tree, hills and sky, left tree, Tower, root, reel, deck, doors and steps are protected; bluff face and river are unchanged. The woods have uneven overlapping crowns and restrained west-lit edges. No houses, cables or lane posts were added. audit.json records mask/preservation checks and hashes.

Ran the standard prepare_slot.py and validate_slot.py against the live registry. Validation initially failed C9 after reduction; cleanup passed on rerun. The validator refused the stale slots.json first, so the standard Godot render_slot_refs.gd --export-only refreshed metadata. That is the only watched shared-source difference among 114 files. No registry source, palette strip, installed asset, installed.json, gameplay or creature files changed. Existing root review approval is preserved in review-before.json and the new repaint is explicitly pending.

Source issues for Claude: none blocking. The placeholder still draws its old houses/waylines, as the repaint brief warned; it was not used as the visual target. The current palette strip already contains all 47 colours, so no palette rebuild was needed.

Unverified: no in-game capture or opening checks for this candidate because it remains uninstalled; Preston's visual approval is pending. Earlier opening checks belong to the previously installed image. No commit.
