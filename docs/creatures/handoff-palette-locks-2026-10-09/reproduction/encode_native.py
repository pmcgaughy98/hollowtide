from pathlib import Path
from PIL import Image
W=Path(__file__).parent
paths=sorted((W/'native-loop').glob('frame_*.png'));assert len(paths)==24
frames=[Image.open(p).convert('RGB') for p in paths];pal=frames[0].quantize(colors=256)
frames=[f.quantize(palette=pal,dither=Image.Dither.NONE) for f in frames]
frames[0].save(W/'native-walk.gif',save_all=True,append_images=frames[1:],duration=100,loop=0,disposal=2)
print('Native animation review saved')
