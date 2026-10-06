"""Rebuild four reviewed building textures without changing source geometry.

Only writes inside world-buildings-linework-2026-10-04 beside this helper.
Original and generated inputs remain untouched. Requires Pillow and NumPy.
All restoration boxes use half-open native pixel coordinates.
"""
from __future__ import annotations
import hashlib
import json
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent
REVIEW = ROOT / "world-buildings-linework-2026-10-04"
NAMES = ("courtyard_home", "dispatch_hall", "brick_shop", "ledger_house")
RESTORATIONS = {
    "dispatch_hall": (
        ("original plain upper-left timber panel", (37, 95, 52, 116)),
        ("original plain upper-right timber panel", (84, 95, 99, 116)),
        ("original plain lower-left brick panel", (26, 124, 46, 143)),
    ),
    "brick_shop": (
        ("original open doorway and lower frame drift", (90, 137, 120, 170)),
        ("original left display contents", (35, 151, 72, 167)),
        ("original right display contents", (153, 151, 173, 167)),
    ),
}
MATTE = (63, 71, 72)

def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()

def rgba(path: Path) -> np.ndarray:
    with Image.open(path) as image:
        return np.asarray(image.convert("RGBA")).copy()

def occupied_bounds(array: np.ndarray) -> list[int] | None:
    bounds = Image.fromarray(array).getbbox()
    return list(bounds) if bounds else None

def paste_native(canvas: Image.Image, array: np.ndarray, x: int, y: int, scale: int = 2) -> None:
    sprite = Image.fromarray(array)
    sprite = sprite.resize((sprite.width * scale, sprite.height * scale), Image.Resampling.NEAREST)
    canvas.paste(sprite, (x, y), sprite)

def render_comparison(images: dict[str, tuple[np.ndarray, np.ndarray]]) -> None:
    render_dir = REVIEW / "render"
    render_dir.mkdir(exist_ok=True)
    row_height = 432
    comparison = Image.new("RGB", (1280, row_height * len(NAMES)), MATTE)
    draw = ImageDraw.Draw(comparison)
    for row, name in enumerate(NAMES):
        original, final = images[name]
        for column, (label, array) in enumerate((("ORIGINAL", original), ("FINAL REGISTERED LINEWORK", final))):
            x = column * 640
            y = row * row_height
            draw.text((x + 12, y + 10), f"{name} / {label}", fill=(240, 235, 221))
            sprite_x = x + (640 - array.shape[1] * 2) // 2
            sprite_y = y + 32 + (384 - array.shape[0] * 2) // 2
            paste_native(comparison, array, sprite_x, sprite_y)
    comparison.save(render_dir / "four-building-comparison.png")
    gap = 24
    contact_width = sum(images[name][1].shape[1] * 2 for name in NAMES) + gap * (len(NAMES) + 1)
    contact = Image.new("RGB", (contact_width, 432), MATTE)
    draw = ImageDraw.Draw(contact)
    x = gap
    for name in NAMES:
        final = images[name][1]
        draw.text((x, 10), f"{name} / {final.shape[1]}x{final.shape[0]}", fill=(240, 235, 221))
        paste_native(contact, final, x, 32 + (384 - final.shape[0] * 2) // 2)
        x += final.shape[1] * 2 + gap
    contact.save(render_dir / "four-building-contact.png")

def main() -> None:
    if not REVIEW.is_dir() or REVIEW.parent != ROOT:
        raise RuntimeError("The expected review folder must exist beside this helper.")
    inventory = {item["name"]: item for item in json.loads((REVIEW / "source-inventory.json").read_text())}
    input_hashes: dict[Path, str] = {}
    images: dict[str, tuple[np.ndarray, np.ndarray]] = {}
    records = []
    for name in NAMES:
        original_path = REVIEW / "before" / f"{name}.png"
        generated_path = REVIEW / "generated" / f"{name}-rd.png"
        original_hash = sha256(original_path)
        generated_hash = sha256(generated_path)
        if original_hash != inventory[name]["sha256"]:
            raise RuntimeError(f"Original source hash does not match its archive: {name}")
        input_hashes[original_path] = original_hash
        input_hashes[generated_path] = generated_hash
        original = rgba(original_path)
        generated = rgba(generated_path)
        if original.shape != generated.shape:
            raise RuntimeError(f"Canvas size changed in generated source: {name}")
        height, width = original.shape[:2]
        original_visible = original[:, :, 3] > 0
        generated_visible = generated[:, :, 3] > 0
        # Reproduce existing registration, excluding all invented outside-silhouette art.
        final = original.copy()
        usable = original_visible & generated_visible
        final[usable, :3] = generated[usable, :3]
        registered = final.copy()
        restoration_mask = np.zeros((height, width), dtype=bool)
        repairs = []
        for label, box in RESTORATIONS.get(name, ()):
            x0, y0, x1, y1 = box
            if not (0 <= x0 < x1 <= width and 0 <= y0 < y1 <= height):
                raise RuntimeError(f"Restoration box outside source canvas: {name} {box}")
            region = np.s_[y0:y1, x0:x1]
            changed = np.any(final[region] != original[region], axis=2)
            repairs.append({"label": label, "bounds_half_open": list(box), "changed_pixels_restored": int(changed.sum())})
            final[region] = original[region]
            restoration_mask[region] = True
            if not np.array_equal(final[region], original[region]):
                raise RuntimeError(f"Source-copy restoration failed: {name} {box}")
        alpha_exact = np.array_equal(final[:, :, 3], original[:, :, 3])
        transparent_exact = np.array_equal(final[~original_visible], original[~original_visible])
        repair_changes = np.any(final != registered, axis=2)
        outside_repairs = int((repair_changes & ~restoration_mask).sum())
        if not alpha_exact or not transparent_exact or outside_repairs:
            raise RuntimeError(f"Preservation audit failed: {name}")
        output_path = REVIEW / "prepared" / f"{name}.png"
        Image.fromarray(final).save(output_path)
        saved = rgba(output_path)
        if not np.array_equal(saved, final):
            raise RuntimeError(f"PNG round-trip failed: {name}")
        images[name] = (original, final)
        records.append({
            "name": name,
            "size": [width, height],
            "original_alpha_and_transparent_pixels_exact": bool(alpha_exact and transparent_exact),
            "original_bounds": occupied_bounds(original),
            "generated_bounds": occupied_bounds(generated),
            "final_bounds": occupied_bounds(final),
            "original_visible_edge_pixels_restored": int((original_visible & ~generated_visible).sum()),
            "generated_outside_alpha_excluded": int((~original_visible & generated_visible).sum()),
            "changed_visible_RGB": int((original_visible & np.any(final[:, :, :3] != original[:, :, :3], axis=2)).sum()),
            "source_restoration_rectangles": [list(box) for label, box in RESTORATIONS.get(name, ())],
            "restorations": repairs,
            "prepared_diff_outside_restoration_boxes": outside_repairs,
            "source_sha256": original_hash,
            "generated_sha256": generated_hash,
            "final_sha256": sha256(output_path),
        })
    render_comparison(images)
    for path, expected in input_hashes.items():
        if sha256(path) != expected:
            raise RuntimeError(f"An input changed during preparation: {path}")
    (REVIEW / "native-preparation.json").write_text(json.dumps(records, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"outputs": [{"name": record["name"], "sha256": record["final_sha256"], "repairs": record["restorations"]} for record in records]}, indent=2))

if __name__ == "__main__":
    main()

