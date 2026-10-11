from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
pending=json.loads((W/'pending-install.json').read_text());fix=[]
for r in ['scripts/ui/crew_portrait_canvas.gd','docs/AI_COLLABORATION.md']:
    record=next(d for d in pending if d['path']==r)
    assert sha(L/r)==record['after'],('New concurrent edit',r)
    backup=W/'installed-before-border-fix'/r;backup.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,backup)
    dst=W/'candidate'/r
    if r.endswith('.gd'):shutil.copy2(C/r,dst)
    else:
        raw=(L/r).read_bytes();a=b'Frames, emotion backgrounds/marks and text stay outside that finish.';b=b'Each creature is clipped to the portrait window so its expanded contour cannot cover the brass border; the approved outline is retained. Frames, emotion backgrounds/marks and text stay outside that finish.'
        assert raw.count(a)==1;dst.write_bytes(raw.replace(a,b))
    fix.append({'path':r,'before':record['after'],'after':sha(dst)})
    record['after']=sha(dst)
(W/'border-fix.json').write_text(json.dumps(fix,indent=2));(W/'pending-install.json').write_text(json.dumps(pending,indent=2))
print('Prepared guarded border-only correction; approved outline unchanged.')
