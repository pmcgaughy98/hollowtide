"""Shared reader for the art slot registry (Claude, 2026-10-26, placeholder factory contract).

The registry is GDScript (scripts/art/art_slots.gd and scripts/art/slots/*.gd). Python never parses it: it reads
docs/design/placeholder-factory-2026-10-26/slots.json, which tools/art/render_slot_refs.gd writes, and checks the
stamp inside against the registry files on disk with the same SHA-256 ArtSlots.registry_hash() computes (file name,
a newline, then the file with CRLF read as LF, in name order). A stale slots.json is refused, so a tool can never
work from a list that disagrees with the game.
"""
import hashlib
import json
import os
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
DOC = ROOT / "docs" / "design" / "placeholder-factory-2026-10-26"
SLOTS_JSON = DOC / "slots.json"
SLOT_DIR = ROOT / "scripts" / "art" / "slots"
LOADER = ROOT / "scripts" / "art" / "art_slots.gd"
DEFAULT_GODOT = r"C:\Users\pmcga\Games\Tools\Godot_v4.7.2\Godot_v4.7.2-stable_win64.exe"
EXPORT_HINT = "godot --headless --path . --script res://tools/art/render_slot_refs.gd -- --export-only"


class StaleRegistry(RuntimeError):
    pass


def res_path(res: str) -> Path:
    """res://a/b.png -> <repo>/a/b.png"""
    return ROOT / res.replace("res://", "", 1) if res.startswith("res://") else Path(res)


def registry_hash() -> str:
    h = hashlib.sha256()
    names = sorted(p.name for p in SLOT_DIR.glob("*.gd"))
    for path in [LOADER] + [SLOT_DIR / n for n in names]:
        h.update((path.name + "\n").encode("utf-8"))
        h.update(path.read_bytes().replace(b"\r\n", b"\n"))
    return h.hexdigest()


def load(allow_stale: bool = False) -> dict:
    """slots.json as a dict, refused when its stamp is not the registry on disk."""
    if not SLOTS_JSON.is_file():
        raise StaleRegistry(f"{SLOTS_JSON} is missing; export it: {EXPORT_HINT}")
    doc = json.loads(SLOTS_JSON.read_text(encoding="utf-8"))
    now = registry_hash()
    if doc.get("registry_sha256") != now and not allow_stale:
        raise StaleRegistry(f"slots.json is stale (stamp {str(doc.get('registry_sha256'))[:12]}, registry {now[:12]}); export it again: {EXPORT_HINT}")
    return doc


def spec(slot_id: str, allow_stale: bool = False) -> dict:
    slots = load(allow_stale)["slots"]
    if slot_id not in slots:
        raise KeyError(f"no slot named {slot_id}")
    return slots[slot_id]


def allowed_sides(edges) -> set:
    if isinstance(edges, list):
        return set(edges)
    return {"all": {"top", "bottom", "left", "right"}, "bottom": {"bottom"}}.get(edges, set())


def cells(img: np.ndarray, s: dict):
    """(row, frame, cell array) for every cell of a sheet."""
    w, h = s["size"]
    for r in range(s["rows"]):
        for f in range(s["frames"]):
            yield r, f, img[r * h:(r + 1) * h, f * w:(f + 1) * w]


def palette(s: dict):
    """The slot's palette strip colours (N x 3 uint8), from res://assets/slots/palettes/ or the refs folder, or None."""
    fam = s["palette"].get("family", "")
    if not fam or fam == "as_installed":
        return None
    for p in (res_path(s["palette"].get("source", "")), DOC / "refs" / "palettes" / f"{fam}.png"):
        if p and p.is_file():
            a = np.asarray(Image.open(p).convert("RGBA"))
            opaque = a[..., 3] > 0
            return np.unique(a[opaque][:, :3], axis=0)
    return None


def creature_box(form: str):
    """(w, h) of a creature's town/s.png content, read now, or None."""
    p = ROOT / "assets" / "sprites" / "arena" / form / "town" / "s.png"
    if not p.is_file():
        return None
    bb = Image.open(p).convert("RGBA").getchannel("A").point(lambda a: 255 if a > 0 else 0).getbbox()
    return (bb[2] - bb[0], bb[3] - bb[1]) if bb else None


def godot() -> str:
    g = os.environ.get("GODOT", "") or (DEFAULT_GODOT if os.name == "nt" else "")
    return g if g and Path(g).is_file() else ""
