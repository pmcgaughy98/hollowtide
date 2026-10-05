from pathlib import Path
from PIL import Image,ImageFilter
import numpy as np,json
W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an");P=Path(r"C:/Users/pmcga/dev/hollowtide");D=W/"historic-frontage-2026-10-04"
# Rebuild only paving from the unchanged original plus the approved native material.
text=(W/"install_historic_frontage.py").read_text()
fragment=text[text.index('original=Image.open'):text.index('s=(P/"scripts/historic_street.gd").read_text()')]
fragment=fragment.replace('],22)','],46)').replace('[356,404]','[365,404]')
scope={"Image":Image,"ImageFilter":ImageFilter,"np":np,"P":P,"W":W,"DEST":P/"assets/sprites/world/historic_frontage_2026_10_04"}
scope["audit"] = []
exec(fragment,scope)
p=P/"scripts/historic_street.gd";s=p.read_text().replace('"homes":Vector2(356,244)','"homes":Vector2(365,244)');p.write_text(s,encoding="utf-8",newline="\n")
p=W/"historic_frontage_walk.gd";s=p.read_text().replace('Vector2(356,244)','Vector2(365,244)');p.write_text(s)
audit=json.loads((D/"native-preparation.json").read_text());audit[-1]["new_path_pixels"]=int(scope["edit"].sum());audit[-1]["workshop_forecourt_half_width"]=46;audit[-1]["rowhome_doors_x"]=[365,404]
(D/"native-preparation.json").write_text(json.dumps(audit,indent=2))
print("Grounded the keeper on the workshop forecourt and aligned the doorstep interaction to the visible left door")
