from PIL import Image,ImageDraw,ImageFilter
from pathlib import Path
import numpy as np,json,base64,struct,hashlib
P=Path(__file__).parent
CELLS=json.loads((P/'route_cells.json').read_text())
OUT=P/'terrain';OUT.mkdir(exist_ok=True)
RAMPS={
 'grass':['#526c56','#5c755c','#657d62','#6e8467','#788c6e','#819374'],
 'path':['#9b8968','#a5916e','#af9b76','#b8a37d','#c1ad85','#c8b68d'],
 'water':['#3f635d','#466c63','#4c756a','#557e71','#5e8577','#698d7f']}
tex={}
for key,colors in RAMPS.items():
 a=np.array(Image.open(P/(key+'_original.png')).convert('RGB')); lum=a@np.array([0.28,0.56,0.16]);lo,hi=np.percentile(lum,[2,98]);v=np.clip((lum-lo)/(hi-lo),0,1)
 # Keep the ground quieter than the actors, while retaining generated clusters.
 levels=np.clip(np.floor(v*5.999).astype(int),0,5)
 pal=np.array([tuple(bytes.fromhex(c[1:])) for c in colors],dtype=np.uint8)
 b=np.array(Image.fromarray(pal[levels]).filter(ImageFilter.ModeFilter(3)))
 # Lock periodic opposite rows/columns to the same existing colors, no blur.
 b[-1,:]=b[0,:];b[:,-1]=b[:,0]
 tex[key]=b;Image.fromarray(b).save(OUT/(key+'_matched32.png'))
types=[(1,1),(0,6),(1,6),(1,3),(1,4),(1,5),(0,4),(2,4),(3,1),(4,1)]
atlas=Image.new('RGBA',(128,80));locations={};tile_infos=[]
for t,(ax,ay) in enumerate(types):
 for phase in range(4):
  px=phase%2;py=phase//2;idx=t*4+phase;cx=idx%8;cy=idx//8
  tile=np.zeros((16,16,4),dtype=np.uint8);tile[:,:,3]=255
  for y in range(16):
   for x in range(16):
    gx=x+px*16;gy=y+py*16;is_path=False;is_water=False;bank=False
    # Distinct, quiet edges replace the old repeating sawtooth sand outline.
    wiggle=[1,1,0,0,-1,-1,0,1,1,0,-1,-1,0,0,1,0]
    if (ax,ay)==(1,4):is_path=True
    elif (ax,ay)==(1,3):is_path=y>=10+wiggle[x]
    elif (ax,ay)==(1,5):is_path=y<=5+wiggle[x]
    elif (ax,ay)==(0,4):is_path=x>=10+wiggle[y]
    elif (ax,ay)==(2,4):is_path=x<=5+wiggle[y]
    elif (ax,ay)==(4,1):is_water=True
    elif (ax,ay)==(3,1):
      # The river remains to the east, behind the existing x448 collision.
      edge=9+wiggle[y];is_water=x>=edge;bank=abs(x-edge)<2
    family='water' if is_water else ('path' if is_path or bank else 'grass')
    tile[y,x,:3]=tex[family][gy,gx]
    # Short earth lip on each path, away from the walkable centre.
    if (ax,ay) in [(0,4),(2,4)] and abs(x-(10+wiggle[y] if ax==0 else 5+wiggle[y]))==0:
      tile[y,x,:3]=(138,127,92)
    if bank and not is_water:tile[y,x,:3]=(104,92,70)
  atlas.paste(Image.fromarray(tile),(cx*16,cy*16));locations[(ax,ay,phase)]=(cx,cy);tile_infos.append((cx,cy))
atlas.save(OUT/'route1_ground_atlas.png')
converted=[];world=Image.new('RGBA',(640,384))
for x,y,source,ax,ay,alt in CELLS:
 phase=(x%2)+(y%2)*2;cx,cy=locations[(ax,ay,phase)];converted.append([x,y,source,cx,cy,alt]);world.paste(atlas.crop((cx*16,cy*16,cx*16+16,cy*16+16)),(x*16,y*16))
raw=b'\0\0'+b''.join(struct.pack('<6h',*c) for c in converted)
(OUT/'terrain_data_base64.txt').write_text(base64.b64encode(raw).decode())
world.resize((1280,768),Image.Resampling.NEAREST).save(OUT/'route_ground_review.png')
tres='[gd_resource type="TileSet" format=3]\n\n[ext_resource type="Texture2D" path="res://assets/tilesets/route1_rd_2026_10_01/route1_ground_atlas.png" id="1_ground"]\n\n[sub_resource type="TileSetAtlasSource" id="Ground"]\ntexture = ExtResource("1_ground")\ntexture_region_size = Vector2i(16, 16)\n'
for cx,cy in tile_infos:tres+=f'{cx}:{cy}/0 = 0\n'
tres+='\n[resource]\ntile_size = Vector2i(16, 16)\nsources/0 = SubResource("Ground")\n';(OUT/'route1_ground_tileset.tres').write_text(tres)
report={'cell_count':len(CELLS),'world_size':[640,384],'native_tile_size':16,'atlas_size':atlas.size,'topology_changes':0,'collision_changes':0,'source_generation_sizes':{k:[32,32] for k in tex},'edge_repeat_repair':'Opposite last edges copy first native rows/columns; no interpolation.','palette_ramps':RAMPS,'tileset_types':types,'converted_data_sha256':hashlib.sha256(raw).hexdigest()}
(OUT/'terrain_preparation.json').write_text(json.dumps(report,indent=2));print(json.dumps(report))
