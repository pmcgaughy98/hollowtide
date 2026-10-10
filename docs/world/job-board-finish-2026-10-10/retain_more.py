from pathlib import Path
import hashlib,json,shutil,subprocess
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
accepted=json.loads((W/'accepted-post-preinstall.json').read_text());art=json.loads((W/'retained-concurrent-ui-art.json').read_text())
for r in ['scripts/town/hub_town.gd','scripts/ui/party_screen.gd','assets/sprites/ui/frame/nameplate.png']:
 p=L/r;h=hashlib.sha256(p.read_bytes()).hexdigest();info={'sha256':h,'reason':'Inspected concurrent Claude UI padding / textured party frame / flat brass nameplate refinement; unchanged by Board install.'}
 accepted[r]=info
 if r.startswith('assets/'):art[r]=info
 d=W/'archive/concurrent'/r;d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,d)
 if p.suffix=='.gd':
  diff=subprocess.run(['git','diff','--no-index','--',str(C/r),str(d)],capture_output=True,text=True)
  (d.parent/(d.name+'.diff.txt')).write_text(diff.stdout)
(W/'accepted-post-preinstall.json').write_text(json.dumps(accepted,indent=2));(W/'retained-concurrent-ui-art.json').write_text(json.dumps(art,indent=2))
print('Retained inspected town/party padding and brass nameplate edits')
