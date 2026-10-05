from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,base64,hashlib
D=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/kithflare-tail-review")
P=Path(r"C:/Users/pmcga/dev/hollowtide")
atlas=Image.new("RGBA",(576,320),(255,0,255,255))
atlas_mask=Image.new("L",atlas.size,0)
configs=[]
coal=np.array(Image.open(D/"coalcrest-front-before.png").convert("RGBA"))
bulb=Image.fromarray(coal).crop((118,98,149,129))
ImageDraw.Draw(bulb).rectangle((0,24,5,30),fill=(0,0,0,0))
bulb.save(D/"original-coalcrest-lantern.png")
for col,name in enumerate(["kithflare","wayburn","coalcrest"]):
  for row,view in enumerate(["front","back"]):
    image=Image.open(D/(name+"-"+view+"-before.png")).convert("RGBA")
    prep=image.copy();mask=Image.new("L",image.size,0);draw=ImageDraw.Draw(mask)
    allowed=Image.new("L",image.size,0)
    if name=="kithflare":
      draw.rectangle((50,29,64,42) if view=="front" else (50,39,62,52),fill=255)
    elif name=="wayburn" and view=="back":
      draw.polygon([(33,39),(44,43),(48,54),(42,57),(35,49),(29,46)],fill=255)
    elif name=="wayburn":
      draw.rectangle((10,31,88,92),fill=255)
      draw.polygon([(74,34),(91,23),(98,24),(100,36),(88,50),(78,58)],fill=255)
      draw.rectangle((76,73,90,94),fill=0)
      draw.rectangle((65,90,90,94),fill=0)
      # Keep the original distal glowing bulb exact; the tail is the repair target.
      draw.rectangle((92,11,113,26),fill=0)
    else:
      draw.rectangle((9,89,61,137 if view=="front" else 144),fill=255)
      if view=="front":
        clear=ImageDraw.Draw(prep);clear.rectangle((118,96,153,133),fill=(0,0,0,0))
        ImageDraw.Draw(allowed).rectangle((118,96,153,133),fill=255)
      # The same original rotationally symmetric lamp is reused, not redesigned.
      prep.alpha_composite(bulb,(26,98))
      bulb_alpha=np.array(bulb)[:,:,3]>0
      ma=np.array(mask);ma[98:129,26:57][bulb_alpha]=0;mask=Image.fromarray(ma)
      ImageDraw.Draw(allowed).rectangle((26,98,56,128),fill=255)
    mask.save(D/(name+"-"+view+"-rd-mask.png"))
    union=np.maximum(np.array(allowed),np.array(mask))
    Image.fromarray(union).save(D/(name+"-"+view+"-allowed-mask.png"))
    prep.save(D/(name+"-"+view+"-prepared.png"))
    bg=Image.new("RGBA",image.size,(255,0,255,255));bg.alpha_composite(prep)
    at=(col*192,row*160)
    atlas.paste(bg,at)
    atlas_mask.paste(mask,at)
    configs.append({"name":name,"view":view,"atlas_origin":list(at),"native_size":list(image.size)})
atlas.convert("RGB").save(D/"tail-edit-input.png")
atlas_mask.save(D/"tail-edit-mask.png")
overlay=atlas.convert("RGB")
red=Image.new("RGB",atlas.size,(255,80,80))
overlay=Image.composite(Image.blend(overlay,red,.35),overlay,atlas_mask)
overlay.resize((1152,640),Image.Resampling.NEAREST).save(D/"masked-tail-preview.png")
prompt="""Edit only the white mask on this 576x320 native pixel-art sprite atlas, preserving the grid and all black-masked pixels. Three columns, each 192 pixels wide: column 1 Kithflare, column 2 Wayburn, column 3 Coalcrest. Top row FRONT sprites, bottom row BACK sprites, each row 160 pixels high. This is one approved reptile evolution line with an organic luminous lantern growth at the end of its tail. No text, no extra creatures, no extra bulbs.

Kithflare front and back, and Wayburn back: strengthen only the tiny brown stem/collar joining tail tip to the existing golden lantern. Make the attachment visibly continuous, smoothly tapered and shaded with the tail's own warm skin palette. Keep each existing bulb's exact form and location.

Wayburn FRONT (top middle) needs its ACTUAL TAIL reshaped: replace the awkward flat, shelf-like horizontal loop with a graceful naturally curving reptile tail, a smooth rising C/S curve behind the hips, robust at the root and gradually tapering to a readable 3-pixel neck at its existing glowing distal tip. Keep the original lantern at its current top location. Preserve the untouched hips, legs, crest, head and chest. Avoid a flat straight upper shelf, angular pipe, rope, branch or disconnected segments.

Coalcrest front and back (right column): the original banded lantern has already been placed in the tail area at local x26..56, y98..128. Use exactly that existing lamp. Rebuild the distal brown tail into a strong organic upward curl from its preserved rump/root at the right of the mask, sweeping left then upward and inward, ending at the TOP of that lamp at local x42,y99. The lamp must be visibly an anatomical growth at the tail tip, with a short thick skin neck and dark continuous outline. No chain, cord, handle, metal hook, hovering light, second lantern or tail stump. Preserve the completed sail fin and all torso/limb pixels outside the mask. Match each sprite's existing material texture, restrained highlights and substantial dark outline.

Fill all remaining background with exact solid magenta #ff00ff. Keep native one-pixel clusters, no antialiasing, no checkerboard, no whole-image redraw."""
(D/"exact-prompt.txt").write_text(prompt)
args={"tool_id":"inpainting","input_image":base64.b64encode((D/"tail-edit-input.png").read_bytes()).decode(),"mask_image":base64.b64encode((D/"tail-edit-mask.png").read_bytes()).decode(),"prompt":prompt,"soft_inpaint":False}
(D/"tail-edit-request.json").write_text(json.dumps(args))
(D/"atlas-layout.json").write_text(json.dumps(configs,indent=2))
baseline={}
for folder in ["assets","data","scripts","scenes"]:
  for p in (P/folder).rglob("*"):
    if p.is_file():baseline[p.relative_to(P).as_posix()]=hashlib.sha256(p.read_bytes()).hexdigest()
baseline["project.godot"]=hashlib.sha256((P/"project.godot").read_bytes()).hexdigest()
(D/"protected-hashes-before.json").write_text(json.dumps(baseline,indent=2))
print(json.dumps({"atlas_size":list(atlas.size),"sprites":6,"protected_files":len(baseline),"masked_pixels":int((np.array(atlas_mask)>0).sum())}))
