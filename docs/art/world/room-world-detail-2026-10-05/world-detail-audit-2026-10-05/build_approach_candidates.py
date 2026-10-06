from pathlib import Path
from PIL import Image, ImageDraw
import json, hashlib
P=Path('C:/Users/pmcga/dev/hollowtide')
W=Path('C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an')
A=W/'world-detail-audit-2026-10-05'
D=A/'candidate-approaches';D.mkdir(exist_ok=True)
OV=W/'home-interior-linework-2026-10-04/proof/overview'
specs=[
 {'id':'hometown_hall_approach','source':'assets/sprites/world/area_transitions_2026_10_03/hometown_streets.png','source_rect':[750,438,787,482],'world_origin':[750,414],'visible_hall_foot':[768,418],'preview_capture':'male-hometown-overview-native-1x.png','preview_crop':[720,376,816,468],'max_canvas':[37,44],'same_material_native_translation':[0,-24],'door_gate':{'center':[768,424],'size':[20,8],'target':'courier_hall'}},
 {'id':'riverfront_branch_approach','source':'assets/sprites/world/area_transitions_2026_10_03/riverfront_streets.png','source_rect':[490,378,535,426],'world_origin':[490,354],'visible_hall_foot':[512,362],'preview_capture':'male-riverfront-overview-native-1x.png','preview_crop':[464,320,560,414],'max_canvas':[45,48],'same_material_native_translation':[0,-24],'door_gate':None,'actor_foot':[512,376],'note':'Branch is an outdoor clerk interaction, not an enterable hall gate.'}
]
contracts=[]
for s in specs:
 source=P/s['source'];im=Image.open(source).convert('RGBA')
 patch=im.crop(s['source_rect'])
 assert patch.size==tuple(s['max_canvas'])
 # Exact crop-only native RGBA. No new pixels, palette shift, resampling or source writes.
 out=D/(s['id']+'.png');patch.save(out)
 before=Image.open(OV/s['preview_capture']).convert('RGBA')
 after=before.copy();origin=s['world_origin'];after.alpha_composite(patch,dest=tuple(origin))
 # Preview preserves captured facade exactly: actual installation must place patch behind facade.
 foot=s['visible_hall_foot'][1]
 for yy in range(origin[1],foot+1):
  for xx in range(origin[0],origin[0]+patch.width):after.putpixel((xx,yy),before.getpixel((xx,yy)))
 actor_note=None
 if s['id'].startswith('riverfront'):
  actor=Image.open(P/'assets/sprites/player/retro_diffusion_chibi_walking_2026_10_01/female_chibi_walk_eight_directions_native80.png').convert('RGBA').crop((0,0,80,80))
  mask=actor.getchannel('A').resize((38,38),Image.Resampling.NEAREST)
  # Display-only approximation to the captured 30/64 actor, expanded 1px to keep old actor outline exact.
  for yy in range(mask.height):
   for xx in range(mask.width):
    if mask.getpixel((xx,yy))>0:
     px,py=493+xx,342+yy
     for dx,dy in [(0,0),(-1,0),(1,0),(0,-1),(0,1)]:
      if 0<=px+dx<after.width and 0<=py+dy<after.height:after.putpixel((px+dx,py+dy),before.getpixel((px+dx,py+dy)))
  actor_note='Saved courier pixels preserved by nearest alpha proxy plus 1px dilation; this comparison is an approximation. Native engine proof required.'
 box=s['preview_crop'];b=before.crop(box);a=after.crop(box)
 scale=4;b=b.resize((b.width*scale,b.height*scale),Image.Resampling.NEAREST);a=a.resize((a.width*scale,a.height*scale),Image.Resampling.NEAREST)
 sheet=Image.new('RGB',(b.width+a.width, b.height+28),'#354038');draw=ImageDraw.Draw(sheet);sheet.paste(b,(0,28));sheet.paste(a,(b.width,28));draw.text((5,8),'SAVED NATIVE BEFORE',fill='white');draw.text((b.width+5,8),'SOURCE-MATERIAL PATCH PREVIEW (not engine)',fill='white')
 sheet.save(D/(s['id']+'-context-comparison.png'))
 preview=Image.new('RGB',(patch.width*8,patch.height*8),'#344738');preview.paste(patch.resize((patch.width*8,patch.height*8),Image.Resampling.NEAREST),(0,0),patch.resize((patch.width*8,patch.height*8),Image.Resampling.NEAREST));preview.save(D/(s['id']+'-patch-8x.png'))
 world_rect=[origin[0],origin[1],origin[0]+patch.width,origin[1]+patch.height]
 rec={**s,'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'patch':out.as_posix(),'patch_sha256':hashlib.sha256(out.read_bytes()).hexdigest(),'patch_rgba_bytes_match_source_crop':patch.tobytes()==im.crop(s['source_rect']).tobytes(),'world_change_bounds_exclusive':world_rect,'integration_proposal':'New centered=false nearest Sprite2D at world_origin, depth -6; same native scale 1.0; under existing RouteDecor y-sorted building/actor art. No old source replacement. Gate/collision/speed/camera unchanged. Root must select unique depth versus HomeApproaches/HistoricStreetLane and verify actual native joins.','outside_world_rect_exact_by_construction':True,'source_never_written':True,'native_game_verified':False,'preview_actor_note':actor_note}
 contracts.append(rec)
(D/'contracts.json').write_text(json.dumps(contracts,indent=2),encoding='utf-8')
print(json.dumps([{k:s[k] for k in ['id','patch','max_canvas','world_change_bounds_exclusive','patch_rgba_bytes_match_source_crop']} for s in contracts],indent=2))
