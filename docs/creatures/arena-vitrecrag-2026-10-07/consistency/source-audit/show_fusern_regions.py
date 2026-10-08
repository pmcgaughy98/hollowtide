from pathlib import Path
import json
w=Path('C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/arena-vitrecrag-consistency-2026-10-07/source-audit')
rs=json.loads((w/'before-metrics.json').read_text());print(json.dumps([{k:r[k] for k in ('kind','facing','frame','canvas','bbox','mean_brightness','mean_saturation','top_colours')} for r in rs if r['form']=='fusern' and r['kind'] in ('base','full')],indent=2))
