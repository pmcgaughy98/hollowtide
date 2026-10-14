from pathlib import Path
from PIL import Image
import json,shutil,hashlib,re
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');P=W/'staging';A=P/'art'
(A/'components').mkdir(parents=True,exist_ok=True);(A/'pre_finish').mkdir(exist_ok=True);(A/'props').mkdir(exist_ok=True)
source=Image.open(W/'generation/shell.png').convert('RGBA')
floor_path=R/'assets/sprites/world/hall_floors_2026_10_11/lower_floor.png'
shutil.copy2(floor_path,W/'references/hall-floor.png')
floor=Image.open(floor_path).convert('RGBA').crop((144,72,504,312))
floor.save(A/'components/floor.png')
shell_parts={
 'north':{'crop':[64,0,1370,145],'size':[360,72],'at':[24,0]},
 'west':{'crop':[0,430,60,1016],'size':[24,312],'at':[0,0]},
 'east':{'crop':[1374,430,1434,1016],'size':[24,312],'at':[384,0]},
 'south_left':{'crop':[64,1018,600,1097],'size':[144,24],'at':[24,288]},
 'south_right':{'crop':[830,1018,1370,1097],'size':[144,24],'at':[240,288]},
}
for name,spec in shell_parts.items():source.crop(spec['crop']).resize(spec['size'],Image.Resampling.NEAREST).save(A/'components'/(name+'.png'))
props=Image.open(W/'generation/props.png').convert('RGBA')
recipes={
 'cabinet_left':{'crop':[64,80,448,560],'size':[72,96]},
 'cabinet_right':{'crop':[576,80,928,560],'size':[72,96]},
 'counter':{'crop':[960,288,1536,560],'size':[144,60]},
 'crates':{'crop':[96,640,416,928],'size':[48,48]},
 'basket':{'crop':[624,672,928,928],'size':[48,40]},
 'lamp':{'crop':[1152,640,1344,928],'size':[16,32]},
}
for name,spec in recipes.items():
    im=props.crop(spec['crop'])
    # Native preparation of a copy: remove generated soft halos by requiring
    # near-opaque source alpha, then use only a uniform nearest-neighbour fit.
    alpha=im.getchannel('A').point(lambda v:255 if v>=224 else 0)
    im.putalpha(alpha);bbox=im.getbbox();assert bbox,name
    im=im.crop(bbox);tw,th=spec['size'];scale=min((tw-4)/im.width,(th-4)/im.height)
    fitted=im.resize((max(1,round(im.width*scale)),max(1,round(im.height*scale))),Image.Resampling.NEAREST)
    canvas=Image.new('RGBA',(tw,th),(0,0,0,0));at=((tw-fitted.width)//2,th-fitted.height-2)
    canvas.paste(fitted,at)
    canvas.save(A/'pre_finish'/(name+'.png'))
    spec.update({'alpha_threshold':224,'alpha_crop_within_source_rect':bbox,'uniform_scale':scale,'fitted_size':fitted.size,'paste_at':at})
placements=[
 {'id':'cabinet_left','asset':'cabinet_left','rect':[48,16,72,96],'depth_y':112,'suggested_footprint_tiles':[2,3,3,2]},
 {'id':'cabinet_right','asset':'cabinet_right','rect':[288,16,72,96],'depth_y':112,'suggested_footprint_tiles':[12,3,3,2]},
 {'id':'counter','asset':'counter','rect':[132,96,144,60],'depth_y':156,'suggested_footprint_tiles':[6,5,5,2]},
 {'id':'crates','asset':'crates','rect':[48,216,48,48],'depth_y':264,'suggested_footprint_tiles':[2,9,2,2]},
 {'id':'basket','asset':'basket','rect':[312,220,48,40],'depth_y':260,'suggested_footprint_tiles':[13,9,2,2]},
 {'id':'lamp_left','asset':'lamp','rect':[140,24,16,32],'depth_y':56,'suggested_footprint_tiles':None},
 {'id':'lamp_right','asset':'lamp','rect':[252,24,16,32],'depth_y':56,'suggested_footprint_tiles':None},
]
plan={'status':'ART PROPOSAL ONLY; Claude chooses final layout, solids, depth and service/door hooks','native_size':[408,312],'tile_size':24,'room_tiles':[17,13],'floor_rect':[24,72,360,216],'floor_continuation_under_threshold':[168,288,72,24],'north_wall_rect':[24,0,360,72],'side_wall_rects':[[0,0,24,312],[384,0,24,312]],'south_wall_rects':[[0,288,168,24],[240,288,168,24]],'proposed_entry_tile':[8,12],'proposed_counter_approach_tile':[8,7],'clear_aisle_rect':[168,168,72,144],'instances':placements,'no_keeper':True,'existing_storage_panel_rect':'Rect2(166,64,820,160+40*max(1,rows.size())) unchanged; Claude decides room hook'}
(P/'placements.json').write_text(json.dumps(plan,indent=2),encoding='utf-8')
(W/'native-preparation.json').write_text(json.dumps({'shell_source_size':source.size,'shell_parts':shell_parts,'floor_reused_native_1x':{'path':str(floor_path),'crop':[144,72,504,312],'sha256':hashlib.sha256(floor_path.read_bytes()).hexdigest()},'props':recipes},indent=2),encoding='utf-8')
# Exact shared finish dependencies, copied only into the standalone art project.
for rel in ['scripts/art/selout.gd','scripts/dungeon/dungeon_finish.gdshader','scripts/arena/sel_out.gdshaderinc','scripts/arena/sparkwick_palette.gdshaderinc']:
    dest=P/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(R/rel,dest)
print('Prepared six props, native floor reuse, five shell pieces and seven proposed placements. No live art or source writes.')
