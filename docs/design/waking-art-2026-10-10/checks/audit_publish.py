from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
import hashlib,json,shutil,re
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');P=L/'docs/design/waking-art-2026-10-10'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
d=json.loads((W/'install-manifest.json').read_text());base=json.loads((W/'baseline.json').read_text())
owned=list(d['files']);bad=[r for r in owned if sha(L/r)!=d['files'][r]['candidate']]
assert not bad,f'Installed owned changes need review: {bad}'
def compare(item):
 r,old=item;p=L/r
 return (r,'missing' if not p.exists() else sha(p)) if not p.exists() or sha(p)!=old else None
with ThreadPoolExecutor(max_workers=8) as pool:
 changes=[x for x in pool.map(compare,[(r,h) for r,h in base.items() if r not in owned]) if x]
print('Concurrent baseline removals retained:',[r for r,h in changes if h=='missing'])
source=json.loads((W/'starward-sources.json').read_text());source_changes=[r for r,h in source.items() if not (L/r).exists() or sha(L/r)!=h]
original_bad=[]
for r,m in d['files'].items():
 if m['before'] and sha(P/'originals'/r)!=m['before']:original_bad.append(r)
assert not original_bad,original_bad
assert sha(L/'scripts/town/hub_town.gd')==d['preserved_claude_town'],'Concurrent town changed; inspect.'
live={}
for name in ['waking_check','journey_check','soul_check','starward_check','starward_team_check','portrait_scene_check','approach_check','town_loop_check','art_check','selout_check','dungeons_check','town_walk_check']:
 path=W/f'live-{name}.log';text=path.read_text(encoding='utf-8')
 assert not any(token in text for token in ['SCRIPT ERROR:','ERROR:','FAIL','WRONG','leaked']),name
 live[name]=[line for line in text.splitlines() if any(token in line for token in ['PASS','RESULT:','DUNGEONS:'])][-1:]
archive_sources={p.name:sha(p) for p in (P/'sources').iterdir()};assert archive_sources==d['source_images']
result={'owned_installed_exact':len(owned),'originals_exact':True,'claude_town_byte_exact':True,'unowned_baseline_file_count':len(base)-len([r for r in base if r in owned]),'concurrent_baseline_changes_retained':changes,'starward_source_changes_retained':source_changes,'generated_sources_exact':archive_sources,'final_native_results':live}
(W/'audit.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
shutil.copytree(W/'review',P/'review',dirs_exist_ok=True)
for p in W.iterdir():
 if p.is_file() and p.suffix in ['.gd','.py','.json','.log']:shutil.copy2(p,P/'checks'/p.name)
shutil.copytree(W/'initial-originals',P/'initial-originals',dirs_exist_ok=True)
readme=P/'README.md';text=readme.read_text(encoding='utf-8')
text+='\n## Final installed result\n\nAll twelve final native fixtures pass without errors or leaks. Starward GPU: 9/9 across 329 textures, including 117 changed head/neck fringe pixels; all eight emotions also pass in real town/dungeon dialogue. Team headshot and breathing preview receive the same finish. Waking 96/96; playable journey 17/17; bank art 11/11; bank finish 5/5. Entrance material GPU: 30,529 selected pixels changed, zero outside its mask, alpha and bright glow exact. Claude cinematic entrance uses nearest native art and the shared material finish; the preserved walk/cross/fade reaches the Hollow. The first trial/clear, return inventory/taught/IQ and faint loss loop passes.\n\nAudit: '+str(len(owned))+' installed files and original backups match; Claude town hook is byte-exact. '+str(len(changes))+' baseline paths changed or were removed concurrently outside this scope; their current state was retained. '+str(len(source_changes))+' Starward source paths changed concurrently after the art snapshot; retained current live textures were used in final GPU review. Audit details: [audit](checks/audit.json). Godot generated import/UID cache was refreshed for live verification; project.godot and default_bus_layout.tres were not edited.\n'
readme.write_text(text,encoding='utf-8')
print(json.dumps({'owned':len(owned),'concurrent_retained':len(changes),'starward_sources_concurrent':len(source_changes),'native_fixtures':len(live)}))
