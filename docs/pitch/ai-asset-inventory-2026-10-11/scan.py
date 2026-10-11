from pathlib import Path
from collections import Counter
import json, re

ROOT = Path('C:/Users/pmcga/dev/hollowtide')
OUT = Path(__file__).parent
ASSET_EXTS = {'.png','.jpg','.jpeg','.svg','.wav','.mp3','.ogg','.ttf','.otf','.tres','.tscn','.gdshader','.gdshaderinc'}
assets = [p for p in (ROOT/'assets').rglob('*') if p.is_file() and p.suffix.lower() in ASSET_EXTS]
groups = Counter('/'.join(p.relative_to(ROOT).parts[:4]) if len(p.relative_to(ROOT).parts)>4 else p.parent.relative_to(ROOT).as_posix() for p in assets)
refs = []
network = []
for folder in ['scripts','scenes','resources','dialogue']:
    base = ROOT/folder
    if not base.exists(): continue
    for p in base.rglob('*'):
        if p.suffix not in {'.gd','.tscn','.tres','.dialogue'}: continue
        body=p.read_text(encoding='utf-8-sig')
        for lineno,line in enumerate(body.splitlines(),1):
            for target in re.findall(r'res://[^\s"\'\)\],]+',line):
                refs.append({'source':p.relative_to(ROOT).as_posix(),'line':lineno,'target':target})
            if re.search(r'HTTPRequest|HTTPClient|https?://|OpenAI|ElevenLabs|Retro.?Diffusion|Suno|LLM',line,re.I):
                network.append({'source':p.relative_to(ROOT).as_posix(),'line':lineno,'text':line.strip()})
payload={'scope':'Repository asset census, not an exported build manifest; includes unused/raw/archive assets','groups':dict(sorted(groups.items())),'asset_files':[p.relative_to(ROOT).as_posix() for p in assets],'references':refs,'runtime_network_mentions':network}
(OUT/'census.json').write_text(json.dumps(payload,indent=2),encoding='utf-8')
print('Asset census:',len(assets),'files;',len(refs),'res references')
for group,count in sorted(groups.items()):
    if group.startswith(('assets/audio','assets/sprites/arena')): continue
    print(count,group)
print('Audio family counts:',dict(Counter('/'.join(p.relative_to(ROOT).parts[:4]) for p in assets if '/audio/' in p.as_posix())))
print('Network mentions:',json.dumps(network,indent=2))
