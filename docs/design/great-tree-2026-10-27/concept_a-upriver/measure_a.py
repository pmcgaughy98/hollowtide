"""Measure the concept A mocks: colours in the repainted backdrop area, and the tree's box."""
from PIL import Image

HERE = "C:/Users/pmcga/dev/hollowtide/docs/design/great-tree-2026-10-27/concept_a-upriver"
B = "C:/Users/pmcga/dev/hollowtide/docs/design/wayline-tower-2026-10-27/build"


def load1x(p):
    im = Image.open(p).convert("RGB")
    if im.size == (1152, 648):
        im = im.resize((384, 216), Image.NEAREST)
    return im


for name, src, sky in [
    ("hold", B + "/round2/11_reveal_hold_top.png",
     ["#2e3b52", "#3a4a60", "#4a5e73", "#566c80", "#62788a", "#7f939a", "#a3a891", "#c2b58f", "#d9bf94"]),
    ("vista", B + "/round2/13_road_vista.png",
     ["#56708e", "#6a84a0", "#879db0", "#a9b5ba", "#cdc6b4", "#e4cba6", "#f0d59f", "#f7e3b5"]),
    ("title", B + "/title_highbank_1x.png",
     ["#1e302e", "#263d3a", "#33524e", "#43665a", "#61785c", "#9f946d", "#dca562"]),
]:
    a = load1x(src)
    b = Image.open(HERE + "/%s_tree_1x.png" % name).convert("RGB")
    pa, pb = a.load(), b.load()
    skyc = {tuple(int(h[i:i + 2], 16) for i in (1, 3, 5)) for h in sky}
    backdrop = set()
    changed = 0
    xs, ys = [], []
    for y in range(a.height):
        for x in range(a.width):
            if pa[x, y] != pb[x, y]:
                changed += 1
                xs.append(x)
                ys.append(y)
                backdrop.add(pb[x, y])
            elif pa[x, y] in skyc:
                backdrop.add(pb[x, y])
    print(name, "changed px", changed, "backdrop colours", len(backdrop),
          "changed box x %d-%d y %d-%d" % (min(xs), max(xs), min(ys), max(ys)))
