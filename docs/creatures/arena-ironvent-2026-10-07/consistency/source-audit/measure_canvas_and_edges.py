from pathlib import Path
import json
w=Path('C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/arena-ironvent-consistency-2026-10-07/source-audit')
rs=json.loads((w/'before-metrics.json').read_text())
summary={}
for n in ('cinderhide','clinkerhide','ironvent'):
 summary[n]={'base':next(r for r in rs if r['form']==n and r['kind']=='base'),'facing_canvases':sorted({tuple(r['canvas']) for r in rs if r['form']==n and r['kind']=='full'}),'walk_canvases':sorted({tuple(r['canvas']) for r in rs if r['form']==n and r['kind']=='walk_full'}),'small_canvases':sorted({tuple(r['canvas']) for r in rs if r['form']==n and r['kind']=='small'}),'source_edge_contacts':[{'kind':r['kind'],'facing':r['facing'],'frame':r['frame'],'touches':r['painted_touches_canvas'],'foot':r['foot_row']} for r in rs if r['form']==n and r['kind'] in ('full','walk_full') and any(r['painted_touches_canvas'].values())]}
for n in summary:
 b=summary[n]['base'];summary[n]['base']={k:b[k] for k in ('canvas','bbox','foot_row','mean_brightness','mean_saturation','colour_count','dark_edge_share_pct','dark_edge_rgb_median','interior_lone_colour_pct')}
print(json.dumps(summary,indent=2))
(w/'canvas-and-source-outline-summary.json').write_text(json.dumps(summary,indent=2))
