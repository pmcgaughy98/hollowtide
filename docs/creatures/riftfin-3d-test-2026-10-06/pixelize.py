"""Render the 3D test model's turntable views down to Riftfin's sprite size and palette (Claude, 2026-10-06).
Each view: background removed, shrunk with nearest-neighbour so the body is as tall as the sprite's,
colours mapped to the current front sprite's palette, and a 1 px dark outline added like the 2D art."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
D = Path("docs/creatures/riftfin-3d-test-2026-10-06")
front = Image.open("assets/sprites/creatures/starter_material_detail_2026_10_05/502_riftfin_front_material_detail.png").convert("RGBA")
back_old = Image.open("assets/sprites/creatures/rimefin_catfish_2026_10_05/riftfin_back.png").convert("RGBA")
take1 = Image.open("docs/creatures/riftfin-back-2026-10-06/riftfin_back_front_take1.png").convert("RGBA")
tt = Image.open(D / "turntable.png").convert("RGBA")
bg = tt.getpixel((2, 2))[:3]
pal_src = front.convert("RGB").quantize(colors=48, method=Image.Quantize.MEDIANCUT)
def pixelize(view, height):
    px = view.load()
    for y in range(view.height):
        for x in range(view.width):
            r, g, b, a = px[x, y]
            if abs(r - bg[0]) + abs(g - bg[1]) + abs(b - bg[2]) < 18:
                px[x, y] = (0, 0, 0, 0)
    view = view.crop(view.getbbox())
    k = height / view.height
    small = view.resize((max(1, round(view.width * k)), height), Image.Resampling.BOX)
    alpha = small.getchannel("A").point(lambda a: 255 if a > 110 else 0)
    rgb = small.convert("RGB").quantize(palette=pal_src, dither=Image.Dither.NONE).convert("RGB")
    out = Image.new("RGBA", (small.width + 2, small.height + 2))
    out.paste(rgb, (1, 1), alpha)
    grown = out.getchannel("A").filter(ImageFilter.MaxFilter(3))
    line = Image.new("RGBA", out.size, (16, 24, 34, 255))
    edged = Image.new("RGBA", out.size); edged.paste(line, (0, 0), grown); edged.alpha_composite(out)
    return edged
h = front.getbbox()[3] - front.getbbox()[1]
views = [tt.crop((i * 256, 0, (i + 1) * 256, 256)) for i in range(4)]
front3d, back3d = pixelize(views[3].copy(), h), pixelize(views[2].copy(), h)
front3d.save(D / "front_3d_pixel.png"); back3d.save(D / "back_3d_pixel.png")
cells = [("2D front (current)", front), ("3D front, pixelized", front3d), ("2D back (current)", back_old),
         ("2D back take 1", take1), ("3D back, pixelized", back3d)]
W = 240; s = Image.new("RGBA", (W * 5, 300), (40, 44, 52, 255)); d = ImageDraw.Draw(s)
for i, (n, im) in enumerate(cells):
    im = im.crop(im.getbbox())
    if im.width > W - 8:
        im = im.resize((W - 8, round(im.height * (W - 8) / im.width)), Image.NEAREST)
    s.alpha_composite(im, (i * W + (W - im.width) // 2, 296 - im.height)); d.text((i * W + 6, 6), n, fill=(225, 225, 225, 255))
s = s.resize((s.width * 2 // 2, s.height), Image.NEAREST)
s.save(D / "riftfin_2d_vs_3d.png")
