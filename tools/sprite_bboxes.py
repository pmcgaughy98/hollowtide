"""One-off diagnostic: how much of its canvas each creature sprite actually fills.

Read-only. Prints, per sprite: canvas size, the opaque content bounding box, the
content height and width in pixels, and the on-screen size the battle screen
would draw it at (whole-number zoom toward CREATURE_HEIGHT * battle_size).

Delete this file once the size pass is done; it has no runtime role.
"""
import glob
import os

from PIL import Image

CREATURE_HEIGHT = 264


def main() -> None:
    print("%-26s %-11s %-20s %-9s %-8s %s" % (
        "file", "canvas", "content bbox", "content", "zoom", "on-screen"))
    for path in sorted(glob.glob("assets/sprites/creatures/*.png")):
        with Image.open(path) as image:
            canvas = image.size
            box = image.convert("RGBA").getbbox()
        if box is None:
            continue
        width = box[2] - box[0]
        height = box[3] - box[1]
        zoom = max(1, round(CREATURE_HEIGHT / canvas[1]))
        print("%-26s %-11s %-20s %-9s %-8d %dx%d" % (
            os.path.basename(path),
            "%dx%d" % canvas,
            "%d,%d,%d,%d" % box,
            "%dx%d" % (width, height),
            zoom,
            width * zoom,
            height * zoom,
        ))


if __name__ == "__main__":
    main()
