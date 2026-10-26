from pathlib import Path
import difflib,hashlib,json,re,shutil
from PIL import Image,ImageDraw
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');E=L/'docs/ui/title-new-game-2026-10-26'
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
    old=(W/'originals'/rel).read_text(encoding='utf-8');now=(L/rel).read_text(encoding='utf-8')
    diff+=''.join(difflib.unified_diff(old.splitlines(True),now.splitlines(True),fromfile='original/'+rel,tofile='installed/'+rel))
(W/'source.diff').write_text(diff,encoding='utf-8')
keys=['continue-Highbank','continue-first','continue-mouth','continue-hollow','continue-backup','prompt-from-main']
contact=Image.new('RGB',(1152,1056),'#242b25');d=ImageDraw.Draw(contact)
for i,key in enumerate(keys):
    x=(i%2)*576;y=(i//2)*352
    im=Image.open(W/'native'/(key+'.png')).convert('RGB');assert im.size==(1152,648)
    contact.paste(im.resize((576,324),Image.Resampling.NEAREST),(x,y+24));d.text((x+8,y+6),key+(' (private flag ON)' if key.startswith('prompt') else ''),fill='white')
contact.save(W/'native-contact.png')
cmd={'command':['C:/Users/pmcga/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe','tools/debug/run_checks.py','ui_fit','save_check','opening_flow','--jobs','1','--logs',str(W/'runner'),'--md',str(W/'runner-result.md')],'cwd':str(L),'APPDATA':str(W/'runner-profile'),'LOCALAPPDATA':str(W/'runner-local-profile'),'exit':0,'result':'3 PASS; known raw exit warnings retained','note':'Command reconstructed from this session; native command receipts are captured by run.py.'}
(W/'runner-command.json').write_text(json.dumps(cmd,indent=2))
E.mkdir(parents=True)
for folder in ('originals','prepared','native','ui-fit','runner','concurrent-at-finish','docs-before-publication'):
    if (W/folder).exists():shutil.copytree(W/folder,E/folder,ignore=shutil.ignore_patterns('__pycache__','*.pyc'))
for p in W.iterdir():
    if p.is_file() and p.name!='HANDOFF.md' and p.suffix in ('.py','.gd','.md','.log','.json','.diff','.png'):
        shutil.copy2(p,E/p.name)
handoff=L/'docs/team/CODEX_HANDOFF_2026-10-26_title_new_game.md';assert not handoff.exists();shutil.copy2(W/'HANDOFF.md',handoff)
result='''
## Codex result, October 26: C6 Continue details and proposed New Game confirmation

CONTINUE DETAILS INSTALLED; PROMPT IMPLEMENTED/TESTED BUT OFF pending Preston's wording choice, as requested. Continue now names its actual resume destination (Highbank, or suspended Rootbank Warren / Hollow Mouth / The Hollow and floor) and saved leader level. Read-only validated save/backup preview preserves running team data and disk bytes; campaign menu/recovery note fits above the key hint. Both title New Game and Help's Start New Game share one framed No/Yes prompt when privately enabled. No is focused first; No, Esc and controller B restore the originating page/button, Yes enters the existing storm once. Normal flag remains false with no scene override. Proposed body: 'Saving the new journey will replace your current save.' This avoids the older inaccurate Highbank checkpoint claim: dungeon suspension can autosave before town. No save timing/rules changed. Final native47/47 and native ui_fit48/48 clean; official opening_flow/save_check/ui_fit3 PASS, exit0 (known raw exit warnings retained). Final native run covers the corrected proposal body; UI-fit/official checks precede only that body/comment change. Actual Yes-to-storm smoke preserves the old save. [Preview, originals, diff and evidence](../ui/title-new-game-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_title_new_game.md).

Production changes only in main_menu.gd and creature_opening.gd. C1 safe settings methods, Continue dispatch, existing entry and scenery methods exact; TeamState source unchanged. Claude's concurrent timing_check edit preserved/archived. Private profiles/saves only; no art/generation/paid calls/creature rules/Route1/message/commit. Shared pause preference backup-rename gap from task4/C1 remains OPEN with its earlier tested8/8 candidate still staged only. Retired opening placement not redesigned. Next ordered independent slice: section9 item5 Storm advance/skip hint and pixel soul light, then item6 white-out transitions. C6 stays off until Preston picks words; remaining C7/C8/C9/opening/export/art work pending.
'''
queue=L/'docs/team/CODEX_TASKS_2026-10-22.md';raw=queue.read_bytes();assert raw==(W/'docs-before-publication/docs/team/CODEX_TASKS_2026-10-22.md').read_bytes()
nl=b'\r\n' if b'\r\n' in raw else b'\n';queue.write_bytes(raw+result.encode().replace(b'\n',nl))
collab=L/'docs/AI_COLLABORATION.md';raw=collab.read_bytes();assert raw==(W/'docs-before-publication/docs/AI_COLLABORATION.md').read_bytes()
head,sep,rest=raw.partition(b'\n');nl=b'\r\n' if b'\r\n' in raw else b'\n'
entry='''
## Codex: C6 Continue details and default-off New Game prompt (October 26, 2026)

Continue place/floor and saved leader level INSTALLED. New Game confirmation IMPLEMENTED/TESTED, flag still OFF pending Preston's wording choice per section9. Title and Help share framed No/Yes, initial No focus, keyboard/controller cancellation back to origin, one-use Yes into existing storm. Preview reads validated disk/backup without mutating running TeamState or save files. Proposed body: 'Saving the new journey will replace your current save.' The older Highbank timing claim was inaccurate because dungeon suspension can save before town; no save rules changed. Final native47/47 plus native ui_fit48/48 clean; official opening_flow/save_check/ui_fit3 PASS, known raw exit warnings retained. Actual Yes-to-storm save bytes exact. Only two owned menu scripts edited, Claude's concurrent timing check preserved; safe settings/Continue/entry/scenery methods exact, TeamState unchanged. [Preview/evidence](ui/title-new-game-2026-10-26/README.md); [handoff](team/CODEX_HANDOFF_2026-10-26_title_new_game.md). Private saves only; no art/rules/paid call/message/commit. C1 shared preference recovery gap still OPEN with candidate staged only. Next ordered slice Storm advance/skip hint and pixel soul light, then white-outs. Proposed prompt stays off.

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
receipt={'protected_baseline_files':len(base),'protected_unchanged_after_docs':len(base)-len(after),'owned_production_changes':sorted(owned),'concurrent_source_changes_preserved':concurrent,'all_changed_existing_paths':after,'prior_docs_preserved':True,'native':'47/47 clean','native_ui_fit':'48/48 clean','official':'3 PASS; exit0; known raw warnings retained','prompt_default':'OFF pending wording choice','shared_preference_gap':'OPEN; prior candidate not installed','local_links_checked':links,'evidence':str(E),'handoff':str(handoff)}
(W/'publication.json').write_text(json.dumps(receipt,indent=2));shutil.copy2(W/'publication.json',E/'publication.json');print(json.dumps(receipt,indent=2))
