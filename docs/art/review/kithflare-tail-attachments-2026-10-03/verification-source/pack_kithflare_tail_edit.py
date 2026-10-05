from pathlib import Path
from PIL import Image,ImageDraw
import json,base64
D=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/kithflare-tail-review")
layout=[
("wayburn","front",(0,0,112,96),(0,0)),
("kithflare","front",(16,16,80,80),(112,0)),
("kithflare","back",(16,26,80,90),(176,0)),
("wayburn","back",(8,20,72,84),(112,64)),
("coalcrest","front",(0,80,80,160),(0,96)),
("coalcrest","back",(0,80,80,160),(176,64))]
atlas=Image.new("RGB",(256,192),(255,0,255))
mask=Image.new("L",atlas.size,0);records=[]
for name,view,rect,at in layout:
  im=Image.open(D/(name+"-"+view+"-prepared.png")).convert("RGBA").crop(rect)
  bg=Image.new("RGBA",im.size,(255,0,255,255));bg.alpha_composite(im)
  atlas.paste(bg.convert("RGB"),at)
  mask.paste(Image.open(D/(name+"-"+view+"-rd-mask.png")).crop(rect),at)
  records.append({"name":name,"view":view,"source_crop":list(rect),"atlas_origin":list(at),"crop_size":list(im.size)})
atlas.save(D/"tail-edit-input.png");mask.save(D/"tail-edit-mask.png")
overlay=Image.composite(Image.blend(atlas,Image.new("RGB",atlas.size,(255,80,80)),.35),atlas,mask)
overlay.resize((1024,768),Image.Resampling.NEAREST).save(D/"masked-tail-preview.png")
prompt="""Precisely repair only the white mask on this native 256x192 pixel-art atlas of SIX TAIL CROPS. Black mask pixels, existing glowing bulbs, native grid and crop positions must stay exact. Background is solid magenta #ff00ff. There are six separate crops, NOT one connected drawing. Never join across crop boundaries. No text, no extra creature bodies, no extra lanterns.

1. TOP LEFT x0..111,y0..95: WAYBURN FRONT tail. Rebuild the actual awkward flat horizontal loop as a naturally curved reptile tail. Smooth rising C/S shape behind the hips, strong at its preserved root at x78,y81, gradual tapered curves ending in a readable 3-pixel brown skin neck at the EXISTING top-right lantern around x103,y20. Preserve that lamp and the protected hip. Avoid a flat straight shelf, squared pipe or hair-thin thread. Match the existing tan tail's continuous golden marking, scale shading and dark outline.

2. TOP CENTER x112..175,y0..63: KITHFLARE FRONT curled tail and bulb. Strengthen only its masked small stem/collar so the warm bulb reads as an organic growth at the tail tip, not a dangling separate ornament. Smooth warm brown skin attachment with continuous dark outline.
3. TOP RIGHT x176..239,y0..63: KITHFLARE BACK tail and bulb, same attachment fix.
4. CENTER x112..175,y64..127: WAYBURN BACK tail and bulb, same attachment fix with the original tan skin shading.

5. LOWER LEFT x0..79,y96..175: COALCREST FRONT tail base and its repositioned original striped round lantern.
6. CENTER RIGHT x176..255,y64..143: COALCREST BACK tail base and same striped round lantern.
For BOTH Coalcrest crops, rebuild the distal tail into a strong organic upward curl from the preserved brown root at the right of the crop, sweeping left then upward/inward and terminating at the TOP of the existing lantern. The local crop lamp occupies x26..56,y18..48; attach a short thick skin neck at local x42,y19. Same design from both angles. Match each view's own brown scale material and dark outlines. Keep every lantern pixel unchanged. No cord, chain, metal handle, disconnected bulb, second tail, foot-like tail stump or straight shelf. Remove obsolete tail mass only inside the white mask. Keep the protected rump, legs and sail outside it intact.

Use one-native-pixel clusters, restrained highlights and the source sprites' own materials. No antialiasing, no resizing, no checkerboard, no whole-sheet repaint. All remaining background exact magenta."""
(D/"exact-prompt.txt").write_text(prompt)
(D/"atlas-layout.json").write_text(json.dumps(records,indent=2))
args={"tool_id":"inpainting","input_image":base64.b64encode((D/"tail-edit-input.png").read_bytes()).decode(),"mask_image":base64.b64encode((D/"tail-edit-mask.png").read_bytes()).decode(),"prompt":prompt,"soft_inpaint":False}
(D/"tail-edit-request.json").write_text(json.dumps(args))
print(json.dumps(args))
