"""Cut, key and register the original chibi courier for Claude's integration."""
from pathlib import Path
from collections import Counter, deque
import json
import hashlib
import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT=Path(r"C:\Users\pmcga\dev\hollowtide")
SOURCE=Path(r"C:\Users\pmcga\OneDrive\Documents\HollowTide Sprites\Character\Male.jpg")
ART=SOURCE.parent
OUT=ROOT/"assets/sprites/player/courier_chibi_prepared_2026_09_30"
REVIEW=ROOT/"docs/art/characters/chibi-courier-preparation-2026-09-30"
OUT.mkdir(exist_ok=True); REVIEW.mkdir(exist_ok=True)
(OUT/"source_detail").mkdir(exist_ok=True)
(REVIEW/"source_masters").mkdir(exist_ok=True)
source=Image.open(SOURCE).convert("RGB"); a=np.array(source).astype(int)
bg=(a[:,:,0]>150)&(a[:,:,2]>120)&(a[:,:,1]<100)&(a[:,:,0]-a[:,:,1]>60)&(a[:,:,2]-a[:,:,1]>60)
mask=~bg

def bands(signal,minimum):
    indices=np.where(signal>5)[0]
    cuts=np.where(np.diff(indices)>1)[0]+1
    return [(int(g[0]),int(g[-1])+1) for g in np.split(indices,cuts) if len(g)>minimum]

rows=bands(mask[:,:source.width//4].sum(1),50)
cols=bands(mask.sum(0),50)
if len(rows)!=4 or len(cols)!=4:
    raise RuntimeError(f"Uneven source grid needs review: rows={rows}, cols={cols}")

def main_component(m):
    """Remove detached JPEG noise; keep the connected character, without erosion."""
    seen=np.zeros_like(m,dtype=bool); components=[]
    for y,x in zip(*np.where(m)):
        if seen[y,x]: continue
        q=deque([(y,x)]); seen[y,x]=True; part=[]
        while q:
            yy,xx=q.popleft(); part.append((yy,xx))
            for dy,dx in [(-1,0),(1,0),(0,-1),(0,1),(-1,-1),(-1,1),(1,-1),(1,1)]:
                ny,nx=yy+dy,xx+dx
                if 0<=ny<m.shape[0] and 0<=nx<m.shape[1] and m[ny,nx] and not seen[ny,nx]:
                    seen[ny,nx]=True; q.append((ny,nx))
        components.append(part)
    largest=max(components,key=len)
    keep=np.zeros_like(m,dtype=bool)
    for y,x in largest: keep[y,x]=True
    # Any substantial detached source detail is preserved for visual review.
    for part in components:
        if len(part)>=16:
            for y,x in part: keep[y,x]=True
    return keep

records=[]; masters=[]; samples=[]
directions=["down","left","right","up"]
for row,direction in enumerate(directions):
    top,bottom=rows[row]
    for frame,(left,right) in enumerate(cols):
        box=(max(0,left-3),max(0,top-3),min(source.width,right+3),min(source.height,bottom+3))
        l,t,r,b=box
        rgb=a[t:b,l:r].copy().astype(np.uint8)
        kept=main_component(mask[t:b,l:r])
        yy,xx=np.where(kept)
        # Head center anchors the torso; wide stride bounds never move the hip.
        head=kept[:max(1,(yy.max()-yy.min())//3+yy.min())]
        hy,hx=np.where(head)
        center_x=int(round((hx.min()+hx.max())/2))
        foot_y=int(yy.max())
        rgba=np.dstack([rgb,np.where(kept,255,0).astype(np.uint8)])
        # Magenta contamination near the keyed outline becomes dark ink only.
        spill=kept & (rgb[:,:,0].astype(int)>rgb[:,:,1].astype(int)*1.4+12) & (rgb[:,:,2].astype(int)>rgb[:,:,1].astype(int)*1.4+12)
        rgba[spill,:3]=(24,26,24)
        master=Image.new("RGBA",(272,272),(0,0,0,0))
        at=(136-center_x,260-foot_y)
        master.paste(Image.fromarray(rgba),at)
        master_path=REVIEW/"source_masters"/f"{direction}_source_pose_{frame:02d}.png"
        master.save(master_path)
        full_folder=OUT/"source_detail"/direction; full_folder.mkdir(exist_ok=True)
        master.save(full_folder/f"source_pose_{frame:02d}.png")
        masters.append(master)
        # Pixel-cell area sample for the actual32px map target. Subsequent
        # shared-palette snap and binary alpha return whole, opaque pixels.
        small=master.resize((32,32),Image.Resampling.BOX)
        sa=np.array(small); sa[:,:,3]=np.where(sa[:,:,3]>=128,255,0)
        sa[sa[:,:,3]==0,:3]=0
        samples.append(sa)
        records.append({"direction":direction,"source_column":frame,"source_box":box,
            "master":str(master_path.relative_to(ROOT)),"master_cell":[272,272],
            "full_detail_frame":str((full_folder/f"source_pose_{frame:02d}.png").relative_to(ROOT)),
            "head_center_source":center_x+l,"foot_pixel_source":foot_y+t,
            "master_registration":{"head_center_x":136,"bottom_boot_y":260},
            "outline_spill_pixels_repainted":int(spill.sum()),
            "keyed_visible_pixels":int(kept.sum()),
            "pose_role":"extended stride/contact variant; no confirmed passing pose",
            "review_status":"needs per-frame visual review"})

visible=np.concatenate([sa[:,:,:3][sa[:,:,3]>0] for sa in samples])
palette_image=Image.fromarray(visible.reshape(1,-1,3)).quantize(colors=32,method=Image.Quantize.MEDIANCUT,dither=Image.Dither.NONE)
palette=np.array(palette_image.getpalette()[:32*3],dtype=int).reshape(-1,3)
atlas=Image.new("RGBA",(128,128),(0,0,0,0))
for i,(sa,rec) in enumerate(zip(samples,records)):
    visible_mask=sa[:,:,3]>0
    colors=sa[:,:,:3][visible_mask].astype(int)
    distance=((colors[:,None]-palette[None])**2).sum(2)
    sa[:,:,:3][visible_mask]=palette[distance.argmin(1)]
    frame=Image.fromarray(sa)
    folder=OUT/rec["direction"]; folder.mkdir(exist_ok=True)
    path=folder/f"source_pose_{rec['source_column']:02d}.png"
    frame.save(path)
    rec["prepared_frame"]=str(path.relative_to(ROOT))
    rec["visible_bbox_32"]=frame.getbbox()
    atlas.paste(frame,((i%4)*32,(i//4)*32))
atlas.save(OUT/"source_pose_atlas_4x4.png")
full_atlas=Image.new("RGBA",(1088,1088),(0,0,0,0))
for i,master in enumerate(masters): full_atlas.paste(master,((i%4)*272,(i//4)*272))
full_atlas.save(OUT/"source_detail/source_pose_atlas_4x4.png")
for row,direction in enumerate(directions):
    atlas.crop((0,row*32,128,(row+1)*32)).save(OUT/f"{direction}_source_poses_4x1.png")
    full_atlas.crop((0,row*272,1088,(row+1)*272)).save(OUT/"source_detail"/f"{direction}_source_poses_4x1.png")

font=ImageFont.truetype(r"C:\Windows\Fonts\consola.ttf",18)
contact=Image.new("RGB",(864,860),(28,33,41)); dr=ImageDraw.Draw(contact)
dr.text((15,12),"MAIN COURIER / SOURCE POSES PREPARED FOR GODOT",font=font,fill=(237,225,205))
dr.text((15,40),"Transparent32px frames / foot-aligned / source order, not a completed gait",font=font,fill=(173,194,183))
for i,rec in enumerate(records):
    x=40+(i%4)*200; y=94+(i//4)*182
    frame=Image.open(ROOT/rec["prepared_frame"]).convert("RGBA")
    background=Image.new("RGBA",(32,32),(64,71,72,255)); background.alpha_composite(frame)
    tile=background.convert("RGB").resize((160,160),Image.Resampling.NEAREST)
    contact.paste(tile,(x,y))
    dr.text((x,y+162),f"{rec['direction'].upper()} {i%4}",font=font,fill=(237,225,205))
dr.text((16,826),"Side rows repeat a held stride. Contact + passing additions are still needed.",font=font,fill=(223,183,132))
contact.save(REVIEW/"chibi_source_pose_contact_sheet.png")
detail_contact=Image.new("RGB",(864,900),(28,33,41)); ddc=ImageDraw.Draw(detail_contact)
ddc.text((15,12),"MAIN COURIER / FULL-DETAIL TRANSPARENT SOURCE CUTS",font=font,fill=(237,225,205))
ddc.text((15,40),"Pose and body proportions retained / all16 source poses reviewed separately",font=font,fill=(173,194,183))
for i,rec in enumerate(records):
    x=40+(i%4)*200; y=82+(i//4)*194
    master=masters[i]
    bg_image=Image.new("RGBA",master.size,(64,71,72,255)); bg_image.alpha_composite(master)
    detail_contact.paste(bg_image.convert("RGB").resize((174,174),Image.Resampling.NEAREST),(x,y))
    ddc.text((x,y+176),f"{rec['direction'].upper()} {i%4}",font=font,fill=(237,225,205))
ddc.text((15,862),"Integration source.32px size study is separate; passing poses still missing.",font=font,fill=(223,183,132))
detail_contact.save(REVIEW/"chibi_full_detail_contact_sheet.png")

# A proof-size animation is a visual review artifact; no game run or test.
preview_frames=[]
for col in range(4):
    canvas=Image.new("RGB",(512,380),(28,33,41)); dd=ImageDraw.Draw(canvas)
    for row,direction in enumerate(directions):
        x=32+(row%2)*240; y=26+(row//2)*176
        dd.text((x,y),direction.upper(),font=font,fill=(237,225,205))
        f=Image.open(OUT/direction/f"source_pose_{col:02d}.png").convert("RGBA")
        f=f.resize((128,128),Image.Resampling.NEAREST)
        canvas.paste(f,(x+48,y+30),f)
    preview_frames.append(canvas)
preview_frames[0].save(REVIEW/"chibi_source_pose_review.gif",save_all=True,append_images=preview_frames[1:],duration=160,loop=0,disposal=2)

manifest={"status":"prepared source-pose package, not integrated or a repaired walk cycle",
    "source":str(SOURCE),"source_sha256":hashlib.sha256(SOURCE.read_bytes()).hexdigest(),
    "source_size":source.size,"actual_row_bands":rows,"actual_column_bands":cols,
    "selected_identity":"Preston's original chibi teal jacket/forehead goggles courier",
    "source_order":["DOWN","LEFT","RIGHT","UP"],"main_atlas_cell":[272,272],"main_atlas_size":[1088,1088],
    "main_atlas":"assets/sprites/player/courier_chibi_prepared_2026_09_30/source_detail/source_pose_atlas_4x4.png",
    "optional_map_candidate_cell":[32,32],"optional_map_candidate_atlas_size":[128,128],
    "shared_character_palette":palette.tolist(),"alpha":"binary0/255; all background removed",
    "source_master_cell":[272,272],"source_master_registration":{"head_center_x":136,"bottom_boot_y":260},
    "game_target":"Full-detail source272px cells, nearest filter, common source foot anchor(136,260), same display zoom across directions.32px reduced set is an unapproved size study; it loses source face/goggle detail.",
    "sampling":"Source masters retain exact source proportions/poses.32px map version is a deliberate reduction: BOX cell sample, binary alpha and one32-color character palette; it is not a claim of recovering an original32px grid.",
    "frames":records,"missing_gait":"Side poses repeat nearly the same extended stride; no adequate passing poses. Down/up alternate contacts but also lack a clear four-phase contact/passing cycle.",
    "runtime":"No player.gd, scene, project start or current walk resources changed. No game run or tests performed.",
    "claude_handoff":"docs/art/characters/chibi-courier-preparation-2026-09-30/CLAUDE_HANDOFF.md"}
(REVIEW/"manifest.json").write_text(json.dumps(manifest,indent=2),encoding="utf-8")
(OUT/"README.md").write_text("""# Prepared original chibi courier

Preston selected this earlier chibi design. Codex cut all16 source poses, removed magenta, repainted magenta-contaminated outline pixels and aligned head/foot anchors. The full-detail source cuts are the main integration handoff.

## Main handoff: source_detail

- `source_detail/source_pose_atlas_4x4.png`:1088x1088,272x272 cells, rows DOWN, LEFT, RIGHT, UP and original columns0-3.
- `source_detail/{direction}/source_pose_00..03.png`: individual full-detail transparent poses.
- `source_detail/{direction}_source_poses_4x1.png`:1088x272 directional rows.
- Each cell has head-center x136 and lowest boot y260. Keep one common display scale. See CLAUDE_HANDOFF for placement.

## Optional32px map size study (not visually approved)

- `source_pose_atlas_4x4.png`:128x128,32x32 cells. Rows DOWN, LEFT, RIGHT, UP; original column order0-3.
- `down/`, `left/`, `right/`, `up/`: individual transparent32x32 frames.
- `{direction}_source_poses_4x1.png`:128x32 directional rows.

All versions are **source pose candidates**, not a repaired gait. The original side rows hold the same extended stride. See both contact sheets, review GIF and CLAUDE_HANDOFF in `docs/art/characters/chibi-courier-preparation-2026-09-30/` before choosing frames.

The32px set uses a shared32-color character palette but loses some face and goggle detail. Do not substitute it as an approved redraw. Full-detail source masters are also retained in the review folder. Avoid changing direction-specific scales; compare at actual play size before changing the current player.
""",encoding="utf-8")
print(json.dumps({"package":str(OUT),"review":str(REVIEW),"frames":len(records),"row_bands":rows,"column_bands":cols,"alpha_levels":sorted(set(atlas.getchannel("A").get_flattened_data()))},indent=2))
