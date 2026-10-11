from pathlib import Path
from PIL import Image
import shutil,json
W=Path(__file__).parent
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
G=Path('C:/Users/pmcga/.codex/generated_images/01a11b73-6d5a-78a3-819c-fd3b9ced7188')
F=C/'assets/sprites/world/hall_floors_2026_10_11'
F.mkdir(parents=True,exist_ok=True)
sources={'lower':'exec-8c75c1f6-3334-4e44-a94c-95c7ab381397.png','wood':'exec-7f9b1266-a857-4905-9865-a7429001bcb2.png','fixtures':'exec-718266e5-ffda-4fc0-afe5-3b5ac9f6874d.png','runners':'exec-2417fd87-1de7-4b16-9858-87c4c88d3fae.png'}
manifest={}
(W/'generation').mkdir(exist_ok=True)
for name,file in sources.items():shutil.copy2(G/file,W/'generation'/file)
def sprite(sheet,name,region,size):
    part=sheet.crop(region)
    alpha=part.getchannel('A').point(lambda a:255 if a>127 else 0)
    bounds=alpha.getbbox()
    assert bounds,name
    part=part.crop(bounds)
    out=part.resize(size,Image.Resampling.NEAREST)
    out.save(F/(name+'.png'))
    manifest[name]={'region':region,'alpha_bounds_in_region':bounds,'native':size}
atlas=Image.open(G/sources['fixtures']).convert('RGBA')
pieces=[
('north_door',(0,0,360,290),(60,46)),('window',(365,0,715,290),(44,32)),('banner',(730,0,1015,290),(16,38)),('duty',(1020,0,1402,280),(52,28)),
('side_door',(0,290,250,600),(18,52)),('kitchen',(250,290,540,595),(24,48)),('mess',(540,290,1190,595),(144,50)),('supply',(1195,280,1402,606),(20,82)),
('keepsakes',(0,602,250,867),(20,82)),('ledgers',(250,602,455,867),(20,82)),('river_map',(457,600,930,851),(96,32)),('dais',(940,606,1402,867),(72,52)),
('stairs_down',(0,875,272,1122),(48,48)),('stairs_up',(280,875,528,1122),(48,48)),('rollcall',(550,861,1000,1122),(153,93)),('window_wide',(1030,878,1402,1122),(68,32))]
for name,region,size in pieces:sprite(atlas,name,region,size)
atlas=Image.open(G/sources['runners']).convert('RGBA')
pieces=[('bunk_ochre',(0,70,340,520),(48,52)),('bunk_slate',(360,70,700,520),(48,52)),('chest',(735,220,1150,510),(48,22)),('pegs',(1170,70,1402,520),(16,48)),
('lamp',(0,700,180,960),(10,18)),('runner',(190,530,370,1080),(36,128)),('teal_rug',(385,580,1010,1000),(192,120)),('rust_rug',(1020,720,1402,980),(96,48))]
for name,region,size in pieces:sprite(atlas,name,region,size)
# Five cropped background sprites per room: fit the shell to the exact wall/floor bands in code.
# These are sprite crops and nearest preparation only; no painting, floor cloning or object erasure.
for name,size,source,cut in [('lower',(720,432),'lower',(58,144,1562,892)),('chamber',(384,264),'wood',(68,183,1446,942)),('runners',(336,240),'wood',(68,183,1446,942))]:
    sheet=Image.open(G/sources[source]).convert('RGBA')
    sw,sh=sheet.size;x0,y0,x1,y1=cut;w,h=size
    crops={'floor':((x0,y0,x1,y1),(w-48,h-72)), 'north':((0,0,sw,y0),(w,48)), 'south':((0,y1,sw,sh),(w,24)),
           'west':((0,y0,x0,y1),(24,h-72)), 'east':((x1,y0,sw,y1),(24,h-72))}
    for part,(rect,target) in crops.items():
        sheet.crop(rect).resize(target,Image.Resampling.NEAREST).save(F/(name+'_'+part+'.png'))
        manifest[name+'_'+part]={'source':sources[source],'region':rect,'native':target}
(W/'native-preparation.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print(f'{len(manifest)} native sprite/background crops prepared. Original four generated sources retained.')
