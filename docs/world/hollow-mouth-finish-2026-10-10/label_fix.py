from pathlib import Path
import hashlib,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
r='scripts/town/hub_town.gd';assert hashlib.sha256((L/r).read_bytes()).hexdigest()==hashlib.sha256((W/'originals'/r).read_bytes()).hexdigest(),'Controller changed; inspect before presentation patch.'
t=(W/'originals'/r).read_text();needle='\t\tvar mid: float = at.x + r.size.x * T * 0.5\n';assert t.count(needle)==1
t=t.replace(needle,needle+'\t\t# Landing overlaps the finished Mouth; keep its temporary plaque at its own spot.\n\t\tif p["id"] == "landing" and is_instance_valid(_building_exteriors) and _building_exteriors.buildings.has("gate"):\n\t\t\tmid = p["door"].x * T + T * 0.5\n\t\t\tat.y = p["door"].y * T + 6\n')
(W/'candidate'/r).write_text(t)
print('Landing label-only patch; every controller / job / state method retained.')
