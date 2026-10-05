from pathlib import Path
from PIL import Image
import numpy as np, json
W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an")
P=Path(r"C:/Users/pmcga/dev/hollowtide")
D=W/"area-transition-review"/"candidate"
atlas=Image.open(P/"assets/tilesets/route1_rd_2026_10_01/route1_ground_atlas_polished.png").convert("RGBA")
soil=np.array(atlas.crop((176,0,192,16)))
pavers=np.array(Image.open(W/"historic-riverfront-review/historic_pavers_tile_source.png").convert("RGBA"))
def bake(name,size,paths,tile,offset=(0,0)):
    width,height=size
    yy,xx=np.mgrid[:height,:width]
    dist=np.full((height,width),10000.0)
    for points,radius in paths:
        for a,b in zip(points,points[1:]):
            a=np.array(a,float); b=np.array(b,float); v=b-a
            u=np.clip(((xx-a[0])*v[0]+(yy-a[1])*v[1])/max(1,np.dot(v,v)),0,1)
            d=np.sqrt((xx-a[0]-v[0]*u)**2+(yy-a[1]-v[1]*u)**2)-radius
            dist=np.minimum(dist,d)
    rgba=tile[(yy+offset[1])%tile.shape[0],(xx+offset[0])%tile.shape[1]].copy()
    rgba[:,:,3]=np.where(dist<=0,255,0)
    Image.fromarray(rgba).save(D/name)
home=[
 ([(224,280),(224,336),(352,336),(560,336),(560,512),(1016,512)],16),
 ([(560,248),(560,336)],15),
 ([(768,456),(768,512)],18),
 ([(224,336),(160,416),(160,560),(288,632),(448,632),(560,576),(560,512)],14),
 ([(288,608),(288,632)],16),
 ([(448,608),(448,632)],16),
]
route=[
 ([(8,512),(128,512),(128,336),(336,336),(336,192),(768,192)],18),
 ([(128,512),(288,560),(512,528),(640,416),(736,336)],12),
]
city=[
 ([(0,512),(160,512),(384,512),(640,512),(816,512),(968,512)],20),
 ([(512,400),(512,456),(384,512)],22),
 ([(768,272),(768,512)],18),
 ([(336,656),(336,592),(384,512)],18),
 ([(512,456),(640,416),(640,336),(768,304),(768,272)],14),
]
bake("hometown_streets.png",(1024,768),home,soil)
bake("route1_meadow_approach.png",(768,640),route,soil,(-768,0))
bake("riverfront_streets.png",(1024,768),city,pavers)
(D/"paths.json").write_text(json.dumps({"hometown":home,"route1_approach":route,"riverfront":city,"material_sources":["route1_ground_atlas_polished.png tile(11,0)","historic_pavers_tile_source.png"],"preparation":"Mask existing native materials. No source artwork resized or repainted."},indent=2))
print("Baked three native material paths.")
