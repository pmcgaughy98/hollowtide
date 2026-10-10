"""Whinet's expression edits drew a mouth on it (Claude, 2026-10-10): a dark line along the bottom of
the head with the legs turned cream like teeth below it, a bar between the two eyes, and a toothy far
eye. This keeps each edit's near eye and copies everything else in that lower-right area back from the
plain portrait. Surprised's near eye came back white, so it takes the plain eye too.
Run after rd_expressions.py whinet (rerunning that is free once the edits exist).
    python tools/ui/fix_whinet_legs.py
"""
from PIL import Image

DIR = "assets/sprites/ui/dialogue/"
FACES = ["happy", "surprised", "angry", "sad", "determined", "mischievous"]
BELOW_EYE = 26          # the head's underside, legs and proboscis: every row from here down
BESIDE_EYE = (29, 15)   # right of the near eye from row 15: the bar between the eyes and the far eye
NEAR_EYE = (17, 14, 29, 26)   # surprised only: the plain red eye in place of the white one

# The far eye (columns 33-36, behind the proboscis) gets the same lid as the near eye, drawn by hand:
# the row of the lid line in each column. Angry slants down toward the middle of the face (its left).
FAR_LIDS = {
    "angry": {33: 20, 34: 19, 35: 18, 36: 18},
    "sad": {33: 19, 34: 20, 35: 20, 36: 20},
    "determined": {33: 19, 34: 18, 35: 18, 36: 18},
    "mischievous": {33: 20, 34: 19, 35: 19, 36: 19},
}
LID_SKIN = (128, 121, 95, 255)   # the shaded side of the head
LID_LINE = (19, 18, 15, 255)

base = Image.open(DIR + "whinet.png").convert("RGBA")


def far_lid(im, lids):
    for x, line in lids.items():
        for y in range(15, line):
            if im.getpixel((x, y))[3] == 0:
                continue
            edge = x + 1 >= im.width or im.getpixel((x + 1, y))[3] == 0
            if not edge:   # keep the silhouette's own outline on the right
                im.putpixel((x, y), LID_SKIN)
        im.putpixel((x, line), LID_LINE)


def restore(im, x0, y0, x1, y1):
    for y in range(y0, y1):
        for x in range(x0, x1):
            im.putpixel((x, y), base.getpixel((x, y)))


for face in FACES:
    path = DIR + "whinet_%s.png" % face
    im = Image.open(path).convert("RGBA")
    restore(im, 0, BELOW_EYE, im.width, im.height)
    restore(im, BESIDE_EYE[0], BESIDE_EYE[1], im.width, BELOW_EYE)
    if face == "surprised":
        restore(im, *NEAR_EYE)
    if face in FAR_LIDS:
        far_lid(im, FAR_LIDS[face])
    im.save(path)
    print("fixed", path)
