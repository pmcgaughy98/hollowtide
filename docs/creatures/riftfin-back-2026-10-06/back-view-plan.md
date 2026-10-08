# Riftfin: front study and back-view plan (Claude, 2026-10-06)

Preston: study Riftfin's front view and idle first, then plan the back view and its idle so the art is consistent enough for a publishable game that could stand next to Coromon or Nexomon. Measurements come from `tools/unity_port/sprite_study.py` and the frame study below; they are this project's numbers, not the other games'.

## What the front is

**Front still** (Codex's material-detail version, `502_riftfin_front_material_detail.png`): 224 px canvas, body 184 x 170, 51 colours, hard pixel edges (no soft alpha), a near-black outline (RGB 0,3,9) on 98% of the silhouette, even lighting (no strong light direction), 15% lone detail pixels.

**Front idle** (Retro Diffusion, 8 frames, 2.0 s; this is what you see on the opponent's side, not the still):
- Motion: the body sinks 0 to 6 art pixels and rises, feet planted; the head side dips more. 55% of the movement is in the middle of the body, the head half slightly more than the tail half.
- It is not the still: frame 0 matches the still on only 36% of pixels. It uses 46 colours (43 of the still's 51, plus 3 new).
- **Shimmer:** after allowing for movement, about 44% of pixels are redrawn every frame (Codex's Kithflare idle: 27%; the bend-built back idle: 10%, the measuring floor). The AI repaints scales and plates each frame, so at battle size the texture crawls. See `front_idle_head_closeup.gif`.

## Where the back views went wrong
| Back | Problem against the front |
|---|---|
| Old RD rotation | Lost the tail; tall ridge shape; lit from a different side (+23 brightness top-left); 33 colours |
| Take 1 (installed in Unity now) | Tail curls forward (Preston: wrong way); softer outline on only 69% of the edge; drawn smaller (160 x 155) |
| Fresh A | Right angle and tail; outline matches (99%); but darker overall (67 vs 85) and the spiked crest became a single fin |
| Fresh B | Crest and plates right; tail still curls forward |

The pattern: each generation gets some of the front right and drifts on the rest. Prompting alone will not hold all of it at once.

## The plan: the front is the rulebook, and every back is checked against it
1. **Lock the front's numbers** per creature: palette, outline colour, body size, brightness. `sprite_study.py` measures them; a back must land within tolerance.
2. **Shape** (paid, the only AI step): generate from the front only, at the front's canvas size (224, so nothing gets rescaled), with the research rules: 20 to 30 degrees off straight-behind so a cheek and eye show, the dorsal feature as the focus, and each creature's tail direction written out. Two takes, pick one, then at most one RD edit for a missing feature (for Riftfin: give Fresh A back its spiked cyan crest and flank plates).
3. **Finish** (free, scripted): map every pixel to the front's exact 51 colours, redraw the silhouette edge in the front's outline colour, and match brightness. Then the back cannot drift in colour or line from the front.
4. **Idle** (free): the matched bend, driven by the front idle's measured motion, so front and back breathe on the same beat; plus small secondary motion (barbels, tail fin).
5. **Front idle cleanup** (free, optional): rebuild the front idle the same way, using the still's pixels moved by the RD idle's motion, which removes the shimmer while keeping the movement. Only if Preston wants it; he rated the fronts and idles as good.
6. **Review**: front and back side by side, then in Unity play mode, before anything is installed.

## The honest bar for "publishable next to Coromon"
This pipeline makes every creature consistent with itself and with the rest of the roster (one palette rule, one outline rule, one motion rule). That is the part a solo AI pipeline can do well. Hand-pixelled games also have an artist cleaning every frame. The realistic route to that last step is a pixel artist's pass over final sprites, which the demo plan already aims to recruit for. It also answers the copyright point from the Gemini research, because human-reworked art is protectable.

## Riftfin next steps and cost
Edit Fresh A's crest ($0.18), then palette, outline and size lock, the matched idle, and a Unity play-mode check (free). Optional front-idle cleanup (free). RD balance $3.90.

## Update, same day: what actually worked (installed as `riftfin_back_v6.png`)
Generating a back from a text description (even with the front as a reference) reinvented the body every time; Preston: "looks like a new model". **Editing the front itself** with RD `image_edit` ("turn this exact same creature around...") kept Riftfin's own plates, crest, scales, X marks and build. Then a second edit lowered the tail to the left like the front's and opened the mouth like the front's (edit B of two). Then `finish_back.py` locked colours, outline and brightness, and `matched_back_idle.py` built the idle from the front idle's motion. Cost for these steps: $0.72 (two turn edits, two fix edits). This is the method for the other starters: **turn edit on the front, one fix edit, finish, matched idle.**
