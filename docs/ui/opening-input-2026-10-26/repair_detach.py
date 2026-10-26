from pathlib import Path
import hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');rel='scripts/storm_open.gd'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
installed=json.loads((W/'installed-files.json').read_text());assert sha(L/rel)==installed[rel]
s=(L/rel).read_text(encoding='utf-8')
s=s.replace('\tif advance:\n\t\tif _skip_armed','\tif advance:\n\t\tget_viewport().set_input_as_handled()   # _next may detach this scene immediately\n\t\tif _skip_armed',1)
needle='\t\t\t_skip_released = false\n\t\tget_viewport().set_input_as_handled()\n\telif _skip_armed:';assert s.count(needle)==1
s=s.replace(needle,'\t\t\t_skip_released = false\n\telif _skip_armed:',1)
raw=(L/rel).read_bytes();nl=b'\r\n' if b'\r\n' in raw else b'\n';payload=s.encode().replace(b'\n',nl)
(W/'prepared'/rel).write_bytes(payload);(L/rel).write_bytes(payload);installed[rel]=sha(L/rel);(W/'installed-files.json').write_text(json.dumps(installed,indent=2));print('Handled advance before scene change; source hash updated.')
