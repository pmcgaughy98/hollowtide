"""Writes the Codex and Grok art task lists from the art slot registry (Claude, 2026-10-26, placeholder factory
task-list lane; 00-BUILD-PLAN.md section 4, 03-spec-format.md sections 4.1 to 4.5).

    python tools/art/write_art_tasks.py [--date 2026-10-26] [--check-refs]
    python tools/art/write_art_tasks.py --stack <out.png> <top.png> <bottom.png> [...]

Reads slots.json through slot_registry (a stale export is refused), puts every Codex and Grok slot still on its
placeholder into one of the batches below (one batch is one area Preston can walk into), and writes
docs/team/CODEX_ART_TASKS_<date>.md and docs/team/GROK_ART_TASKS_<date>.md. A task can never disagree with the code:
a fix goes into scripts/art/slots/*.gd, the registry is exported again (render_slot_refs.gd), and this runs again.
It refuses when a generator slot sits in no batch or in two, when a batch is over its size (Codex 6 slots, Grok 8),
and, with --check-refs, when a reference picture for a task is missing.

--stack joins state stills top to bottom (the street lamp's unlit and lit stills) into the one raw picture
prepare_slot.py cuts back into state rows; each still is scaled to the first one's width first.

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
               "lit": "the lit still, the same lamp with its lantern glass lit warm gold from inside"}


def creature(form: str) -> str:
    box = reg.creature_box(form) if form else None
    return f"{form} ({box[1]} px tall, {box[0]} px wide, measured now from its town/s.png)" if box else form


def slot_states(s: dict) -> list:
    """State names in registry order (slots.json sorts its keys, so read the slot file for the order)."""
    names = list(s.get("states", {}).keys())
    if len(names) < 2:
        return names
    path = reg.SLOT_DIR / f"{s.get('slot_file', '')}.gd"
    if path.is_file():
        text = path.read_text(encoding="utf-8")
        at = text.find(f'"{s["id"]}"')
        m = re.search(r'"states":\s*\{([^}]*)\}', text[at:]) if at >= 0 else None
        if m:
            ordered = re.findall(r'"(\w+)"\s*:', m.group(1))
            if sorted(ordered) == sorted(names):
                return ordered
    return names


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
    if sid == "town.building.hall":
        return ("SpriteCook generate_game_art (aspect 9:16, pixel true, style_asset_ids = the uploaded house art), then "
                "prepare_slot crops 9:16 to 300:576. Weak: nothing else reaches 576 px (PixelLab stops at 400, RD Pro "
                "at 256) and 3 SpriteCook credits cover one try. Codex stays the route.")
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
    {"id": "cx-01-buildings", "tag": "town", "title": "Highbank's buildings and the Wayline Tower",
     "note": "The v2 canvases from the building template at BUILDING_SCALE 1.0 (Preston call 1's default). v1, today's "
             "town, keeps the old PNGs at rect x 24 and does not change; these show only with Highbank v2 on. The Tower "
             "is canon from 2026-10-26: the Hall's base footprint and doors, rising 24 tiles to a beacon mast.",
     "checks": "hall_door hub_town building_template art_slots",
     "slots": ["town.building.hall", "town.building.home", "town.building.shop", "town.building.storage",
               "town.building.scrolls"]},
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
         "and keep the fill otherwise, so today's card is unchanged. Source issue: the registry note still says "
         "`#161f1b` at :21 (the dc37005af text), so its placeholder bands use the old colour.",
         "`scripts/creature_opening.gd:8` `const VILLAGE = preload(...)` and `:41` `town.texture=VILLAGE`: read "
         "`ArtSlots.texture(\"title.backdrop.village\")` (a keep row; its legacy is today's file, so nothing changes). "
         "It stays at 4.5x (Preston call 8).",
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
    {"id": "cx-09-road", "tag": "road", "title": "The road back up to Highbank: the trail's layers",
     "note": "Added after the plan's counts (lane S, Preston's canon change 4, 2026-10-26). The walkable road scene "
             "draws these as parallax layers; each layer's note gives its scroll rate and haze.",
     "checks": "road mouth_escape art_slots",
     "slots": ["road.backdrop.sky", "road.backdrop.far", "road.backdrop.river", "road.backdrop.mid",
               "road.backdrop.near", "road.ground.path"]},
    {"id": "cx-10-road-far", "tag": "far", "title": "Highbank and the Wayline Tower far off, and the Tower's sky",
     "note": "Added after the plan's counts (lane S). Canon 2026-10-26: on the road back, Highbank and the Tower show on "
             "the horizon, faded with distance (the scene adds the haze, so paint them clear); the Tower scene pans up "
             "against tower_sky.",
     "checks": "road tower_reveal art_slots",
     "slots": ["road.backdrop.highbank_far", "road.backdrop.vista", "story.backdrop.tower_sky"]},
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
    {"id": "gb-07-road", "tag": "road", "title": "The road back: trail props",
     "checks": "road art_slots", "slots": ["road.prop.ferry_sign", "road.prop.waymark", "road.prop.lost_parcel"],
     "note": "Added after the plan's counts (lane S, Preston's canon change 4)."},
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
            elif slots[sid]["owner"] != owner or slots[sid]["status"] != "placeholder":
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


def palette_line(s: dict) -> str:
    p = s["palette"]
    fam = p.get("family", "")
    lock = " (locked: only these colours)" if p.get("lock") else ""
    return f"colours <= {p.get('max')} from `{REFS}/palettes/{fam}.png`{lock}"


def common_lines(sid: str, s: dict) -> list:
    w, h = s["size"]
    sheet = s.get("sheet_size", s["size"])
    out = []
    states = slot_states(s)
    if len(states) > 1:
        out.append(f"Sheet: {sheet[0]}x{sheet[1]}, one {w}x{h} row per state, top to bottom: {', '.join(states)}")
    out.append(f"Size:  exactly {w}x{h} world px (aspect {ratio(w, h)}), drawn at {s.get('drawn_at', 3)}x; "
               f"{palette_line(s)}; light from the upper left")
    out.append(f"Edges: {edges_rule(s)}; {alpha_rule(s)}; {outline_rule(s)}")
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
        pts = ", ".join(f"{k} ({v[0]}, {v[1]})" for k, v in sorted(s["anchors"].items()))
        out.append(f"Keep:  these points where the code expects them: {pts}")
    forbid = ", ".join(s.get("forbid", []))
    out.append(f"Never: {forbid} (no letters or numbers anywhere; nothing that reads as another game)")
    return out


def codex_list(slots: dict, date: str) -> str:
    total = sum(len(b["slots"]) for b in CODEX_BATCHES)
    planned = sum(len(b["slots"]) for b in CODEX_BATCHES if not b["id"].startswith("cx-09")
                  and not b["id"].startswith("cx-10"))
    L = [f"# Codex art tasks, {date} (written by tools/art/write_art_tasks.py; do not edit by hand)", ""]
    L += [f"Placeholder factory, task-list lane (Claude). {len(CODEX_BATCHES)} batches, {total} slots: the plan's 8 "
          f"batches and {planned} slots (00-BUILD-PLAN.md section 4), plus 2 road batches ({total - planned} slots) "
          f"that lane S added for Preston's canon change of 2026-10-26 (the road back shows Highbank and the Wayline "
          f"Tower far off). Registry {reg.load()['registry_sha256'][:12]}.", ""]
    L += HEADER_WHY[:1] + [""] + HEADER_WHY[1:] + [""]
    L += ["**Canon, 2026-10-26.** The Wayline Hall is the Wayline Tower in everything the player sees. Ids, files and "
          "flags keep `hall` (`town.building.hall`, rooms `hall` and `hall_low`). Tower Rise is the v2 area's working "
          "label. Highbank v2 stays behind its switch (HT_HIGHBANK_V2, off) until Preston walks it. All new names are "
          "working labels.", ""]
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
          "every scripted check passes).",
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
        L += [f"## {b['id']}: {b['title']} ({len(b['slots'])} slots)", "", b["note"], ""]
        for n, sid in enumerate(b["slots"], 1):
            s = slots[sid]
            p = ref_paths(sid)
            L += [f"### CX-{b['tag']}-{n}: {sid} ({s['kind']})", "", "```",
                  f"Spec:  {p['spec']}",
                  f"Ref:   {p['target']} (target), {p['grid']} (grid, foot row, door, scale block)",
                  f"Card:  {p['card']} (style sample, placeholder, palette strip)",
                  f"Brief: {s.get('brief', '')}"]
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
        L += [f"Review: `python tools/art/review_sheet.py {b['id']}`, then Preston's yes per slot, then install and "
              f"`python tools/debug/run_checks.py {b['checks']} --jobs 1`.", ""]
    L += _not_verified()
    return "\n".join(L) + "\n"


def grok_list(slots: dict, date: str) -> str:
    n_slots = sum(len(b["slots"]) for b in GROK_BATCHES)
    images = sum(max(1, len(slot_states(slots[sid]))) for b in GROK_BATCHES for sid in b["slots"])
    road = sum(len(b["slots"]) for b in GROK_BATCHES if b["id"] == "gb-07-road")
    L = [f"# Grok art tasks, {date} (written by tools/art/write_art_tasks.py; do not edit by hand)", ""]
    L += [f"Placeholder factory, task-list lane (Claude). {len(GROK_BATCHES)} batches, {n_slots} slots, {images} images "
          f"(the street lamp has two states): the plan's 6 batches, {n_slots - road} slots and {PLANNED_GROK_IMAGES} "
          f"images (00-BUILD-PLAN.md section 4), plus 1 road batch of {road} trail props that lane S added for "
          f"Preston's canon change of 2026-10-26. Registry {reg.load()['registry_sha256'][:12]}. This is the list "
          "promised at docs/team/GROK_TASKS_2026-10-26.md:78.", ""]
    lo_p, hi_p = PLANNED_GROK_IMAGES * GROK_LOW, PLANNED_GROK_IMAGES * GROK_HIGH
    lo, hi = images * GROK_LOW, images * GROK_HIGH
    L += [f"**Grok's spend is asked before anything runs.** The plan's {PLANNED_GROK_IMAGES} images x ${GROK_LOW:.2f} "
          f"to ${GROK_HIGH:.2f} = ${lo_p:.2f} to ${hi_p:.2f}. With the {images - PLANNED_GROK_IMAGES} road props: "
          f"{images} x ${GROK_LOW:.2f} to ${GROK_HIGH:.2f} = ${lo:.2f} to ${hi:.2f}. Ask Preston per batch, quoting "
          "its image count and range, before its first run. A redo costs another image.", ""]
    L += HEADER_WHY + [""]
    L += ["**Canon, 2026-10-26.** The Wayline Hall is the Wayline Tower in everything the player sees; ids keep "
          "`hall` (so `town.prop.sign_hall` is the Tower's sign). All new names are working labels.", ""]
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
        L += [f"## {b['id']}: {b['title']} ({len(b['slots'])} slots, {imgs} images)", ""]
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
                L.append(f"Stack: python tools/art/write_art_tasks.py --stack {folder}/raw.png {stack}")
            else:
                L.append(f"Make:  {what}")
                L.append(f"Run:   python tools/grok_image.py make {p['card']} {folder}/raw.png \"{what}\" "
                         f"--aspect {asp}")
            L += [f"Then:  python tools/art/prepare_slot.py {sid} {folder}/raw.png {folder}/prepared.png",
                  f"       python tools/art/validate_slot.py {sid} {folder}/prepared.png",
                  "Report: the check line, Grok's one-sentence reply, the cost.", "```", "",
                  f"Alt: {alt_route(sid, s)}", ""]
        L += [f"Review: `python tools/art/review_sheet.py {b['id']}`, then Preston's yes per slot, then install and "
              f"`python tools/debug/run_checks.py {b['checks']} --jobs 1`.", ""]
    L += _not_verified()
    return "\n".join(L) + "\n"


def _make_line(s: dict, state: str = "") -> str:
    """The make line for tools/grok_image.py: the brief, then the house rules (no text said again here)."""
    brief = s.get("brief", "").replace('"', "'").strip()
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
            "review_sheet.py shows where it is missing."]


def stack(out: str, parts: list) -> int:
    imgs = [Image.open(p).convert("RGBA") for p in parts]
    w = imgs[0].width
    imgs = [im if im.width == w else im.resize((w, round(im.height * w / im.width)), Image.LANCZOS) for im in imgs]
    sheet = Image.new("RGBA", (w, sum(im.height for im in imgs)), (255, 0, 255, 255))
    y = 0
    for im in imgs:
        sheet.paste(im, (0, y))
        y += im.height
    sheet.save(out)
    print(f"stacked {len(imgs)} stills into {out} ({sheet.width}x{sheet.height})")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description="Write the Codex and Grok art task lists from the slot registry.")
    ap.add_argument("--date", default="2026-10-26")
    ap.add_argument("--check-refs", action="store_true", help="refuse when a task's reference picture is missing")
    ap.add_argument("--stack", nargs="+", metavar="PNG", help="<out.png> <top.png> <bottom.png> ...")
    a = ap.parse_args()
    if a.stack:
        if len(a.stack) < 3:
            print("--stack needs <out.png> and at least two stills")
            return 2
        return stack(a.stack[0], a.stack[1:])
    try:
        slots = load_slots()["slots"]
    except reg.StaleRegistry as e:
        print(f"refused: {e}")
        return 2
    errors = check_batches(slots, CODEX_BATCHES, "codex", 6) + check_batches(slots, GROK_BATCHES, "grok", 8)
    if a.check_refs:
        for b in CODEX_BATCHES + GROK_BATCHES:
            for sid in b["slots"]:
                for kind, path in ref_paths(sid).items():
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
