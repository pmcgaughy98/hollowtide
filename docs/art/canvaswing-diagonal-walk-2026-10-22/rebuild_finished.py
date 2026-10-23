from pathlib import Path
from collections import Counter,defaultdict
import subprocess,sys,json,shutil,importlib.util
import numpy as np
from PIL import Image
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');BACK=R/'docs/creatures/recolor-2026-10-11/before';ART='assets/sprites/arena/canvaswing';WALK='docs/creatures/arena-starters-2026-10-07/walk';name='canvaswing_se_sheet.png'
old=np.array(Image.open(BACK/WALK/name).convert('RGBA'));current=np.array(Image.open(R/WALK/name).convert('RGBA'));new=np.array(Image.open(W/'project'/WALK/name).convert('RGBA'))
lookup=defaultdict(Counter)
for a,b in zip(old[:128,:384].reshape(-1,4),current[:128,:384].reshape(-1,4)):
    if a[3] and b[3]:lookup[tuple(b[:3])][tuple(a[:3])]+=1
pre_new=old.copy()
for i in range(3,8):
    a=new[i//4*128:(i//4+1)*128,i%4*128:(i%4+1)*128];z=np.zeros_like(a)
    for y in range(128):
        for x in range(128):
            if a[y,x,3]:z[y,x,:3]=lookup[tuple(a[y,x,:3])].most_common(1)[0][0];z[y,x,3]=255
    pre_new[i//4*128:(i//4+1)*128,i%4*128:(i%4+1)*128]=z
spec=importlib.util.spec_from_file_location('paint',R/'tools/arena/recolor_creature.py');paint=importlib.util.module_from_spec(spec);spec.loader.exec_module(paint)
commands=[];projects={}
for label in ['baseline-finished','candidate-finished']:
    project=W/label;project.mkdir();projects[label]=project
    for rel,src in [('tools/arena',R/'tools/arena'),(ART,BACK/ART),('scripts/arena',W/'project/scripts/arena')]:
        dst=project/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copytree(src,dst)
    dest=project/WALK;dest.mkdir(parents=True)
    for p in (BACK/WALK).glob('canvaswing_*_sheet.png'):shutil.copy2(p,dest/p.name)
    if label=='candidate-finished':Image.fromarray(pre_new).save(dest/name)
    for tool,args in [('build_dungeon_set.py',['canvaswing']),('build_dungeon_set.py',['canvaswing','--set=town','--scale=1.5']),('build_small.py',['canvaswing'])]:
        cmd=[sys.executable,str(project/'tools/arena'/tool),*args];p=subprocess.run(cmd,cwd=project,capture_output=True,text=True,encoding='utf-8',timeout=90);assert p.returncode==0,p.stderr
        commands.append({'project':str(project),'command':cmd,'stdout':p.stdout,'stderr':p.stderr,'exit':p.returncode});print(label,p.stdout,flush=True)
    for folder in ['dungeon','town','small']:
        for p in (project/ART/folder).glob('*.png'):paint.recolor(Image.open(p),paint.SCHEMES['canvaswing']['rule'],None).save(p)
B=projects['baseline-finished'];P=projects['candidate-finished'];mismatches=[];changes=[]
for folder in ['dungeon','town','small']:
    for p in (P/ART/folder).glob('*.png'):
        rel=p.relative_to(P).as_posix();a=np.array(Image.open(p).convert('RGBA'));b=np.array(Image.open(B/rel).convert('RGBA'));c=np.array(Image.open(R/rel).convert('RGBA'))
        if not np.array_equal(b,c):mismatches.append({'path':rel,'pixels':int(np.any(b!=c,axis=2).sum()),'alpha':int((b[:,:,3]!=c[:,:,3]).sum())})
        if not np.array_equal(a,b):changes.append(rel)
result={'baseline_mismatches':mismatches,'changed_frames':changes,'builder_commands':commands,'colour_order':'Preserved pre-recolour sources -> original named builders with unchanged args -> existing Canvaswing recolor rule once. New native current-palette frames reverse-mapped through preserved good-frame pixel pairs only for builder input.'}
(W/'finished-build.json').write_text(json.dumps(result,indent=2),encoding='utf-8');print('Baseline mismatches:',len(mismatches),'candidate changed:',len(changes),flush=True)
assert not mismatches,mismatches[:4]
assert len(changes)==30
