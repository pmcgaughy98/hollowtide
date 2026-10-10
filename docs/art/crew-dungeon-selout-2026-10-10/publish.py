from pathlib import Path
import json,hashlib,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');P=L/'docs/art/crew-dungeon-selout-2026-10-10'
assert P.is_dir()
for name,marker in [('live_selout_check.log','SEL-OUT: 22 checks, 0 failures'),('live_dungeons_check.log','DUNGEONS: all ok')]:
 assert marker in (W/name).read_text()
 assert 'SCRIPT ERROR' not in (W/name).read_text()
report=json.loads((W/'audit.json').read_text());assert report['owned_installed_exact']==8 and report['note_prior_content_retained']
manifest=json.loads((W/'pending-install.json').read_text())
for entry in manifest:assert hashlib.sha256((L/entry['path']).read_bytes()).hexdigest()==entry['candidate'],entry['path']
readme=(W/'README.md').read_text(encoding='utf-8')
readme+='\nFinal live checks: 22/22 finish checks and Claude’s current dungeon regression pass. 11,212 protected paths and 10,685 original art/source paths are exact; eight installed files are exact. Nine concurrent changes (six Kithflare emotion portraits, town code and two tools) were preserved and separately snapshotted. No live script errors or shutdown leaks in the final checks.\n'
(W/'README.md').write_text(readme,encoding='utf-8')
for p in W.iterdir():
 if p.is_file() and p.suffix in ['.py','.gd','.json','.log','.md','.ps1']:shutil.copy2(p,P/p.name)
for folder in ['review/live','concurrent-final']:
 shutil.copytree(W/folder,P/folder,dirs_exist_ok=True)
entries=[]
for p in P.rglob('*'):
 if p.is_file() and p.name!='publication.json':entries.append({'path':p.relative_to(P).as_posix(),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
(W/'publication.json').write_text(json.dumps({'files':len(entries),'entries':entries},indent=2))
shutil.copy2(W/'publication.json',P/'publication.json')
print('Final native evidence and preservation audit published:',len(entries),'files.')
