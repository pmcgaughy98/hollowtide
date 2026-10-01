"""Retouch Vitrecrag's approved back using its official front palette.

Texture only: pixel edits are clipped to existing material pixels. Silhouette,
alpha, canvas, registration, shell architecture, window rails and limbs stay put.
Writes a separate candidate, never overwrites the project's source textures.
"""
import argparse
import hashlib
import json
from collections import Counter
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(r"C:\Users\pmcga\dev\hollowtide")
OUT = Path(__file__).resolve().parent
FRONT = ROOT / "assets/sprites/creatures/vitrecrag_official.png"
BACK = ROOT / "assets/sprites/creatures/vitrecrag_back_official_2026_09_30.png"
BODY = ROOT / "assets/sprites/creatures/idle/vitrecrag_flame/body.png"

INK = (20, 12, 20)
PLUM = [(44, 28, 44), (60, 36, 52), (76, 44, 60), (124, 84, 100)]
STONE = [(28, 28, 28), (52, 44, 36), (68, 52, 44), (92, 76, 68), (124, 108, 100)]
COPPER = [(68, 28, 28), (84, 36, 36), (108, 44, 36), (116, 60, 52),
          (140, 68, 52), (148, 84, 68), (164, 100, 76), (204, 124, 100)]
HEAT = [(156, 52, 20), (220, 92, 36), (252, 116, 36), (252, 156, 76)]


def material(array, colors):
    return np.any(np.all(array[:, :, None, :3] == np.array(colors)[None, None, :, :], axis=3), axis=2)


def polygon(points, size):
    image = Image.new("1", size)
    ImageDraw.Draw(image).polygon(points, fill=1)
    return np.array(image, dtype=bool)


def edge(mask):
    padded = np.pad(mask, 1)
    interior = padded[:-2, 1:-1] & padded[2:, 1:-1] & padded[1:-1, :-2] & padded[1:-1, 2:]
    return mask & ~interior


def stats(array):
    counts = Counter(map(tuple, array[array[:, :, 3] > 0, :3].tolist()))
    return {"colors": len(counts), "palette_counts": [{"rgb": list(c), "pixels": n} for c, n in counts.most_common()]}


def preview(images, output, factor=4):
    width, height = 128 * factor + 24, 128 * factor + 44
    canvas = Image.new("RGB", (width * len(images), height), (30, 34, 43))
    draw = ImageDraw.Draw(canvas)
    for index, (title, image) in enumerate(images):
        x = index * width
        draw.text((x + 12, 12), title, fill=(240, 221, 196))
        enlarged = image.resize((128 * factor, 128 * factor), Image.Resampling.NEAREST)
        canvas.paste(enlarged, (x + 12, 32), enlarged)
    canvas.save(output)


def connect_front_hips(front):
    """Show a buried, load-bearing stone torso behind the existing leg armor.

    Repaint interior body pixels only; keep the actual six limbs, stance,
    shell/window assembly and all silhouette pixels in their approved places.
    """
    source = np.array(front)
    result = source.copy()
    visible = source[:, :, 3] > 0
    contour = edge(visible)
    # Keep all plum shell surfaces, luminous material and their copper rim.
    protected = material(source, PLUM + HEAT) | contour
    yy, xx = np.indices(visible.shape)
    protected |= (yy <= 79) | (xx >= 83)
    edits = []

    def plane(label, points, color):
        area = polygon(points, front.size) & visible & ~protected
        changed = area & np.any(result[:, :, :3] != color, axis=2)
        result[area, :3] = color
        edits.append({"region": label, "rgb": list(color), "polygon": points,
                      "painted_pixels": int(changed.sum())})

    # The body continues behind the thighs, rather than tracing a separate
    # closed dark ring around each hip. Dark lower planes retain their depth.
    plane("recessed continuous stone torso", [(24, 81), (29, 80), (38, 82),
          (48, 81), (56, 81), (64, 81), (75, 82), (76, 86), (69, 87),
          (62, 85), (57, 85), (51, 86), (45, 85), (38, 86), (31, 85), (25, 84)], STONE[1])
    plane("rear hip seated under the torso", [(23, 83), (27, 81), (31, 82),
          (32, 85), (28, 88), (24, 87)], STONE[2])
    plane("rear hip upper stone face", [(25, 82), (28, 82), (30, 83),
          (29, 85), (26, 85)], STONE[3])
    plane("middle hip continuous stone root", [(36, 81), (41, 80), (46, 82),
          (47, 86), (44, 89), (39, 88), (36, 85)], STONE[3])
    plane("middle hip upper left stone light", [(39, 81), (42, 81),
          (43, 83), (41, 86), (39, 85)], STONE[4])
    plane("far hip seated behind middle limb", [(55, 82), (60, 82), (63, 85),
          (60, 88), (57, 87), (54, 85)], STONE[2])
    plane("fore hip under-shell root", [(68, 83), (72, 83), (75, 85),
          (74, 88), (70, 87)], STONE[2])
    if not np.array_equal(source[:, :, 3], result[:, :, 3]) or not np.array_equal(source[contour], result[contour]):
        raise ValueError("Front hip pass changed its silhouette.")
    front.save(OUT / "front_before.png")
    candidate = Image.fromarray(result)
    candidate.save(OUT / "front_hip_candidate.png")
    body_image = Image.open(BODY).convert("RGBA")
    body = np.array(body_image)
    changed = np.any(source != result, axis=2)
    if not np.array_equal(body[changed], source[changed]):
        raise ValueError("Idle body differs at a front retouch coordinate; inspect before transferring.")
    body_image.save(OUT / "front_body_before.png")
    body[changed] = result[changed]
    Image.fromarray(body).save(OUT / "front_body_hip_candidate.png")
    return candidate, {"source_sha256": hashlib.sha256(FRONT.read_bytes()).hexdigest(),
                       "body_source_sha256": hashlib.sha256(BODY.read_bytes()).hexdigest(),
                       "changed_pixels": int(changed.sum()), "regions": edits,
                       "alpha_preserved": True, "outer_contour_preserved": True,
                       "idle_body_received_same_pixel_changes": True}


def main():
    global FRONT, BACK, BODY, OUT
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--front-source", type=Path, default=FRONT)
    parser.add_argument("--back-source", type=Path, default=BACK)
    parser.add_argument("--body-source", type=Path, default=BODY)
    parser.add_argument("--output", type=Path, default=OUT)
    args = parser.parse_args()
    FRONT, BACK, BODY, OUT = args.front_source, args.back_source, args.body_source, args.output
    OUT.mkdir(parents=True, exist_ok=True)
    front = Image.open(FRONT).convert("RGBA")
    original = Image.open(BACK).convert("RGBA")
    if front.size != (128, 128) or original.size != (128, 128):
        raise ValueError("Reconsider native coordinates if the approved art has changed size.")
    original.save(OUT / "back_before.png")
    source = np.array(original)
    result = source.copy()
    visible = source[:, :, 3] > 0
    contour = edge(visible)
    surfaces = {"plum": material(source, PLUM), "stone": material(source, STONE),
                "copper": material(source, COPPER), "heat": material(source, HEAT)}
    edits = []

    def paint(label, kind, points, color):
        area = polygon(points, original.size) & surfaces[kind] & visible & ~contour
        changed = area & np.any(result[:, :, :3] != color, axis=2)
        result[area, :3] = color
        edits.append({"region": label, "material": kind, "rgb": list(color),
                      "polygon": points, "painted_pixels": int(changed.sum())})

    # Restore the front's missing intermediate plum tone in existing plate
    # planes. Never paint across a copper seam or invent another plate.
    paint("upper rear plate turning plane", "plum",
          [(49, 41), (61, 43), (68, 48), (67, 51), (59, 56), (51, 52)], PLUM[1])
    paint("upper rear plate shadow plane", "plum",
          [(57, 49), (66, 48), (67, 52), (61, 56), (56, 53)], PLUM[0])
    paint("rear left plate shoulder light", "plum",
          [(29, 53), (34, 51), (40, 53), (42, 56), (38, 59), (32, 58), (28, 62)], PLUM[2])
    paint("rear left plate upper edge highlight", "plum",
          [(31, 52), (34, 52), (38, 54), (38, 55), (35, 54), (32, 54)], PLUM[3])
    paint("rear left plate turning plane", "plum",
          [(43, 59), (50, 60), (53, 63), (47, 69), (40, 69)], PLUM[1])
    paint("rear left plate lower overlap shadow", "plum",
          [(40, 68), (46, 68), (49, 66), (47, 71), (40, 71), (37, 70)], PLUM[0])
    paint("middle overlap turned surface", "plum",
          [(57, 67), (63, 64), (67, 66), (65, 72), (61, 77), (57, 77)], PLUM[1])
    paint("middle overlap upper facet", "plum",
          [(60, 66), (64, 65), (65, 66), (63, 69), (60, 70), (59, 69)], PLUM[2])

    # Each rock limb gets a broad existing-material face and a short upper-left
    # highlight. This replaces flat vertical strips with the front's planes.
    paint("near hind shin broad face", "stone",
          [(53, 99), (58, 100), (59, 103), (58, 108), (53, 107), (52, 103)], STONE[3])
    paint("near hind shin lit edge", "stone",
          [(53, 99), (55, 100), (55, 106), (54, 107), (53, 104)], STONE[4])
    paint("near hind shin turned face", "stone",
          [(59, 101), (62, 100), (63, 107), (59, 109), (58, 107)], STONE[1])
    paint("near hind foot rock face", "stone",
          [(55, 115), (58, 114), (61, 116), (61, 119), (55, 119)], STONE[3])
    paint("near hind foot top facet", "stone",
          [(56, 115), (58, 114), (59, 115), (58, 117), (56, 117)], STONE[4])
    paint("middle thigh broad rock plane", "stone",
          [(79, 82), (82, 83), (84, 90), (82, 94), (78, 90)], STONE[3])
    paint("middle thigh left highlight", "stone",
          [(79, 82), (80, 83), (81, 89), (80, 90), (78, 87)], STONE[4])
    paint("middle shin angled plane", "stone",
          [(81, 98), (84, 98), (88, 106), (87, 109), (84, 108), (80, 102)], STONE[3])
    paint("middle shin upper-left highlight", "stone",
          [(81, 98), (83, 99), (85, 104), (84, 105), (82, 103)], STONE[4])
    paint("middle foot rock face", "stone",
          [(89, 112), (91, 113), (93, 116), (91, 117), (88, 115)], STONE[3])
    paint("middle foot top light", "stone",
          [(89, 112), (91, 113), (91, 115), (89, 115)], STONE[4])
    paint("far hind shin", "stone",
          [(16, 99), (19, 100), (19, 103), (17, 104), (14, 101)], STONE[3])
    paint("far hind shin top light", "stone",
          [(16, 99), (17, 100), (17, 102), (15, 101)], STONE[4])
    paint("far fore shin", "stone",
          [(103, 97), (105, 97), (108, 102), (108, 103), (105, 102)], STONE[3])
    paint("far fore shin light", "stone",
          [(103, 97), (104, 98), (106, 100), (105, 100)], STONE[4])
    paint("far fore foot top plane", "stone",
          [(111, 108), (113, 109), (114, 110), (111, 110)], STONE[3])

    # A few larger warm facets on existing shoulder armor, without turning
    # the whole back orange or brightening its black joints and outlines.
    paint("rear hip existing plate light plane", "copper",
          [(30, 83), (32, 83), (35, 87), (35, 93), (32, 92), (30, 89)], (116, 60, 52))
    paint("rear hip existing plate highlight", "copper",
          [(30, 83), (31, 84), (32, 87), (31, 89), (30, 86)], (148, 84, 68))
    paint("near hind shoulder plane", "copper",
          [(52, 91), (57, 89), (61, 91), (62, 93), (57, 93), (53, 95)], (140, 68, 52))
    paint("near hind shoulder lit ridge", "copper",
          [(53, 91), (57, 90), (60, 91), (59, 92), (55, 92)], (164, 100, 76))

    # Golden liquid cores are clipped to existing furnace heat pixels, so the
    # two chambers and all mullions/rails keep their original drawn structure.
    paint("large furnace orange surround", "heat",
          [(81, 58), (84, 59), (88, 61), (87, 69), (82, 70), (80, 67)], HEAT[2])
    paint("large furnace golden core", "heat",
          [(83, 61), (86, 62), (87, 64), (86, 67), (84, 69), (82, 67), (82, 64)], HEAT[3])
    paint("small furnace golden core", "heat",
          [(75, 64), (77, 64), (78, 66), (77, 68), (75, 67)], HEAT[3])

    # Preston's clarification: the large rust-colored rear panel is the
    # creature's stone hip/underside. Translate it to the front's silver-grey
    # rock ramp, keeping the existing seams, relief, rim and body silhouette.
    hip_area = polygon([(29, 80), (35, 81), (42, 83), (43, 88),
                        (41, 94), (34, 95), (30, 92), (28, 86)], original.size)
    hip_area &= surfaces["copper"] & visible & ~contour
    copper_to_stone = {COPPER[0]: STONE[0], COPPER[1]: STONE[1], COPPER[2]: STONE[2],
                       COPPER[3]: STONE[3], COPPER[4]: STONE[3], COPPER[5]: STONE[4],
                       COPPER[6]: STONE[4], COPPER[7]: STONE[4]}
    for old, new in copper_to_stone.items():
        select = hip_area & np.all(source[:, :, :3] == old, axis=2)
        result[select, :3] = new
    edits.append({"region": "rear hip rust-to-silver material correction",
                  "material": "stone", "painted_pixels": int(hip_area.sum()),
                  "mapping": [{"from": list(a), "to": list(b)} for a, b in copper_to_stone.items()]})
    # The same recessed rock continues under the shell into the rear limb
    # roots. This is an interior shading connection, not another armor pod.
    underside = polygon([(33, 94), (41, 92), (48, 86), (54, 86),
                         (55, 89), (49, 93), (45, 98), (38, 98), (32, 97)], original.size)
    underside &= visible & ~contour & ~surfaces["plum"] & ~surfaces["heat"]
    result[underside, :3] = STONE[1]
    edits.append({"region": "buried stone torso to rear limb roots", "material": "stone",
                  "rgb": list(STONE[1]), "painted_pixels": int(underside.sum())})
    hip_face = polygon([(31, 83), (35, 84), (39, 87), (39, 92),
                        (35, 94), (31, 91), (30, 87)], original.size) & hip_area
    result[hip_face, :3] = STONE[3]
    hip_turn = polygon([(39, 85), (41, 87), (41, 92), (39, 94),
                        (37, 93), (39, 90)], original.size) & hip_area
    result[hip_turn, :3] = STONE[2]
    hip_light = polygon([(31, 84), (32, 85), (34, 88), (34, 90),
                         (32, 89), (31, 87)], original.size) & hip_area
    result[hip_light, :3] = STONE[4]

    # Production guards enforce the texture-only contract before delivery.
    if not np.array_equal(source[:, :, 3], result[:, :, 3]):
        raise ValueError("Alpha changed; discard this candidate.")
    if not np.array_equal(source[contour], result[contour]):
        raise ValueError("Outer contour changed; discard this candidate.")
    front_palette = {tuple(c) for c in np.array(front)[np.array(front)[:, :, 3] > 0, :3].tolist()}
    result_palette = {tuple(c) for c in result[visible, :3].tolist()}
    if not result_palette.issubset(front_palette):
        raise ValueError("Candidate introduced a color outside the official front palette.")
    candidate = Image.fromarray(result)
    candidate.save(OUT / "back_texture_candidate.png")
    front_candidate, front_report = connect_front_hips(front)
    preview([("OFFICIAL FRONT", front), ("BACK BEFORE", original), ("BACK TEXTURE MATCH", candidate)],
            OUT / "front_back_texture_review_4x.png")
    preview([("FRONT BEFORE", front), ("FRONT: CONNECTED STONE HIPS", front_candidate),
             ("BACK: MATCHED STONE + FURNACE", candidate)], OUT / "front_back_final_review_4x.png")
    changed = np.any(result != source, axis=2)
    report = {"source": str(BACK), "source_sha256": hashlib.sha256(BACK.read_bytes()).hexdigest(),
              "front": str(FRONT), "front_sha256": hashlib.sha256(FRONT.read_bytes()).hexdigest(),
              "size": list(original.size), "source_bbox": original.getbbox(), "candidate_bbox": candidate.getbbox(),
              "changed_pixels": int(changed.sum()), "visible_pixels": int(visible.sum()),
              "before": stats(source), "after": stats(result), "regions": edits,
              "alpha_preserved": True, "outer_contour_preserved": True,
              "candidate_uses_front_colors_only": True,
              "front_hip_pass": front_report,
              "scope": "Interior texture and hip attachment shading. No silhouette, body-part placement, frame timing or registration edits."}
    (OUT / "texture_pass_manifest.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(json.dumps({key: report[key] for key in ["size", "source_bbox", "candidate_bbox", "changed_pixels", "visible_pixels"]}))


if __name__ == "__main__":
    main()
