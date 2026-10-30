# Sprite pipeline research, 2026-10-28

Gemini Deep Research (in Chrome), given `research_brief.md` and nine evidence files from this folder. Full report:
Google Doc "2D Pixel Art Sprite Pipeline",
https://docs.google.com/document/d/1NKK-xK0Q-Yr9sktWZ3uCvCuC_DgCWJO-FzsMcT7WZw4/edit

## Claude's read of it

**Trust carefully.** It broke the same rules as the 2026-10-12 report (memory: gemini-deep-research-quality):

- It lists our own `judge_all_sets.txt` as a source, and plays our brief back as findings (it even names our
  `walk_lock.py`), even though the prompt said not to.
- Its pipeline thresholds (height within 5%, palette ΔE 3.5, body boil under 0.08, legs over 0.15, image-to-image
  strength 0.35 to 0.55) have no source. Treat them as invented.
- It recommends Retro Diffusion's "Clean Rotate" (RotSprite) for directions. RotSprite turns a sprite inside the flat
  picture; it cannot turn a creature to face another way. Wrong for eight views.
- Prices are unverified, and it calls the Codex image model "DALL-E 3 / GPT-4o".
- It used few firsthand GitHub accounts, mostly Reddit threads, vendor pages and link lists.

**Worth acting on (each still needs a check):**

1. **Mirroring flips the light.** Mirroring e to w, ne to nw and se to sw saves generations, but the upper-left light
   becomes upper-right on the west side. Either accept that (many games do) or add a relight pass. This is Preston's
   call, since the house rule says upper-left light in every view.
2. **SpriteCook's grid-exact model is text-only.** Its Pixel Engine Image model can't take a reference image; with
   references it switches to Nano Banana 2.1. That matches what we saw with Nano Banana 2.1 in October (source:
   spritecook.ai pages).
3. **Use 3D as structure, not as the final look.** Render a 3D proxy only for shape and angle, then do an
   image-to-image pass in the house style on top. This matches our own results: a raw render matched our drawn views
   at 0.56, while repainting with our sprites as references reached 0.82.
4. **Walks from keyframes, body locked.** Generate the contact and passing keyframes for each direction, hold the body
   still with a one-pixel bob on the down frames, and move only the legs. That is our walk_lock, plus keyframes.
5. **Unsolved: quadruped legs under about 48 px merge in the passing pose.** Expect to separate them by hand or in code.
   That fits the walk audit's facing and limb failures.
6. **PixelLab is strongest on two-legged bodies and drifts on quadrupeds.** Source: a single r/aigamedev thread;
   unverified.
