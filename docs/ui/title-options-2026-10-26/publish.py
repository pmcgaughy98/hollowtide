from pathlib import Path
import difflib,hashlib,json,re,shutil
from PIL import Image,ImageDraw
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');E=L/'docs/ui/title-options-2026-10-26'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'protected-before.json').read_text());installed=json.loads((W/'installed-files.json').read_text());owned=set(installed)
for p,h in installed.items():assert sha(L/p)==h,p
assert not E.exists()
docs={'docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-22.md'}
changed=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h]
concurrent=[p for p in changed if p not in owned|docs]
for p in concurrent:
    if (L/p).is_file():
        d=W/'concurrent-at-finish'/p;d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/p,d)
for p in docs:
    d=W/'docs-before-publication'/p;d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/p,d)
diff=''
for rel in sorted(owned):
    old=(W/'originals'/rel).read_text(encoding='utf-8') if (W/'originals'/rel).exists() else ''
    diff+=''.join(difflib.unified_diff(old.splitlines(True),(L/rel).read_text(encoding='utf-8').splitlines(True),fromfile='original/'+rel if old else '/dev/null',tofile='installed/'+rel))
(W/'source.diff').write_text(diff,encoding='utf-8')
sheet=Image.new('RGB',(1152,704),'#242b25');d=ImageDraw.Draw(sheet)
for row,key in enumerate(('options','controls-keyboard')):
    for col,phase in enumerate(('before','after')):
        im=Image.open(W/('native-'+phase)/(key+'.png')).convert('RGB')
        sheet.paste(im.resize((576,324),Image.Resampling.NEAREST),(col*576,row*352+24));d.text((col*576+8,row*352+5),phase+': '+key,fill='white')
sheet.save(W/'before-after.png')
keys=['options','rebind','controls-keyboard','controls-keyboard-bottom','controls-pad','controls-pad-bottom']
contact=Image.new('RGB',(1152,480),'#242b25');d=ImageDraw.Draw(contact)
for i,key in enumerate(keys):
    x=(i%3)*384;y=(i//3)*240
    im=Image.open(W/'native-after'/(key+'.png')).convert('RGB');contact.paste(im.resize((384,216),Image.Resampling.NEAREST),(x,y+24));d.text((x+6,y+5),key,fill='white')
contact.save(W/'native-contact.png')
cmd={'command':['C:/Users/pmcga/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe','tools/debug/run_checks.py','ui_fit','rebind','opening_flow','--jobs','1','--logs',str(W/'runner'),'--md',str(W/'runner-result.md')],'cwd':str(L),'APPDATA':str(W/'runner-profile'),'LOCALAPPDATA':str(W/'runner-local-profile'),'exit':0,'result':'3 PASS; raw known exit noise retained'}
(W/'runner-command.json').write_text(json.dumps(cmd,indent=2))
E.mkdir(parents=True)
for folder in ('originals','prepared','native-before','native-after','native-restart','ui-fit','runner','concurrent-at-install','concurrent-at-finish','docs-before-publication'):
    if (W/folder).exists():shutil.copytree(W/folder,E/folder,ignore=shutil.ignore_patterns('__pycache__','*.pyc'))
for p in W.iterdir():
    if p.is_file() and p.name!='HANDOFF.md' and p.suffix in ('.py','.gd','.md','.log','.json','.diff','.png'):
        target=E/(p.name+'.txt' if p.name=='installed-before-type-repair.gd' else p.name)
        shutil.copy2(p,target)
handoff=L/'docs/team/CODEX_HANDOFF_2026-10-26_title_options.md';assert not handoff.exists();shutil.copy2(W/'HANDOFF.md',handoff)
result='''
## Codex result, October 26: C4 title Options and live Controls

COMPLETE/INSTALLED: full title Options with Master/Music/Sound effects, Screen, Text speed, Reduce motion and Rebind keys. New small title_settings.gd host subclasses existing pause Options/Rebind pages and reuses exact slider track/fill/knob and input rules, without pausing the title or offering game pages. Title audio/motion route through unchanged C1 safe writer; game prefs/bindings use existing APIs. Back returns focus to Options; Esc cancels listening before leaving Rebind. Help Controls uses ControlsText.groups/note, updates on real controller input and binding saves, highlights active tab and scrolls while actions stay visible. Native30/30 plus fresh-process19/19, clean; native ui_fit48/48 clean; official opening_flow21, rebind26 and ui_fit48 all PASS, exit0 (known raw exit noise retained). Options ends582, Rebind617, Help602. C1 save/load, New Game/Continue, wordmark/scenery, soul and Journey words exact. Claude's shared UI/menu/rebind/input/ControlsText sources untouched. Private test preferences/saves only; no art/generation/paid call/rules/new wording/commit. [Before/after, evidence and originals](../ui/title-options-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_title_options.md).

Source issues for Claude: original task4 shared game/pause preference backup-rename gap remains OPEN; title-owned keys keep C1 safe replacement, while screen/text-speed/binding paths retain existing APIs. Tested8/8 candidate-only diff remains settings-save-2026-10-26/proposal/shared-pause-save.diff for the active UI lane, not installed. Standalone creature check-only lacks existing DialogueManager/PlayerParty autoload names; project-native and official opening checks pass, no autoload change. Fresh baseline fixture initially failed to compile; before pictures instead come from C3 captures whose installed-source hashes exactly match both fresh menu originals. New tab boolean annotation error fixed; failed attempts retained and invalid intermediate source stored as text. No cross-chat message sent. Next ordered independent slice C6 New Game prompt/Continue summary, with prompt gate OFF until Preston chooses wording. Remaining C7/C8/C9/opening/export/art work and proposed flags unchanged.
'''
queue=L/'docs/team/CODEX_TASKS_2026-10-22.md';raw=queue.read_bytes();assert raw==(W/'docs-before-publication/docs/team/CODEX_TASKS_2026-10-22.md').read_bytes()
nl=b'\r\n' if b'\r\n' in raw else b'\n';queue.write_bytes(raw+result.encode().replace(b'\n',nl))
collab=L/'docs/AI_COLLABORATION.md';raw=collab.read_bytes();assert raw==(W/'docs-before-publication/docs/AI_COLLABORATION.md').read_bytes()
head,sep,rest=raw.partition(b'\n');nl=b'\r\n' if b'\r\n' in raw else b'\n'
entry='''
## Codex: C4 title Options and live Controls (October 26, 2026)

COMPLETE/INSTALLED: title hosts existing pause Options/Rebind via small title_settings subclass, with all three audio rows, Screen, Text speed, Reduce motion and Rebind. Exact shared filled sliders/input rules, no tree pause; title-owned values retain C1 safe writer. ControlsText groups/note drive Help, live binding/device refresh, active tab frame and scrolling keep all text/actions reachable. Native30/30 +restart19/19 clean; native ui_fit48/48 clean; official opening_flow/rebind/ui_fit3 PASS (known raw exit noise retained). Options582/Rebind617/Help602. Two owned menu scripts +new host only; shared Claude UI/menu/rebind/input/ControlsText untouched, C1 methods/wordmark/story/New Game/Continue preserved. [Evidence](ui/title-options-2026-10-26/README.md); [handoff](team/CODEX_HANDOFF_2026-10-26_title_options.md). Prior shared prefs backup-rename gap remains OPEN with staged8/8 candidate, not installed; game keys still use those APIs. No real prefs/save, art/generation, paid call, rules, message or commit. Next C6 prompt/Continue details, keeping prompt gate off until Preston chooses words; remaining factory work pending.

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
receipt={'protected_before':len(base),'protected_unchanged_after_docs':len(base)-len(after),'owned_production_changes':sorted(owned),'new_title_host':'scripts/ui/title_settings.gd','concurrent_source_changes_preserved':concurrent,'all_changed_existing_paths':after,'original_current_docs_preserved':True,'native_running_title':'30/30 clean','native_fresh_launch':'19/19 clean','native_ui_fit':'48/48 clean','official_runner':'3 PASS; exit0; known raw noise retained','shared_save_gap':'still open; staged fix not installed','before_images':'source-hash verified previous C3 captures','local_links_checked':links,'evidence':str(E),'handoff':str(handoff)}
(W/'publication.json').write_text(json.dumps(receipt,indent=2));shutil.copy2(W/'publication.json',E/'publication.json');print(json.dumps(receipt,indent=2))
