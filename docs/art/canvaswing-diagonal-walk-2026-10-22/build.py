from pathlib import Path
import subprocess,sys,shutil,json,hashlib
from PIL import Image
import numpy as np
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');P=W/'project';B=W/'baseline-project';art='assets/sprites/arena/canvaswing';walk='docs/creatures/arena-starters-2026-10-07/walk'
B.mkdir(exist_ok=True)
for rel in ['tools/arena',art,walk,'scripts/arena']:
    dest=B/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copytree(P/rel,dest)
shutil.copy2(R/walk/'canvaswing_se_sheet.png',B/walk/'canvaswing_se_sheet.png')
commands=[]
for project,label in [(B,'baseline'),(P,'candidate')]:
    for tool,args in [('build_dungeon_set.py',['canvaswing']),('build_dungeon_set.py',['canvaswing','--set=town','--scale=1.5']),('build_small.py',['canvaswing'])]:
        cmd=[sys.executable,str(project/'tools/arena'/tool),*args];p=subprocess.run(cmd,cwd=project,capture_output=True,text=True,encoding='utf-8',timeout=90)
        commands.append({'project':str(project),'command':cmd,'exit':p.returncode,'stdout':p.stdout,'stderr':p.stderr});assert p.returncode==0,p.stderr;print(label,p.stdout,flush=True)
(W/'build-commands.json').write_text(json.dumps(commands,indent=2),encoding='utf-8')
changes=[];baseline_differences=[]
for folder in ['dungeon','town','small']:
    for p in (P/art/folder).glob('*.png'):
        rel=p.relative_to(P).as_posix();current=R/rel;base=B/rel
        a=np.array(Image.open(p).convert('RGBA'));b=np.array(Image.open(base).convert('RGBA'));c=np.array(Image.open(current).convert('RGBA'))
        if not np.array_equal(b,c):baseline_differences.append({'path':rel,'pixels':int(np.any(b!=c,axis=2).sum())})
        if not np.array_equal(a,b):changes.append(rel)
(W/'build-comparison.json').write_text(json.dumps({'new_source_changes':changes,'baseline_vs_installed':baseline_differences},indent=2),encoding='utf-8');print('Changed from baseline:',len(changes),'baseline mismatches:',len(baseline_differences),flush=True)
