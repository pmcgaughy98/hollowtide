"""Create a review-only pixel study for Hollowtide's proposed River Listener.

The exported 64x64 PNG is not connected to the game roster. This script keeps
the hand-authored pixel study easy to revise while the creature line is under
design review.
"""

from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parent
SIZE = 64

INK = "#140f18"
DEEP = "#202431"
SHADOW = "#2d3d49"
SLATE = "#4b6870"
RIVER = "#71999a"
FOAM = "#bed0c2"
COPPER = "#bd7958"
GOLD = "#edc27b"

image = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
draw = ImageDraw.Draw(image)


def polygon(points: list[tuple[int, int]], fill: str, outline: str = INK) -> None:
    draw.polygon(points, fill=fill, outline=outline)


# Rear sensory tail: short and broad, like a fin that can brace in a cutbank.
polygon([(17, 30), (10, 26), (5, 27), (8, 32), (5, 37), (11, 38), (18, 35)], SHADOW)
draw.polygon([(10, 29), (7, 28), (10, 32), (8, 35), (12, 35), (15, 33)], fill=SLATE)
draw.point((8, 31), fill=FOAM)

# Low paired limbs keep the silhouette grounded without making it a mammal.
polygon([(21, 36), (27, 39), (26, 44), (21, 46), (17, 45), (20, 42)], DEEP)
draw.line([(21, 42), (18, 44), (16, 44)], fill=SLATE)
polygon([(37, 36), (42, 38), (44, 43), (41, 46), (37, 43), (35, 39)], DEEP)
draw.line([(40, 42), (43, 43), (45, 42)], fill=SLATE)

# Main cutbank body: a compressed, armored shape with an open underside.
polygon(
    [(13, 30), (17, 25), (23, 21), (31, 20), (38, 22), (44, 26),
     (47, 31), (44, 36), (39, 40), (31, 42), (23, 41), (17, 38), (12, 35)],
    SHADOW,
)
draw.polygon([(18, 29), (23, 24), (30, 23), (37, 24), (42, 28), (39, 31), (30, 30), (23, 33)], fill=SLATE)
draw.polygon([(23, 34), (30, 32), (40, 33), (42, 36), (37, 39), (29, 39), (23, 37)], fill=DEEP)
draw.line([(20, 27), (24, 24), (29, 24)], fill=FOAM)
draw.line([(20, 35), (24, 37), (29, 38)], fill=SHADOW)

# Three gill-fan plates flare backward from the head. Their gaps are part of
# the silhouette, not a glowing effect, so they remain readable at 1x scale.
polygon([(31, 25), (34, 19), (37, 24), (36, 32), (32, 34)], RIVER)
polygon([(34, 27), (39, 21), (41, 27), (39, 35), (35, 36)], SLATE)
polygon([(37, 29), (43, 25), (43, 31), (41, 37), (37, 37)], COPPER)
draw.line([(34, 24), (34, 30)], fill=FOAM)
draw.line([(38, 25), (37, 32)], fill=FOAM)
draw.point((40, 29), fill=GOLD)

# Split paddle brow: two offset lobes with a deliberate notch between them.
# It suggests current-sensing anatomy without copying a real fish literally.
polygon([(40, 25), (47, 21), (54, 21), (60, 24), (61, 27), (57, 29), (48, 29), (43, 31)], RIVER)
polygon([(41, 33), (47, 33), (56, 32), (61, 35), (59, 39), (53, 40), (47, 38), (42, 37)], SLATE)
draw.polygon([(48, 24), (54, 23), (58, 25), (54, 26), (49, 26)], fill=FOAM)
draw.polygon([(49, 35), (55, 35), (58, 37), (54, 37)], fill=RIVER)

# Small eye is set back from the paddle; no smile, teeth, or mascot cheeks.
draw.point((45, 29), fill=INK)
draw.point((46, 28), fill=GOLD)

# Broken dorsal ridges and a few deliberate surface marks tie it to the game's
# angular creature language while keeping the palette under ten colors.
polygon([(22, 24), (24, 18), (27, 23)], DEEP)
polygon([(28, 22), (31, 16), (34, 23)], DEEP)
draw.line([(24, 19), (25, 22)], fill=RIVER)
draw.point((29, 25), fill=COPPER)
draw.line([(26, 35), (29, 34)], fill=RIVER)
draw.line([(30, 37), (33, 36)], fill=SLATE)
draw.point((14, 32), fill=FOAM)

image.save(ROOT / "river-listener-stage1-candidate.png")
scaled = image.resize((SIZE * 4, SIZE * 4), Image.Resampling.NEAREST)
preview = Image.new("RGBA", scaled.size, "#bfc4ad")
preview.alpha_composite(scaled)
preview.save(ROOT / "river-listener-stage1-preview.png")
