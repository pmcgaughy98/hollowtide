"""Build Hollowtide Evolution Forge v5.1 (v5 plus Preston's evolve-not-grow rule, 2026-10-14), an Opal workflow (Claude, 2026-10-14).

Preston: "Skill up and update evolution forge. Then evolve new flintram." The September original (Drive id
13O5Xm_9Go-u1cKn9TUCWAZhAXDe6OKbV) stays unchanged; this writes a new workflow file beside it. Same four inputs and
node ids, same Nano Banana Pro generate step and result page; the prompt is brought current (README.md here).
    python docs/art/opal-forges/build_evolution_forge_v5.py
"""
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
INPUT_TYPE = "embed://a2/a2.bgl.json#21ee02e7-83fa-49d0-964c-0cab10eafc2c"


def chip(path, title):
    return '{{"type":"in","path":"%s","title":"%s"}}' % (path, title)


BRIEF = chip("ask_user_evolution_brief", "Evolution Brief")
PREV = chip("ask_user_previous_stage_front", "Previous Stage Front / Pose Guide")
SAME = chip("ask_user_approved_evolved_front", "Approved Evolved Front")
STYLE = chip("ask_user_style_anchor", "Style Anchor")
IMAGE = chip("node_step_evolution_sprites_image", "Render One Growth View")

PROMPT = """Create exactly ONE image for the selected mode. Read the Evolution Brief first; its first line says VIEW: FRONT, VIEW: BACK or VIEW: EIGHT. Use its stage name, anatomy, facing, temperament, palette and avoid-list. Never mix modes in one run.

VIEW: FRONT (the creature EVOLVES into its next stage the way monster-collecting games do it: at a glance you can tell what it came from, yet it is clearly a different creature, never the old body with one part swapped). The Previous Stage Front is the stage just before, already approved. Ignore Approved Evolved Front. Draw only the new Stage II or III, in the brief's three-quarter pose facing toward the viewer and to the right, face visible.
KEEP only these anchors: the eye shape and face motif, the colour family, and the one signature feature the brief names (which must itself evolve, see below). CHANGE everything else on purpose:
- SILHOUETTE: filled in solid black and set beside the previous stage, the two must read as different creatures. Rebuild the body plan: torso depth and length, leg length and thickness, shoulder and hip height, neck, tail, and the outline's character (rounded becomes angular, low becomes high-shouldered, compact becomes long, or the reverse as the brief says).
- HEAD: change the head shape too: snout or jaw length, brow or crest, cheek and skull outline. Keep the eye motif recognizable but older (harder, narrower, set deeper).
- SIGNATURE FEATURE: it evolves into something bigger and new (a brow wedge becomes a full crest, a groove becomes a row of sockets); it is not the old feature with a new part beside it.
- COLOUR: same family, visibly shifted. Move the main colour's shade (deeper, richer or cooler), let an accent become a main colour or add the new colour the brief names, and change where colours sit on the body. Never reuse the previous stage's exact palette and colour layout.
- MATURITY: Stage I reads young (bigger head and eyes, shorter limbs, softer forms); Stage II reads adult and stronger (smaller head-to-body ratio, heavier jaw, more defined planes); Stage III reads powerful and settled.
- SIZE: clearly larger than the previous stage at the stage scale below.
Do not trace the previous pose, enlarge it, or bolt on armour, shoulder pads, sacs, straps, props, extra spikes or a bigger glow. Keep the number of load-bearing legs unless the brief changes it. Before output, check: different silhouette, different head, shifted palette, same eye motif and lineage.

VIEW: BACK: the Approved Evolved Front is this exact form; use its identity, not its pose. The camera is behind the rear end and a little above; the creature walks away toward the upper right. Rear end and hind legs are nearest and largest; the side shows only at a steep angle; hide the face or show at most a thin far-side sliver. Move each marking, plate and limb to its correct rear position; each visible limb keeps its own foot. Match the front's scale, palette and baseline. Never mirror, grow again or redesign. If the brief labels the Previous Stage Front a POSE GUIDE, copy only its camera angle, body placement and leg positions.

VIEW: EIGHT: the Approved Evolved Front is this exact form. One square sheet in a regular 3x3 grid, one complete creature per cell, the centre cell empty. Row 1, left to right: walking away toward the upper right (back three-quarter); straight back view; walking away toward the upper left. Row 2: side profile facing right; empty centre; side profile facing left. Row 3: three-quarter front facing down and to the right; straight front view; three-quarter front facing down and to the left. Use the SAME art-pixel size as the Approved Evolved Front: each cell is as wide as that front's whole canvas, so each view is as tall in art pixels as the front. Keep every plate, spike, groove and marking as the same separate piece in the same place on the body; never merge separate plates into one shell or smooth dome. Same camera height, upper-left light, scale and baseline row in every cell; neutral standing pose; generous spacing; nothing touching a cell edge; no overlaps; no grid lines.

HOUSE QUALITY STANDARD: the Style Anchor (the approved Tallowroot, or the line's own approved stage) controls pixel craft only: a substantial dark outline around the whole silhouette, large coherent colour clusters, stepped directional shading across material planes, specific material texture, restrained focal accents and planted weight. Never copy the anchor's anatomy, markings or palette into another species. Avoid pillow shading, parallel colour bands, single-pixel confetti, fuzzy edges and floating contacts. Mature grounded folklore; never cute, chibi or toy-like.

HOLLOWTIDE RULES: These are not Earth animals; use the brief's palette as fantasy colours, not a real animal's natural colours. The Hollow essence means absence (hollows, gaps, missing pieces, quiet), never ghosts or glowing phantoms. Every body part the brief names must stay clearly visible, because a creature's moves come from its body parts. Wild creatures carry no tools, bags or clothing unless the brief says it is a town character.

GAME SCALE: Stage II on a 144x144 logical grid, the creature about 85 to 100 cells tall; Stage III and kings on 160x160, about 105 to 125 tall. A BACK matches its front's size. Every logical cell is one flat colour, hard edges, about 20 to 36 colours, clean clusters with very few lone pixels. No gradients, blur, anti-aliasing, noise or subpixel detail. Match the approved creature's brightness; only its own glowing parts are brighter.

RIG-READY: one intact organism with readable head and neck, shoulder, hip, tail and limb roots, and clear near and far overlaps of limbs and plates. No artificial cut seams or detached parts. In BACK mode never invent a spike or flip a slab toward the head when the front points it rearward.

EDGES AND BACKGROUND: every pixel is drawing or one exact flat pure magenta #FF00FF; no magenta on the creature. Glows, sparks and smoke are solid opaque clusters of stepped colours; never fade a glow or soft edge into the magenta. Keep every part, tails and feet included, at least 6 cells inside the canvas (or cell) edge. The lowest contact point sits on a steady baseline with at least six magenta cells below. No transparency, checkerboard, floor or ground line, baked shadow, frame, text, effects or second form. Output exactly one image and no text. If the reference the selected mode needs is missing, ask for it rather than inventing continuity.

previous_stage_front: """ + PREV + """

approved_evolved_front: """ + SAME + """

style_anchor: """ + STYLE + """

evolution_brief: """ + BRIEF

SHOWCASE = """Create a clean Hollowtide creature result page showing exactly the ONE image produced in this run at nearest-neighbor scale (image-rendering: pixelated). Label it with the creature name and VIEW from the Evolution Brief. If VIEW: FRONT, show the Previous Stage Front as a small comparison thumbnail; if VIEW: BACK or VIEW: EIGHT, show the Approved Evolved Front as the matching same-form reference. Never display a second generated image or invent a summary. Keep the page dark, simple and readable, with neutral accents. The source image must remain unmodified and keep its flat magenta background for later conversion.

evolution_brief: """ + BRIEF + """

previous_stage_front: """ + PREV + """

approved_evolved_front: """ + SAME + """

style_anchor: """ + STYLE + """

evolution_sprites_image: """ + IMAGE + "\n"


def inp(node_id, title, desc, modality, y):
    return {"id": node_id, "type": INPUT_TYPE,
            "metadata": {"title": title, "visual": {"x": 250, "y": y, "collapsed": "expanded", "outputHeight": 88}, "userModified": True},
            "configuration": {"description": {"role": "user", "parts": [{"text": desc}]}, "p-modality": modality, "p-required": False}}


def graph():
    ins = ["ask_user_evolution_brief", "ask_user_previous_stage_front", "ask_user_approved_evolved_front", "ask_user_style_anchor"]
    edges = []
    for i in ins:
        edges.append({"from": i, "to": "node_step_evolution_sprites_image", "out": "context", "in": "p-z-" + i})
        edges.append({"from": i, "to": "node_step_creature_showcase", "out": "context", "in": "p-z-" + i})
    edges.append({"from": "node_step_evolution_sprites_image", "to": "node_step_creature_showcase", "out": "context",
                  "in": "p-z-node_step_evolution_sprites_image"})
    return {
        "metadata": {"intent": "", "tags": ["creative", "gaming", "creature-generator", "sprite", "creature", "art", "generation", "pixel-art", "design"], "parameters": {}},
        "assets": {},
        "title": "Hollowtide Evolution Forge v5.1",
        "description": ("Evolve approved Hollowtide creatures into clearly different Stage II and III forms at the game's scale, then make "
                        "true rear views and eight-view sheets from their approved fronts. Updated by Claude 2026-10-14; the "
                        "original Evolution Forge is unchanged."),
        "version": "0.0.6",
        "nodes": [
            {"id": "node_step_evolution_sprites_image", "type": "embed://a2/generate.bgl.json#module:main",
             "metadata": {"title": "Render One Growth View", "visual": {"x": 700, "y": 350, "collapsed": "expanded", "outputHeight": 88},
                          "userModified": True,
                          "expected_output": [{"list": False, "description": "One Hollowtide creature image on flat magenta.", "type": "image"}]},
             "configuration": {"config$prompt": {"role": "user", "parts": [{"text": PROMPT}]},
                               "generation-mode": "image-pro", "p-aspect-ratio": "1:1"}},
            {"id": "node_step_creature_showcase", "type": "embed://a2/a2.bgl.json#module:render-outputs",
             "metadata": {"title": "Show One Sprite", "visual": {"x": 1400, "y": 350, "collapsed": "expanded", "outputHeight": 88}, "userModified": True},
             "configuration": {"text": {"role": "user", "parts": [{"text": SHOWCASE}]}, "p-render-mode": "Auto", "b-render-model-name": "gemini-flash"}},
            inp("ask_user_evolution_brief", "Evolution Brief",
                "Paste one Stage II or III brief from docs/creatures/creature-roster-draft.md. Begin with VIEW: FRONT to grow a "
                "new stage, VIEW: BACK for the approved form's rear view, or VIEW: EIGHT for its eight-view sheet.", "Text", 300),
            inp("ask_user_previous_stage_front", "Previous Stage Front / Pose Guide",
                "For VIEW: FRONT, upload the approved front of the stage just before. For VIEW: BACK, leave empty unless the "
                "brief labels this input POSE GUIDE. Leave empty for VIEW: EIGHT.", "Image", 450),
            inp("ask_user_approved_evolved_front", "Approved Evolved Front",
                "For VIEW: BACK and VIEW: EIGHT, upload the approved front of this exact stage. Leave empty for VIEW: FRONT.", "Image", 600),
            inp("ask_user_style_anchor", "Style Anchor",
                "Optional: the approved Tallowroot (assets/sprites/arena/tallowroot/se.png) or the line's own approved stage, for "
                "pixel craft only. Never Preostmar.", "Image", 750),
        ],
        "edges": edges,
    }


if __name__ == "__main__":
    out = os.path.join(HERE, "hollowtide-evolution-forge-v5.1.json")
    s = json.dumps(graph(), ensure_ascii=False, separators=(",", ":"))
    json.loads(s)
    open(out, "w", encoding="utf-8").write(s)
    print("wrote", out, len(s), "chars")
