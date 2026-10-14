from pathlib import Path
import json,hashlib,shutil
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');PREV=Path('D:/dev/hollowtide-dialogue-corner-20261014')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
protected=json.loads((PREV/'protected.json').read_text(encoding='utf-8'))
assert all(sha(R/r)==h for r,h in protected.items()),'Sources changed; inspect before reusing checked candidate.'
(W/'protected.json').write_text(json.dumps(protected,indent=2),encoding='utf-8')
ui=R/'scripts/ui/ui_style.gd';shutil.copy2(ui,W/'original-ui_style.gd')
original=ui.read_text(encoding='utf-8');candidate=(PREV/'candidate-ui_style.gd').read_text(encoding='utf-8')
assert original.replace('const PORTRAIT_INSET := 150.0','const PORTRAIT_INSET := 162.0').replace('box.position + Vector2(30, -34)','box.position + Vector2(42, -34)')==candidate
(W/'candidate-ui_style.gd').write_text(candidate,encoding='utf-8')
shutil.copy2(PREV/'candidate.diff',W/'installed.diff')
for name in ['flood.gd','gallery.gd']:
    text=(PREV/name).read_text(encoding='utf-8').replace('D:/dev/hollowtide-dialogue-corner-20261014/','D:/dev/hollowtide-dialogue-install-20261014/')
    (W/name).write_text(text,encoding='utf-8')
print('Guarded current source matches the natively checked original; two-value candidate prepared.')
