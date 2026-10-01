"""Match Vitrecrag's used attack hip materials to the updated official idle.

Pixel-only finishing of existing selected whole poses. Original source sheets,
animation order, holds, alpha, outer edge and effects are unchanged. Use archived
before/ files for an exact rebuild after installation.
"""
import argparse
import hashlib
import json
import shutil
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

STONE = [(28,28,28),(52,44,36),(68,52,44),(92,76,68),(124,108,100)]
# Ordered rear, near-middle, far-middle and fore hip roots. Each was inspected
# in its own native frame; the lowered head and forward tip have distinct roots.
POSES = {
 "plate/load": [(28,84),(45,85),(59,87),(75,89)],
 "plate/brace": [(28,82),(47,86),(64,85),(76,89)],
 "plate/launch": [(26,82),(45,84),(64,85),(77,89)],
 "plate/contact": [(27,84),(45,89),(62,89),(74,90)],
 "plate/recover": [(28,84),(47,84),(61,85),(75,87)],
 "glass/load": [(33,85),(50,87),(67,86),(82,89)],
 "glass/hole": [(32,88),(53,91),(65,91),(81,96)],
 "glass/flood": [(33,81),(51,83),(67,83),(82,87)],
 "glass/overload": [(32,82),(51,82),(67,82),(81,85)],
 "glass/overload_pour_a": [(32,82),(51,82),(67,82),(81,85)],
 "glass/overload_pour_b": [(32,82),(51,82),(67,82),(81,85)],
 "glass/breakout": [(33,82),(52,83),(67,82),(81,86)],
 "glass/recover": [(33,84),(52,85),(66,86),(80,88)],
}
FRAME_NOTES = {
 "plate/load": ("sheet4_f01", "Early forward load; shell high, head down a little, existing wide legs planted."),
 "plate/brace": ("sheet4_f02", "Head tucks down; body remains on the planted feet during the code draw-back/brace."),
 "plate/launch": ("sheet4_f03", "Plate begins extending; body leans and roots follow that lean."),
 "plate/contact": ("sheet4_f04", "Fully extended plate reaches low; shell tips forward and the rear loads upward."),
 "plate/recover": ("sheet4_f05", "Plate retracts and torso rises; roots stay buried as it returns to idle."),
 "glass/load": ("sheet2_f01", "Head lowers; loaded furnace remains inside the shell; legs stay planted."),
 "glass/hole": ("sheet4_f01", "Head recessed, glowing front opening low; torso and hip roots descend with this pose."),
 "glass/flood": ("sheet2_f02", "Raised shell glows orange during brace/strain; copper and furnace light are intentional."),
 "glass/overload": ("overload.png", "Pressure peak, mouth-glass bulge and hanging droplets; whole original overload pose preserved."),
 "glass/overload_pour_a": ("overload.png + sheet2_f04 stream", "Same pressure body; thick pouring strand and foot-level pool in phase A."),
 "glass/overload_pour_b": ("overload.png + sheet1_f04 stream", "Same pressure body; alternate flowing strand and pool in phase B."),
 "glass/breakout": ("sheet2_f03", "Head/front opens with the first material stream; body settles out of the pressure peak."),
 "glass/recover": ("sheet2_f05", "Head returns with cooling material at the mouth; torso returns toward the neutral stance."),
}
DIRS = {"plate":"vitrecrag_plate_lunge", "glass":"vitrecrag_lava_pour"}

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def silhouette(mask):
    p = np.pad(mask,1)
    interior = p[:-2,1:-1] & p[2:,1:-1] & p[1:-1,:-2] & p[1:-1,2:]
    return mask & ~interior

def polygon(points, size):
    image = Image.new("1",size)
    ImageDraw.Draw(image).polygon(points,fill=1)
    return np.asarray(image,dtype=bool)

def palette(image):
    a=np.asarray(image)
    return set(map(tuple,a[a[:,:,3]>0,:3].tolist()))

def finish(image,roots):
    src=np.asarray(image).copy()
    out=src.copy()
    visible=src[:,:,3]>0
    contour=silhouette(visible)
    r,g,b=(src[:,:,i].astype(int) for i in range(3))
    # Keep existing plum shell planes and hot liquid/drips. Dark internal lines
    # may become recessed stone where a closed hip socket formerly sat.
    plum=(b>g+8)&(b>=r*0.7)&(np.maximum.reduce([r,g,b])<150)
    ink=np.all(src[:,:,:3]==[20,12,20],axis=2)
    plum &= ~ink
    heat=(np.maximum.reduce([r,g,b])>205)|((r>=150)&(g>=50)&(b<60))
    protected=contour|plum|heat
    regions=[]
    def plane(name,points,color):
        area=polygon(points,image.size)&visible&~protected
        changed=area&np.any(out[:,:,:3]!=color,axis=2)
        out[area,:3]=color
        regions.append({"name":name,"polygon":points,"rgb":color,"changed":int(changed.sum())})
    top=[(x,y-2) for x,y in roots]
    bottom=[(x,y+2) for x,y in reversed(roots)]
    plane("recessed continuous stone torso",top+bottom,STONE[1])
    x,y=roots[0]
    plane("rear hip seated beneath torso",[(x-3,y),(x-1,y-2),(x+3,y-1),(x+3,y+2),(x,y+4),(x-3,y+2)],STONE[2])
    plane("rear hip upper stone face",[(x-1,y-1),(x+1,y-1),(x+2,y),(x,y+2),(x-1,y+1)],STONE[3])
    x,y=roots[1]
    plane("near middle hip continuous stone root",[(x-4,y-1),(x-1,y-3),(x+3,y-2),(x+4,y+2),(x+2,y+5),(x-2,y+4),(x-4,y+1)],STONE[3])
    plane("near middle hip upper-left light",[(x-2,y-2),(x,y-2),(x+1,y),(x-1,y+2),(x-2,y+1)],STONE[4])
    x,y=roots[2]
    plane("far middle hip buried behind near leg",[(x-3,y-1),(x+2,y-1),(x+3,y+2),(x,y+4),(x-3,y+2)],STONE[2])
    x,y=roots[3]
    plane("fore hip continuous under-shell root",[(x-3,y-1),(x+1,y-1),(x+3,y+1),(x+2,y+3),(x-2,y+2)],STONE[2])
    if not np.array_equal(src[:,:,3],out[:,:,3]) or not np.array_equal(src[contour],out[contour]):
        raise ValueError("Rejected: alpha or silhouette pixels changed")
    if not np.array_equal(src[protected],out[protected]):
        raise ValueError("Rejected: shell or hot material changed")
    return Image.fromarray(out),regions

def review(images,path):
    scale=4
    w,h=588,556
    out=Image.new("RGB",(w*5,h*((len(images)+4)//5)),(34,38,48))
    draw=ImageDraw.Draw(out)
    for i,(name,image) in enumerate(images):
        x=(i%5)*w;y=(i//5)*h
        draw.text((x+12,y+12),name,fill=(240,224,201))
        up=image.resize((image.width*scale,image.height*scale),Image.Resampling.NEAREST)
        out.paste(up,(x+12,y+32),up)
    out.save(path)

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project",type=Path,required=True)
    parser.add_argument("--output",type=Path,required=True)
    parser.add_argument("--sources",type=Path,help="Archived before/ folder for rebuilding")
    args=parser.parse_args()
    args.output.mkdir(parents=True,exist_ok=True)
    official=Image.open(args.project/"assets/sprites/creatures/vitrecrag_official.png").convert("RGBA")
    valid_colors=palette(official)
    entries=[];before=[("UPDATED IDLE",official)];after=[("UPDATED IDLE",official)]
    generated={}
    for key,roots in POSES.items():
        family,name=key.split("/")
        rel=f"assets/sprites/creatures/attacks/{DIRS[family]}/style_matched/{name}.png"
        source=args.sources/family/f"{name}.png" if args.sources else args.project/rel
        original=Image.open(source).convert("RGBA")
        target=args.output/"candidates"/family/f"{name}.png"
        target.parent.mkdir(parents=True,exist_ok=True)
        backup=args.output/"before"/family/f"{name}.png"
        backup.parent.mkdir(parents=True,exist_ok=True)
        if backup.exists() and digest(backup)!=digest(source):
            raise ValueError(f"Archived original differs: {key}")
        if source.resolve()!=backup.resolve():
            shutil.copy2(source,backup)
        result,regions=finish(original,roots)
        added=palette(result)-palette(original)
        if not added.issubset(valid_colors):
            raise ValueError(f"Unknown material colors: {key}")
        result.save(target)
        src=np.asarray(original);out=np.asarray(result)
        changed=int(np.any(src!=out,axis=2).sum())
        entries.append({"id":key,"path":rel,"source":str(source),"source_sha256":digest(source),
          "candidate":str(target),"candidate_sha256":digest(target),"canvas":list(result.size),
          "source_frame":FRAME_NOTES[key][0],"observation":FRAME_NOTES[key][1],
          "facing":"front three-quarter, toward screen right","decision":"retain original whole pose and timing; finish hip material only",
          "roots":roots,"regions":regions,"changed_pixels":changed,"alpha_exact":True,
          "outer_contour_exact":True,"shell_and_heat_exact":True,
          "before_colors":len(palette(original)),"after_colors":len(palette(result))})
        before.append((key,original));after.append((key,result));generated[key]=(original,result)
    key="glass/titlecard"
    rel="assets/sprites/creatures/attacks/vitrecrag_lava_pour/style_matched/titlecard.png"
    source=args.sources/"glass/titlecard.png" if args.sources else args.project/rel
    original=Image.open(source).convert("RGBA")
    overload_before,overload_after=generated["glass/overload"]
    # Every visible title-card pixel matches overload at offset (9,29).
    # Transfer those same material changes, never independently redesign it.
    src=np.asarray(original).copy()
    ov0=np.asarray(overload_before.crop((9,29,129,122)))
    ov1=np.asarray(overload_after.crop((9,29,129,122)))
    visible=src[:,:,3]>0
    if original.size!=(120,93) or not np.array_equal(src[visible],ov0[visible]):
        raise ValueError("Title card no longer matches the inspected overload crop")
    out=src.copy();out[visible]=ov1[visible]
    contour=silhouette(visible)
    if not np.array_equal(src[:,:,3],out[:,:,3]) or not np.array_equal(src[contour],out[contour]):
        raise ValueError("Title-card registration changed")
    target=args.output/"candidates/glass/titlecard.png";backup=args.output/"before/glass/titlecard.png"
    if backup.exists() and digest(backup)!=digest(source):
        raise ValueError("Title card source differs from archive")
    if source.resolve()!=backup.resolve(): shutil.copy2(source,backup)
    result=Image.fromarray(out);result.save(target)
    entries.append({"id":key,"path":rel,"source":str(source),"source_sha256":digest(source),
       "candidate":str(target),"candidate_sha256":digest(target),"canvas":list(result.size),
       "source_frame":"exact visible overload crop at +9,+29","observation":"pressure title-card close-up; same body and drip pose as overload",
       "facing":"front three-quarter, toward screen right","decision":"same hip edit as overload, exact cropped registration retained",
       "changed_pixels":int(np.any(src!=out,axis=2).sum()),"alpha_exact":True,"outer_contour_exact":True,
       "before_colors":len(palette(original)),"after_colors":len(palette(result))})
    before.append((key,original));after.append((key,result))
    review(before,args.output/"before_frames_4x.png")
    review(after,args.output/"after_frames_4x.png")
    review([("UPDATED IDLE",official),("PLATE LOAD BEFORE",generated["plate/load"][0]),
            ("PLATE LOAD AFTER",generated["plate/load"][1]),("GLASS LOAD BEFORE",generated["glass/load"][0]),
            ("GLASS LOAD AFTER",generated["glass/load"][1])],args.output/"idle_entry_comparison_4x.png")
    manifest={"date":"2026-10-01","official_front":str(args.project/"assets/sprites/creatures/vitrecrag_official.png"),
        "official_sha256":digest(args.project/"assets/sprites/creatures/vitrecrag_official.png"),
        "scope":"Interior hip connection shading only, selected live frames. No source-sheet cuts, pose/order/timing changes, or resampling.",
        "frames":entries}
    (args.output/"manifest.json").write_text(json.dumps(manifest,indent=2),encoding="utf-8")
    print(json.dumps([{"id":e["id"],"changed":e["changed_pixels"],"canvas":e["canvas"]} for e in entries]))

if __name__=="__main__":
    main()
