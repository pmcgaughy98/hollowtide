from pathlib import Path
import difflib,hashlib,json,re,shutil
from PIL import Image,ImageDraw
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');E=L/'docs/ui/title-panel-bounds-2026-10-26'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'protected-before.json').read_text(encoding='utf-8'))
owned={'scripts/creature_opening.gd','scripts/main_menu.gd'}
changes=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h]
assert set(changes)==owned,changes
for p,h in json.loads((W/'installed-files.json').read_text(encoding='utf-8')).items():assert sha(L/p)==h,p
assert not E.exists()
diff=''
for p in sorted(owned):
    diff+=''.join(difflib.unified_diff((W/'originals'/p).read_text(encoding='utf-8').splitlines(True),(L/p).read_text(encoding='utf-8').splitlines(True),fromfile='original/'+p,tofile='installed/'+p))
(W/'source.diff').write_text(diff,encoding='utf-8')
sheet=Image.new('RGB',(1152,1056),'#242b25');d=ImageDraw.Draw(sheet)
for row,key in enumerate(('creature_opening-options','creature_opening-help-controls','creature_opening-quit')):
    for col,stage in enumerate(('before','after')):
        im=Image.open(W/('native-'+stage)/(key+'.png')).convert('RGB')
        sheet.paste(im.resize((576,324),Image.Resampling.NEAREST),(col*576,row*352+24))
        d.text((col*576+8,row*352+5),stage+': '+key,fill='white')
sheet.save(W/'before-after.png')
runner_cmd={'command':['C:/Users/pmcga/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe','tools/debug/run_checks.py','ui_fit','--jobs','1','--logs',str(W/'runner'),'--md',str(W/'runner-result.md')],'cwd':str(L),'APPDATA':str(W/'runner-profile'),'LOCALAPPDATA':str(W/'runner-local-profile'),'exit':0,'result':'PASS ui_fit_check'}
(W/'runner-command.json').write_text(json.dumps(runner_cmd,indent=2),encoding='utf-8')
E.mkdir(parents=True)
for folder in ('originals','prepared','native-before','native-after','native-legacy','ui-fit','runner'):
    shutil.copytree(W/folder,E/folder,ignore=shutil.ignore_patterns('__pycache__','*.pyc'))
for p in W.iterdir():
    if p.is_file() and p.name!='HANDOFF.md' and p.suffix in ('.py','.gd','.md','.log','.diff','.json','.png'):shutil.copy2(p,E/p.name)
handoff=L/'docs/team/CODEX_HANDOFF_2026-10-26_title_bounds.md';assert not handoff.exists();shutil.copy2(W/'HANDOFF.md',handoff)
result='''
## Codex result, October 26: task 3 / pass 6 C2 title bounds

COMPLETE/INSTALLED: Options y120-599, both How to play topics y120-621 (all above y636), Quit x635-1136 with 16px right margin based on its actual 501px minimum width. Shared base Options y120 also fixes the legacy opening (bottom558). Only four panel placements in scripts/creature_opening.gd and scripts/main_menu.gd changed; text/fonts/spacing/settings/art untouched. Native campaign 12/12 and full native ui_fit 48/48, clean runtime logs; all four campaign captures inspected. Official unmodified run_checks.py ui_fit: PASS, exit0, including the three formerly failing title points. Legacy geometry/focus/cancel 6/6 with separately recorded ObjectDB exit warnings. No claim that the whole suite was rerun. Fresh protected-file receipt: 1369/1373 existing files exact after source/docs publication, only the two owned source files and two handoff documents changed; Claude's modified ui_fit and other source work preserved. Private profiles/saves only, no generation/asset/rule change or commit. [Evidence and before/after](../ui/title-panel-bounds-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_title_bounds.md).

Source issues for Claude: the first combined fixture freed the legacy title while its unused world_journey background load was running; waiting removed the cascading shutdown errors. Legacy-only exits still show 100-101 ObjectDB instances across baseline/installed fixtures; unused route load removal remains C12. The official unmodified ui_fit leaves 7 instances/3 resources, accepted by the current runner's noise list; the private native copy's music teardown exits cleanly. Original task3's separation10 suggestion would not meet the newer y636 target, so current spacing12 is retained and latest C2 placement used. Next original-queue slice: task4 / C1, preference preservation and crash-safe saving against today's split preference contract. C3/C4 and remaining factory requests remain pending; proposed wording flags unchanged.
'''
queue=L/'docs/team/CODEX_TASKS_2026-10-22.md';raw=queue.read_bytes();assert sha(queue)==base[queue.relative_to(L).as_posix()]
nl=b'\r\n' if b'\r\n' in raw else b'\n';queue.write_bytes(raw+result.encode('utf-8').replace(b'\n',nl))
collab=L/'docs/AI_COLLABORATION.md';raw=collab.read_bytes();assert sha(collab)==base[collab.relative_to(L).as_posix()]
head,sep,rest=raw.partition(b'\n');nl=b'\r\n' if b'\r\n' in raw else b'\n'
entry='''
## Codex: title panel bounds, task 3 / C2 (October 26, 2026)

COMPLETE/INSTALLED: four panel placement changes in creature_opening.gd and main_menu.gd. Options ends599, both How to play topics621, Quit right1136 (16px margin); shared legacy Options ends558. Native campaign12/12 and full native ui_fit48/48 clean; official unmodified run_checks.py ui_fit PASS, exit0, the three title failures green. Legacy6/6 with separate ObjectDB exit warnings; official headless ui_fit retains its runner-exempt7-instance/3-resource exit diagnostics. Claude's current dirty sources/checks preserved:1369/1373 protected existing files exact after source/docs; only the two owned scripts and two handoff docs differ. [Evidence, originals and captures](ui/title-panel-bounds-2026-10-26/README.md); [handoff](team/CODEX_HANDOFF_2026-10-26_title_bounds.md). Private saves/profiles only; no text/font/spacing/settings/art/rules/generation/commit change. Next original-queue slice task4/C1: current preference preservation and crash-safe saving. C3/C4 and remaining factory work still pending. Unused legacy preload remains C12; initial fixture waited for it before teardown to avoid shutdown errors.

'''
collab.write_bytes(head+sep+entry.encode('utf-8').replace(b'\n',nl)+rest)
allowed=owned|{'docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-22.md'}
changed=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h];assert set(changed)==allowed,changed
assert queue.read_bytes().startswith((W/'originals/docs/team/CODEX_TASKS_2026-10-22.md').read_bytes())
assert collab.read_bytes().endswith((W/'originals/docs/AI_COLLABORATION.md').read_bytes().partition(b'\n')[2])
(E/'publication.json').write_text('{}',encoding='utf-8')
links=0
for p in (E/'README.md',handoff):
    for target in re.findall(r'\]\(([^)]+)\)',p.read_text(encoding='utf-8')):
        assert (p.parent/target).exists(),(p,target)
        links+=1
receipt={'protected_before':len(base),'protected_unchanged_after_docs':len(base)-len(changed),'existing_baseline_changes':changed,'original_queue_preserved_as_prefix':True,'original_collaboration_body_preserved_as_suffix':True,'local_links_checked':links,'native_campaign':'12/12','native_ui_fit':'48/48','legacy':'6/6; ObjectDB exit warning retained','official_runner':'PASS; exit0; known exit noise retained','production_scope':'four placements in two scripts','evidence':str(E),'handoff':str(handoff)}
(W/'publication.json').write_text(json.dumps(receipt,indent=2),encoding='utf-8');shutil.copy2(W/'publication.json',E/'publication.json');print(json.dumps(receipt,indent=2))
