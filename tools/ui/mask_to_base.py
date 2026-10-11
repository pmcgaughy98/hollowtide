"""Clip expression faces to the plain portrait's silhouette (Claude, 2026-10-10). Some edits leave a
fringe of stray pixels just outside the creature's outline (Gruntle's came back yellow); where the pose
does not change between faces, anything outside the base portrait's shape is background.
    python tools/ui/mask_to_base.py <form> <face> [face ...]
"""
import sys
from PIL import Image

DIR = "assets/sprites/ui/dialogue/"
form, faces = sys.argv[1], sys.argv[2:]
base = Image.open(DIR + form + ".png").convert("RGBA")
for face in faces:
    path = DIR + "%s_%s.png" % (form, face)
    im = Image.open(path).convert("RGBA")
    n = 0
    for y in range(im.height):
        for x in range(im.width):
            if base.getpixel((x, y))[3] < 128 and im.getpixel((x, y))[3] > 0:
                im.putpixel((x, y), (0, 0, 0, 0))
                n += 1
    im.save(path)
    print(path, "cleared", n)
