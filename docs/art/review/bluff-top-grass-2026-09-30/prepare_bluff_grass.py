"""Recover the actual pixel patches in the user-generated grass sheet for review."""
from pathlib import Path
from collections import Counter
import json
import hashlib
import shutil
import numpy as np
from PIL import Image, ImageDraw, ImageFont

PROJECT = Path(r"C:\Users\pmcga\dev\hollowtide")
SRC = Path(r"C:\Users\pmcga\OneDrive\Documents\HollowTide Sprites\Assets\World-Tiles\Bluff-Top-Grass.jfif")
OUT = Path(__file__).parent / "bluff-grass-preparation-2026-09-30"
OUT.mkdir(exist_ok=True)
source = Image.open(SRC).convert("RGB")
array = np.array(source)
# The 1024px sheet has fifty drawing pixels per 256px nominal cell:
# one magenta gutter pixel each side, forty-eight actual material pixels.
period = 256 / 50
tiles = []
raws = []
for row in range(4):
    for col in range(4):
        out = np.empty((48,48,3), dtype=np.uint8)
        raw = np.empty_like(out)
        for y in range(48):
            for x in range(48):
                sx = int(col*256 + (x+1.5)*period)
                sy = int(row*256 + (y+1.5)*period)
                raw[y,x] = array[sy,sx]
                out[y,x] = np.median(array[sy-1:sy+2,sx-1:sx+2], axis=(0,1)).astype(np.uint8)
        raws.append(Image.fromarray(raw))
        tiles.append(Image.fromarray(out))

atlas_raw = Image.new("RGB", (192,192))
atlas_sampled = Image.new("RGB", (192,192))
for n,tile in enumerate(tiles):
    atlas_raw.paste(raws[n], ((n%4)*48,(n//4)*48))
    atlas_sampled.paste(tile, ((n%4)*48,(n//4)*48))
# Remove JPEG color noise within this one source family only. No game-wide palette.
atlas = atlas_sampled.quantize(colors=40, method=Image.Quantize.MEDIANCUT,
                               dither=Image.Dither.NONE).convert("RGB")
# The base grass plane drifted a few JPEG levels between source cells.
# Match only that plane, so the repetitions do not become a checkerboard.
aa = np.array(atlas)
base = np.array(Counter(atlas.crop((0,0,48,48)).get_flattened_data()).most_common(1)[0][0])
near_base = np.linalg.norm(aa.astype(float)-base,axis=2) < 8
aa[near_base] = base
atlas = Image.fromarray(aa)
atlas_raw.save(OUT / "bluff_grass_sampled_raw_192.png")
atlas.save(OUT / "bluff_grass_native_atlas_192.png")
native = []
for n in range(16):
    c,r=n%4,n//4
    tile=atlas.crop((c*48,r*48,(c+1)*48,(r+1)*48))
    tile.save(OUT / f"patch_{n:02d}_48.png")
    native.append(tile)

categories = ["CENTER A", "CENTER B", "CENTER A", "NE OUTER",
              "SW OUTER", "S EDGE A", "S EDGE B", "SE OUTER",
              "NW OUTER", "NE OUTER", "NW OUTER", "NE OUTER",
              "SW OUTER", "SE OUTER", "SW OUTER", "CENTER C"]
fontpath = Path(r"C:\Windows\Fonts\consola.ttf")
font = ImageFont.truetype(str(fontpath),18) if fontpath.exists() else ImageFont.load_default()
small = ImageFont.truetype(str(fontpath),15) if fontpath.exists() else ImageFont.load_default()
canvas = Image.new("RGB",(816,920),(28,33,41)); d = ImageDraw.Draw(canvas)
d.text((18,14),"BLUFF GRASS / RECOVERED 48px PATCHES",font=font,fill=(237,225,205))
d.text((18,43),"Source order is classified by visible art, not its requested labels.",font=small,fill=(169,180,176))
for n,tile in enumerate(native):
    x,y=(n%4)*200+12,(n//4)*208+82
    canvas.paste(tile.resize((192,192),Image.Resampling.NEAREST),(x,y))
    d.text((x,y+193),f"{n:02d} {categories[n]}",font=small,fill=(226,207,174))
canvas.save(OUT / "grass_patch_contact_sheet.png")

compare = Image.new("RGB",(840,338),(28,33,41)); dc=ImageDraw.Draw(compare)
for n,(label,im) in enumerate([("SOURCE",source.crop((5,5,251,251))),
                              ("48px / GRID RECOVERY",native[0]),
                              ("16px / DETAIL LOST",native[0].resize((16,16),Image.Resampling.NEAREST))]):
    x=n*280+15
    dc.text((x,14),label,font=font,fill=(237,225,205))
    compare.paste(im.resize((240,240),Image.Resampling.NEAREST),(x,54))
dc.text((16,309),"Keep the 48px patch; it fits 3x3 of the existing 16px map cells.",font=small,fill=(182,193,182))
compare.save(OUT / "grass_native_grid_comparison.png")

# Material/context study, not a recreation of Route 1 or an installed tileset.
# A south edge supplies a narrow border; its flipped copy is clearly a study
# for the missing north edge, not an approved new transition.
map_width,map_height=288,192
study=Image.new("RGB",(map_width,map_height))
order=[0,1,15,1,15,0,15,0,1,0,1,15,1,15,0,15,0,1,15,1,0,1,0,15]
for row in range(4):
    for col in range(6):
        study.paste(native[order[row*6+col]],(col*48,row*48))
dirt=native[3].crop((32,0,48,16))
for y in [112,128]:
    for x in range(0,map_width,16):
        study.paste(dirt,(x,y))
border=native[5].crop((0,16,48,32))
for x in range(0,map_width,48):
    study.paste(border,(x,96))
    study.paste(border.transpose(Image.Transpose.FLIP_TOP_BOTTOM),(x,144))

walk_path=PROJECT / "assets/sprites/player/male_vertical_walk_4x2_2026_09_27.png"
walk=Image.open(walk_path).convert("RGBA").crop((256,0,512,512))
walk=walk.crop(walk.getbbox())
walk=walk.resize((max(1,round(walk.width*36/walk.height)),36),Image.Resampling.NEAREST)
study.paste(walk,(148-walk.width//2,137-walk.height),walk)
study.save(OUT / "grass_route_material_study_native.png")
review=Image.new("RGB",(1216,714),(28,33,41)); dr=ImageDraw.Draw(review)
dr.text((18,14),"HOLLOWTIDE / BLUFF-TOP GRASS MATERIAL STUDY",font=font,fill=(237,225,205))
dr.text((18,44),"Recovered 48px terrain patches on a 16px map grid / current teal courier",font=small,fill=(180,190,179))
review.paste(study.resize((864,576),Image.Resampling.NEAREST),(16,80))
cinder_path=PROJECT / "assets/sprites/creatures/cinderhide.png"
cinder=Image.open(cinder_path).convert("RGBA")
cinder_box=Image.new("RGBA",cinder.size,(28,33,41,255)); cinder_box.alpha_composite(cinder)
dr.text((910,86),"APPROVED FINISH ANCHOR",font=small,fill=(230,209,176))
review.paste(cinder_box.convert("RGB").resize((300,300),Image.Resampling.NEAREST),(896,118))
for y,text in enumerate(["Ground is quieter", "than battle art.", "", "North border is a", "mirrored study only.", "", "Missing transitions", "need original art."]):
    dr.text((914,450+y*22),text,font=small,fill=(176,190,178))
dr.text((18,675),"CANDIDATE ONLY / no Route 1 change / missing N,E,W edges, inner corners and pure dirt",font=small,fill=(226,207,174))
review.save(OUT / "grass_route_material_review.png")

shutil.copy2(SRC, OUT / "source_bluff_top_grass.jfif")
manifest = {
    "status":"candidate terrain family; not a complete transition atlas; not installed",
    "source":str(SRC),"source_sha256":hashlib.sha256(SRC.read_bytes()).hexdigest(),
    "source_size":source.size,"nominal_sheet_layout":[4,4],
    "measured_grid_scale":period,"logical_cell_with_gutter":[50,50],
    "recovered_patch_size":[48,48],"native_atlas_size":[192,192],
    "native_palette_colors":len(set(atlas.get_flattened_data())),
    "method":"Recover the center of each 5.12px drawing block; median 3x3 JPEG-noise sample; source-family quantization without dithering and unify only near-identical base grass; preserve source patch shapes.",
    "patch_roles":[{"slot":n,"role":role,"file":f"patch_{n:02d}_48.png"} for n,role in enumerate(categories)],
    "missing_roles":["N edge","E edge","W edge","NW inner","NE inner","SE inner","SW inner","pure packed dirt"],
    "duplicate_roles":"Several outer corners and CENTER A repeat with small generated differences; not sixteen distinct transitions.",
    "map_geometry":"48px patches can cover 3x3 existing16px cells without changing map collision or scale; never shrink the family to16 just to fit a grid.",
    "context_preview":"Material study uses the actual current teal/goggles courier at36px visible height; Cinderhide is shown separately as the finish anchor. Its path uses an existing S border plus a vertically mirrored study for the missing N border; it is not Route1 geometry or a complete final TileSet.",
    "remaining_review":"Inspect repetition and seams; decide if the quiet grass finish fits the world before generating missing transitions. Courier identity is decided (teal/goggles); chibi turnaround/portrait art still needs approval."
}
(OUT/"grass_preparation_manifest.json").write_text(json.dumps(manifest,indent=2),encoding="utf-8")
print(json.dumps({"atlas":str(OUT/"bluff_grass_native_atlas_192.png"),"native_patch":48,"colors":manifest["native_palette_colors"],"missing":manifest["missing_roles"]},indent=2))
