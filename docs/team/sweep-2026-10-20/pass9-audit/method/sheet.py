"""Contact sheet of probe shots (pass 9 audit, scratch). python sheet.py out.png scale cols shot1.png shot2.png ...
Each tile is labelled with its file name. Read-only on the shots."""
import sys
from pathlib import Path
from PIL import Image, ImageDraw

out, scale, cols = sys.argv[1], float(sys.argv[2]), int(sys.argv[3])
paths = [Path(p) for p in sys.argv[4:]]
ims = [Image.open(p).convert("RGB") for p in paths]
w, h = int(ims[0].width * scale), int(ims[0].height * scale)
rows = (len(ims) + cols - 1) // cols
sheet = Image.new("RGB", (cols * w, rows * (h + 14)), (40, 0, 40))
d = ImageDraw.Draw(sheet)
for i, (p, im) in enumerate(zip(paths, ims)):
    x, y = (i % cols) * w, (i // cols) * (h + 14)
    sheet.paste(im.resize((w, h), Image.NEAREST if scale >= 1 else Image.BILINEAR), (x, y + 14))
    d.text((x + 3, y + 1), p.stem, fill=(255, 255, 0))
sheet.save(out)
print(out, sheet.size)
