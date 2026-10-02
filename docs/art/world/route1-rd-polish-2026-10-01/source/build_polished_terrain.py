from pathlib import Path
from PIL import Image, ImageFilter, ImageDraw
import numpy as np, json, base64, struct, hashlib

ROOT=Path(__file__).resolve().parent
SOURCE=ROOT.parent
cells=json.loads((SOURCE/'route_cells.json').read_text())
mask=Image.new('L',(640,384))
m=np.zeros((384,640),dtype=np.uint8)
wiggle=[0,0,1,1,0,0,-1,-1,0,0,1,1,0,0,-1,0]
for cx,cy,source,ax,ay,alt in cells:
    for y in range(16):
        for x in range(16):
            p=(ax,ay)==(1,4)
            if (ax,ay)==(1,3):p=y>=10+wiggle[x]
            if (ax,ay)==(1,5):p=y<=5+wiggle[x]
            if (ax,ay)==(0,4):p=x>=10+wiggle[y]
            if (ax,ay)==(2,4):p=x<=5+wiggle[y]
            if p:m[cy*16+y,cx*16+x]=255
# Smooth the contour mask, then threshold back to crisp native pixels.
# Colour pixels are never interpolated.
mask=Image.fromarray(m).filter(ImageFilter.GaussianBlur(2.5)).point(lambda v:255 if v>=128 else 0)
path=np.array(mask)>0
outer=np.array(mask.filter(ImageFilter.MaxFilter(7)))>0
inner=np.array(mask.filter(ImageFilter.MinFilter(3)))>0
ramps={
 'grass':['#526c55','#576f57','#5b745a','#60795e','#657e61','#6b8365'],
 'path':['#ad9873','#b3a078','#b7a57d','#bbaa80','#bfae84','#c3b389'],
 'water':['#37655e','#3b6b63','#3f7067','#45766c','#4b7c72','#538479']}
texture={}
for name,colours in ramps.items():
    raw=np.array(Image.open(SOURCE/(name+'_original.png')).convert('RGB'))
    luminance=raw@np.array([.28,.56,.16])
    lo,hi=np.percentile(luminance,[2,98])
    levels=np.clip(((luminance-lo)/(hi-lo)*5.999).astype(int),0,5)
    # Discrete majority filtering removes salt-and-pepper noise.
    levels=np.array(Image.fromarray(levels.astype('uint8')).filter(ImageFilter.ModeFilter(5)))
    levels[-1,:]=levels[0,:];levels[:,-1]=levels[:,0]
    pal=np.array([tuple(bytes.fromhex(c[1:])) for c in colours],dtype='uint8')
    texture[name]=pal[levels]
    Image.fromarray(texture[name]).save(ROOT/(name+'_quiet32.png'))
yy,xx=np.indices((384,640))
world=texture['grass'][yy%32,xx%32].copy()
world[path]=texture['path'][yy[path]%32,xx[path]%32]
fringe=outer&~path&(xx<448)
world[fringe]=(67,94,70)
rim=path&~inner
world[rim]=(157,144,106)
# A continuous dry-earth bank unifies the path and river edge.
waterline=456+np.array(wiggle)[yy%16]
bank=(xx>=448)&(xx<waterline)
water=xx>=waterline
world[bank]=texture['path'][yy[bank]%32,xx[bank]%32]
toe=(xx==waterline-1)|(xx==waterline-2)
world[toe]=(106,106,74)
world[water]=texture['water'][yy[water]%32,xx[water]%32]
wet=xx==waterline
world[wet]=(98,137,117)
image=Image.fromarray(world).convert('RGBA')
tiles=[];lookup={};converted=[]
for cx,cy,source,ax,ay,alt in cells:
    tile=image.crop((cx*16,cy*16,cx*16+16,cy*16+16))
    key=tile.tobytes()
    if key not in lookup:lookup[key]=len(tiles);tiles.append(tile)
    idx=lookup[key];converted.append([cx,cy,source,idx%16,idx//16,alt])
height=((len(tiles)+15)//16)*16
atlas=Image.new('RGBA',(256,height))
for i,tile in enumerate(tiles):atlas.paste(tile,((i%16)*16,(i//16)*16))
atlas.save(ROOT/'route1_ground_atlas_polished.png')
raw=b'\0\0'+b''.join(struct.pack('<6h',*c) for c in converted)
(ROOT/'tile_map_data.txt').write_text(base64.b64encode(raw).decode())
tres='[gd_resource type="TileSet" format=3]\n\n[ext_resource type="Texture2D" path="res://assets/tilesets/route1_rd_2026_10_01/route1_ground_atlas_polished.png" id="1_ground"]\n\n[sub_resource type="TileSetAtlasSource" id="Ground"]\ntexture = ExtResource("1_ground")\ntexture_region_size = Vector2i(16, 16)\n'
for i in range(len(tiles)):tres+=f'{i%16}:{i//16}/0 = 0\n'
tres+='\n[resource]\ntile_size = Vector2i(16, 16)\nsources/0 = SubResource("Ground")\n'
(ROOT/'route1_ground_polished.tres').write_text(tres)
image.resize((1280,768),Image.Resampling.NEAREST).save(ROOT/'polished_ground_review.png')
report={'source_cells':len(cells),'preserved_cell_positions':all(a[:3]==b[:3] and a[5]==b[5] for a,b in zip(cells,converted)),'unique_native_tiles':len(tiles),'atlas_size':atlas.size,'palette':ramps,'colour_interpolation':False,'collision_changes':0,'converted_sha256':hashlib.sha256(raw).hexdigest()}
(ROOT/'terrain_polish.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report))
