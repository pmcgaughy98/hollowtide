from pathlib import Path
from PIL import Image,ImageDraw
W=Path(__file__).parent
panels=[('Down stairs','hall',(332,236,388,294)),('Up stairs','hall_low',(596,308,652,366)),('West door','hall_low',(0,112,30,176)),('East door','hall_low',(690,112,720,176)),('Kitchen hatch','hall_low',(0,184,30,248)),('Keepsakes','chamber',(22,4,50,76)),('Ledgers','chamber',(358,4,386,76)),('Supply','hall_low',(646,4,674,76)),('Empty pegs','runners',(304,98,320,132))]
im=Image.new('RGB',(830,9*230+40),'#211d19');d=ImageDraw.Draw(im)
d.text((20,12),'CURRENT CLAUDE FIXTURES                   NATIVE GODOT FINISH',fill='#efdfb8')
for i,(label,room,box) in enumerate(panels):
    y=40+i*230;d.text((18,y+4),label,fill='#efdfb8')
    for j,phase in enumerate(['before','after']):
        src=Image.open(W/'review'/phase/(room+'_gpu.png')).convert('RGB').crop(box)
        src=src.resize((src.width*3,src.height*3),Image.Resampling.NEAREST)
        im.paste(src,(170+j*320,y+8))
im.save(W/'review/fixture_comparison.png')
print('Saved native screenshot contact sheet.')
