"""Flat-fill silhouette test for the Town Spine Wayline Tower concept (proposal).

Draws the assembled 432x864 frame from the part rectangles in the concept, the current 300x576 placeholder stages
for comparison, then shrinks both to 25 percent and to the road far-view scale (about 74 px tall) with nearest
neighbour, so the read at small size can be judged by eye. Scratch only, nothing in the repo.
"""
from PIL import Image, ImageDraw

OUT = "C:/Users/pmcga/AppData/Local/Temp/claude/C--Users-pmcga-dev-hollowtide/a9e8a4f0-7051-47b8-8115-f9a36b2774b8/scratchpad/"
INK = (40, 34, 30, 255)
BG = (214, 226, 222, 255)


def spine(colour=True):
    im = Image.new("RGBA", (432, 864), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    stone, deck, root, timber, brass, amber, teal = (
        (204, 178, 144, 255), (144, 137, 64, 255), (140, 101, 69, 255), (146, 114, 75, 255),
        (196, 146, 67, 255), (251, 212, 144, 255), (52, 128, 120, 255))
    if not colour:
        stone = deck = root = timber = brass = amber = teal = INK
    # T1 footing and depot (the door-bearing core, 288x192 at 72,672)
    d.rectangle((72, 696, 359, 767), fill=deck)            # depot roof deck seen from above
    d.rectangle((72, 768, 359, 863), fill=stone)           # front wall
    d.ellipse((80, 736, 172, 792), fill=deck)              # porch moss dome (left)
    d.rectangle((316, 700, 334, 760), fill=stone)          # mess chimney stack
    # stair turret (right) 72 wide, foot to the cap
    d.rectangle((360, 440, 431, 863), fill=stone)
    d.ellipse((354, 392, 437, 462), fill=deck)             # turret moss dome
    d.rectangle((324, 412, 372, 428), fill=timber)         # bridge to the ring
    # T2 sorting drum
    d.rectangle((108, 448, 323, 751), fill=stone)
    # hoist jib (left), rope and basket
    d.polygon([(108, 486), (10, 474), (10, 484), (108, 498)], fill=timber)
    d.line((108, 540, 30, 482), fill=timber, width=7)
    d.rectangle((8, 476, 22, 498), fill=brass)
    d.line((15, 498, 15, 610), fill=INK, width=1)
    d.rectangle((8, 610, 24, 624), fill=timber)
    # chutes (overlay, right, down to the depot deck)
    d.line((300, 560, 352, 712), fill=timber, width=10)
    d.line((280, 600, 330, 730), fill=timber, width=8)
    # T3 the Wayline Ring (gallery deck, wider than the drum) and the landings drum
    d.rectangle((72, 404, 359, 443), fill=timber)
    d.rectangle((132, 232, 299, 415), fill=stone)
    d.rectangle((299, 278, 384, 290), fill=timber)         # landing boards
    d.rectangle((299, 328, 362, 338), fill=timber)
    d.rectangle((380, 244, 383, 290), fill=timber)         # windsock pole
    d.polygon([(383, 246), (404, 250), (404, 256), (383, 258)], fill=teal)
    d.polygon([(64, 404), (92, 326), (120, 404)], outline=timber, width=6)   # bell A-frame (left)
    d.ellipse((80, 352, 104, 380), fill=brass)
    # T4 crown: lantern deck, caged lantern, carry-handle loop, vane, pennant
    d.rectangle((132, 184, 299, 239), fill=timber)
    d.rectangle((156, 96, 275, 199), fill=brass)
    d.rectangle((168, 110, 263, 186), fill=amber)
    d.ellipse((150, 72, 281, 116), fill=brass)
    d.arc((164, 8, 267, 150), 180, 360, fill=brass, width=12)  # the open handle loop over the cage
    d.rectangle((210, 0, 222, 14), fill=brass)
    d.polygon([(222, 2), (246, 6), (222, 12)], fill=teal)
    # pass 2 (after looking): round the decks, flare the footing, add the great root sweeping up the left
    d.ellipse((104, 432, 327, 466), fill=deck)             # sorting drum's moss top seen from above
    d.ellipse((60, 394, 371, 456), fill=timber)            # the Ring as a rounded deck, not a box
    d.ellipse((124, 172, 307, 248), fill=timber)           # lantern deck, rounded
    d.polygon([(48, 863), (64, 816), (367, 816), (384, 863)], fill=stone)   # boulder footing flares out
    d.polygon([(0, 863), (0, 826), (26, 772), (58, 700), (88, 628), (110, 566), (128, 560), (120, 610),
               (104, 690), (90, 770), (80, 863)], fill=root)                # the great root, left
    d.polygon([(384, 863), (400, 836), (431, 828), (431, 863)], fill=root)  # root foot under the turret
    # waylines: three anchor posts on the ring, lines fanning down to the frame edges
    for ax, ay, bx, by in ((84, 440, 0, 640), (216, 452, 140, 863), (348, 440, 431, 600)):
        d.line((ax, ay, bx, by), fill=INK, width=1)
    # door (dark) inside the arch, for reference
    if colour:
        d.ellipse((180, 772, 251, 830), fill=stone)
        d.rectangle((192, 798, 239, 861), fill=(20, 18, 16, 255))
    return im


def old():
    im = Image.new("RGBA", (300, 576), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    for x, y, w, h in ((146, 2, 9, 28), (114, 30, 72, 26), (120, 56, 60, 48), (84, 104, 132, 16),
                       (96, 120, 108, 326), (6, 422, 288, 154)):
        d.rectangle((x, y, x + w - 1, y + h - 1), fill=INK)
    return im


def shrink(im, f):
    return im.resize((max(1, round(im.width * f)), max(1, round(im.height * f))), Image.NEAREST)


new_c, new_s, old_s = spine(True), spine(False), old()
sheet = Image.new("RGBA", (432 + 300 + 108 + 75 + 37 + 30 + 16 * 7, 900), BG)
x = 16
for im in (new_c, new_s, old_s):
    sheet.alpha_composite(im, (x, 900 - 16 - im.height)); x += im.width + 16
# 25 percent and the far-view scale (74 px tall), plus that at the scene's 0.82
for im in (shrink(new_s, 0.25), shrink(old_s, 0.25 * 576 / 864 * 1.5), shrink(new_s, 74 / 864),
           shrink(shrink(new_s, 74 / 864), 0.82)):
    sheet.alpha_composite(im, (x, 900 - 16 - im.height)); x += im.width + 16
sheet = sheet.resize((sheet.width * 2, sheet.height * 2), Image.NEAREST)
sheet.save(OUT + "spine_silhouette_sheet.png")
far = Image.new("RGBA", (160, 96), BG)
far.alpha_composite(shrink(new_s, 74 / 864), (74, 96 - 76))
far.resize((640, 384), Image.NEAREST).save(OUT + "spine_far_view_x4.png")
print("ok", sheet.size)
