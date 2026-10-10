from pathlib import Path
from PIL import Image
W=Path(__file__).parent
sources=sorted((W/'capture').glob('frame_*.png'))
assert len(sources)==90,len(sources)
frames=[Image.open(p).convert('RGB').resize((768,432),Image.Resampling.NEAREST) for p in sources]
palette=frames[0].quantize(colors=256,method=Image.Quantize.MEDIANCUT)
frames=[f.quantize(palette=palette,dither=Image.Dither.NONE) for f in frames]
frames[0].save(W/'menu-loop.gif',save_all=True,append_images=frames[1:],duration=100,loop=0,optimize=False,disposal=2)
print('90 native menu samples encoded')
