# Generating creature sprites

Working notes plus copy-paste commands. **This file is meant to be edited.** Every time a
generation comes out well or badly, change the template and add a line to the log at the bottom.

Written 2026-09-22.

> **Superseded for current still-sprite work (2026-09-25):** Preston chose Hollowtide Sprite Forge in Google Opal and stopped using Pixelorama. The PixelLab and Sprite Fusion account details, commands, and recommendations below are historical research; do not use them as the current generation workflow or spend PixelLab credits for new creature sprites. The live Opal setup uses Nano Banana Pro and is documented in `docs/forges/opal-sprite-forge-prompt-v2.md`. Its optional prior-stage image is wired to the prompt but has not been generation-tested. Raw output has a magenta background and still needs a not-yet-built 64×64 conversion before Godot import. PixelLab can be reconsidered for animation separately.

---

## Account reality, read this first

```
subscription: { type: generations, status: "trial", plan: null,
                generations: 16.8, total: 40.0 }
credits:      { type: usd, usd: 0.0 }
```

**You are on a free trial, not a paid plan.** 40 generations total, about 16.8 left as of writing.
Every call below spends one. Check before you burn a batch:

```bash
curl -s -H "Authorization: Bearer $PIXELLAB_TOKEN" https://api.pixellab.ai/v2/balance
```

Two separate wallets exist. `credits.usd` is pay-as-you-go and yours is empty. `subscription.generations`
is the trial pool and it is what everything below draws from. The paid Pixel Apprentice tier is
$12/month for 2,000 images, which is the fix when the trial runs out.

**`/generate-image-v2` (Pro) returns HTTP 402 "Insufficient resources" on this account.** Pro is
not available to you. Everything below uses the pixflux endpoint, which works.

---

## Previous tool selection: historical

Revised 2026-09-22 after Preston asked what skeleton animation is actually for. The earlier
advice in this file, PixelLab for creatures, was weighted wrong.

The former recommendation was Sprite Fusion for still art and PixelLab for animation and rotation.
It was superseded on 2026-09-25 by Preston's choice of Hollowtide Sprite Forge in Opal, recorded
at the top of this file.

The reason is selection, not model quality:

| | Images per generation | Cost of best-of-12 |
|---|---|---|
| Sprite Fusion generator | **12** | 1 action |
| PixelLab pixflux | **1** | 12 generations |

The Sprite Fusion sprite that looked better was a best-of-12 pick. The PixelLab ones were single
rolls. Matching that selection on PixelLab would cost twelve generations for one creature, which is
most of the remaining trial.

**The tools compose, so this is not a choice between them.** PixelLab's animation endpoints take an
arbitrary input image: `animate-with-skeleton` requires `reference_image`, `rotate` requires
`from_image`. Neither cares where the art came from. Sprite Fusion maxes at 64x64 and PixelLab's
skeleton wants 16, 32 or 64. **They agree at 64x64.** Working there keeps both doors open.

### What skeleton animation is worth, honestly

Mark the joints on a sprite, move them, the tool redraws the pose. One drawing becomes many poses.

It is a labour saver for animation, and **this project has no animation.** Every movement in
`battle_screen.gd` is a tween on a static sprite: the lunge slides the whole sprite, the squash
scales it, the flash tints it, the shake moves the screen. `docs/battle/game-feel.md` researched this and
concluded that responsiveness makes simpler art feel alive, and that with no animation budget the
tween juice is the highest-leverage lever available.

Animation is not on the scope order. Do not let a feature that is not scoped decide which tool makes
the art you look at today.

---

## The canvas question, settled at 64x64

Earlier today I told you picking PixelLab meant you could stay at 96x88. **That was wrong**, and
here is the evidence that changed it. All of it comes from PixelLab's own API schema.

| Feature | Size constraint | Source |
|---|---|---|
| `animate-with-text` | **exactly 64x64**, min 64 and max 64 | v2 OpenAPI `ImageSize` |
| `animate-with-skeleton` keypoints | "Warning! Sizes that are not 16x16, 32x32 and 64x64 can cause the generations to be lower quality" | API schema description |
| `create-image-bitforge` (web tiers) | tier 1 caps at 80x80 | reported, not schema-confirmed |
| plain image generation | 16 to 400 | v2 OpenAPI |

Text-based animation is **hard locked** to 64x64. Skeleton animation, the entire reason you chose
PixelLab over Sprite Fusion, is documented as degrading outside 16/32/64. 96x88 is supported by
exactly one thing, plain image generation, and nothing else in the pipeline.

**64x64 is the only size where every PixelLab path works.** It is also what Sprite Fusion supports,
what your original Cinderpelt prompt said, and a quarter fewer pixels to clean up by hand.

Cost of switching today: redoing Rimefin and Cinderhide. That cost only grows.

---

## What actually improved the output

One controlled comparison, same creature, one generation each.

**Attempt 1.** v1 endpoint, only `description`, `image_size`, `no_background`. Result: muddy, low
contrast, creature sits small in frame, silhouette unclear.

**Attempt 2.** v2 endpoint, full style parameters, 64x64. Result: bold readable outline, clear
silhouette, creature fills the frame. Palette drifted to grey steel instead of charcoal and rust.

### The rules that came out of it

1. **Always pass the style parameters.** The schema calls them "weakly guiding," but leaving them
   out is what produced the muddy first attempt. They are the difference between the two images.

2. **Never put the resolution in the description text.** Your original prompt opened with
   "pixel art monster sprite, 64x64". Saying "64x64" or "low res" or "tiny sprite" in the text makes
   the model draw chunky fake pixels instead of generating at that size. The size is already a
   parameter. Take it out of the words.

3. **Describing a palette in words mostly fails.** Attempt 2 asked for charcoal and rust and got
   grey steel. Use `color_image` instead: any small PNG containing the colours you want. PixelLab
   reads only the colours, not the content. This is the single biggest lever still untried.

4. **Reference images beat prompt text.** PixelLab's own Getting Started says the init image "is
   one of the best ways to improve the results you're getting." They publish no real prompting
   guide, which tells you where they think quality comes from.

5. **`style_strength` defaults to 0.** On bitforge, passing a `style_image` without raising this
   does nothing at all. 50 is documented as balanced.

6. **Keep the description to about 30 words.** Structure it as
   `[subject + 2 or 3 concrete details] + [pose] + [view] + [style anchor]`.

7. **`negative_description` is deprecated on pixflux** and live on bitforge. Do not count on it in
   the command below.

8. **`text_guidance_scale`** defaults to 8, ranges 1 to 20. 11 was used in attempt 2. Pushing it too
   high is documented to cause artifacts and over-saturation.

---

## The template

Fill the three bracketed slots. Leave everything else alone until the log says otherwise.

```
[SUBJECT: squat ember grub monster]
[FORM: blocky cubic body, short stubby legs, coal-lump belly, two small angular ear tufts]
[FEATURE: single bright molten ember core glowing in its chest]
bold chunky silhouette, creature fills the frame
```

Do not add: the resolution, "pixel art", "transparent background", "no anti-aliasing", "thick
outline". Those are all parameters below and repeating them in words costs you description budget
for no gain.

### Per essence

Palette belongs in `color_image`, not in the text. Build a small PNG with the colours you want and
point at it. Keep one per essence so a whole family reads as related, which is what
`THE_CONCEPT.md` asks for with "shared palette family per essence."

| Essence | Palette direction (yours to set) |
|---|---|
| Ember | charcoal, rust, ember orange, pale ash |
| Tide | not yet chosen |
| Stone | not yet chosen |
| Gale | not yet chosen |
| Nature | not yet chosen |
| Hollow | not yet chosen |

`Preston Hub\06 Creative Projects\Design\The_Turbo_Green.md` holds a measured palette of yours,
hue 167.5, mid tone `#42776B`, that has no home yet. It is a candidate for a family here.

---

## Sprite Fusion: REST, not MCP

There is no Sprite Fusion MCP server. `/api/mcp` and `/mcp` both return 404, and their docs describe
a plain REST API. **`sprite-ai.art` is a different company** and is not this.

Base URL `https://www.spritefusion.com/api/v1`. Key from Account → API keys, shown once.

```bash
export SPRITE_FUSION_API_KEY="sf_live_..."

curl -sS -H "Authorization: Bearer $SPRITE_FUSION_API_KEY" \
  https://www.spritefusion.com/api/v1/credits

curl -sS -N https://www.spritefusion.com/api/v1/generate \
  -H "Authorization: Bearer $SPRITE_FUSION_API_KEY" \
  -H "Content-Type: application/json" \
  --data '{"operation":"generate","prompt":"squat ember grub monster, blocky cubic body, short stubby legs, coal-lump belly, two small angular ear tufts, single bright molten ember core glowing in its chest, bold chunky silhouette","size":64}'
```

`/generate` streams Server-Sent Events and covers all five operations: generate, edit, style match,
eight directions, animate. `size` is a single number, so square only, which is another reason 64
is the right canvas. One generate returns 12 images.

Other endpoints: `POST /uploads` for large private inputs, `GET /credits` for the balance.

---

## Run it yourself

Set the token once per terminal session.

```bash
export PIXELLAB_TOKEN="your-token-here"
```

Then this whole block, editing only the `description`:

```bash
curl -s -X POST https://api.pixellab.ai/v2/create-image-pixflux \
  -H "Authorization: Bearer $PIXELLAB_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "squat ember grub monster, blocky cubic body, short stubby legs, coal-lump belly, two small angular ear tufts, single bright molten ember core glowing in its chest, bold chunky silhouette, creature fills the frame",
    "image_size": {"width": 64, "height": 64},
    "outline": "single color black outline",
    "shading": "basic shading",
    "detail": "low detail",
    "view": "side",
    "direction": "east",
    "no_background": true,
    "text_guidance_scale": 11,
    "seed": 20260922
  }' -o out.json
```

Then decode the PNG out of the response:

```bash
python -c "import json,base64; open('sprite.png','wb').write(base64.b64decode(json.load(open('out.json'))['image']['base64']))"
```

**Same seed plus same prompt gives the same image.** Change the seed to rerol1; keep it to iterate
on wording while holding the dice still. That is the difference between learning and gambling.

### Adding a forced palette

Once a palette PNG exists, add this field. The image is base64 of any PNG containing those colours.

```
"color_image": {"type": "base64", "base64": "<your palette png in base64>"}
```

```bash
python -c "import base64;print(base64.b64encode(open('palette_ember.png','rb').read()).decode())"
```

### Valid values, from the schema

- `outline`: `single color black outline`, `single color outline`, `selective outline`, `lineless`
- `shading`: `flat shading`, `basic shading`, `medium shading`, `detailed shading`, `highly detailed shading`
- `detail`: `low detail`, `medium detail`, `highly detailed`
- `view`: `side`, `low top-down`, `high top-down`
- `direction`: `north`, `north-east`, `east`, `south-east`, `south`, `south-west`, `west`, `north-west`

---

## Log

Add a row every time. This is what makes the template get better instead of resetting each session.

| Date | Creature | Endpoint | Size | Notable settings | Result |
|---|---|---|---|---|---|
| 2026-09-22 | Cinderpelt | v1 pixflux | 96x88 | none, description only | Muddy, low contrast, small in frame. Rejected. |
| 2026-09-22 | test | v2 pixflux | 64x64 | full style params, guidance 11, seed 20260922 | Bold outline, good silhouette, fills frame. Palette went grey instead of rust. |
| 2026-09-22 | test | v2 pixflux | 64x64 | same as above **plus `color_image: docs/art/palettes/ember.png`** | Palette fixed. Warm charcoal, rust and ember, glowing core. Only the palette changed between this and the row above, so `color_image` is confirmed as the cause. Best result so far. |

---

## Still unknown

- ~~Whether `color_image` fixes the palette drift.~~ **Confirmed 2026-09-22. It does, and it is the
  single biggest quality lever found so far.** `docs/art/palettes/ember.png` is the first one. Five more
  essences need palettes, and those colours are Preston's to pick.
- Whether bitforge with an approved sprite as `style_image` and `style_strength: 50` holds a
  consistent look across a whole roster. This is the roster consistency mechanism and it is untested.
- Good values for `text_guidance_scale`. No user data found anywhere; 11 worked once.
- Whether `create-character-v3` with `body_type: quadruped` and the animal templates beats plain
  image generation for creatures. It produces 8 rotations, which the plain endpoint does not.
- No firsthand reports from other developers on holding style across many sprites could be found.
  Reddit blocks crawlers and the rest of the search results were affiliate marketing.
