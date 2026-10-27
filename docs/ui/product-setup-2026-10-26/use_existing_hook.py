from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
owned=json.loads((W/'installed-files.json').read_text());sidecars=json.loads((W/'verification.json').read_text())['sidecars']
for rel,h in owned.items():assert sha(L/rel)==h,rel
for rel,h in sidecars.items():assert sha(L/rel)==h,rel
s=(L/'project.godot').read_text().replace(', "res://addons/hollowtide_export/plugin.cfg"','');(L/'project.godot').write_text(s,encoding='utf-8')
s=(L/'export_presets.cfg').read_text().replace('addons/hollowtide_export/*,','');(L/'export_presets.cfg').write_text(s,encoding='utf-8')
for rel in list(owned)+list(sidecars):
 if not rel.startswith('addons/hollowtide_export/'):continue
 src=L/rel;dst=W/'retired-duplicate-hook'/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst);src.unlink();owned.pop(rel,None)
try:(L/'addons/hollowtide_export').rmdir()
except OSError:pass
for rel in owned:owned[rel]=sha(L/rel)
(W/'installed-files.json').write_text(json.dumps(owned,indent=2))
print('Removed only the hash-guarded duplicate addon. Source already registers Godot AI export hook.')
