from pathlib import Path
from PIL import Image
import hashlib,json,collections
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');P=W/'staging'
plan=json.loads((P/'placements.json').read_text(encoding='utf-8'))
for p in plan['instances']:
    if p['id']=='counter':p['suggested_footprint_tiles']=[6,5,5,2]
(P/'placements.json').write_text(json.dumps(plan,indent=2),encoding='utf-8')
prep=json.loads((W/'native-preparation.json').read_text(encoding='utf-8'))
props=[]
for name,spec in prep['props'].items():
    before=Image.open(P/'art/pre_finish'/(name+'.png')).convert('RGBA')
    after=Image.open(P/'art/props'/(name+'.png')).convert('RGBA')
    assert before.size==after.size==tuple(spec['size'])
    assert before.getchannel('A').tobytes()==after.getchannel('A').tobytes()
    assert set(after.getchannel('A').get_flattened_data())=={0,255}
    box=after.getbbox();assert box[0]>=2 and box[1]>=2 and box[2]<=after.width-2 and box[3]<=after.height-2,(name,box)
    inner_changes=0;rim_changes=0
    for y in range(after.height):
        for x in range(after.width):
            if before.getpixel((x,y))==after.getpixel((x,y)):continue
            edge=any(not (0<=x+dx<after.width and 0<=y+dy<after.height) or before.getpixel((x+dx,y+dy))[3]==0 for dx,dy in [(0,-1),(0,1),(-1,0),(1,0)])
            if edge:rim_changes+=1
            else:inner_changes+=1
    assert inner_changes==0
    props.append({'name':name,'size':after.size,'hard_alpha':True,'two_pixel_canvas_margin':True,'rim_changed_pixels':rim_changes,'changed_interior_pixels':inner_changes})
raw=Image.open(P/'art/storage-raw.png').convert('RGBA')
mask=Image.open(P/'art/detail-mask.png').convert('RGBA')
assert raw.size==(408,312) and raw.getchannel('A').getextrema()==(255,255)
floor=Image.open(P/'art/components/floor.png').convert('RGBA')
source=Image.open(W/'references/hall-floor.png').convert('RGBA').crop((144,72,504,312))
assert source.tobytes()==floor.tobytes()
aisle=(168,168,240,312)
assert raw.crop(aisle).tobytes()==floor.crop((144,96,216,240)).tobytes()
assert set(mask.crop(aisle).get_flattened_data())=={(0,0,0,255)}
# Illustrative connectivity only. These suggested footprints are never installed
# as game collision; Claude retains the final room and data model.
walk={(x,y) for x in range(1,16) for y in range(3,12)}|{(x,12) for x in range(7,10)}
for p in plan['instances']:
    r=p['suggested_footprint_tiles']
    if r:
        x,y,w,h=r;walk-={(xx,yy) for xx in range(x,x+w) for yy in range(y,y+h)}
entry=tuple(plan['proposed_entry_tile']);seen={entry};queue=collections.deque([entry])
while queue:
    x,y=queue.popleft()
    for dx,dy in [(1,0),(-1,0),(0,1),(0,-1)]:
        p=(x+dx,y+dy)
        if p in walk and p not in seen:seen.add(p);queue.append(p)
assert seen==walk
assert tuple(plan['proposed_counter_approach_tile']) in seen
protected=json.loads((W/'protected.json').read_text(encoding='utf-8'))
changed=[rel for rel,sha in protected.items() if hashlib.sha256((R/rel).read_bytes()).hexdigest()!=sha]
assert not changed,changed
native=json.loads((W/'review/native-checks.json').read_text(encoding='utf-8'));assert native['passed']==native['total']==8
result={'props':props,'native_renderer_checks':native,'room_size':[408,312],'original_hall_floor_crop_exact':True,'three_tile_aisle_and_threshold_exact':True,'proposed_walkable_tiles':len(walk),'proposed_reachable_tiles':len(seen),'proposed_service_approach_reachable':True,'collision_installed':False,'protected_existing_sources_exact':len(protected),'changed_protected_sources':changed,'keeper_added':False}
(W/'verification.json').write_text(json.dumps(result,indent=2),encoding='utf-8');print(json.dumps({k:v for k,v in result.items() if k not in ['props','native_renderer_checks']},indent=2))
