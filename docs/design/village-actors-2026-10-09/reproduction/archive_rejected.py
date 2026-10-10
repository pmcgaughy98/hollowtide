from pathlib import Path
import json,urllib.request
W=Path(__file__).parent
j=json.loads((W/'punchybun-rejected-result.json').read_text())
urllib.request.urlretrieve(j['result']['output_urls'][0],W/'punchybun-rejected-raw.gif')
print('Rejected animation retained only as evidence')
