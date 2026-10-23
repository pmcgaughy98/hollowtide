# Synthesis from the mech RPG session, for Hollowtide (Claude, 2026-10-20)

> **Moved here 2026-10-22 (Claude, Hollowtide session).** The mech session wrote this into `D:\dev\hollowtide`, an old copy
> of the repo last updated 2026-10-11, so no Hollowtide session saw it. The real repo is `C:\Users\pmcga\dev\hollowtide`.

Preston: "add everything you learned and can add to the synthesis for hollowtide claude session so they can synthesize
with you and skill up off you." Written by the Claude session working in `D:\dev\new-mech-rpg` over 2026-10-19 and 20:
six creatures rebuilt from Codex reference sheets, a part-by-part refine of each, Grok Build brought in for world and
UI art, Codex finishing alongside. What follows is what transfers. The mech RPG's own detail is in its
`.claude/skills/factory-pass/SKILL.md` and `docs/plan/creature-factory-2026-10-12.md` (newest sections at the end).

**Hollowtide rules still win.** Grok's role here (creature and attack rules, 2026-10-02) is unchanged by anything below.
The "Grok images for world and UI only" rule in part 3 is the mech RPG's; ask Preston before applying it here.

## 1. Measure, then build: the synthesis loop that worked
Preston's definition: use everything on hand (MCPs, connectors, installed skills, his references), measure the
references, build, look, score, repeat, and say what each tool contributed. In practice:
- **Equal-height grid comparison.** Crop ours and the reference to their content boxes, scale both to the same
  height, draw 10% grid lines, then read positions off the grid. Width to height alone hides where the difference is.
  An eye estimate was wrong once ("the torso is a quarter longer"; the grid said 4%, the gap was the tail and head).
- **Colour-family shares.** Count each family (red, gold, light grey, near-black under brightness 70 to 80) as a share
  of opaque pixels, ours against the reference. Twice this found the real issue (a kangaroo 31% near-black against 25%,
  a pangolin grey 21% against 16%) where the eye only said "muddy".
- **Region crops.** Rear, middle and front thirds side by side, zoomed: the part gaps show up per region.
- **Part attribution.** When a dark or pale area is the problem, find which part owns it before changing anything.
  The mech pipeline renders a piece-index pass; the pale slab everyone blamed on a rump plate was the thigh.
- **Speck count.** Single light pixels whose four neighbours are all 50+ darker: count them before and after a change.
  The white specks on the wolf came from the pixelizer's glint rule, not the bolts removed to fix them (38 before and
  after); capping the glints took them to 24.
- **Structure-only study of shipped sprites** (Zoids Legacy here; Mystery Dungeon and the rest for Hollowtide): never
  copy, read the rule. The useful one this time: limbs a step darker than the body, highlights only on top edges, so
  legs read as separate columns instead of one pale slab.

## 2. Three AIs, one repo: what kept work from colliding
- **Roles that worked:** Codex makes reference sheets and hand-finishes installed pixels (with locks and hash audits);
  Grok Build makes new world and UI images; Claude owns source, builds, installs and the checks.
- **Read the other agents' result files before committing.** On 2026-10-20 Codex finished three machines while Claude
  rebuilt them; one Codex finish was replaced by a later raw install and only showed up because the result files were
  read before the commit. Hollowtide's `AI_COLLABORATION.md` top entries play the same role.
- **After a source fix on an asset someone hand-finished, replace only what changed.** The mech repo's
  `tools/art/patch_frames.py` compares the old and new raw renders and writes only changed frames (a paw fix touched 2
  of 40 frames; the other 38 kept Codex's finish). Hollowtide's guarded installs follow the same idea.
- **Codex's audits catch real source bugs.** Its finish notes flagged paws drifting a row in an idle and a loose disc
  in a death clip; both were Claude's source errors (section 5). Ask Codex to list "source issues for Claude" in every
  result.
- **Locks:** an empty `CODEX_IN_PROGRESS` file per asset folder; every install script stops while it exists.

## 3. Grok Build: a new tool on Preston's PC
- Installed at `C:\Users\pmcga\.grok\bin\grok.exe` (v1.0.62), logged in on Preston's Grok Lite plan. Runs Grok 4.7
  with the **Imagine** image tool, reads image files, and runs headless:
  `grok -p "<prompt>" --output-format json --max-turns 8 --always-approve --disable-web-search`, from a working folder.
- **Run it in a scratch folder holding only its input image.** It reads whatever folder it starts in; one of Preston's
  own sessions ran from the Preston Hub. Never start it in the Hub (private context, AmFam rule).
- Each run reports a cost in its JSON: about $0.03 for text, $0.06 to $0.13 for one image. On the subscription login
  that should be plan usage, not a card charge; Lite's caps are unknown, so one image per run.
- **Prompt rules that held:** an honesty line first ("if a step fails or you cannot see the attached image, say so
  plainly"); attach one installed image as the style reference; "nothing from any existing franchise"; "no text,
  words or letters" said twice (it added labels when said once); name the stance and the materials outright.
- **Where it drifted:** creatures. Its model sheets came out as true flat side, front and back views (more useful for
  measuring than Codex's angled views), but an armoured gorilla stood upright, a mech bird grew real feathers, a
  kangaroo went cartoon. Preston's call for the mech RPG: Grok images for world and UI only.
- **Where it was good:** world and UI. A top-down canyon field in the existing grassland's style with the path joining
  at the right edge; a dark navy menu screen and pause panel in the dialogue box's style; cleaner flat versions of the
  title, field and opening screens. Preston installed six of seven.
- `tools/grok_image.py` (added with this note) does one run safely: scratch folder, the prompt rules above, the
  output and Grok's reply and cost saved beside it, and a `--reduce` step for part 4.

## 4. Generated art into a pixel game
- **Reduce to the slot, then compare:** box-downscale to the slot's exact size, median-cut to a fixed palette (32 to
  48 colours for a 320x180 screen, 16 to 32 for a UI panel), no dithering; show it beside the installed file. The
  old screens were pixel art already but carried 15,000 to 28,000 colours of soft gradients.
- **A pixel anchor** (from the pixel-art skill's idea): one short spec every generated asset follows: slot sizes,
  colour counts, outlines a darker shade of the area's own colour (never black), three tones per material, light from
  the upper left, no gradients or anti-aliasing. Put it in the task list the generator reads.
- **Check the scene, not just the file.** The canyon scene painted an opaque placeholder floor and a "(placeholder)"
  label over its background slot; the new art would have been hidden. Draw placeholders only when the art is missing.
- **Scrolling or tiling art:** compare the left and right edge columns (mean difference per row) against the current
  file before installing.
- **Back up originals outside the import tree** (the mech repo used `docs/art/2d/screens_pre_grok_2026-10-20/`), so
  Godot does not import the copies.

## 5. Source lessons that cost a round each
- **Any size change can push a sprite out of its render frame.** After stretching a body, check every view's content
  box against the frame edge; two diagonal views were clipped for a whole build before anyone looked.
- **Animation apexes move with proportions.** A leap that pivots about the body's middle rose 9 cm when the rear got
  30 cm longer; scale the pivot motion by the lever instead of raising the allowance.
- **A turned camera hides length and lifts the far end.** A 35-degree side view made a long tail and the hind feet
  float; the same stretch measured less than half its real effect at that angle. Re-measure after every change.
- **Hit-test surface details against the outermost layer.** A chest vent was placed on the core under the chest plate
  and stayed invisible for eight builds.
- **Duplicate names break part binding silently.** Two wheel pieces reused the ankle disc's names; Blender renamed them
  `.001`, the bone rule could not read that, and they came loose in the death clip. The bind audit's catch-all bone hid
  it. Grep for names a builder creates twice.
- **A rename can change a procedural pass everywhere.** The detail pass skips names containing words like "seam" and
  picks panel or vent by each part's place in a sorted list; renaming one ring changed every frame (and 232 triangles).
  Compare triangle or pixel counts after any rename. Hollowtide's painters keyed on sorted lists or name filters
  behave the same way.
- **Idle breathing moves feet unless they are held.** The fix plants feet against the body's bob and pitch in the
  stance solver; measure each foot's lowest row per frame, not the whole sprite's.
- **The shell refuses `rm -rf` on a variable path** and it is never needed: renders overwrite their files.
- **Long work in the background:** start Blender or render jobs in the background and wait for the completion notice;
  one Godot at a time (`tasklist | grep -qi "Godot_v4"`, since a plain "godot" also matches the MCP server).

## 6. What each source contributed this time
- Codex's returned reference sheets: the design targets per creature (proportions, parts, colour shares).
- Codex's finish audits: two source bugs found.
- Zoids Legacy sprites (structure only): the limb value rule.
- Grok Build: six installed world and UI images; creature sheets kept as reference only.
- The pixel-art skill: the pixel anchor idea.
- The piece pass, the bind audit and eight Godot checks: which part to change, and proof nothing broke.
