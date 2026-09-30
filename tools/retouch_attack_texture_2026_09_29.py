"""Repeatable pixel finish for Vitrecrag's Molten Cannon attack frames.

The source frames are never changed. This pass preserves their RGBA alpha,
canvas, pose, and pixel coordinates while matching the approved battle art's
dark silhouette edge and clustered, stepped fire colours.
"""

from __future__ import annotations

from collections import Counter
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets/sprites/creatures/attacks/vitrecrag_molten_cannon/built"
DEST = ROOT / "assets/sprites/creatures/attacks/vitrecrag_molten_cannon/style_matched"
FRAMES = ("rest", "brace", "charge", "swirl", "blaze", "kindle", "loaded", "spent", "vent")
IRONVENT_SOURCE = ROOT / "assets/sprites/creatures/attacks/ironvent_furnace_roar/built"
IRONVENT_DEST = ROOT / "assets/sprites/creatures/attacks/ironvent_furnace_roar/style_matched"
IRONVENT_FRAMES = ("rest", "warm", "pressure", "rear", "open", "cutin", "roar", "settle", "cool")
GLASS_ROOT = ROOT / "assets/sprites/creatures/attacks/vitrecrag_lava_pour"
GLASS_FRAMES = ("overload", "overload_pour_a", "overload_pour_b", "titlecard")
OXBOW_ROOT = ROOT / "assets/sprites/creatures/attacks/oxbowarchon_kingstone_rail"
OXBOW_FRAMES = (
    "rest", "raise", "glow", "kindle", "kindle_arcs", "swirl", "full", "full_b",
    "burst", "burst_b", "shot", "spent", "afterglow", "settle",
)
OXBOW_BODY_PALETTE = (
    (4, 4, 4), (20, 20, 12), (28, 28, 28), (44, 44, 36),
    (60, 52, 44), (84, 76, 60), (100, 84, 68), (108, 100, 76),
    (140, 132, 108), (20, 44, 44), (28, 60, 52), (36, 76, 60),
    (52, 84, 68), (68, 100, 84), (76, 116, 92), (92, 124, 100),
    (4, 36, 12), (4, 76, 44), (12, 108, 52), (20, 132, 68),
    (36, 156, 76), (60, 180, 100), (92, 228, 132), (132, 244, 156),
    (188, 228, 188), (116, 76, 36), (180, 116, 44), (212, 148, 44),
)
OXBOW_GLOW_PALETTE = ((4, 76, 44), (18, 183, 106), (124, 245, 184), (207, 255, 230))
OUTLINE = (20, 12, 20)
DARK_STONE = (52, 44, 36)
MID_STONE = (84, 36, 36)


def is_edge(pixels, x: int, y: int, width: int, height: int) -> bool:
    return any(
        nx < 0 or ny < 0 or nx >= width or ny >= height or pixels[nx, ny][3] < 128
        for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1))
    )


def texture_frame(frame: str) -> None:
    original = Image.open(SOURCE / f"{frame}.png").convert("RGBA")
    width, height = original.size
    pixels = original.load()
    finished = original.copy()
    result = finished.load()

    for y in range(height):
        for x in range(width):
            red, green, blue, alpha = pixels[x, y]
            if alpha < 128:
                continue

            rgb = (red, green, blue)
            # Give the source orb a broken, forward-moving hot seam. A round
            # radial highlight made it read like a button rather than fire.
            if frame == "loaded" and x >= 130 and y <= 96 and red > 170 and green > 70 and blue < 150:
                seam_y = 83 - (x - 132) // 3
                if 136 <= x <= 150 and abs(y - seam_y) <= (2 if x < 144 else 1):
                    rgb = (255, 224, 124)
                elif 133 <= x <= 151 and abs(y - seam_y) <= 5:
                    rgb = (255, 192, 76)
                elif green >= 140:
                    rgb = (252, 156, 76)
                elif red >= 230:
                    rgb = (252, 116, 36)

            # Finish the edge last so every silhouette colour, including the
            # fireball, gets the same dark frame as the approved attack art.
            if is_edge(pixels, x, y, width, height):
                rgb = OUTLINE
            elif rgb == (4, 4, 4):
                rgb = OUTLINE
            elif rgb == (28, 28, 28):
                rgb = DARK_STONE
            elif rgb == (68, 28, 28):
                bright_nearby = any(
                    max(pixels[nx, ny][:3]) > 140 and pixels[nx, ny][3] >= 128
                    for ny in range(max(0, y - 2), min(height, y + 3))
                    for nx in range(max(0, x - 2), min(width, x + 3))
                )
                if bright_nearby:
                    rgb = MID_STONE
            result[x, y] = (*rgb, alpha)

    DEST.mkdir(parents=True, exist_ok=True)
    finished.save(DEST / f"{frame}.png")
    before_alpha = original.getchannel("A").tobytes()
    after_alpha = finished.getchannel("A").tobytes()
    if before_alpha != after_alpha or original.size != finished.size:
        raise RuntimeError(f"Pose mask or canvas changed: {frame}")
    colors = Counter(px for px in finished.get_flattened_data() if px[3] >= 128)
    print(f"{frame}: {width}x{height}, {len(colors)} colours, alpha exact")


def _same_material(a: tuple[int, int, int], b: tuple[int, int, int]) -> bool:
    def family(rgb: tuple[int, int, int]) -> int:
        r, g, blue = rgb
        if r > 130 and r > g * 1.4 and r > blue * 1.4:
            return 2  # furnace light
        if r > g * 1.5 and r > blue * 1.5:
            return 1  # dark red head or copper
        return 0  # coal and stone

    return family(a) == family(b)


def texture_ironvent_frame(frame: str) -> None:
    original = Image.open(IRONVENT_SOURCE / f"{frame}.png").convert("RGBA")
    width, height = original.size
    pixels = original.load()
    finished = original.copy()
    result = finished.load()

    for y in range(height):
        for x in range(width):
            r, g, b, alpha = pixels[x, y]
            if alpha < 128:
                continue
            rgb = (r, g, b)
            if is_edge(pixels, x, y, width, height):
                result[x, y] = (4, 4, 4, alpha)
                continue

            # Preserve the head's approved dark red recolour and every bright
            # ember. On neutral stone, merge isolated flecks into a nearby
            # cluster only when nearby neighbours agree on a close tone.
            if rgb == (36, 12, 12) or max(rgb) > 130:
                continue
            neighbors_4 = ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1))
            if any(pixels[nx, ny][:3] == rgb for nx, ny in neighbors_4):
                continue
            neighbor_colors = Counter(
                pixels[nx, ny][:3]
                for ny in range(y - 1, y + 2)
                for nx in range(x - 1, x + 2)
                if (nx != x or ny != y)
                and pixels[nx, ny][3] >= 128
                and _same_material(rgb, pixels[nx, ny][:3])
            )
            if neighbor_colors:
                replacement, count = neighbor_colors.most_common(1)[0]
                distance = sum(abs(a - b) for a, b in zip(rgb, replacement))
                if count >= 2 and distance <= 64:
                    result[x, y] = (*replacement, alpha)

    IRONVENT_DEST.mkdir(parents=True, exist_ok=True)
    finished.save(IRONVENT_DEST / f"{frame}.png")
    if original.size != finished.size or original.getchannel("A").tobytes() != finished.getchannel("A").tobytes():
        raise RuntimeError(f"Ironvent pose mask or canvas changed: {frame}")
    colors = Counter(px for px in finished.get_flattened_data() if px[3] >= 128)
    print(f"ironvent/{frame}: {width}x{height}, {len(colors)} colours, alpha exact")


def texture_glass_extra(frame: str, palette: tuple[tuple[int, int, int], ...]) -> None:
    original = Image.open(GLASS_ROOT / f"{frame}.png").convert("RGBA")
    width, height = original.size
    pixels = original.load()
    finished = original.copy()
    result = finished.load()
    mapping: dict[tuple[int, int, int], tuple[int, int, int]] = {}

    for y in range(height):
        for x in range(width):
            r, g, b, alpha = pixels[x, y]
            if alpha < 128:
                continue
            rgb = (r, g, b)
            if is_edge(pixels, x, y, width, height):
                mapped = OUTLINE
            else:
                if rgb not in mapping:
                    mapping[rgb] = min(
                        palette,
                        key=lambda c: (r - c[0]) ** 2 * 0.8 + (g - c[1]) ** 2 + (b - c[2]) ** 2 * 0.7,
                    )
                mapped = mapping[rgb]
            result[x, y] = (*mapped, alpha)

    dest = GLASS_ROOT / "style_matched" / f"{frame}.png"
    finished.save(dest)
    if original.size != finished.size or original.getchannel("A").tobytes() != finished.getchannel("A").tobytes():
        raise RuntimeError(f"Molten Glass pose mask or canvas changed: {frame}")
    colors = Counter(px for px in finished.get_flattened_data() if px[3] >= 128)
    print(f"glass/{frame}: {width}x{height}, {len(colors)} colours, alpha exact")


def texture_oxbow(source: Path, dest: Path, label: str, attack: bool) -> None:
    original = Image.open(source).convert("RGBA")
    width, height = original.size
    src = original.load()
    finished = original.copy()
    out = finished.load()
    full_palette = OXBOW_BODY_PALETTE + OXBOW_GLOW_PALETTE
    mapping: dict[tuple[tuple[int, int, int], bool], tuple[int, int, int]] = {}

    for y in range(height):
        for x in range(width):
            r, g, b, alpha = src[x, y]
            if alpha < 128:
                continue
            if is_edge(src, x, y, width, height):
                out[x, y] = (4, 4, 4, alpha)
                continue
            effect = attack and y < 115 and g > r * 1.35 and g > b * 1.04
            key = ((r, g, b), effect)
            if key not in mapping:
                candidates = OXBOW_GLOW_PALETTE if effect else full_palette
                mapping[key] = min(
                    candidates,
                    key=lambda c: (r - c[0]) ** 2 * 0.8 + (g - c[1]) ** 2 + (b - c[2]) ** 2 * 0.7,
                )
            out[x, y] = (*mapping[key], alpha)

    # Merge only dark, isolated texture flecks; preserve the rails, eyes,
    # bright Kingstone and designed one-pixel sparks.
    quantized = finished.copy()
    q = quantized.load()
    for y in range(height):
        for x in range(width):
            rgb = q[x, y][:3]
            alpha = q[x, y][3]
            if alpha < 128 or max(rgb) > 140 or is_edge(q, x, y, width, height):
                continue
            if any(q[nx, ny][:3] == rgb for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1))):
                continue
            nearby = Counter(
                q[nx, ny][:3]
                for ny in range(y - 1, y + 2)
                for nx in range(x - 1, x + 2)
                if (nx != x or ny != y) and q[nx, ny][3] >= 128
            )
            if nearby:
                replacement, count = nearby.most_common(1)[0]
                if count >= 2 and sum(abs(a - b) for a, b in zip(rgb, replacement)) <= 54:
                    out[x, y] = (*replacement, alpha)

    dest.parent.mkdir(parents=True, exist_ok=True)
    finished.save(dest)
    if original.size != finished.size or original.getchannel("A").tobytes() != finished.getchannel("A").tobytes():
        raise RuntimeError(f"Oxbowarchon pose mask or canvas changed: {label}")
    colors = Counter(px for px in finished.get_flattened_data() if px[3] >= 128)
    print(f"oxbow/{label}: {width}x{height}, {len(colors)} colours, alpha exact")


if __name__ == "__main__":
    for name in FRAMES:
        texture_frame(name)
    for name in IRONVENT_FRAMES:
        texture_ironvent_frame(name)
    anchor = Image.open(GLASS_ROOT / "style_matched/flood.png").convert("RGBA")
    palette = {px[:3] for px in anchor.get_flattened_data() if px[3] >= 128}
    palette.update(((252, 196, 116), (252, 228, 164), (252, 236, 188), (252, 252, 236)))
    for name in GLASS_FRAMES:
        texture_glass_extra(name, tuple(sorted(palette)))
    for name in OXBOW_FRAMES:
        texture_oxbow(OXBOW_ROOT / "built" / f"{name}.png", OXBOW_ROOT / "style_matched" / f"{name}.png", name, True)
    texture_oxbow(
        ROOT / "assets/sprites/creatures/oxbowarchon.png",
        ROOT / "assets/sprites/creatures/oxbowarchon_style_candidate_2026_09_29.png",
        "idle-candidate", False,
    )
