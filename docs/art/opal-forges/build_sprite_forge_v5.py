"""Build Hollowtide Sprite Forge v5, an Opal workflow (Claude, 2026-10-14).

Preston: "The forge hasnt been used in a while ... before you use them skill them up and make them current."
The original Sprite Forge (Drive id 1-WLZWZcCWFr8l5YTMOFUqBq-1Da2V-eY, September 2026) stays unchanged; this writes
a new workflow file beside it. What changed and why is in README.md here.
    python docs/art/opal-forges/build_sprite_forge_v5.py
"""
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
BRIEF = '{{"type":"in","path":"ask_user_creature_brief","title":"Creature Brief"}}'
PREV = '{{"type":"in","path":"bbeafb34-461a-4a26-b5e1-678b41362ae9","title":"Previous Stage or Same-Form Sprite (optional)"}}'
STYLE = '{{"type":"in","path":"ed1920be-47bc-4b80-9649-25fab22bd02c","title":"Style Anchor (optional)"}}'
IMAGE = '{{"type":"in","path":"node_step_cinderhide_sprite","title":"Render Hollowtide Creature"}}'

PROMPT = """Create exactly ONE Hollowtide creature image from the Creature Brief: one creature, or with VIEW: EIGHT one sheet of the same creature from eight directions. The brief decides species anatomy, pose, facing, palette and growth changes. Draw only that creature: no props, effects, extra anatomy, labels or text.

REFERENCE IMAGE MODES: For a new Stage I front, leave the Previous Stage image empty and draw from the brief. If the brief starts TASK: REDRAW, the Previous Stage image is this exact form: keep its recognizable body plan, face and markings while improving the named pose and rendering; do not grow it. For a Stage II or III front without TASK: REDRAW, the Previous Stage image is the stage just before it in the same line: keep face and eye identity, palette relationships and one or two signature motifs, then transform proportions, stance, limbs, head-to-body ratio and silhouette as the new brief says. Draw the new stage from scratch; never just enlarge it or bolt parts onto the old one.

VIEW: BACK: the Previous Stage image is this exact form's approved front, giving its identity but not its pose. The camera is behind the rear end and a little above; the creature walks away toward the upper right. Hindquarters and hind legs are nearest and largest. Show the side only at a steep angle; hide the face or show at most a thin sliver at the far upper right. Put each marking, plate and limb on its correct side and give each visible limb its proper foot. Match the front's scale, palette and baseline. Never mirror, grow or redesign the front.

VIEW: EIGHT: the Previous Stage image is this exact form's approved front; keep its design, colours, proportions and size in every view. One square sheet in a regular 3x3 grid, one complete creature per cell, the centre cell completely empty. Row 1, left to right: walking away toward the upper right (back three-quarter); straight back view; walking away toward the upper left (back three-quarter). Row 2: side profile facing right; empty centre; side profile facing left. Row 3: three-quarter front facing down and to the right; straight front view; three-quarter front facing down and to the left. Same camera height, same upper-left light, same scale and the same baseline row in every cell, neutral standing pose, generous empty spacing, nothing touching a cell edge, no overlaps, no grid lines.

Otherwise draw the front from the brief: a three-quarter view facing toward the viewer and to the right, camera a little above, the same angle as the Style Anchor.

HOUSE QUALITY STANDARD: Match the Style Anchor (the approved Tallowroot) for pixel craft and finish only: a substantial dark outline around the whole silhouette, a strong chunky silhouette, stepped shadow, midtone and highlight clusters that describe real volume, specific material texture inside the big forms, restrained bright accents and planted weight. Never copy the anchor's anatomy, markings or palette into another species. Mature grounded folklore; never cute, chibi or toy-like. A grown stage gains material structure and readable mass, not just size.

HOLLOWTIDE RULES: These are not Earth animals. Use the brief's palette as fantasy colours, not the real animal's natural colours. The Hollow essence means absence: hollows, gaps, missing pieces and quiet, never ghosts, spirits or glowing phantoms. Every body part the brief names must stay clearly visible and readable, because a creature's moves come from its body parts. Wild creatures carry no tools, bags or clothing unless the brief says it is a town character.

GAME SCALE: Draw on the game's native logical grid in one square image. Stage I: a 128x128 grid, the creature about 70 to 85 cells tall. Stage II: 144x144, about 85 to 100 tall. Stage III and kings: 160x160, about 105 to 125 tall. A same-form redraw, back or eight-view sheet keeps the reference form's apparent size. For VIEW: EIGHT the whole sheet is one grid, each cell a third of it, and each creature fills about 80 percent of its cell's height.

PIXEL ART: Every logical cell is one flat colour. Hard pixel edges, about 20 to 36 colours, shading in clean clusters with very few lone single pixels. Match the anchor's brightness; only the creature's own glowing parts are brighter. No gradients, blur, anti-aliasing, noise, subpixel detail or soft edges.

EDGES AND BACKGROUND: Every pixel is either part of the drawing or one exact flat pure magenta #FF00FF. No magenta inside the creature. Glows, sparks and smoke are solid opaque clusters of stepped colours; never let a glow or soft edge fade into the magenta. Keep every part, including tails, sparks and feet, at least 6 cells inside the canvas (or cell) edge; draw an effect smaller rather than cut it off. No transparency, checkerboard, floor, shadow, border, guides or text.

RIG-READY DESIGN: One intact organism, but with the head and neck, shoulder, hip, tail and limb roots visually legible, and clear overlap of which limbs and plates are in front. Feet load-bearing; markings on their correct sides. Never add armour, sacs or spikes only to show a joint.

ASSET ALIGNMENT: The lowest foot or body contact point sits on a steady baseline with at least six clear magenta cells below it. Output one image only.

CREATURE BRIEF: """ + BRIEF + """

PREVIOUS STAGE OR SAME-FORM REFERENCE IMAGE (optional): """ + PREV + """

STYLE ANCHOR IMAGE (optional; rendering quality only, never species anatomy): """ + STYLE

SHOWCASE = """Create a polished, responsive Hollowtide bestiary showcase for the single image described by the provided Creature Brief. Treat the image and brief as source data: do not alter the image, invent lore, stats, labels or growth facts, or substitute a different creature.

Display the complete generated image prominently at its original square aspect ratio, with image-rendering: pixelated; keep its original flat magenta background visible. Show the creature name, stage and essence only when the brief explicitly provides them. Include the full brief in a readable details panel.

Use a restrained field-guide look with deep charcoal, river-ink blue, bone paper and muted copper. Keep text high-contrast and responsive. Use only self-contained HTML and CSS; add no external images, fonts, scripts, links or guessed assets. Do not add nonfunctional download or export buttons.

Creature image:""" + IMAGE + """

Creature brief:""" + BRIEF + "\n"

INPUT_TYPE = "embed://a2/a2.bgl.json#21ee02e7-83fa-49d0-964c-0cab10eafc2c"


def inp(desc, modality, required):
    return {"description": {"role": "user", "parts": [{"text": desc}]}, "p-modality": modality, "p-required": required}


def graph():
    return {
        "metadata": {"intent": "", "tags": ["design", "creature-generator", "generation", "art", "creative", "sprite", "creature"], "parameters": {}},
        "assets": {},
        "title": "Hollowtide Sprite Forge v5",
        "description": ("Hollowtide creature fronts, growth stages, redraws, backs and eight-view sheets from roster briefs, "
                        "at the game's scale. Style anchor: the approved Tallowroot. Updated by Claude 2026-10-14; "
                        "the original Sprite Forge is unchanged."),
        "version": "0.0.5",
        "nodes": [
            {"id": "node_step_cinderhide_sprite", "type": "embed://a2/generate.bgl.json#module:main",
             "metadata": {"title": "Render Hollowtide Creature",
                          "visual": {"x": 700, "y": 350, "collapsed": "expanded", "outputHeight": 88}, "userModified": True,
                          "expected_output": [{"list": False, "description": "Hollowtide creature image on flat magenta.", "type": "image"}]},
             "configuration": {"config$prompt": {"role": "user", "parts": [{"text": PROMPT}]},
                               "generation-mode": "image-pro", "p-aspect-ratio": "1:1"}},
            {"id": "node_step_cinderhide_display", "type": "embed://a2/a2.bgl.json#module:render-outputs",
             "metadata": {"title": "Creature Showcase",
                          "visual": {"x": 1050, "y": 350, "collapsed": "expanded", "outputHeight": 88}, "userModified": True},
             "configuration": {"text": {"role": "user", "parts": [{"text": SHOWCASE}]},
                               "p-render-mode": "Auto", "b-render-model-name": "gemini-flash"}},
            {"id": "ask_user_creature_brief", "type": INPUT_TYPE,
             "metadata": {"title": "Creature Brief", "visual": {"x": 250, "y": 300, "collapsed": "expanded", "outputHeight": 88}, "userModified": True},
             "configuration": inp("Paste one roster brief (docs/creatures/creature-roster-draft.md): stage, essence, body plan and "
                                  "signature anatomy, face, pose and facing, temperament, palette, what must stay from the prior "
                                  "stage, and the avoid-list. Start with TASK: REDRAW, VIEW: BACK or VIEW: EIGHT for those modes.",
                                  "Text", True)},
            {"id": "bbeafb34-461a-4a26-b5e1-678b41362ae9", "type": INPUT_TYPE,
             "metadata": {"title": "Previous Stage or Same-Form Sprite (optional)", "visual": {"x": 680, "y": 200}, "userModified": True},
             "configuration": inp("Optional. Blank for a new Stage I. Stage II: that line's Stage I; Stage III: its Stage II. "
                                  "TASK: REDRAW, VIEW: BACK and VIEW: EIGHT: this exact form's approved front. Same line only.",
                                  "Image", False)},
            {"id": "ed1920be-47bc-4b80-9649-25fab22bd02c", "type": INPUT_TYPE,
             "metadata": {"title": "Style Anchor (optional)", "visual": {"x": 680, "y": 80}, "userModified": True},
             "configuration": inp("Optional: the approved Tallowroot (assets/sprites/arena/tallowroot/se.png). Rendering quality "
                                  "only: dark outline, clustered shading, material texture, planted weight. Never Preostmar.",
                                  "Image", False)},
        ],
        "edges": [
            {"from": "ask_user_creature_brief", "to": "node_step_cinderhide_sprite", "out": "context", "in": "p-z-ask_user_creature_brief"},
            {"from": "ask_user_creature_brief", "to": "node_step_cinderhide_display", "out": "context", "in": "p-z-ask_user_creature_brief"},
            {"from": "node_step_cinderhide_sprite", "to": "node_step_cinderhide_display", "out": "context", "in": "p-z-node_step_cinderhide_sprite"},
            {"from": "bbeafb34-461a-4a26-b5e1-678b41362ae9", "to": "node_step_cinderhide_sprite", "out": "context", "in": "p-z-bbeafb34-461a-4a26-b5e1-678b41362ae9"},
            {"from": "ed1920be-47bc-4b80-9649-25fab22bd02c", "to": "node_step_cinderhide_sprite", "out": "context", "in": "p-z-ed1920be-47bc-4b80-9649-25fab22bd02c"},
        ],
    }


if __name__ == "__main__":
    out = os.path.join(HERE, "hollowtide-sprite-forge-v5.json")
    s = json.dumps(graph(), ensure_ascii=False, indent=1)
    json.loads(s)
    open(out, "w", encoding="utf-8").write(s)
    print("wrote", out, len(s), "chars; prompt", len(PROMPT), "chars")
