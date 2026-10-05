from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib,shutil,collections
from coalcrest_curve_helpers import smooth
W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an")
P=Path(r"C:/Users/pmcga/dev/hollowtide");D=W/"coalcrest-recheck-2026-10-04"
def rgba(p):return np.array(Image.open(p).convert("RGBA"))
def component(a,start):
 if not a[start]:return set()
 seen={start};q=collections.deque(seen)
 while q:
  y,x=q.popleft()
  for dy,dx in [(0,1),(1,0),(-1,0),(0,-1)]:
   yy,xx=y+dy,x+dx
   if 0<=yy<160 and 0<=xx<160 and a[yy,xx] and(yy,xx)not in seen:seen.add((yy,xx));q.append((yy,xx))
 return seen
records=[];specs=json.loads((D/"draft-audit.json").read_text())
for spec in specs:
 view=spec["view"];before=rgba(D/(view+"-before.png"));a=rgba(D/("coalcrest_"+view+"-draft.png"))
 mask=np.array(Image.open(D/(view+"-authorized-regions.png")))>0
 diff=np.any(a!=before,2);opaque=a[:,:,3]>0;allcomp=component(opaque,(95,32))
 disconnected=[(int(y),int(x))for y,x in np.argwhere(opaque&mask)if(y,x)not in allcomp]
 protected=np.zeros((160,160),bool);protected[:65]=True
 if view=="front":protected[:103,51:130]=True
 else:protected[:97,66:126]=True
 # Verify the curl reaches the body within its own authored corridor, not by a torso shortcut.
 path=smooth(spec["tail_points"],spec["tail_widths"]);y,x=np.mgrid[:160,:160]
 d=np.stack([x,y],-1)[:,:,None,:]-path[None,None,:,:2]
 near=(d*d).sum(3).argmin(2)
 corridor=(d*d).sum(3).min(2)<=(path[near,2]/2+1)**2
 comp=component(opaque&corridor,(98,15))
 root=(106,64)if view=="front"else(121,64)
 tail_connected=root in comp and(75,25)in comp and(79,35)in comp
 root_pixels=sum((yy,xx)in comp for yy in range(root[0]-2,root[0]+3)for xx in range(root[1]-2,root[1]+3))
 colors=set(map(tuple,a[opaque,:3].tolist()))
 source_colors=set(map(tuple,before[before[:,:,3]>0,:3].tolist()))|set(map(tuple,rgba(D/("original-"+view+".png"))[rgba(D/("original-"+view+".png"))[:,:,3]>0,:3].tolist()))
 unexpected=sorted(colors-source_colors)
 leg=a[102:122,57:65];emitter=np.any((leg[:,:,3]>0)&(leg[:,:,0]>195)&(leg[:,:,1]>115))
 lamp=np.zeros((160,160),bool);lamp[77:110,18:51]=True
 # Exclude preserved main-body marking pixels, which are deliberately luminous.
 tail_only=mask&corridor&opaque&~lamp&(x<55)
 white=np.any(np.all(a[:,:,:3]>225,2)&tail_only)
 checks={"native_size_160":a.shape==(160,160,4),"binary_alpha":set(np.unique(a[:,:,3])).issubset({0,255}),"fixed_region_guard":not np.any(diff&~mask),"fin_head_upper_body_exact":not np.any(diff&protected),"no_edited_islands":not disconnected,"curl_to_root_connected_without_body_shortcut":tail_connected,"multi_pixel_root_contact":root_pixels>=12,"native_palette_only":not unexpected,"no_white_tail_fringe":not white,"old_front_lantern_branch_absent":not np.any(opaque[122:129,118:154])if view=="front"else True,"rear_leg_emitter_absent":not emitter if view=="back"else True,"canvas_unclipped":not(np.any(opaque[0])or np.any(opaque[-1])or np.any(opaque[:,0])or np.any(opaque[:,-1]))}
 records.append({"view":view,"checks":checks,"passed":all(checks.values()),"changed_pixels":int(diff.sum()),"unexpected_palette_colors":unexpected,"disconnected_pixels":disconnected,"root_contact_pixels":root_pixels,"bbox":Image.fromarray(a).getbbox(),"sha256":hashlib.sha256((D/("coalcrest_"+view+"-draft.png")).read_bytes()).hexdigest()})
(D/"native-qa.json").write_text(json.dumps(records,indent=2));print(json.dumps(records))
assert all(r["passed"]for r in records)
F=P/"assets/sprites/creatures/coalcrest_rechecked_2026_10_04";F.mkdir(exist_ok=True)
# Protect against concurrent resource edits and preserve every existing property.
rp=P/"data/creatures/105_coalcrest.tres";before=(D/"105_coalcrest-before.tres").read_text();now=rp.read_text()
after=before.replace("coalcrest_refined_2026_10_04/","coalcrest_rechecked_2026_10_04/")
assert now in [before,after],"Concurrent creature-resource edit detected"
assert after.count("coalcrest_rechecked_2026_10_04/")==2
for view in ["front","back"]:shutil.copy2(D/("coalcrest_"+view+"-draft.png"),F/("coalcrest_"+view+".png"))
rp.write_text(after)
# Review on dark/light/neutral mattes, all whole-cell integer nearest scaling.
sheet=Image.new("RGB",(960,1060),(108,118,119));dr=ImageDraw.Draw(sheet)
for row,color in enumerate([(24,29,31),(230,230,221),(108,118,119)]):
 for col,view in enumerate(["front","back"]):
  im=Image.open(F/("coalcrest_"+view+".png")).convert("RGBA")
  bg=Image.new("RGBA",(160,160),(*color,255));bg.alpha_composite(im)
  sheet.paste(bg.resize((320,320),Image.Resampling.NEAREST),(col*480+80,row*350+25))
  dr.text((col*480+80,row*350+5),view.upper()+" / "+["DARK","LIGHT","NEUTRAL"][row],fill="white")
sheet.save(D/"matte-review.png")
review=Image.new("RGB",(1000,520),(108,118,119));dr=ImageDraw.Draw(review)
for col,view in enumerate(["front","back"]):
 im=Image.open(F/("coalcrest_"+view+".png")).convert("RGBA").resize((480,480),Image.Resampling.NEAREST)
 review.paste(im,(10+col*500,30),im);dr.text((20+col*500,10),view.upper()+" - rechecked",fill="white")
review.save(D/"coalcrest-rechecked-review.png")
(D/"runtime-final").mkdir(exist_ok=True)
fixture=(W/"coalcrest_refinement_runtime.gd").read_text().replace("coalcrest-refinement-2026-10-04/runtime-final/","coalcrest-recheck-2026-10-04/runtime-final/").replace("COALCREST_REFINEMENT_RUNTIME","COALCREST_FULL_RECHECK_RUNTIME")
fixture=fixture.replace('var tag := ""','var tag := ""\nvar sampled_frames: Array = []\nvar observed_frames := 0\nvar motion_samples: Array = []')
start=fixture.index("func watch(");end=fixture.index("func _run(",start)
fixture=fixture[:start]+'''func watch(sprite: Sprite2D, expected: Texture2D) -> void:
    while watching:
        await process_frame
        observed_frames+=1
        if sprite.texture != expected: mismatch=true
        if observed_frames in [1,15,30,60,90,120,180,240,360]:
            sampled_frames.append(observed_frames)
            motion_samples.append({"frame":observed_frames,"position":str(sprite.position),"scale":str(sprite.scale),"rotation":sprite.rotation,"texture":sprite.texture.resource_path})
            await capture(tag+"-phase-%03d"%observed_frames)
''' +fixture[end:]
fixture=fixture.replace("            for child in hud_controls: child.show()\n            hud_controls.clear()\n            await frames(2)","            # Leave only fixture HUD controls hidden during diagnostic attack sampling.\n            await frames(2)")
fixture=fixture.replace("mismatch=false;seen=false;watching=true","mismatch=false;seen=false;watching=true;observed_frames=0;sampled_frames=[];motion_samples=[]")
fixture=fixture.replace('and not mismatch','and not mismatch and sampled_frames.size()>=3')
fixture=fixture.replace('"passed":okay','"diagnostic_hud_hidden":true,"observed_frames":observed_frames,"sampled_frames":sampled_frames.duplicate(),"motion_samples":motion_samples.duplicate(true),"passed":okay')
needle="                paused=false\n    var f:="
fixture=fixture.replace(needle,'                paused=false\n            for child in hud_controls: child.show()\n            hud_controls.clear()\n            await frames(2);await capture(spec[1]+"-"+side+"-normal-hud-restored")\n    var f:=')
(W/"coalcrest_recheck_runtime.gd").write_text(fixture)
