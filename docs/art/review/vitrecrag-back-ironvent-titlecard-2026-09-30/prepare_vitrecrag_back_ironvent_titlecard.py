"""Prepare Preston's approved 2026-09-30 art without changing its design."""
from pathlib import Path
from collections import Counter
import sys
import json
import argparse
import numpy as np
from PIL import Image, ImageDraw

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--project", type=Path, default=Path(r"C:\Users\pmcga\dev\hollowtide"))
parser.add_argument("--output", type=Path, required=True, help="Separate output directory; originals are never edited.")
parser.add_argument("--back-source", type=Path)
parser.add_argument("--titlecard-source", type=Path)
args = parser.parse_args()
ROOT = args.project.resolve()
ART = Path(r"C:\Users\pmcga\OneDrive\Documents\HollowTide Sprites")
WORK = args.output.resolve()
WORK.mkdir(parents=True, exist_ok=True)
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / "tools"))
import convert_forge_sprite as forge

def source_after_reorganization(current, previous):
    """Prefer current art folders while still accepting older layouts."""
    current_path = ART / current
    return current_path if current_path.is_file() else ART / previous

SOURCES = {
    "vitrecrag_back": args.back_source or source_after_reorganization(
        "Creatures/Creatures-Back/Vitrecrag-Back.jfif", "Creatures-Back/Vitrecrag-Back.jfif"),
    "ironvent_titlecard": args.titlecard_source or source_after_reorganization(
        "Creatures/Signature-Titlecards/Ironvent-titlecard.png", "Signature-Titlecards/Ironvent-titlecard.png"),
}
ANCHORS = {
    "vitrecrag_front": ROOT / "assets/sprites/creatures/vitrecrag_official.png",
    "vitrecrag_titlecard": ROOT / "assets/sprites/creatures/attacks/vitrecrag_lava_pour/style_matched/titlecard.png",
    "ironvent_front": ROOT / "assets/sprites/creatures/ironvent.png",
    "ironvent_roar": ROOT / "assets/sprites/creatures/attacks/ironvent_furnace_roar/style_matched/roar.png",
    "ironvent_old_titlecard": ROOT / "assets/sprites/creatures/attacks/ironvent_furnace_roar/style_matched/titlecard.png",
}

def stats(path):
    im = Image.open(path).convert("RGBA")
    counts = Counter(px[:3] for px in im.get_flattened_data() if px[3] >= 128)
    return {"path": str(path), "size": im.size, "bbox": im.getbbox(),
            "colours": len(counts), "palette": counts.most_common(90)}

def preview(name, path, factor=7):
    im = Image.open(path).convert("RGBA")
    bg = Image.new("RGBA", im.size, (27, 31, 39, 255))
    bg.alpha_composite(im)
    bg.convert("RGB").resize((im.width*factor, im.height*factor), Image.Resampling.NEAREST).save(WORK / f"{name}_7x.png")

def outline(mask):
    p = np.pad(mask, 1)
    return mask & ~(p[:-2, 1:-1] & p[2:, 1:-1] & p[1:-1, :-2] & p[1:-1, 2:])

def snap(rgb, palette):
    palette = np.array(palette, dtype=np.int32)
    distance = ((rgb[:, None].astype(np.int32) - palette[None]) ** 2 * np.array([0.8, 1.0, 0.7])).sum(2)
    return palette[distance.argmin(1)].astype(np.uint8)

def collapse_flecks(a, protected=None, maximum=140, difference=58):
    """One conservative, simultaneous pass; do not soften contours or hot cores."""
    src = a.copy()
    mask = a[:, :, 3] > 0
    edge = outline(mask)
    if protected is None:
        protected = np.zeros(mask.shape, bool)
    edited = 0
    for y in range(1, a.shape[0]-1):
        for x in range(1, a.shape[1]-1):
            col = tuple(src[y, x, :3])
            if not mask[y,x] or edge[y,x] or protected[y,x] or max(col) > maximum:
                continue
            if any(tuple(src[ny,nx,:3]) == col for nx,ny in [(x-1,y),(x+1,y),(x,y-1),(x,y+1)]):
                continue
            nearby = Counter(tuple(src[ny,nx,:3]) for ny in range(y-1,y+2) for nx in range(x-1,x+2)
                             if (nx,ny)!=(x,y) and mask[ny,nx] and not edge[ny,nx])
            if not nearby:
                continue
            other,count = nearby.most_common(1)[0]
            # Similar brightness and hue only: don't cross shell/trim/limb boundaries.
            if count < 3 or max(other) <= 28 or sum(abs(int(c)-int(d)) for c,d in zip(col,other)) > difference:
                continue
            purple = lambda c: c[2] > c[1]+8 and c[0] < c[2]+35
            if purple(col) != purple(other):
                continue
            a[y,x,:3] = other
            edited += 1
    return edited

def finish_back():
    raw = Image.open(WORK / "vitrecrag_back_converted.png").convert("RGBA")
    # Match the approved front's foot baseline. A translation, no rescaling.
    front = Image.open(ANCHORS["vitrecrag_front"]).convert("RGBA")
    aligned = Image.new("RGBA", raw.size)
    aligned.paste(raw, (0, front.getbbox()[3]-raw.getbbox()[3]))
    aligned.save(WORK / "vitrecrag_back_native_before.png")
    a = np.array(aligned)
    mask = a[:,:,3] > 0
    rgb = a[:,:,:3].astype(np.int32)
    r,g,b = rgb[:,:,0],rgb[:,:,1],rgb[:,:,2]
    edge = outline(mask)
    # Existing plum plate colours from the official front. Keep shell shades
    # separate from stone greys even where the source has greyish highlights.
    plum = mask & (b > g+5) & (r < b+35)
    plum &= ~((g < 0.45*np.minimum(r,b)) & (np.abs(r-b) < 30))
    plum_palette = [(20,12,20),(44,28,44),(60,36,52),(76,44,60),(124,84,100)]
    a[plum,:3] = snap(rgb[plum], plum_palette)
    # Furnace windows contain liquid light, not the copper rail highlights.
    yy,xx = np.indices(mask.shape)
    windows = (((xx>=79)&(xx<=94)&(yy>=52)&(yy<=78)) |
               ((xx>=72)&(xx<=80)&(yy>=64)&(yy<=75)))
    heat = mask & windows & (r>155) & (r>g*1.48) & (g>b*1.35)
    heat_palette = [(156,52,20),(220,92,36),(252,116,36),(252,156,76)]
    a[heat,:3] = snap(rgb[heat], heat_palette)
    official = np.array(front)
    palette = sorted(set(map(tuple, official[official[:,:,3]>0,:3])))
    body_palette = [c for c in palette if c not in [(156,52,20),(252,156,76),(220,92,36),(252,116,36)]]
    remainder = mask & ~plum & ~heat
    a[remainder,:3] = snap(rgb[remainder], body_palette)
    # Outline spill never becomes purple anatomy. Keep every silhouette pixel.
    spill = mask & (g < 0.45*np.minimum(r,b)) & (np.abs(r-b) < 30)
    a[spill,:3] = (20,12,20)
    a[edge,:3] = (20,12,20)
    protected = heat | windows | edge
    edited = collapse_flecks(a, protected, difference=48)
    a[~mask] = 0
    dest = WORK / "vitrecrag_back_official_2026_09_30.png"
    Image.fromarray(a).save(dest)
    if not np.array_equal(a[:,:,3], np.array(aligned)[:,:,3]):
        raise RuntimeError("Back silhouette changed")
    preview("vitrecrag_back_finished", dest)
    return dest, edited

def finish_titlecard():
    raw = Image.open(WORK / "ironvent_titlecard_converted.png").convert("RGBA")
    a = np.array(raw)
    mask = a[:,:,3] > 0
    rgb = a[:,:,:3].astype(np.int32)
    r,g,b = rgb[:,:,0],rgb[:,:,1],rgb[:,:,2]
    edge = outline(mask)
    # Ironvent's own stone/brown ramps, kept dark around the luminous vents.
    stone = [(4,4,4),(28,28,28),(36,12,12),(44,36,44),(44,44,44),
             (52,52,52),(68,68,68),(76,84,76),(92,92,92),(108,108,100),
             (52,28,28),(60,44,36),(68,36,20),(76,52,44),(84,68,52),
             (92,76,68),(108,92,76),(124,100,84)]
    warm = [(124,52,44),(148,60,36),(164,52,28),(172,68,44),(196,76,36),
            (220,92,28),(244,116,44),(244,140,44)]
    # Same pale gold highlight family as Vitrecrag's title card, plus two
    # reflected stone highlights already present in this approved artwork.
    lit_stone = [(148,124,100),(180,164,132)]
    light = [(252,156,76),(252,196,116),(252,228,164),(252,236,188),(252,252,236)]
    fiery = mask & ((r>145)&(r>g*1.45)&(g>b*1.45) | ((r>230)&(g>165)))
    a[fiery,:3] = snap(rgb[fiery], warm + light)
    rest = mask & ~fiery
    a[rest,:3] = snap(rgb[rest], stone + warm + lit_stone)
    # Local reflected light immediately beside the existing white-hot dorsal
    # openings. No new cracks, vents, flames or outside-body glow are drawn.
    yy,xx = np.indices(mask.shape)
    hot = mask & (r>230) & (g>155) & (xx<65) & (yy<48)
    p = np.pad(hot, 2)
    near = np.zeros_like(hot)
    touch = np.zeros_like(hot)
    for dy in range(-2,3):
        for dx in range(-2,3):
            if abs(dx)+abs(dy) <= 2:
                region = p[2+dy:2+dy+mask.shape[0],2+dx:2+dx+mask.shape[1]]
                near |= region
                if abs(dx)+abs(dy)==1:
                    touch |= region
    reflected = near & mask & ~fiery & ~edge & (rgb.max(2)>=44) & (rgb.max(2)<=132)
    a[reflected & touch,:3] = (196,76,36)
    a[reflected & ~touch,:3] = (148,60,36)
    a[edge,:3] = (4,4,4)
    # Preserve skull anatomy, eyes, horn joins and delicate fingers.
    protected = fiery | reflected | edge | ((xx>=50)&(yy<=48)) | (yy>=79)
    edited = collapse_flecks(a, protected, maximum=124, difference=38)
    a[~mask] = 0
    dest = WORK / "ironvent_titlecard_official_2026_09_30.png"
    Image.fromarray(a).save(dest)
    if not np.array_equal(a[:,:,3], np.array(raw)[:,:,3]):
        raise RuntimeError("Titlecard silhouette changed")
    preview("ironvent_titlecard_finished", dest)
    return dest, edited

def review_sheet(destinations):
    rows = [("CURRENT FRONT", ANCHORS["vitrecrag_front"]),
            ("FINISHED BACK", destinations[0]),
            ("NEW TITLE CARD", destinations[1]),
            ("VITRECRAG CARD REFERENCE", ANCHORS["vitrecrag_titlecard"])]
    tile_w,tile_h,factor = 660, 690, 5
    sheet = Image.new("RGB", (tile_w*2,tile_h*2), (27,31,39))
    draw = ImageDraw.Draw(sheet)
    for i,(label,path) in enumerate(rows):
        im = Image.open(path).convert("RGBA")
        x,y = (i%2)*tile_w,(i//2)*tile_h
        draw.text((x+20,y+12),label,fill=(233,222,204))
        im = im.resize((im.width*factor,im.height*factor),Image.Resampling.NEAREST)
        sheet.paste(im,(x+(tile_w-im.width)//2,y+42+(640-im.height)//2),im)
    sheet.save(WORK / "vitrecrag_back_ironvent_titlecard_review.png")

if __name__ == "__main__":
    report = {}
    for name, src in SOURCES.items():
        dest = WORK / f"{name}_converted.png"
        forge.convert(str(src), str(dest))
        report[name] = stats(dest)
        preview(name, dest)
    for name, path in ANCHORS.items():
        report[name] = stats(path)
        preview(name, path)
    (WORK / "analysis.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    for name, detail in report.items():
        print(name, json.dumps({k:v for k,v in detail.items() if k!="palette"}))
    back,back_edits = finish_back()
    card,card_edits = finish_titlecard()
    review_sheet([back,card])
    for label,path,edits in [("finished_back",back,back_edits),("finished_card",card,card_edits)]:
        print(label, json.dumps({k:v for k,v in stats(path).items() if k!="palette"}), "flecks merged", edits)
