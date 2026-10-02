from pathlib import Path
from PIL import Image, ImageDraw, ImageOps
import hashlib, json

ROOT = Path(__file__).resolve().parent
SOURCE = Path('C:/Users/pmcga/dev/hollowtide/assets/sprites/player/retro_diffusion_chibi_walking_2026_10_01/male_chibi_walk_eight_directions_native80.png')
atlas = Image.open(SOURCE).convert('RGBA')
final = atlas.copy()
checks = []
for src_row, dst_row in [(2, 6), (3, 5)]:
    for col in range(8):
        box = (col*80, src_row*80, (col+1)*80, (src_row+1)*80)
        src = atlas.crop(box)
        mirror = ImageOps.mirror(src)
        dest = (col*80, dst_row*80, (col+1)*80, (dst_row+1)*80)
        final.paste(mirror, (dest[0], dest[1]))
        assert final.crop(dest).tobytes() == mirror.tobytes()
        b = src.getbbox()
        checks.append({'source_row': src_row, 'destination_row': dst_row, 'beat': col, 'height': b[3]-b[1], 'exact_mirror': True})
for row in [0,1,2,3,4,7]:
    box = (0, row*80, 640, (row+1)*80)
    assert final.crop(box).tobytes() == atlas.crop(box).tobytes()
output = ROOT / 'male_chibi_walk_matched_turns_native80.png'
final.save(output)
manifest = {'source': str(SOURCE), 'source_sha256': hashlib.sha256(SOURCE.read_bytes()).hexdigest(), 'output_sha256': hashlib.sha256(output.read_bytes()).hexdigest(), 'unchanged_rows': [0,1,2,3,4,7], 'corrected_rows': [5,6], 'method': 'Per-frame horizontal reflection of approved left and up-left. No resampling. Accessories follow the reflection.', 'checks': checks}
(ROOT / 'male_turn_correction.json').write_text(json.dumps(manifest, indent=2))
canvas = Image.new('RGB', (1280,720), '#727a70')
draw = ImageDraw.Draw(canvas)
for i, (row, label) in enumerate([(2,'left: unchanged'),(6,'right: matched'),(3,'up-left: unchanged'),(5,'up-right: matched')]):
    draw.text((8, i*180+2), label, fill='white')
    for col in range(8):
        frame = final.crop((col*80,row*80,(col+1)*80,(row+1)*80)).resize((160,160),Image.Resampling.NEAREST)
        canvas.paste(frame,(col*160,i*180+18),frame)
canvas.save(ROOT / 'male_turns_matched.png')
gif_frames=[]
for col in range(8):
    tile=Image.new('RGB',(480,180),'#727a70')
    d=ImageDraw.Draw(tile)
    for idx,(row,label) in enumerate([(2,'left'),(6,'right'),(3,'up-left'),(5,'up-right')]):
        f=final.crop((col*80,row*80,(col+1)*80,(row+1)*80)).resize((120,120),Image.Resampling.NEAREST)
        tile.paste(f,(idx*120,28),f)
        d.text((idx*120+10,8),label,fill='white')
    gif_frames.append(tile)
gif_frames[0].save(ROOT/'male_turns_matched.gif',save_all=True,append_images=gif_frames[1:],duration=125,loop=0,optimize=False)
print(json.dumps({'output':str(output),'checks':len(checks),'unchanged_rows':manifest['unchanged_rows']}))
