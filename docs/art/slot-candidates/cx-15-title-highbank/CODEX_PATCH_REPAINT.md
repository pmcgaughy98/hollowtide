# Codex: repaint the patched woods on the Highbank title (cx-15 follow-up, 2026-10-29)

**Slot:** `title.backdrop.highbank`, 384 x 216, installed at `assets/slots/title/backdrop/highbank.png`
(sha256 57a11306de1c). Palette `highbank_title`: the 47 colours in `PALETTE` of
`scripts/art/placeholders/title_highbank.gd` (strip `docs/design/placeholder-factory-2026-10-26/refs/palettes/highbank_title.png`),
48 at most.

**What Preston saw:** the woods where the four houses stood look cut out and pasted over a drawn scene. That is what
happened. Claude cloned the woods from x 28 to 88 and tiled them, mirrored, across x 88 to 268, y 140 to 188. The
result has mirrored repeats, a straight seam at y 140, and bushes standing in an even row. Then the three waylines and
their lane posts were painted out by filling from neighbouring pixels in x 170 to 305, y 72 to 182.

**The job:** repaint those two areas by hand so they belong to the painting.
- One continuous woods edge from the left woods to the Tower's root. Vary the tree shapes and heights. No repeated or
  mirrored shapes, and no hard horizontal seam.
- The same light as the rest of the painting, low from the west.
- The bluff top and path (rows 179 to 188) should match the stretch left of x 88.
- No buildings, no wires, cables or posts.
- Leave everything outside those two areas exactly as it is, pixel for pixel: the sky, the calm area behind the
  wordmark, the great tree, the hills, the Tower, the root, the reel ring and deck, the bluff face and the river.

**References** (all in `docs/art/slot-candidates/cx-15-title-highbank/`):
- the hand-drawn woods at x 0 to 88 in the installed picture;
- `layout-a-2026-10-28/`: before the patch, with the houses still in;
- `layout-a-no-houses/` and `layout-a-no-wires/` (with `unwire.py`): exactly what was patched.

The placeholder painter still draws the houses and waylines, so ignore it for this. The brief in
`scripts/art/slots/title.gd` (line 63) is current.

**Deliver:**
- `patch-repaint/candidate.png`, with `python tools/art/validate_slot.py title.backdrop.highbank <it>` passing C1 to C9;
- a 3x before/after of the band (x 0 to 310, y 60 to 195).

Do not install it. Preston's yes goes in `review.json`, then `install_slot.py`.

**Watch out:** something rewrote the palette strip from the placeholder's render this morning, probably
`render_slot_refs.gd`. That left 31 colours and made C5 fail. If C5 fails on colours you know are in `PALETTE`, run
`python tools/art/write_art_tasks.py --date 2026-10-26 --tower-refs`, which writes the exact strips again.
