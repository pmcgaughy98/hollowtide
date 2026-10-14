from pathlib import Path
from PIL import Image
import json,sys
W=Path(__file__).parent
folder=sys.argv[1] if len(sys.argv)>1 else 'after'
state=json.loads((W/'before/state.json').read_text());after=json.loads((W/folder/'state.json').read_text())
assert state==after
assert (W/'before/floor-data.bin').read_bytes()==(W/folder/'floor-data.bin').read_bytes()
cases=[('turn09-dry',0),('turn10-first-rise',1),('turn20-two-rows',2),('turn30-ceiling',state['water_max'])]
receipts=[]
for name,rows in cases:
    a=Image.open(W/'before'/(name+'-native.png')).convert('RGBA')
    b=Image.open(W/folder/(name+'-native.png')).convert('RGBA')
    assert a.size==b.size==(state['w']*24,state['h']*24)
    changed=outside=0
    for y in range(a.height):
        for x in range(a.width):
            if a.getpixel((x,y))!=b.getpixel((x,y)):
                changed+=1
                tx,ty=x//24,y//24
                if not (rows>0 and state['water_base']-rows<=ty<state['water_base'] and state['tiles'][ty*state['w']+tx]!=0):outside+=1
    assert outside==0,(name,outside)
    assert (changed==0) if rows==0 else (changed>500)
    receipts.append({'case':name,'rows':rows,'changed_wet_pixels':changed,'changed_dry_wall_pixels':outside})
(W/('live-mask-verification.json' if folder=='live-captures' else 'mask-verification.json')).write_text(json.dumps({'layout_exact':True,'checks':receipts},indent=2),encoding='utf-8');print(json.dumps(receipts,indent=2))
