"""Writes the Codex and Grok art task lists from the art slot registry (Claude, 2026-10-26, placeholder factory
task-list lane; 00-BUILD-PLAN.md section 4, 03-spec-format.md sections 4.1 to 4.5).

    python tools/art/write_art_tasks.py [--date 2026-10-26] [--check-refs]
    python tools/art/write_art_tasks.py --stack <out.png> <top.png> <bottom.png> [...] [--frames 3,1,1]
    python tools/art/write_art_tasks.py --tower-refs

Reads slots.json through slot_registry (a stale export is refused), puts every Codex and Grok slot still on its
placeholder into one of the batches below (one batch is one area Preston can walk into), and writes
docs/team/CODEX_ART_TASKS_<date>.md and docs/team/GROK_ART_TASKS_<date>.md. A task can never disagree with the code:
a fix goes into scripts/art/slots/*.gd, the registry is exported again (render_slot_refs.gd), and this runs again.
It refuses when a generator slot sits in no batch or in two, when a batch is over its size (Codex 6 slots, Grok 8),
and, with --check-refs, when a reference picture for a task is missing.

--stack joins state stills top to bottom (the street lamp's unlit and lit stills) into the one raw picture
prepare_slot.py cuts back into state rows; each still is scaled to the first one's width first. --frames gives each
state's frame count (the route lantern's lit row has 3): the still is copied into that many cells of its row, so
prepare_slot.py cuts the same grid as the slot's sheet, and the frames are then made to differ by hand.

--tower-refs (Wayline Tower, 2026-10-27; TOWER_DESIGN.md section 11) runs after render_slot_refs.gd has rendered the
tower's slots and tower_parts_check.gd -- --render has written refs/wayline_tower/. It writes the exact palette strips
of the tower and the Highbank title (the colours their coded placeholders are snapped to; render_slot_refs' median
cut mixes the old Hall's colours into a locked family), puts that strip on each of their cards, and writes each body
part's <id>_band.png: its place in the assembled blockout with a 24 px band of the neighbours it meets.

Nothing here calls a generator. The balances below were read with each tool's read-only balance call; update them
by hand when they are read again.
"""
import argparse
import math
import re
import sys
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
import slot_registry as reg  # noqa: E402

DOC = "docs/design/placeholder-factory-2026-10-26"
REFS = DOC + "/refs"
CANDIDATES = "docs/art/slot-candidates"
TOWER_REFS = REFS + "/wayline_tower"   # tower_parts_check.gd -- --render writes the whole tower's pictures here
TOWER_KEY = "town.building.hall.key"
KEY_APPROVED = f"{CANDIDATES}/cx-11-tower-key/{TOWER_KEY}/prepared.png"   # the key after Preston's yes
EXACT_STRIPS = ("wayline_tower", "highbank_title")   # families whose strip is their placeholders' own colours
BAND = 24                          # px of neighbours shown round a tower part (one tile)
CARD_BACK = (0x1c, 0x1f, 0x1c, 255)   # render_slot_refs.gd's card colours and sizes
GRID_BACK = (0x3a, 0x3d, 0x40, 255)
CARD_H, STRIP_W = 192, 768
GROK_LOW, GROK_HIGH = 0.06, 0.13   # dollars per Grok Imagine image on Preston's Grok Lite login
PLANNED_GROK_IMAGES = 27           # build plan section 7, call 15

# Read-only balance calls, 2026-10-27 morning. No generation was run to get them.
BALANCES = [
    ("AutoSprite", "get_account", "15 credits. Connected, no sign-in needed. generate_asset_preview costs 1 credit a call; "
     "an 8-direction character pack costs 15. The 2026-10-26 sprite tool test recorded that its generate step needed a "
     "paid plan; not retested, since no generation call was made."),
    ("PixelLab", "get_balance", "$0.00 credits; trial plan with 0 plan generations left (51.2 used of 40); 16 daily bonus "
     "generations left today, refilled nightly (+5, up to 20)."),
    ("SpriteCook", "get_credit_balance", "3 credits, free tier, one job at a time."),
    ("Retro Diffusion", "get_balance", "$0.11 (the call also reports 50 credits; the free cost estimate reports 0 credits "
     "left). One RD Pro top-down prop at 48x56 is estimated at $0.18, so RD needs a top-up before any run."),
]

# What each alternative tool can and cannot do, from its own tool description (read 2026-10-27, nothing run).
TOOL_NOTES = [
    "**AutoSprite** (connected): makes characters (8-direction packs, spritesheets, portraits, poses) and single assets "
    "through generate_asset_preview: weapon, item, character, prop, effect or texture, in pixel, painted, flat, anime, "
    "comic or isometric style, 1 credit a call; pixelArt true gives a 16-bit sprite on a crisp grid in 32 colours. No "
    "style reference and no size control, so prepare_slot does the sizing and the palette. Never for creatures here.",
    "**PixelLab**: create_map_object makes one object on a clear background, canvas 32 to 400 px (clear only up to "
    "40,000 px of area); given a background_image (up to 192x192 for inpainting) it paints the object in that picture's "
    "style. create_building_kit makes matched floor, wall, doorway and stair pieces (square_topdown, tiles 16 to 96 px, "
    "walls 1 to 3 tiles, a colour cap). create_ui_asset makes 9-slice-style panels (192 to 688 px). The top-down tileset "
    "tools make two-terrain autotile sets (16 or 32 px tiles). pixelart_workbench is free: exact pixels placed by hand.",
    "**SpriteCook**: generate_game_art makes pixel or HD stills from text, with up to 14 uploaded style images "
    "(style_asset_ids), one reference or one picture to edit; aspect 1:1, 16:9 or 9:16; mode texture for seamless fills; "
    "the pixel-engine-image-v1 model draws at exactly the asked size from 16 to 128 px (sides up to 4:1) with the "
    "background removed, but takes no references. UI kits and tilesets too. Its 3 credits cover very little.",
    "**Retro Diffusion**: RD Pro styles take up to 9 reference images per run and draw from 12 px up to 256 px (a 16:9 "
    "scene is 256x144, which is not a whole-number step to 384x216). Needs a top-up first (see the balance).",
]

ARTICLE = re.compile(r"^(A|An|The|One|Rough|Sealed)\b")
STATE_HINTS = {"unlit": "the unlit still, the lantern glass dark",
               "lit": "the lit still, the same lamp with its lantern glass lit warm gold from inside",
               # The Wayline Tower's small set (gb-08), 2026-10-27.
               "dark": "the dark still, the same lantern with its glass unlit",
               "quiet": "the quiet still, the same object with dusty grey glass and no wick, for a route that went "
                        "quiet (an absence, never a ghost)",
               "strung": "the strung still, the post's small lantern lit warm gold",
               "waiting": "the waiting still, the same post with its small lantern unlit",
               "full": "the full still, the basket carrying an oilcloth parcel",
               "empty": "the empty still, the same object carrying nothing",
               "loaded": "the loaded still, the cradle carrying an oilcloth parcel",
               "oilcloth": "the oilcloth still, a parcel in oilcloth with a moss-green top, tied with twine",
               "paper": "the paper still, the same parcel in brown paper, tied with twine"}
TOWER_COMMON = re.compile(r"^Part of the Wayline Tower: .*?\(the game rims the tower\)\. ")   # Codex-only lead-in


def creature(form: str) -> str:
    box = reg.creature_box(form) if form else None
    return f"{form} ({box[1]} px tall, {box[0]} px wide, measured now from its town/s.png)" if box else form


def slot_states(s: dict) -> list:
    """State names in sheet order, top row first: the export's state_order (render_slot_refs.gd, pass 9 W10). slots.json
    sorts every object's keys, so "states" alone reads alphabetical (the wayline post's quiet, strung, waiting); this
    used to re-read the slot's .gd file to work round that."""
    names = list(s.get("states", {}).keys())
    order = s.get("state_order")
    if isinstance(order, list) and sorted(order) == sorted(names):
        return list(order)
    if len(names) < 2:
        return names
    raise ValueError(f"{s.get('id', '?')}: slots.json has no state_order matching its states; export it again: "
                     f"{reg.EXPORT_HINT}")


def ratio(w: int, h: int) -> str:
    g = math.gcd(w, h)
    return f"{w // g}:{h // g}"


def grok_aspect(w: int, h: int) -> str:
    """The nearest common aspect to ask Grok for; prepare_slot crops to the slot's own aspect after."""
    shapes = [(1, 1), (2, 3), (3, 2), (3, 4), (4, 3), (9, 16), (16, 9), (1, 2), (2, 1)]
    best = min(shapes, key=lambda a: abs(math.log((w / h) / (a[0] / a[1]))))
    return f"{best[0]}:{best[1]}"


def outline_rule(s: dict) -> str:
    return {"runtime_rim": "no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only",
            "drawn": "a 1 px outline in the object's own darkest tone",
            "none": "no outline"}.get(s.get("outline", ""), s.get("outline", ""))


def edges_rule(s: dict) -> str:
    e = s.get("edges", "none")
    sides = ", ".join(e) if isinstance(e, list) else e
    if sides == "none":
        return "touches no canvas side (keep a 1 px clear margin all round)"
    if sides == "all":
        return "may touch every canvas side"
    return f"may touch only: {sides}"


def alpha_rule(s: dict) -> str:
    return "fully opaque, no transparent pixel" if s.get("alpha") == "opaque" else "alpha 0 or 255 only (no soft edges)"


def tiling_rule(s: dict) -> str:
    t = s.get("tiling", "none")
    return {"h": "tiles left to right: the left and right edge columns must meet (C6)",
            "v": "tiles top to bottom: the top and bottom edge rows must meet (C6)",
            "hv": "tiles both ways (C6)"}.get(t, "")


def anchor_rule(s: dict) -> str:
    a = s.get("anchor", [0, 0])
    mode = s.get("anchor_mode", "")
    if mode == "foot" and s.get("kind") == "backdrop":   # a picture stood on a point of its bottom row (2026-10-28)
        return (f"the scene stands the picture by ({a[0]}, {a[1]}), a point on its bottom row, not the middle of its "
                f"content: keep the target's layout where it is (prepare_slot moves nothing painted at the exact size)")
    if mode == "foot":
        return f"foot row y={a[1]}: the art's lowest opaque row sits on it, centred on x={a[0]}"
    if mode == "left_middle":
        return f"placed by its left middle ({a[0]}, {a[1]})"
    if mode == "tiled":
        return "placed edge to edge as a repeating strip"
    return "placed by its top-left corner"


def rect(r) -> str:
    return f"x {r[0]}, y {r[1]}, {r[2]}x{r[3]}"


def alt_route(sid: str, s: dict) -> str:
    """The best other connected tool for this slot, or why none fits. No call is made; every spend waits for Preston."""
    w, h = s["size"]
    if sid == TOWER_KEY:
        return ("SpriteCook generate_game_art with edit_asset_id = the uploaded assembled blockout (aspect 9:16), 3 "
                "credits for one try; RD Pro stops at 256 px and PixelLab keeps a clear background only up to 40,000 "
                "px (this is 77,760). Codex stays the route: the key must keep the blockout's layout exactly.")
    if sid in ("town.building.hall.route_lantern", "town.prop.hall.basket", "town.prop.hall.cradle",
               "town.prop.hall.parcel"):
        return (f"PixelLab pixelart_workbench (free, exact pixels by hand): {w}x{h} is at or under the generators' "
                f"smallest canvases (PixelLab 32, SpriteCook 16, RD Pro 12), and its states and frames must share every "
                f"pixel but the part that changes. Fits better than Grok.")
    if sid == "town.prop.hall.wayline_post":
        return ("PixelLab create_map_object, style-matched against a 192x192 capture of Tower Rise round tile (2, 10), "
                "view high top-down, for the strung still; then the waiting and quiet stills from it with a mask over "
                "the lantern only, so all three rows share every other pixel; stack them with --stack.")
    if sid == "town.prop.hall.rise_stair":
        return ("PixelLab create_map_object, style-matched: a 192x192 capture of Tower Rise round tile (12, 9) as "
                "background_image with a mask over the 2 x 4 tile stair, view high top-down; then prepare_slot.")
    if s.get("frame_at") and s["palette"].get("family") == "wayline_tower":
        return ("none fits better: a tower part must meet its neighbours' seams and the approved key pixel for pixel, "
                "which no generator here does. If a small part stalls, PixelLab pixelart_workbench (free, exact pixels "
                "by hand) over its blockout cell.")
    if sid == "title.backdrop.highbank":
        return ("SpriteCook generate_game_art with edit_asset_id = the uploaded placeholder (aspect 16:9): a repaint "
                "that keeps the layout and anchors; prepare_slot steps it to 48 colours. RD Pro tops out at 256x144. "
                "Codex stays the route: the Tower in it must match the approved key.")
    if s["kind"] in ("building", "landmark"):
        return (f"PixelLab create_map_object, style-matched: a 192x192 crop of a town capture around the lot as "
                f"background_image with a rectangle mask over the footprint, view high top-down, selective outline. "
                f"At {w}x{h} it fits the 192 px inpainting box, so it is painted in the town's own ground and light; "
                f"then prepare_slot.")
    if sid.startswith("town.room."):
        room = "Item Shop" if ".shop." in sid else "Scroll Keeper cellar"
        floor, wall = (("warm plank floor", "shelved timber walls") if ".shop." in sid
                       else ("cool flagstone floor", "stone walls lined with scroll racks"))
        return (f"PixelLab create_building_kit (tile_type square_topdown, tile_size 24, wall_tiles 2, max_colors 48, "
                f"floor \"{floor}\", walls \"{wall}\"): one kit gives the {room}'s matched floor, wall and doorway "
                f"pieces for all five strips, and Codex assembles them to each strip's exact size. One kit per room.")
    if sid == "town.prop.chamber.rug":
        return ("PixelLab create_map_object (basic, 216x120 canvas, view high top-down, flat shading): 25,920 px keeps "
                "a clear background and it draws at the slot's size.")
    if sid in ("town.prop.chamber.window_wide", "town.prop.runners.window", "town.prop.runners.river_map"):
        return (f"SpriteCook generate_game_art with the pixel-engine-image-v1 model at exactly {w}x{h} (16 to 128 px, "
                f"sides up to 4:1, background removed): fits better than a resize, prepare_slot only snaps colours. "
                f"No references on that model.")
    if sid == "story.backdrop.dawn_bank":
        return ("SpriteCook generate_game_art with edit_asset_id = the uploaded night painting (waking_native.png), "
                "aspect 16:9: the same bank at dawn, which is what the brief asks; prepare_slot crops and steps it to "
                "48 colours. Fits better than painting from text.")
    if sid in ("road.backdrop.far", "road.backdrop.mid", "road.backdrop.near", "road.backdrop.river"):
        return ("none fits better: a strip that tiles left to right with clear sky above needs hand assembly. "
                "(SpriteCook texture mode tiles, but has no clear top; RD Pro stops at 256 px.)")
    if sid in ("road.ground.path", "story.backdrop.river_below"):
        return ("SpriteCook generate_game_art, mode texture (seamless), aspect 16:9, style_asset_ids = uploaded house "
                f"art; prepare_slot crops a {w}x{h} band and C6 checks the seam.")
    if sid == "road.backdrop.highbank_far":
        return ("PixelLab create_map_object (basic, 160x96 canvas, view side, lineless, flat shading): a silhouette "
                "on a clear background at the slot's size (15,360 px).")
    if s["kind"] == "backdrop":
        return ("SpriteCook generate_game_art (aspect 16:9, pixel true, bg_mode include, style_asset_ids = uploaded "
                "house art such as waking_native.png); prepare_slot centre-crops and box-downscales. RD Pro tops out "
                "at 256x144 and PixelLab makes objects, not scenes.")
    if sid == "town.lamp.post":
        return ("PixelLab create_map_object, style-matched against a 192x192 town capture (unlit), then the lit still "
                "from the unlit one with a custom mask over the lantern box only, so both rows share every other "
                "pixel; stack them with --stack.")
    if sid in ("town.prop.crates", "town.prop.barrel", "town.prop.planter", "road.prop.lost_parcel"):
        return ("AutoSprite generate_asset_preview (category prop, pixelArt true, 1 credit of 15): a single object on a "
                "crisp pixel grid. No style reference, so prepare_slot snaps it to the slot palette. Cheaper than Grok.")
    if sid in ("town.prop.fence_h", "town.prop.fence_v", "town.prop.fence_corner") or sid.startswith("town.prop.sign_"):
        return ("PixelLab pixelart_workbench (free, exact pixels by hand): a 24x24 tiling span or a pictogram board is "
                "easier to place pixel by pixel than to generate, and C6 needs the span's edges to meet.")
    if sid == "title.hud_piece.menu_cursor":
        return ("PixelLab pixelart_workbench (free): 8x9 is under every generator's smallest canvas (PixelLab 32, "
                "SpriteCook 16, RD Pro 12); placed by hand like the UI frames. Fits better than Grok.")
    if sid == "dungeon.prop.stairs_sealed":
        return ("PixelLab create_map_object, style-matched against a 192x192 capture of a painted ruin floor, mask over "
                "one tile, prepared 32 to 24 px. (RD Pro with ruin captures as reference_images fits too, at $0.18, "
                "after a top-up.)")
    if ".shop." in sid or ".scrolls_cellar." in sid:
        return ("PixelLab create_map_object, style-matched against a 192x192 capture of the Home interior (the shop and "
                "cellar rooms are still placeholders), view high top-down; then prepare_slot.")
    return (f"PixelLab create_map_object (basic, {max(32, w)}x{max(32, h)} canvas, view high top-down, single colour "
            f"outline), then prepare_slot box-downscales to {w}x{h}.")


CODEX_BATCHES = [
    {"id": "cx-01-buildings", "tag": "town", "title": "Highbank's buildings",
     "note": "The v2 canvases from the building template at BUILDING_SCALE 1.0 (Preston call 1's default). v1, today's "
             "town, keeps the old PNGs at rect x 24 and does not change; these show only with Highbank v2 on. "
             "**The Wayline Tower left this batch on 2026-10-27** (Preston's default): its one-picture slot, the 300x576 "
             "tower, is superseded by the parts plan (cx-11 to cx-14 and gb-08), and `town.building.hall` is now the "
             "tower's 300x192 depot in cx-12. The old candidate in "
             f"`{CANDIDATES}/cx-01-buildings/town.building.hall/` stays where it is, on HOLD, as a record: do not "
             "deliver, review or install it.",
     "checks": "hub_town building_template art_slots",
     "slots": ["town.building.storage", "town.building.scrolls"]},
    {"id": "cx-02-lots", "tag": "lots", "title": "Lots before they open",
     "note": "Lots A and B on Highbank Street, and C, D and E in the East Quarter (working label; empty and closed, "
             "only the debug scene reaches it). No beat opens a lot yet.",
     "checks": "hub_town building_template art_slots",
     "slots": ["town.building.lot_before_stall", "town.building.lot_before_shop", "town.landmark.lot_before_plot"]},
    {"id": "cx-03-shop-room", "tag": "shop", "title": "The Item Shop's room (14x10 tiles)",
     "note": "Its door in Highbank stays shut (Preston call 5); the room is reached only by the debug scene and checks.",
     "checks": "town_room art_slots", "slots": ["town.room.shop.floor", "town.room.shop.north", "town.room.shop.south",
                                                "town.room.shop.west", "town.room.shop.east"]},
    {"id": "cx-04-cellar", "tag": "cellar", "title": "The Scroll Keeper's cellar (12x9 tiles)",
     "note": "Down the Scroll Keeper's south door (Preston call 4); the door stays shut for now (call 5).",
     "checks": "town_room art_slots",
     "slots": ["town.room.scrolls_cellar.floor", "town.room.scrolls_cellar.north", "town.room.scrolls_cellar.south",
               "town.room.scrolls_cellar.west", "town.room.scrolls_cellar.east"]},
    {"id": "cx-05-room-fixes", "tag": "rooms", "title": "Four Tower room props drawn at a stretched size",
     "note": "Today each shows a nearest resize of an older file (its style_ref). A file at the drawn size ends the "
             "stretch. The rooms keep their ids: the chamber and the runners' room inside the Wayline Tower.",
     "checks": "town_room hall_floors art_slots",
     "slots": ["town.prop.chamber.rug", "town.prop.chamber.window_wide", "town.prop.runners.window",
               "town.prop.runners.river_map"]},
    {"id": "cx-06-title", "tag": "title", "title": "The launch card's night",
     "note": "Codex's own launch files; Codex wires them (sites below).",
     "checks": "opening_launch opening_flow art_slots",
     "slots": ["title.backdrop.launch"],
     "wire": [
         "`scripts/opening_flow.gd:27` `ink.color = Color(\"#18172c\")`, the launch card's flat fill: draw "
         "`ArtSlots.texture(\"title.backdrop.launch\")` at 3x under the logo only when `ArtSlots.source(...) == \"file\"`, "
         "and keep the fill otherwise, so today's card is unchanged. The registry's tint and note name that same "
         "`#18172c` since pass 9 (they said `#161f1b` at :21, the dc37005af text, until then).",
         "**Done by Claude, 2026-10-27; nothing to wire here.** Preston: the title's town must be a real place in the "
         "game, so the title backdrop is now Highbank with the Wayline Tower prominent. `scripts/creature_opening.gd:10` "
         "`const BACKDROP := \"title.backdrop.highbank\"` and `:43` `town.texture=Slots.texture(BACKDROP)` draw it at 3x "
         "(its art is batch cx-15). The village is retired from the title: `title.backdrop.village` stays a keep row "
         "and today's file (`assets/sprites/menu/creature_village_2026_10_09.png`) is kept untouched as the reference "
         "for a future town on another map. Do not paint over or replace it.",
         "`scripts/main_menu.gd:357` `_cursor = Polygon2D.new()`: a Sprite2D of "
         "`ArtSlots.texture(\"title.hud_piece.menu_cursor\")` when its source is \"file\", the Polygon2D otherwise; "
         "the bounce stays coded. The cursor's art is Grok's (GB-menu-1)."]},
    {"id": "cx-07-story", "tag": "story", "title": "Story backdrops: the dawn bank and the river below",
     "note": "The dawn bank is already wired (mouth_escape.gd asks waking_bank.gd dawn_image(); until a file is "
             "installed the night painting under today's dawn grade is its placeholder, so the screen is unchanged).",
     "checks": "mouth_escape soul_prologue art_slots",
     "slots": ["story.backdrop.dawn_bank", "story.backdrop.river_below"],
     "wire": [
         "`scripts/soul_prologue.gd:399` `c.draw_rect(Rect2(x, y, 2, 1), ...)`, the river's 2x1 dashes (line 267 at "
         "dc37005af): tile `ArtSlots.texture(\"story.backdrop.river_below\")` when its source is \"file\", the dashes "
         "otherwise; the shimmer stays coded."]},
    {"id": "cx-08-stages", "tag": "stages", "title": "TEAM page stages for the six essences without one",
     "note": "party_screen.gd keeps the plain parchment until a file is installed. 448x252, drawn at 1x.",
     "checks": "ui_fit field_menu art_slots",
     "slots": ["ui.backdrop.stage_blight", "ui.backdrop.stage_hollow", "ui.backdrop.stage_ice",
               "ui.backdrop.stage_loam", "ui.backdrop.stage_murk", "ui.backdrop.stage_sinew"]},
    {"id": "cx-09-road", "tag": "road", "title": "The road back up to Highbank: the trail's layers", "group": "road",
     "note": "Added after the plan's counts (lane S, Preston's canon change 4, 2026-10-26). The walkable road scene "
             "draws these as parallax layers; each layer's note gives its scroll rate and haze.",
     "checks": "road mouth_escape art_slots",
     "slots": ["road.backdrop.sky", "road.backdrop.far", "road.backdrop.river", "road.backdrop.mid",
               "road.backdrop.near", "road.ground.path"]},
    {"id": "cx-10-road-far", "tag": "far", "title": "Highbank and the Wayline Tower far off, and the Tower's sky",
     "group": "road",
     "gate": "GATE: road.backdrop.vista, road.backdrop.highbank_far and story.backdrop.tower_sky are open now (Preston, "
             "2026-10-28: fix the cliff tree and tower 'so codex can go ham').",
     "note": "Added after the plan's counts (lane S). Canon 2026-10-26: on the road back, Highbank and the Tower show on "
             "the horizon, faded with distance (the scene adds the haze, so paint them clear); the Tower scene pans up "
             "against tower_sky. **Re-briefed 2026-10-27 for the approved Tower, now superseded for all three by the "
             "2026-10-28 re-brief that follows** (TOWER_DESIGN.md section 9): the briefs and anchors were then new (highbank_far's beacon at (92, 14) with a cable from wayline_top to "
             "wayline_end; the vista's beacon at (268, 36) with the Tower about 176 px tall; tower_sky is sky only, no "
             "tower). Each far Tower is painted for its own size, not shrunk from the big one. The refs were rendered "
             "again from the new coded far views (TowerParts.paint_far); anything drawn to the 2026-10-26 one-picture "
             "tower is superseded. **Re-briefed 2026-10-28 for the vast-scale design** (docs/design/vast-scale-2026-10-27/"
             "VAST_SCALE_DESIGN.md): road.backdrop.vista now shows the whole 480-tile Wayline Tower standing alone (no "
             "other buildings by it), the great tree as the title paints it (crown centred on its trunk, leaf clusters, "
             "morning colours) and Highbank's roofs set back in a clearing west of the Tower. Paint to its placeholder, "
             "which is the vast-scale mock (final/slot_vista.png); its beacon is now (286, 11) and its five house lamps "
             "moved, so the 176 px tower and the beacon at (268, 36) above are superseded for the vista. "
             "road.backdrop.highbank_far is re-briefed the same way: from 3,000 tiles down the river, the great tree as "
             "the title paints it and the whole Tower (70 px, vane row 5, foot row 75) standing alone over a forest "
             "band on valley mist, Highbank's roofs in a clearing west of it, one wayline from the Low Reel down to "
             "them. Paint to its placeholder, the vast-scale mock (final/slot_highbank_far.png); its foot anchor (the "
             "picture's bottom row under the Tower's axis) is now (104, 95), its beacon (105, 7) and its wayline "
             "(101, 70) to (84, 73), so the earlier flat-topped bluff of roofs and the beacon at (92, 14) above are "
             "superseded. story.backdrop.tower_sky is re-briefed to the vast-scale hold: the sky "
             "behind the Tower's top at first light, a flat sea of cloud under the Waiting Lamp (horizon y 146) and "
             "the great tree's crown cap breaking it on the left, the title's tree in the morning's greens. Paint "
             "to its placeholder, the vast-scale mock (final/slot_tower_sky.png); its beacon anchor (192, 127) is "
             "where the scene's lamp stands at the hold, cool blue sky round it. The banded dawn with the top two "
             "thirds empty is superseded. Still sky only: the scene draws the Tower, and the climb runs up today's "
             "30-tile tower until the town's Tower is redesigned. Light: all three take the low dawn sun from the "
             "east, on the right, as their briefs say. None of the three waits on the town's Tower batches (cx-11 to cx-14) or on their "
             "far_70 and far_170 reads: if Preston's walk of the Tower changes its look, the far Towers get a "
             "touch-up pass then. Delivery (later on 2026-10-28): prepare_slot.py keeps a picture painted at exactly "
             "the slot's size pixel for pixel, so the anchors hold; each of the three has its own palette strip, every "
             "colour its target uses (vast_far, vast_vista, vast_sky), and the far view and the vista allow more lone "
             "pixels (C9) than the usual 1%, as their targets have. Each target passes validate_slot.py as it stands.",
     "checks": "road tower_reveal art_slots",
     "slots": ["road.backdrop.highbank_far", "road.backdrop.vista", "story.backdrop.tower_sky"]},
    # The Wayline Tower, approved 2026-10-27 with Preston's defaults (TOWER_DESIGN.md section 11): judge early, paint
    # late. The tower is a v2 building, so its checks run with HT_HIGHBANK_V2=1 and again without (v1 must not move).
    {"id": "cx-11-tower-key", "tag": "key", "title": "The Wayline Tower's style key (refs only)", "group": "tower",
     "gate": "GATE: paint after Preston has walked the coded blockout (Tower Rise with HT_HIGHBANK_V2=1, and "
             "scenes/debug/building_lineup.tscn) and judged its 25% flat fill (TOWER_DESIGN.md section 11, step 1). "
             "His yes on this key opens cx-12 to cx-15 and gb-08.",
     "note": "One low-detail pass over the assembled blockout at half size (432x720 shown as 216x360). Preston approves "
             "the palette, the light and the eras here once; every part is then painted to it. The key is never "
             "installed and never placed. slots.json carries this slot from 2026-10-27, so prepare_slot.py and "
             "validate_slot.py accept it; a draft made before that export still goes through both and the review.",
     "checks": "tower_parts art_slots",
     "install": "do not install: the key is refs only. After Preston's yes, "
                f"`{KEY_APPROVED}` is the approved key that every later tower batch carries.",
     "slots": [TOWER_KEY]},
    {"id": "cx-12-tower-foot", "tag": "foot", "group": "tower",
     "title": "The Wayline Tower's foot: depot, Route Board gable, root, yard and rise stair (seen every day)",
     "gate": "GATE: nothing here is painted until Preston has walked the blockout and approved the key (cx-11).",
     "note": "What the player sees every day at the doors. The depot keeps the old Hall's id, door box and foot, so the "
             "doors and their checks do not change. Paint each part to the approved key, against its band (the "
             "neighbours it meets), at exactly its size. ROOT CHANGE (Preston, 2026-10-27, yes): the Tower's root is "
             "one root of a separate, massive great tree, so it must read as arriving from off-frame, thickest at the "
             "ground. Redo root_foot once before install: no flared base or footing stone; run it out through the west "
             "edge at full girth (34 to 40 px), half buried under a turf lip. Full note and paint-over: "
             "docs/design/great-tree-2026-10-27/CODEX_ROOT_NOTE.md. The other four slots here are unchanged.",
     "checks": "hall_door building_template tower_parts tower_lean hub_town art_slots",
     "slots": ["town.building.hall", "town.building.hall.gable", "town.building.hall.root_foot",
               "town.building.hall.yard", "town.prop.hall.rise_stair"]},
    {"id": "cx-13-tower-body", "tag": "body", "group": "tower",
     "title": "The Wayline Tower's body: Sorting Drum, hoist, chute, root vein and Galleries",
     "gate": "GATE: nothing here is painted until Preston has walked the blockout and approved the key (cx-11).",
     "note": "The middle of the climb the Tower scene rides. The chute and the root vein are overlays that hide the "
             "drum's seams, so paint the drum and the galleries first and the overlays over them. ROOT CHANGE "
             "(Preston, 2026-10-27, yes): redo root_vein once before install. Same rect and path, but paint it half "
             "sunk into the masonry, with mortar lips along both edges and the drum lips stepping over it, so the "
             "17 to 9 px strip reads as the back of a root about 34 px thick. The other four slots here are unchanged. "
             "Note: docs/design/great-tree-2026-10-27/CODEX_ROOT_NOTE.md.",
     "checks": "building_template tower_parts tower_reveal art_slots",
     "slots": ["town.building.hall.drum", "town.building.hall.hoist", "town.building.hall.chute",
               "town.building.hall.root_vein", "town.building.hall.galleries"]},
    {"id": "cx-14-tower-crown", "tag": "crown", "group": "tower",
     "title": "The Wayline Tower's crown: the Reel Deck, the Reach, the Waiting Lamp, the vane and the bell",
     "gate": "GATE: nothing here is painted until Preston has walked the blockout and approved the key (cx-11).",
     "note": "The top of the Tower scene's climb and the shape the far views must keep: a hooked column with one lit "
             "dot. Keep the Reach thick, banded and tended: no canopy, no face, no creature shape, and never a cane, "
             "gallows or question mark (TOWER_DESIGN.md section 13). cx-10 no longer waits on this batch (opened "
             "2026-10-28 for the vast-scale design). ROOT "
             "CHANGE (Preston, 2026-10-27): the Reach's silhouette is unchanged. Optional, can wait: two or three thin "
             "rootlets trailing west off the crook's back (docs/design/great-tree-2026-10-27/CODEX_ROOT_NOTE.md).",
     "checks": "tower_parts tower_reveal building_template art_slots",
     "slots": ["town.building.hall.reel_back", "town.building.hall.ring_front", "town.building.hall.reach",
               "town.building.hall.lamp", "town.building.hall.vane", "town.building.hall.bell"]},
    {"id": "cx-15-title-highbank", "tag": "highbank", "group": "tower",
     "title": "The title screen: Highbank with the Wayline Tower as the hero",
     "gate": "GATE: nothing here is painted until Preston has walked the blockout and approved the key (cx-11), so "
             "the title's Tower matches it.",
     "note": "Preston, 2026-10-27: the town on the title screen has to be a real town in the game. Highbank from across "
             "the river, painted for its own 384x216 size (drawn at 3x), with the Wayline Tower the largest, brightest "
             "and only tall shape. The wordmark, the menu, the canopy shade and the legibility wash are the game's; "
             "keep their areas calm as the brief says. The old title village is not repainted: it is kept for a future "
             "town on another map. Optional wiring: the six coded fireflies (`scripts/creature_opening.gd` "
             "`_draw_stars`) were placed for the village banks and now float over the Street and the Rise; they were "
             "not retuned. REDO, LAYOUT A (Preston, 2026-10-28): he chose layout A of the cloud-high Tower design, then "
             "said 'Remove the older tower from Title A too, its covering the new tower you made behind it that looks "
             "better'. Keep your houses, river and left tree as painted; take out the painted depot and drum tower and "
             "paint the 480-tile Tower in its place: the round Stack running off the top, down to the ground on its "
             "wide stepped plinth with the doors at street level, the Low Reel and waylines, the great tree's root on "
             "its west face (pre-darken about x0.62 under the canopy shade, x 0 to 311 above y 50, so the band shows no "
             "seam). Behind the town paint the great tree with its full crown of leaves and "
             "branch tops (his words: it needs 'the leaves and branch top'), painted only over sky and far hills. Keep "
             "the menu box (21,108 to 129,200) untouched and the wordmark area calm. The Tower stays slender and the "
             "tree stays 340 tiles away (both his yes). Target picture: docs/design/vast-scale-2026-10-27/final/"
             "title_a_game_3x.png for the layout (its crown and root are out of date, see the update below); numbers: docs/design/vast-scale-2026-10-27/VAST_SCALE_DESIGN.md. The slot's lamp "
             "anchor (333,33) and 'about 162 px tall' brief lines are stale in layout A (no lamp in frame). UPDATE (Preston, 2026-10-28, after seeing Title A in the game): centre the great tree's "
             "crown on its trunk (the left side reached much farther out than the right, so the trunk looked off to "
             "one side), with the limbs under it spreading both ways; and bring the Tower root's lower end up out of "
             "the ground at the first plinth step's west corner, with short roots gripping the Rise either side, then "
             "up the steps and the west face (it used to come in from behind the gardens and looked cut off and "
             "floating). The placeholder now shows both: match docs/design/placeholder-factory-2026-10-26/refs/"
             "title.backdrop.highbank.png for these two.",
     "checks": "opening_launch opening_flow ui_fit art_slots",
     "install": "`python tools/art/install_slot.py title.backdrop.highbank "
                f"{CANDIDATES}/cx-15-title-highbank/title.backdrop.highbank/prepared.png --batch cx-15-title-highbank`, "
                "then `python tools/debug/run_checks.py opening_flow ui_fit art_slots --jobs 1` and "
                "`python tools/debug/run_checks.py opening_launch --jobs 1 --window` (its screenshot needs a window). "
                "The title is the same with Highbank v2 on or off.",
     "slots": ["title.backdrop.highbank"]},
    {"id": "cx-16-item-shop", "tag": "item-shop", "title": "The Item Shop: the first building shaped by its keeper",
     "note": "Preston, 2026-10-28: the buildings were all the same box, and then \"to small and shack like\" with a "
             "perspective that felt wrong. Measured against Explorers of Sky's town (structure only; "
             "docs/design/town-map-2026-10-28/TOWN_SYNTHESIS.md): roof first. The Item Shop is now the trading_post class, "
             "204x192 on an 8x3 base, the roof the top 128 px, the front the bottom 64, the door on base column 3. The "
             "placeholder painted in code (building_template.gd _trading_post) shows the layout to keep. The stock out front "
             "is Grok's dooryard props (gb-10), not part of this picture. Your cx-01 candidate for town.building.shop and the "
             "lean_to of the same morning are superseded: do not install either.",
     "checks": "hub_town building_template art_slots",
     "slots": ["town.building.shop"]},    {"id": "cx-17-home-burrow", "tag": "home", "title": "Home, dug into the bluff",
     "note": "Preston, 2026-10-28: yes to Home dug into the bluff, the next keeper-shaped building after the Item Shop "
             "(docs/design/town-map-2026-10-28/TOWN_MAP.md). Claude wired it on 2026-10-29 as the burrow class: 132x192 on "
             "a 5x3 base, the grass bank the roof (about 70%), the stone face the bottom 56 px, the door on base column 2 "
             "at Rect2i(55, 142, 22, 48). The placeholder painted in code (building_template.gd _burrow) shows the layout to "
             "keep. Your cx-01 candidate for town.building.home is the old 132x144 cottage and is superseded: do not install "
             "it. Storage (Pouchbill's boathouse) follows in its own batch.",
     "checks": "hub_town building_template art_slots",
     "slots": ["town.building.home"]},
]

GROK_BATCHES = [
    {"id": "gb-01-street", "tag": "street", "title": "Street 1: lamp, well, waymark and street furniture",
     "checks": "town_props hub_town art_slots",
     "slots": ["town.lamp.post", "town.prop.well", "town.prop.waymark", "town.prop.bench", "town.prop.crates",
               "town.prop.barrel", "town.prop.planter", "town.prop.mooring_post"]},
    {"id": "gb-02-fences", "tag": "fence", "title": "Street 2: fences and the road east barrier",
     "checks": "town_props hub_town art_slots",
     "slots": ["town.prop.fence_h", "town.prop.fence_v", "town.prop.fence_corner", "town.prop.road_barrier"]},
    {"id": "gb-03-parts", "tag": "parts", "title": "Building parts: five signs and three shut overlays",
     "checks": "hub_town building_template hall_door art_slots",
     "slots": ["town.prop.sign_hall", "town.prop.sign_shop", "town.prop.sign_storage", "town.prop.sign_scrolls",
               "town.prop.sign_yard", "town.prop.shut_boards", "town.prop.shut_chain", "town.prop.shut_rope"]},
    {"id": "gb-04-furniture", "tag": "furniture", "title": "Shop and cellar furniture",
     "checks": "town_room art_slots",
     "slots": ["town.prop.shop.counter", "town.prop.shop.shelf", "town.prop.scrolls_cellar.rack",
               "town.prop.scrolls_cellar.table"]},
    {"id": "gb-05-menu", "tag": "menu", "title": "The main menu's cursor",
     "checks": "opening_flow art_slots", "slots": ["title.hud_piece.menu_cursor"],
     "note": "Codex wires it into main_menu.gd (CX-title-1); the bounce stays coded."},
    {"id": "gb-06-stairs", "tag": "dungeon", "title": "Sealed stairs on the boss floor",
     "checks": "dungeon dungeon_boss art_slots", "slots": ["dungeon.prop.stairs_sealed"],
     "note": "Replaces the red X drawn while the boss stands; the coded slab stands in until then."},
    {"id": "gb-07-road", "tag": "road", "title": "The road back: trail props", "group": "road",
     "checks": "road art_slots", "slots": ["road.prop.ferry_sign", "road.prop.waymark", "road.prop.lost_parcel"],
     "note": "Added after the plan's counts (lane S, Preston's canon change 4)."},
    {"id": "gb-08-tower", "tag": "tower", "group": "tower",
     "title": "The Wayline Tower's small set: route lanterns, wayline posts, basket, cradle and parcel",
     "gate": "GATE: nothing here is made until Preston has walked the Tower's blockout and approved its key (Codex "
             "batch cx-11).",
     "checks": "tower_parts town_props hub_town art_slots",
     "slots": ["town.building.hall.route_lantern", "town.prop.hall.wayline_post", "town.prop.hall.basket",
               "town.prop.hall.cradle", "town.prop.hall.parcel"],
     "note": "Added 2026-10-27 for the approved Wayline Tower (TOWER_DESIGN.md section 5, rows 11 and 17 to 21). Small "
             "things hung on or carried by the tower; the game draws the cables, the rope, the glow and all motion. "
             "The quiet states are the route that went quiet: an absence, never a ghost. Check with HT_HIGHBANK_V2=1 "
             "set (the tower is a v2 building), then once more without it."},
    {"id": "gb-09-forest", "tag": "forest", "title": "The Great Tree Path: one forest trunk",
     "checks": "town_props hub_town art_slots",
     "slots": ["town.prop.forest_trunk"]},
    {"id": "gb-10-dooryards", "tag": "dooryards", "title": "Dooryards: what lies in front of a building",
     "note": "Preston, 2026-10-28: wire the whole map, the area around the buildings too. Each building gets a dooryard "
             "(docs/design/town-map-2026-10-28/TOWN_SYNTHESIS.md), the Item Shop's first: its stock on goods tables, crates "
             "against its walls, rocks closing the yard. Seen from above like the town. "
             "Check with HT_HIGHBANK_V2=1 set.",
     "checks": "town_props hub_town art_slots",
     "slots": ["town.prop.goods_table", "town.prop.crate_stack", "town.prop.rock_cluster"]},
]

HEADER_WHY = [
    "**Why the old buildings read wrong.** The building rects were set on 2026-10-09 (the Home and Item Shop folders "
    "carry that date) and each PNG had to equal its solid footprint, 24 px a tile, with a one-tile door. On 2026-10-10, "
    "a day later, the creatures' town set was rebuilt at 1.5x. A stage 3 now stands 55 to 69 px, 2.3 to 2.9 tiles, "
    "beside a five-tile house with a 24 px door. Nothing in the old brief tied door or wall height to the creatures. "
    "The new canvases do: a single door is 22x48 (clears Sparkjab, a stage 2), the Tower's double door 48x64 (clears "
    "Galeshear, a stage 3), and every building and room task names the creature its door must clear (C11 measures it "
    "from the creature's own town sprite at check time).",
    "**Nothing installs without Preston's yes.** Every batch ends in a review sheet (`python tools/art/review_sheet.py "
    "<batch>`): per slot the placeholder, the prepared candidate, an in-game capture and the check lines. Preston "
    "answers yes, redo (one line why) or keep the placeholder; Claude records it in the batch's review.json; "
    "`install_slot.py` refuses any slot without his yes.",
]


def load_slots() -> dict:
    doc = reg.load()
    return doc


def check_batches(slots: dict, batches: list, owner: str, cap: int) -> list:
    errors = []
    want = {i for i, s in slots.items() if s["owner"] == owner and s["status"] == "placeholder"}
    seen = []
    for b in batches:
        if len(b["slots"]) > cap:
            errors.append(f"{b['id']} holds {len(b['slots'])} slots, over {owner}'s {cap}")
        for sid in b["slots"]:
            seen.append(sid)
            if sid not in slots:
                errors.append(f"{b['id']}: no slot named {sid}")
            # A delivered batch stays listed as the record once its slot is installed (cx-16, 2026-10-29).
            elif slots[sid]["owner"] != owner or slots[sid]["status"] not in ("placeholder", "installed"):
                errors.append(f"{b['id']}: {sid} is {slots[sid]['owner']}/{slots[sid]['status']}, not {owner}/placeholder")
    for sid in sorted(set(seen)):
        if seen.count(sid) > 1:
            errors.append(f"{sid} sits in {seen.count(sid)} batches")
    for sid in sorted(want - set(seen)):
        errors.append(f"{sid} ({owner}) sits in no batch")
    return errors


def ref_paths(sid: str) -> dict:
    return {"target": f"{REFS}/{sid}.png", "grid": f"{REFS}/{sid}_grid.png", "card": f"{REFS}/{sid}_card.png",
            "spec": f"{REFS}/{sid}.json"}


def state_frames(s: dict, state: str) -> int:
    """How many frames a state has (the registry's states are {name: [frames, fps]})."""
    v = s.get("states", {}).get(state, [1, 0])
    return max(1, int(v[0])) if isinstance(v, list) and v else 1


def is_tower_part(s: dict) -> bool:
    """A body or ground part of the Wayline Tower: it has a place in the 432x720 frame."""
    return bool(s.get("frame_at")) and s["palette"].get("family") == "wayline_tower"


def tower_refs(sid: str, s: dict) -> dict:
    """The Wayline Tower's extra references for one task (TOWER_DESIGN.md section 11): the assembled blockout, the
    part's band of neighbours, and the key. Empty for a slot that is not part of the tower or its pictures."""
    out = {}
    if s["palette"].get("family") == "wayline_tower" or sid == "title.backdrop.highbank":
        out["assembled"] = f"{TOWER_REFS}/assembled_blockout.png"
    if is_tower_part(s):
        out["band"] = f"{REFS}/{sid}_band.png"
    if sid == TOWER_KEY:
        out["parts"] = f"{TOWER_REFS}/parts_sheet.png"
        out["far_70"] = f"{TOWER_REFS}/far_70.png"
        out["far_170"] = f"{TOWER_REFS}/far_170.png"
    elif sid == "road.backdrop.highbank_far":   # the vast-scale mock, not the earlier tower's far_70 (2026-10-28)
        out["far"] = "docs/design/vast-scale-2026-10-27/final/road_far_slot_3x.png"
    elif sid == "road.backdrop.vista":   # the vast-scale mock, not the earlier tower's far_170 (2026-10-28)
        out["far"] = "docs/design/vast-scale-2026-10-27/final/vista_3x.png"
    return out


def tower_lines(sid: str, s: dict) -> list:
    """The Frame, Tower and Key lines of a Wayline Tower task."""
    r = tower_refs(sid, s)
    out = []
    if s.get("frame_at"):
        fx, fy = s["frame_at"]
        out.append(f"Frame: top-left at ({fx}, {fy}) in the tower's 432x720 frame; where two parts overlap the upper one "
                   f"owns the seam and carries its 3 px contact shadow")
    if sid == TOWER_KEY:
        out.append(f"Tower: {r['assembled']} (the whole blockout at 1:1: paint it at half size, same layout), "
                   f"{r['parts']} (every part), {r['far_70']} and {r['far_170']} (the far reads the key must keep)")
        return out
    if r.get("band"):
        out.append(f"Tower: {r['assembled']} (the whole blockout), {r['band']} (this part dimmed in its place, with a "
                   f"{BAND} px band of the neighbours it meets)")
    elif r.get("assembled"):
        out.append(f"Tower: {r['assembled']} (the whole blockout)")
    elif r.get("far"):
        out.append(f"Tower: {r['far']} (the vast-scale mock of this view at 3x: the Tower, the great tree and "
                   f"Highbank at this size; not the earlier coded far Tower or cx-14's crown)")
    if r.get("assembled"):
        out.append(f"Key:   {REFS}/{TOWER_KEY}.png until cx-11 is approved, then {KEY_APPROVED}")
    return out


def palette_line(s: dict) -> str:
    p = s["palette"]
    fam = p.get("family", "")
    lock = " (locked: only these colours)" if p.get("lock") else ""
    if p.get("exact"):
        lock += " (every colour the target uses)"
    return f"colours <= {p.get('max')} from `{REFS}/palettes/{fam}.png`{lock}"


def common_lines(sid: str, s: dict) -> list:
    w, h = s["size"]
    sheet = s.get("sheet_size", s["size"])
    out = []
    states = slot_states(s)
    counts = [state_frames(s, st) for st in states]
    if max(counts, default=1) > 1:   # frames run left to right in a state's row; empty cells stay clear
        rows = ", ".join(f"{st} ({n} frame{'s' if n > 1 else ''})" for st, n in zip(states, counts))
        out.append(f"Sheet: {sheet[0]}x{sheet[1]}, one {w}x{h} cell per frame, frames left to right; one row per "
                   f"state, top to bottom: {rows}")
    elif len(states) > 1:
        out.append(f"Sheet: {sheet[0]}x{sheet[1]}, one {w}x{h} row per state, top to bottom: {', '.join(states)}")
    out.append(f"Size:  exactly {w}x{h} world px (aspect {ratio(w, h)}), drawn at {s.get('drawn_at', 3)}x; "
               f"{palette_line(s)}; light from the {str(s.get('light', 'upper_left')).replace('_', ' ')}")   # a row's own light, if it names one
    out.append(f"Edges: {edges_rule(s)}; {alpha_rule(s)}; {outline_rule(s)}")
    if s.get("specks"):   # a row's own C9 limit, set from its target (2026-10-28)
        out.append(f"Specks: lone pixels up to {float(s['specks']):.0%} of the opaque ones (C9), as the target has; "
                   f"the usual limit is 1%")
    out.append(f"Place: {anchor_rule(s)}")
    if tiling_rule(s):
        out.append(f"Tile:  {tiling_rule(s)}")
    if s.get("door_px"):
        out.append(f"Door:  door_px {rect(s['door_px'])}: an open doorway, dark against the wall and open to the path (C10)")
    if s.get("pass_creature"):
        out.append(f"Scale: the doorway clears {creature(s['pass_creature'])} (C11)")
    elif s["kind"] in ("building", "landmark", "room"):
        out.append(f"Scale: the grid's grey block is {creature('sparkjab')}, a stage 2 for scale")
    if s.get("anchors"):
        sw, sh = sheet
        inside = {k: v for k, v in s["anchors"].items() if 0 <= v[0] < sw and 0 <= v[1] < sh}
        if inside:
            pts = ", ".join(f"{k} ({v[0]}, {v[1]})" for k, v in sorted(inside.items()))
            out.append(f"Keep:  these points where the code expects them: {pts}")
        if len(inside) < len(s["anchors"]):   # the depot's beacon and apex sit up the tower, above its canvas
            pts = ", ".join(f"{k} ({v[0]}, {v[1]})" for k, v in sorted(s["anchors"].items()) if k not in inside)
            out.append(f"Code:  points outside this picture that the code reads (paint nothing for them): {pts}")
    forbid = ", ".join(s.get("forbid", []))
    out.append(f"Never: {forbid} (no letters or numbers anywhere; nothing that reads as another game)")
    return out


def group_count(batches: list, group: str) -> tuple:
    """(batches, slots) in one group: "plan" (00-BUILD-PLAN.md), "road" (lane S) or "tower" (2026-10-27)."""
    chosen = [b for b in batches if b.get("group", "plan") == group]
    return len(chosen), sum(len(b["slots"]) for b in chosen)


TOWER_GATE = ("**GATE (Wayline Tower, 2026-10-27): nothing in the tower batches is painted until Preston has walked "
              "the coded blockout and approved the key.** The key (cx-11) starts after his walk (Tower Rise with "
              "HT_HIGHBANK_V2=1, and scenes/debug/building_lineup.tscn); his yes on the key opens the parts, the title "
              "and Grok's small set. The far views and the Tower's sky (cx-10) no longer wait on the crown (cx-14): "
              "they were re-briefed for the vast-scale design and opened on 2026-10-28.")

TOWER_CANON = ("**Wayline Tower approved, 2026-10-27** (Preston: \"go with the defaults and build it\"; "
               "docs/design/wayline-tower-2026-10-27/TOWER_DESIGN.md). A rooted river-stone tower 720 px (30 tiles) "
               "tall, built from 21 parts in one 432x720 frame, whose living root (the Reach) curls over the top like a "
               "crook to hold the Waiting Lamp above the door. The camera leans up 72 px at the doors. Today's game "
               "(v1) keeps the legacy 240x144 Hall until Preston walks v2. The title's town becomes Highbank with the "
               "Tower prominent (cx-15); the old title village is kept for a future town on another map. The Reach, "
               "the Waiting Lamp, the Route Board, the First Post and the dark lantern are working labels until "
               "Preston renames or cuts them.")


def review_line(b: dict) -> str:
    """The batch's last line: the review sheet, Preston's yes, then how its slots go in."""
    head = f"Review: `python tools/art/review_sheet.py {b['id']}`, then Preston's yes per slot"
    if b.get("install"):
        return f"{head}. Install: {b['install']}"
    if b.get("group") == "tower":
        return (f"{head}. Install per slot: `python tools/art/install_slot.py <slot_id> "
                f"{CANDIDATES}/{b['id']}/<slot_id>/prepared.png --batch {b['id']}`. A part shows only with Highbank v2 "
                f"on and in the debug lineup, and only at its exact sheet size, so parts can land one at a time while "
                f"the coded blockout stands in for the rest. Then `python tools/debug/run_checks.py {b['checks']} "
                f"--jobs 1` with HT_HIGHBANK_V2=1 set, and once more without it (v1 must not change).")
    return f"{head}, then install and `python tools/debug/run_checks.py {b['checks']} --jobs 1`."


def codex_list(slots: dict, date: str) -> str:
    total = sum(len(b["slots"]) for b in CODEX_BATCHES)
    n_plan, planned = group_count(CODEX_BATCHES, "plan")
    n_road, road = group_count(CODEX_BATCHES, "road")
    n_tower, tower = group_count(CODEX_BATCHES, "tower")
    L = [f"# Codex art tasks, {date} (written by tools/art/write_art_tasks.py; do not edit by hand)", ""]
    L += [TOWER_GATE, ""]
    L += [f"Placeholder factory, task-list lane (Claude). {len(CODEX_BATCHES)} batches, {total} slots: the plan's "
          f"{n_plan} batches and {planned} slots (00-BUILD-PLAN.md section 4; the Tower's old one-picture slot left "
          f"cx-01 on 2026-10-27), plus {n_road} road batches ({road} slots) that lane S added for Preston's canon change "
          f"of 2026-10-26 (the road back shows Highbank and the Wayline Tower far off), plus {n_tower} batches "
          f"({tower} slots) for the approved Wayline Tower and the Highbank title (2026-10-27, TOWER_DESIGN.md section "
          f"11). Registry {reg.load()['registry_sha256'][:12]}.", ""]
    L += HEADER_WHY[:1] + [""] + HEADER_WHY[1:] + [""]
    L += ["**Canon, 2026-10-26.** The Wayline Hall is the Wayline Tower in everything the player sees. Ids, files and "
          "flags keep `hall` (`town.building.hall`, rooms `hall` and `hall_low`). Tower Rise is the v2 area's working "
          "label. Highbank v2 stays behind its switch (HT_HIGHBANK_V2, off) until Preston walks it. All new names are "
          "working labels.", ""]
    L += [TOWER_CANON, ""]
    L += ["## Generator balances (read only, 2026-10-27; nothing was generated)", ""]
    L += [f"- **{n}** ({call}): {t}" for n, call, t in BALANCES]
    L += ["", "Every credit spend waits for Preston's yes. Each task names one **Alt** route for when Codex's route is "
          "not the best fit; Codex stays the owner the registry names.", ""]
    L += ["<details><summary>What each alternative tool makes</summary>", ""] + [f"- {t}" for t in TOOL_NOTES] + \
         ["", "</details>", ""]
    L += ["## How Codex delivers and installs", "",
          "1. Read the task's spec JSON, the target (the placeholder at its exact size), the grid (pixel and tile lines, "
          "the foot row in cyan, the door box in yellow, the scale creature as a grey block) and the card. Paint to the "
          "exact size; never resize the canvas.",
          f"2. Lock the batch folder while working: `{CANDIDATES}/<batch>/CODEX_IN_PROGRESS`. Remove it when the batch "
          "is delivered.",
          f"3. Per slot, into `{CANDIDATES}/<batch>/<slot_id>/`: `raw.png` (untouched output), `prompt.txt`, "
          "`ledger.json` (tool, references, cost, date), then",
          "   `python tools/art/prepare_slot.py <slot_id> raw.png prepared.png` and "
          "`python tools/art/validate_slot.py <slot_id> prepared.png` (writes `prepared.png.check.json`; exit 0 means "
          "every scripted check passes). A raw painted at exactly the slot's size keeps every pixel where it is: "
          "prepare_slot only keys the background, hardens alpha and snaps colours to the strip.",
          "4. `python tools/art/review_sheet.py <batch>` makes `review_sheet.png` for Preston. Do not install. Preston "
          "answers per slot; Claude records the answers in `review.json`.",
          "5. Only after his yes: `python tools/art/install_slot.py <slot_id> "
          f"{CANDIDATES}/<batch>/<slot_id>/prepared.png --batch <batch>` (it refuses on a lock, a failed check or no "
          "yes; it backs up what it replaces and records the hash), then "
          "`python tools/debug/run_checks.py <the batch's check words> --jobs 1`.",
          "6. Do not edit the registry (`scripts/art/slots/*.gd`) or another lane's files. List \"source issues for "
          "Claude\" in your result. Keep receipts short.", ""]
    L += ["## Batches", ""]
    L += [f"| Batch | Slots | Area | Checks after install |", "|---|---|---|---|"]
    for b in CODEX_BATCHES:
        L.append(f"| `{b['id']}` | {len(b['slots'])} | {b['title']} | {b['checks']} |")
    L.append("")
    for b in CODEX_BATCHES:
        n_slots = len(b["slots"])
        L += [f"## {b['id']}: {b['title']} ({n_slots} slot{'' if n_slots == 1 else 's'})", ""]
        if b.get("gate"):
            L += [f"**{b['gate']}**", ""]
        L += [b["note"], ""]
        for n, sid in enumerate(b["slots"], 1):
            s = slots[sid]
            p = ref_paths(sid)
            L += [f"### CX-{b['tag']}-{n}: {sid} ({s['kind']})", "", "```",
                  f"Spec:  {p['spec']}",
                  f"Ref:   {p['target']} (target), {p['grid']} (grid, foot row, door, scale block)",
                  f"Card:  {p['card']} (style sample, placeholder, palette strip)"]
            L += tower_lines(sid, s)
            L.append(f"Brief: {s.get('brief', '')}")
            if s.get("notes"):
                L.append(f"Notes: {s['notes']}")
            L += common_lines(sid, s)
            L += [f"Deliver to {CANDIDATES}/{b['id']}/{sid}/ with raw, prompt, ledger, prepared and check.json.",
                  "Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.",
                  "List \"source issues for Claude\" in your result.", "```", "",
                  f"Alt: {alt_route(sid, s)}", ""]
        if b.get("wire"):
            L += ["**Wiring (Codex's launch files; sites re-measured by text on 2026-10-27, after factory pass 8):**", ""]
            L += [f"- {w}" for w in b["wire"]] + [""]
        L += [review_line(b), ""]
    L += _not_verified()
    return "\n".join(L) + "\n"


def grok_list(slots: dict, date: str) -> str:
    def images_in(group: str) -> int:
        return sum(max(1, len(slot_states(slots[sid]))) for b in GROK_BATCHES if b.get("group", "plan") == group
                   for sid in b["slots"])

    n_slots = sum(len(b["slots"]) for b in GROK_BATCHES)
    images = sum(max(1, len(slot_states(slots[sid]))) for b in GROK_BATCHES for sid in b["slots"])
    n_plan, planned = group_count(GROK_BATCHES, "plan")
    _, road = group_count(GROK_BATCHES, "road")
    _, tower = group_count(GROK_BATCHES, "tower")
    road_imgs, tower_imgs = images_in("road"), images_in("tower")
    L = [f"# Grok art tasks, {date} (written by tools/art/write_art_tasks.py; do not edit by hand)", ""]
    L += [TOWER_GATE, ""]
    L += [f"Placeholder factory, task-list lane (Claude). {len(GROK_BATCHES)} batches, {n_slots} slots, {images} images "
          f"(a slot with several states takes one image per state): the plan's {n_plan} batches, {planned} slots and "
          f"{PLANNED_GROK_IMAGES} images (00-BUILD-PLAN.md section 4), plus 1 road batch of {road} trail props that "
          f"lane S added for Preston's canon change of 2026-10-26, plus the Wayline Tower's small set (gb-08, {tower} "
          f"slots, {tower_imgs} images, 2026-10-27). Registry {reg.load()['registry_sha256'][:12]}. This is the list "
          "promised at docs/team/GROK_TASKS_2026-10-26.md:78.", ""]
    lo_p, hi_p = PLANNED_GROK_IMAGES * GROK_LOW, PLANNED_GROK_IMAGES * GROK_HIGH
    lo, hi = images * GROK_LOW, images * GROK_HIGH
    L += [f"**Grok's spend is asked before anything runs.** The plan's {PLANNED_GROK_IMAGES} images x ${GROK_LOW:.2f} "
          f"to ${GROK_HIGH:.2f} = ${lo_p:.2f} to ${hi_p:.2f}. With the {road_imgs} road props and the Tower's "
          f"{tower_imgs} images: {images} x ${GROK_LOW:.2f} to ${GROK_HIGH:.2f} = ${lo:.2f} to ${hi:.2f}. Ask Preston "
          "per batch, quoting its image count and range, before its first run. A redo costs another image.", ""]
    L += HEADER_WHY + [""]
    L += ["**Canon, 2026-10-26.** The Wayline Hall is the Wayline Tower in everything the player sees; ids keep "
          "`hall` (so `town.prop.sign_hall` is the Tower's sign). All new names are working labels.", ""]
    L += [TOWER_CANON, ""]
    L += ["## Generator balances (read only, 2026-10-27; nothing was generated)", ""]
    L += [f"- **{n}** ({call}): {t}" for n, call, t in BALANCES]
    L += ["", "Every credit spend waits for Preston's yes. Each task names one **Alt** route; Grok stays the owner the "
          "registry names.", ""]
    L += ["<details><summary>What each alternative tool makes</summary>", ""] + [f"- {t}" for t in TOOL_NOTES] + \
         ["", "</details>", ""]
    L += ["## Rules for every Grok run", "",
          "1. **The honesty line first**: \"if a step fails, or you cannot see the attached image, say so plainly "
          "instead of guessing.\" `tools/grok_image.py make` puts it at the head of every prompt.",
          "2. **One image per run**, through `tools/grok_image.py make <card> <raw.png> \"<make line>\" --aspect <a:b>`. "
          "It copies the card alone into a fresh temporary folder, a **sealed folder**: Grok never reads the repo, the "
          "Preston Hub or anything private. Never run Grok from the repo or the Hub.",
          "3. Grok reads the card (a style sample of installed house art, the placeholder and the palette strip; no "
          "words on it) for style and colours.",
          "4. Clean pixel art: flat colour areas, hard-edged clusters, no gradients or blur, light from the upper left.",
          "5. **Nothing from any franchise**: nothing that reads as another game, show or brand.",
          "6. **No text in images**: no words, letters or numbers anywhere. grok_image.py says it twice and every make "
          "line says it again, because Grok added labels when told once.",
          "7. No creatures, animals or people. No AmFam material goes near any prompt.",
          f"8. Then `python tools/art/prepare_slot.py <slot_id> raw.png prepared.png` and "
          f"`python tools/art/validate_slot.py <slot_id> prepared.png`, both inside "
          f"`{CANDIDATES}/<batch>/<slot_id>/`. Report the check line, Grok's one-sentence reply and the cost "
          f"(from `raw.png.grok.json`).",
          "9. `python tools/art/review_sheet.py <batch>`; nothing installs before Preston's yes (`install_slot.py` "
          "refuses without it).", ""]
    L += ["## Batches", "", "| Batch | Slots | Images | Cost range | Area |", "|---|---|---|---|---|"]
    for b in GROK_BATCHES:
        imgs = sum(max(1, len(slot_states(slots[sid]))) for sid in b["slots"])
        L.append(f"| `{b['id']}` | {len(b['slots'])} | {imgs} | ${imgs * GROK_LOW:.2f} to ${imgs * GROK_HIGH:.2f} | "
                 f"{b['title']} |")
    L.append("")
    for b in GROK_BATCHES:
        imgs = sum(max(1, len(slot_states(slots[sid]))) for sid in b["slots"])
        n_slots = len(b["slots"])
        L += [f"## {b['id']}: {b['title']} ({n_slots} slot{'' if n_slots == 1 else 's'}, {imgs} "
              f"image{'' if imgs == 1 else 's'})", ""]
        if b.get("gate"):
            L += [f"**{b['gate']}**", ""]
        if b.get("note"):
            L += [b["note"], ""]
        for n, sid in enumerate(b["slots"], 1):
            s = slots[sid]
            p = ref_paths(sid)
            w, h = s["size"]
            asp = grok_aspect(w, h)
            folder = f"{CANDIDATES}/{b['id']}/{sid}"
            states = slot_states(s)
            L += [f"### GB-{b['tag']}-{n}: {sid}", "", "```",
                  f"Card:  {p['card']}",
                  f"Spec:  {p['spec']}",
                  f"Ref:   {p['target']} (target), {p['grid']} (grid, foot row)"]
            L += common_lines(sid, s)
            what = _make_line(s)
            if len(states) > 1:
                for st in states:
                    L.append(f"Make ({st}): {_make_line(s, st)}")
                    L.append(f"Run:   python tools/grok_image.py make {p['card']} {folder}/raw_{st}.png "
                             f"\"{_make_line(s, st)}\" --aspect {asp}")
                stack = " ".join(f"{folder}/raw_{st}.png" for st in states)
                counts = [state_frames(s, st) for st in states]
                frames = f" --frames {','.join(str(n) for n in counts)}" if max(counts) > 1 else ""
                L.append(f"Stack: python tools/art/write_art_tasks.py --stack {folder}/raw.png {stack}{frames}")
                if frames:
                    moving = ", ".join(f"{st} {n}" for st, n in zip(states, counts) if n > 1)
                    L.append(f"Frames: {moving} frames. Grok makes one still per state and --frames copies it into each "
                             f"frame cell; then make the frames differ by hand in prepared.png as the brief says "
                             f"(PixelLab pixelart_workbench, free, exact pixels) and validate again. Identical frames "
                             f"are an allowed first pass.")
            else:
                L.append(f"Make:  {what}")
                L.append(f"Run:   python tools/grok_image.py make {p['card']} {folder}/raw.png \"{what}\" "
                         f"--aspect {asp}")
            L += [f"Then:  python tools/art/prepare_slot.py {sid} {folder}/raw.png {folder}/prepared.png",
                  f"       python tools/art/validate_slot.py {sid} {folder}/prepared.png",
                  "Report: the check line, Grok's one-sentence reply, the cost.", "```", "",
                  f"Alt: {alt_route(sid, s)}", ""]
        L += [review_line(b), ""]
    L += _not_verified()
    return "\n".join(L) + "\n"


def _make_line(s: dict, state: str = "") -> str:
    """The make line for tools/grok_image.py: the brief, then the house rules (no text said again here)."""
    brief = s.get("brief", "").replace('"', "'").strip()
    brief = TOWER_COMMON.sub("", brief)   # Grok runs sealed: it cannot read TOWER_DESIGN.md or the key
    brief = brief.replace("No ground shadow: the game draws it.", "No ground shadow.")
    if state:   # one still per run: drop the brief's "as an unlit still and a lit still" and say which one this is
        brief = re.sub(r",? as an? \w+ still and an? \w+ still", "", brief)
        brief = brief.replace("No glow and no ground shadow: the game draws both.",
                              "No glow beyond the glass and no ground shadow.")
    if ARTICLE.match(brief):
        brief = brief[0].lower() + brief[1:]
    if not brief.endswith("."):
        brief += "."
    only = f" This image: {STATE_HINTS.get(state, 'the ' + state + ' still')}." if state else ""
    return (f"{brief}{only} One object only, filling the box, in the game's three-quarter top-down view, on a flat "
            f"pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.")


def _not_verified() -> list:
    return ["## Not verified", "",
            "- No generator was run for this list: the balances are read-only calls, and no route's per-call cost was "
            "measured except Retro Diffusion's free estimate ($0.18 for one 48x56 RD Pro prop).",
            "- The Alt routes come from each tool's own description, not from a test in this project.",
            "- The in-game capture column of the review sheet needs a capture made with the candidate swapped in; "
            "review_sheet.py shows where it is missing.",
            "- The Wayline Tower's references (the assembled blockout, each part's band, the exact palette strips) come "
            "from the coded blockout. No painted part has been seen against its neighbours or under the game's rim "
            "yet, and nothing checks a seam between two painted parts except Preston's eye in review."]


def stack(out: str, parts: list, frames: list = None) -> int:
    """One still per state, top to bottom; with frames, each still is copied into that many cells of its row (the
    cells past a state's own frames stay magenta, which prepare_slot clears)."""
    imgs = [Image.open(p).convert("RGBA") for p in parts]
    w = imgs[0].width
    imgs = [im if im.width == w else im.resize((w, round(im.height * w / im.width)), Image.LANCZOS) for im in imgs]
    frames = frames or [1] * len(imgs)
    sheet = Image.new("RGBA", (w * max(frames), sum(im.height for im in imgs)), (255, 0, 255, 255))
    y = 0
    for im, n in zip(imgs, frames):
        for f in range(n):
            sheet.paste(im, (f * w, y))
        y += im.height
    sheet.save(out)
    print(f"stacked {len(imgs)} stills into {out} ({sheet.width}x{sheet.height}, frames {frames})")
    return 0


# ---------------------------------------------------------------------------------------------------------------------
# The Wayline Tower's extra references (--tower-refs)

def luminance(c) -> float:
    """Godot's Color.get_luminance() on 0-255 channels, so strips sort as render_slot_refs.gd sorts them."""
    return (0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]) / 255.0


# A family whose painter keeps more colours than its placeholder happens to show: its strip is that whole PALETTE.
# The Highbank title (cx-15 layout A) keeps 47 protected colours from the painting before it; the placeholder render
# shows 34 of them, so a strip of only those failed C5 on the other 16 (PALETTE_ISSUE.json, Claude, 2026-10-29).
PAINTER_PALETTES = {"highbank_title": "scripts/art/placeholders/title_highbank.gd"}


def painter_palette(fam: str) -> list:
    path = PAINTER_PALETTES.get(fam)
    if not path:
        return []
    text = (reg.ROOT / path).read_text(encoding="utf-8")
    block = text.split("const PALETTE := [", 1)[1].split("]", 1)[0]
    return [tuple(int(h[i:i + 2], 16) for i in (1, 3, 5)) for h in re.findall(r'"(#[0-9a-fA-F]{6})"', block)]


def exact_strip(slots: dict, fam: str) -> Image.Image:
    """The family's swatch strip (8 x 8 a colour, lightest first): every colour its rendered placeholders use. The
    coded placeholders are snapped to their painter's PALETTE, so this is that palette, not a median cut of it."""
    cols = set(painter_palette(fam))
    for sid, s in slots.items():
        if s["palette"].get("family") != fam:
            continue
        path = reg.ROOT / ref_paths(sid)["target"]
        if not path.is_file():
            continue
        px = Image.open(path).convert("RGBA")
        cols |= {c[:3] for n, c in px.getcolors(px.width * px.height) if c[3] > 0}
    cols = sorted(cols, key=luminance, reverse=True)
    strip = Image.new("RGBA", (8 * len(cols), 8), (0, 0, 0, 0))
    for i, c in enumerate(cols):
        strip.paste(c + (255,), (8 * i, 0, 8 * i + 8, 8))
    return strip


def put_strip_on_card(card_path: Path, strip: Image.Image) -> bool:
    """Swap the palette strip on a card render_slot_refs.gd made. Its strip is the last picture, 768 px wide (any strip
    of five or more swatches is capped there) and centred in the 192 px band; the 8 px gap before it is card colour."""
    card = Image.open(card_path).convert("RGBA")
    x0 = card.width - 8 - STRIP_W
    gap = card.crop((x0 - 8, 8, x0, 8 + CARD_H))
    if strip.width < 40 or x0 < 16 or {c for n, c in gap.getcolors(gap.width * gap.height)} != {CARD_BACK}:
        return False
    h = max(1, round(CARD_H * 4 * CARD_H / (strip.width * (CARD_H // 8))))   # _fit(): 24x up, then capped at 768 wide
    card.paste(CARD_BACK, (x0, 8, x0 + STRIP_W, 8 + CARD_H))
    card.paste(strip.resize((STRIP_W, h), Image.NEAREST), (x0, 8 + (CARD_H - h) // 2))
    card.save(card_path)
    return True


def band_image(assembled: Image.Image, s: dict, part: Image.Image) -> Image.Image:
    """A tower part's place in the assembled blockout, BAND px round it at 1:1: the part's own pixels dimmed, so the
    neighbours it meets read at full colour; empty pixels show the grid's backdrop."""
    fx, fy = s["frame_at"]
    w, h = s["size"]
    box = (max(0, fx - BAND), max(0, fy - BAND), min(assembled.width, fx + w + BAND),
           min(assembled.height, fy + h + BAND))
    out = Image.new("RGBA", (box[2] - box[0], box[3] - box[1]), GRID_BACK)
    out.alpha_composite(assembled.crop(box))
    cell = part.crop((0, 0, w, h))   # the first frame of the first state
    shade = Image.new("RGBA", (w, h), GRID_BACK[:3] + (150,))
    mask = cell.getchannel("A").point(lambda a: 255 if a > 0 else 0)
    out.paste(Image.alpha_composite(out.crop((fx - box[0], fy - box[1], fx - box[0] + w, fy - box[1] + h)), shade),
              (fx - box[0], fy - box[1]), mask)
    return out


def write_tower_refs(slots: dict) -> int:
    refs = reg.ROOT / REFS
    assembled_path = reg.ROOT / TOWER_REFS / "assembled_blockout.png"
    if not assembled_path.is_file():
        print(f"refused: {assembled_path} is missing; render it: godot --headless --path . --script "
              f"res://tools/debug/tower_parts_check.gd -- --render {TOWER_REFS}")
        return 2
    for fam in EXACT_STRIPS:
        strip = exact_strip(slots, fam)
        strip.save(refs / "palettes" / f"{fam}.png")
        print(f"palette {fam}: {strip.width // 8} colours -> {REFS}/palettes/{fam}.png")
    tower_ids = [sid for b in CODEX_BATCHES + GROK_BATCHES if b.get("group") == "tower" or b["id"] == "cx-10-road-far"
                 for sid in b["slots"]]
    for sid in tower_ids:
        s = slots[sid]
        fam = s["palette"].get("family", "")
        card, strip_path = reg.ROOT / ref_paths(sid)["card"], refs / "palettes" / f"{fam}.png"
        if card.is_file() and strip_path.is_file():
            done = put_strip_on_card(card, Image.open(strip_path).convert("RGBA"))
            print(f"card {sid}: {'strip ' + fam if done else 'left as rendered (no strip place found)'}")
    assembled = Image.open(assembled_path).convert("RGBA")
    for sid in tower_ids:
        s = slots[sid]
        if not is_tower_part(s):
            continue
        band = band_image(assembled, s, Image.open(reg.ROOT / ref_paths(sid)["target"]).convert("RGBA"))
        band.save(refs / f"{sid}_band.png")
        print(f"band {sid}: {band.width}x{band.height}")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description="Write the Codex and Grok art task lists from the slot registry.")
    ap.add_argument("--date", default="2026-10-26")
    ap.add_argument("--check-refs", action="store_true", help="refuse when a task's reference picture is missing")
    ap.add_argument("--stack", nargs="+", metavar="PNG", help="<out.png> <top.png> <bottom.png> ...")
    ap.add_argument("--frames", default="", help="with --stack: each still's frame count, as 3,1,1")
    ap.add_argument("--tower-refs", action="store_true",
                    help="write the Wayline Tower's exact palette strips, card strips and part bands")
    a = ap.parse_args()
    if a.stack:
        if len(a.stack) < 3:
            print("--stack needs <out.png> and at least two stills")
            return 2
        frames = [int(n) for n in a.frames.split(",")] if a.frames else None
        if frames and (len(frames) != len(a.stack) - 1 or min(frames) < 1):
            print(f"--frames needs one count of 1 or more per still ({len(a.stack) - 1} stills)")
            return 2
        return stack(a.stack[0], a.stack[1:], frames)
    try:
        slots = load_slots()["slots"]
    except reg.StaleRegistry as e:
        print(f"refused: {e}")
        return 2
    if a.tower_refs:
        return write_tower_refs(slots)
    errors = check_batches(slots, CODEX_BATCHES, "codex", 6) + check_batches(slots, GROK_BATCHES, "grok", 8)
    if a.check_refs:
        for b in CODEX_BATCHES + GROK_BATCHES:
            for sid in b["slots"]:
                extra = tower_refs(sid, slots[sid]) if sid in slots else {}
                paths = list(ref_paths(sid).items()) + list(extra.items())
                for kind, path in paths:
                    if not (reg.ROOT / path).is_file():
                        errors.append(f"missing {kind} reference {path}")
    if errors:
        print("refused:\n  " + "\n  ".join(errors))
        return 1
    team = reg.ROOT / "docs" / "team"
    codex_path = team / f"CODEX_ART_TASKS_{a.date}.md"
    grok_path = team / f"GROK_ART_TASKS_{a.date}.md"
    codex_path.write_bytes(codex_list(slots, a.date).encode("utf-8"))
    grok_path.write_bytes(grok_list(slots, a.date).encode("utf-8"))
    c_slots = sum(len(b["slots"]) for b in CODEX_BATCHES)
    g_slots = sum(len(b["slots"]) for b in GROK_BATCHES)
    g_imgs = sum(max(1, len(slot_states(slots[sid]))) for b in GROK_BATCHES for sid in b["slots"])
    print(f"write_art_tasks: Codex {len(CODEX_BATCHES)} batches, {c_slots} slots -> {codex_path.relative_to(reg.ROOT)}")
    print(f"write_art_tasks: Grok {len(GROK_BATCHES)} batches, {g_slots} slots, {g_imgs} images -> "
          f"{grok_path.relative_to(reg.ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
