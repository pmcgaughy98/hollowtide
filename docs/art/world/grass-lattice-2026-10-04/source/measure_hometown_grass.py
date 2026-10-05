from PIL import Image
from pathlib import Path
import numpy as np,json
D=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an")/"hometown-neighborhood-2026-10-04"
a=np.array(Image.open(D/"render/grass-explicit-texture-shader.png"));b=np.array(Image.open(D/"render/grass-single-surface-no-shader.png"))
tiles=np.array(Image.open(D/"native_grass_same_tiles.png"))
out={}
for x,y in [(584,446),(580,446),(576,446),(575,446),(560,446),(510,220),(600,224),(620,242),(334,640),(333,640),(332,640),(320,640),(512,512),(700,704)]:
 out[str((x,y))]={"shade":a[y,x,:3].tolist(),"no_shader":b[y,x,:3].tolist(),"native":tiles[y,x,:3].tolist()}
print(json.dumps(out,indent=2))
for ar,name in [(a,"shaded"),(b,"unshaded")]:
 crop=Image.fromarray(ar[400:510,510:700]).resize((950,550),Image.Resampling.NEAREST)
 crop.save(D/"render"/("diagnostic-"+name+".png"))
