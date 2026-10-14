# Parts kit test on Ballastak (2026-10-13, Claude)

Proposal art only. Nothing here is in `assets/`.

The question was whether Hollowtide can make new sprite variety from its own pixels, the way Zoids Legacy does
(one hand-drawn body, palette variants, parts placed at anchor points). Tool: `tools/art/parts_kit.py`.

## What is here

- `palette_clay/`, `palette_moss/`, `palette_night/`: Ballastak's eight views recoloured. Each colour family moves
  to a new hue, every pixel keeps its own lightness, the outline stays. The same rule runs on every view, so the
  eight directions stay matched. Scheme names and colours are proposals.
- `crest_from_switchhold/`: the spikes that stick up above Switchhold's back line, cut in each view and planted
  on Ballastak's back in the same view, joined into its outline.
- `contact_parts.png`: all of it next to the raw Ballastak.

## What it shows

- Palette variants look hand-made because they are: no pixel moves.
- Crest planting works on side and three-quarter views. On the straight front and back views the donor has
  only one or two spikes above its outline, so less carries over. It is a part swap, not a redesign: the result
  still has to be judged by eye.

## Rerun

    python tools/art/parts_kit.py variant <views_dir> <out_dir> clay|moss|night
    python tools/art/parts_kit.py plant <recipient_views> <donor_views> <out_dir> [--family flanges]
    python tools/art/parts_kit.py families <view.png>
