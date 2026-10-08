"""Assemble the five actual saved game walk directions for each form for inspection."""
from pathlib import Path
from PIL import Image
W=Path(__file__).resolve().parent
for name in ['slagglass','preostmar','oathfen','oxbowarchon','punchybun','sparkjab','starward']:
    rows=[]
    for f in ['s','se','e','ne','n']:
        im=Image.open(W/f'candidate-review/contacts/{name}-walk-{f}-before-after-game3x.png')
        rows.append(im.crop((0,im.height//2,im.width,im.height)))
    sheet=Image.new('RGB',(max(im.width for im in rows),sum(im.height for im in rows)),(40,47,51))
    y=0
    for row in rows:sheet.paste(row,(0,y));y+=row.height
    sheet.save(W/f'candidate-review/contacts/{name}-all-walks-after-game3x.png')
