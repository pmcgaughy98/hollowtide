from pathlib import Path
from PIL import Image,ImageDraw
import json,hashlib,shutil,re
P=Path(r"C:/Users/pmcga/dev/hollowtide")
W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an")
D=W/"kithflare-tail-review";D.mkdir(exist_ok=True)
entries=[]
canvas=Image.new("RGB",(640,576),(64,72,73))
for i,(id,name) in enumerate([(103,"kithflare"),(104,"wayburn"),(105,"coalcrest")]):
    resource=P/("data/creatures/%03d_%s.tres"%(id,name))
    text=resource.read_text()
    shutil.copy2(resource,D/(resource.name+"-before.txt"))
    for row,(view,key) in enumerate([("front","2_sprite"),("back","7_back")]):
        m=re.search(r'path="res://([^"]+)" id="'+key+'"',text)
        source=P/m.group(1)
        image=Image.open(source).convert("RGBA")
        shutil.copy2(source,D/(name+"-"+view+"-before.png"))
        zoom=image.resize((image.width*3,image.height*3),Image.Resampling.NEAREST)
        at=(row*320, i*192)
        canvas.paste(zoom,(at[0]+16,at[1]+20),zoom)
        ImageDraw.Draw(canvas).text((at[0]+4,at[1]+4),name.upper()+" "+view.upper()+" "+str(image.size),fill="white")
        entries.append({"name":name,"view":view,"source":m.group(1),"size":list(image.size),"sha256":hashlib.sha256(source.read_bytes()).hexdigest()})
canvas.save(D/"before-sheet.png")
(D/"source-ledger.json").write_text(json.dumps(entries,indent=2))
print(json.dumps(entries))
