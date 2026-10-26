from pathlib import Path
import difflib,hashlib,json,re,shutil
from PIL import Image,ImageDraw
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');E=L/'docs/ui/title-type-2026-10-26'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'protected-before.json').read_text())
installed=json.loads((W/'installed-files.json').read_text());owned=set(installed)
for p,h in installed.items():assert sha(L/p)==h,p
assert not E.exists()
changed=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h]
docs={'docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-22.md'}
concurrent=[p for p in changed if p not in owned|docs]
for p in concurrent:
    if (L/p).is_file():
        d=W/'concurrent-at-finish'/p;d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/p,d)
for p in docs:
    d=W/'docs-before-publication'/p;d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/p,d)
diff=''
for rel in sorted(owned):
    diff+=''.join(difflib.unified_diff((W/'originals'/rel).read_text(encoding='utf-8').splitlines(True),(L/rel).read_text(encoding='utf-8').splitlines(True),fromfile='original/'+rel,tofile='installed/'+rel))
(W/'source.diff').write_text(diff,encoding='utf-8')
sheet=Image.new('RGB',(1152,1056),'#242b25');d=ImageDraw.Draw(sheet)
for row,(before,after) in enumerate((('main-save-true','main-save-true'),('soul-long-line','soul-page-1'),('starter-cards','starter-cards'))):
    for col,phase,name in ((0,'before',before),(1,'after',after)):
        im=Image.open(W/('native-'+phase)/(name+'.png')).convert('RGB')
        sheet.paste(im.resize((576,324),Image.Resampling.NEAREST),(col*576,row*352+24));d.text((col*576+8,row*352+5),phase+': '+name,fill='white')
sheet.save(W/'before-after.png')
keys=['main-save-false','main-save-true','options-save-false','help-journey','help-controls','quit']
contact=Image.new('RGB',(1152,704),'#242b25');d=ImageDraw.Draw(contact)
for i,key in enumerate(keys):
    x=(i%3)*384;y=(i//3)*352
    im=Image.open(W/'native-after'/(key+'.png')).convert('RGB')
    contact.paste(im.resize((384,216),Image.Resampling.NEAREST),(x,y+24));d.text((x+8,y+5),key,fill='white')
contact.save(W/'menu-contact.png')
cmd={'command':['C:/Users/pmcga/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe','tools/debug/run_checks.py','ui_fit','soul_prologue','opening_flow','--jobs','1','--logs',str(W/'runner'),'--md',str(W/'runner-result.md')],'cwd':str(L),'APPDATA':str(W/'runner-profile'),'LOCALAPPDATA':str(W/'runner-local-profile'),'exit':0,'result':'3 PASS; known exit noise in raw logs retained'}
(W/'runner-command.json').write_text(json.dumps(cmd,indent=2))
E.mkdir(parents=True)
for folder in ('originals','prepared','native-before','native-after','ui-fit','runner','concurrent-at-install','concurrent-at-finish','docs-before-publication'):
    if (W/folder).exists():shutil.copytree(W/folder,E/folder,ignore=shutil.ignore_patterns('__pycache__','*.pyc'))
for p in W.iterdir():
    if p.is_file() and p.name!='HANDOFF.md' and p.suffix in ('.py','.gd','.md','.log','.json','.diff','.png'):shutil.copy2(p,E/p.name)
handoff=L/'docs/team/CODEX_HANDOFF_2026-10-26_title_type.md';assert not handoff.exists();shutil.copy2(W/'HANDOFF.md',handoff)
result='''
## Codex result, October 26: C3 title and soul type roles

COMPLETE/INSTALLED: title/menu/panel text uses shared UI.TYPE roles, buttons UI.style_button plus UI.frame normal/focus, with creature MENU_FACE/COPY_FACE/direct hint-font overrides removed. Carved wordmark exact RGBA. Soul lines now use UI.dialogue/story with readable two-row pages and page-aware advance; card names/body/hints use roles, duplicate prose typing blip removed. All original story words, input/choice/flight methods, card geometry/creature scale and previous title preference-save methods exact. Current roles are Jersey prose/headings/names and Silkscreen buttons/labels, per the real UI.TYPE contract, not an older Pixelify description. Only three owned title/soul scripts changed; concurrent Claude files preserved/archived. Native45/45 title/story, full native ui_fit48/48, both clean logs; official opening_flow21-check, soul_prologue and ui_fit all PASS, exit0 (known raw exit warnings retained). Main ends590/596 without/with Continue, Options586, Help602, Quit right1108; all fit. Native captures inspected, private saves/profiles only, no art/generation/paid call/rules/new words/commit. [Before/after and evidence](../ui/title-type-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_title_type.md).

Source issues for Claude: C7's shared-dialogue/font portion landed as necessary for the story role's readable page size; its input-action migration and main_menu _ensure_menu_inputs removal remain pending. No runtime UI.HEAD users remain in soul; only party_screen's historical comment remains elsewhere; shared HEAD stays untouched in the active UI lane, remove when ready. Baseline actual Continue menu bottom616 is now measured596 after shared type metrics. Previous task4 shared pause-save gap remains OPEN with its8/8 candidate-only diff under settings-save-2026-10-26/proposal, not installed. No cross-chat message sent. Next independent Codex slice C4 full title Options parity/shared filled sliders and live ControlsText help; C7 remainder, C8 cards, C9 light and other opening/export/art requests remain pending. Proposed words/flags unchanged.
'''
queue=L/'docs/team/CODEX_TASKS_2026-10-22.md';raw=queue.read_bytes();assert raw==(W/'docs-before-publication/docs/team/CODEX_TASKS_2026-10-22.md').read_bytes()
nl=b'\r\n' if b'\r\n' in raw else b'\n';queue.write_bytes(raw+result.encode().replace(b'\n',nl))
collab=L/'docs/AI_COLLABORATION.md';raw=collab.read_bytes();assert raw==(W/'docs-before-publication/docs/AI_COLLABORATION.md').read_bytes()
head,sep,rest=raw.partition(b'\n');nl=b'\r\n' if b'\r\n' in raw else b'\n'
entry='''
## Codex: C3 title and soul type roles (October 26, 2026)

COMPLETE/INSTALLED in main_menu, creature_opening and soul_prologue: shared TYPE fonts, style_button/frame buttons; removed creature font-file overrides. Carved wordmark exact pixels. Soul uses dialogue/story pages and page-aware advancement, names/body/hints use roles; no duplicate prose blip. Native45/45 plus native ui_fit48/48 clean; official opening_flow21-check, soul_prologue and ui_fit3 PASS, exit0, known raw exit noise retained. Main ends590/596, Options586, Help602, Quit right1108. All original story words, inputs/choice/flight/card geometry/scale and prior title-settings methods exact. Claude concurrent source edits preserved/archived. [Evidence](ui/title-type-2026-10-26/README.md); [handoff](team/CODEX_HANDOFF_2026-10-26_title_type.md). C7 dialogue/font part done, input migration and _ensure_menu_inputs still pending. Runtime UI.HEAD users gone from soul (party_screen historical comment remains); shared constant untouched for Claude's lane. Task4 shared pause-save gap still OPEN; tested8/8 proposal remains staged only. Next C4 full title Options/live Controls; other factory work/proposed words pending. Private saves only; no art/generation/paid call/rules/new words/Route1/message/commit change.

'''
collab.write_bytes(head+sep+entry.encode().replace(b'\n',nl)+rest)
assert queue.read_bytes().startswith((W/'docs-before-publication/docs/team/CODEX_TASKS_2026-10-22.md').read_bytes())
assert collab.read_bytes().endswith((W/'docs-before-publication/docs/AI_COLLABORATION.md').read_bytes().partition(b'\n')[2])
for p,h in installed.items():assert sha(L/p)==h,p
after=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h]
assert set(after)<=owned|docs|set(concurrent),after
for p in concurrent:
    if (L/p).is_file():assert sha(L/p)==sha(W/'concurrent-at-finish'/p),f'Concurrent change during publication: {p}'
(E/'publication.json').write_text('{}')
links=0
for p in (E/'README.md',handoff):
    for target in re.findall(r'\]\(([^)]+)\)',p.read_text(encoding='utf-8')):
        assert (p.parent/target).exists(),(p,target)
        links+=1
receipt={'protected_before':len(base),'protected_unchanged_after_docs':len(base)-len(after),'owned_production_changes':sorted(owned),'concurrent_source_changes_preserved':concurrent,'all_changed_existing_paths':after,'original_current_docs_preserved':True,'native_title_story':'45/45 clean','native_ui_fit':'48/48 clean','official_runner':'3 PASS; exit0; known noise retained','local_links_checked':links,'evidence':str(E),'handoff':str(handoff)}
(W/'publication.json').write_text(json.dumps(receipt,indent=2));shutil.copy2(W/'publication.json',E/'publication.json');print(json.dumps(receipt,indent=2))
