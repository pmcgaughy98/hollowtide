from pathlib import Path
from PIL import Image, ImageDraw
import json

ROOT = Path(__file__).resolve().parent
SOURCE = Path('C:/Users/pmcga/dev/hollowtide/assets/sprites/player/retro_diffusion_chibi_walking_2026_10_01/male_chibi_walk_eight_directions_native80.png')
atlas = Image.open(SOURCE).convert('RGBA')
canvas = Image.new('RGB', (1280, 720), '#727a70')
draw = ImageDraw.Draw(canvas)
stats = {}
for i, (row, label) in enumerate([(2, 'left'), (6, 'right'), (3, 'up-left'), (5, 'up-right')]):
    draw.text((8, i * 180 + 2), label, fill='white')
    stats[label] = []
    for col in range(8):
        frame = atlas.crop((col * 80, row * 80, (col + 1) * 80, (row + 1) * 80))
        box = frame.getbbox()
        stats[label].append({'frame': col, 'bounds': box, 'size': [box[2]-box[0], box[3]-box[1]]})
        canvas.paste(frame.resize((160, 160), Image.Resampling.NEAREST), (col * 160, i * 180 + 18), frame.resize((160, 160), Image.Resampling.NEAREST))
canvas.save(ROOT / 'male_turns_before.png')
(ROOT / 'male_turns_before.json').write_text(json.dumps(stats, indent=2))
print(json.dumps(stats))
