from pathlib import Path
import urllib.request,json
W=Path(__file__).parent
for form in ['punchybun','cinderhide']:
    r=json.loads((W/(form+'-base.json')).read_text())
    urllib.request.urlretrieve(r['result']['output_urls'][0],W/(form+'-base.png'))
print('Downloaded both original dedicated menu sprites')
