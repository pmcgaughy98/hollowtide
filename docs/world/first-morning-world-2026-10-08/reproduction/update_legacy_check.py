from pathlib import Path
import hashlib,json
root=Path(__file__).parent;live=Path('C:/Users/pmcga/dev/hollowtide')
name='tools/debug/opening_flow_check.gd'
data=(live/name).read_bytes()
target=root/'originals'/name;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
baseline=json.loads((root/'baseline.json').read_text());baseline[name]=hashlib.sha256(data).hexdigest()
(root/'baseline.json').write_text(json.dumps(baseline,indent=2))
(root/'project'/name).write_text('extends "res://tools/debug/first_morning_check.gd"\n## The first partner now joins through the playable hall story.\n## Use -- male|female kithflare|tallowroot|rimefin for the current opening check.\n')
