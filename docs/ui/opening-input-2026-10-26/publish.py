from pathlib import Path
import difflib,hashlib,json,re,shutil
from PIL import Image,ImageDraw
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');E=L/'docs/ui/opening-input-2026-10-26'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'protected-before.json').read_text());installed=json.loads((W/'installed-files.json').read_text());owned=set(installed)
for p,h in installed.items():assert sha(L/p)==h,p
assert not E.exists()
assert json.loads((W/'native-result.json').read_text())['passed']==85
assert len(json.loads((W/'flow-results/checks.json').read_text())['checks'])==28
docs={'docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-26.md'}
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
keys=['storm-idle-hint','storm-pad-A','storm-rebound-K','soul-rebound-choice']
contact=Image.new('RGB',(1152,704),'#242b25');d=ImageDraw.Draw(contact)
for i,key in enumerate(keys):
    x=(i%2)*576;y=(i//2)*352
    im=Image.open(W/'native'/(key+'.png')).convert('RGB');assert im.size==(1152,648)
    contact.paste(im.resize((576,324),Image.Resampling.NEAREST),(x,y+24));d.text((x+8,y+6),key,fill='white')
contact.save(W/'native-contact.png')
E.mkdir(parents=True)
for folder in ('originals','prepared','native','flow-results','runner','attempts','proposal','concurrent-at-finish','docs-before-publication'):
    if (W/folder).exists():shutil.copytree(W/folder,E/folder,ignore=shutil.ignore_patterns('__pycache__','*.pyc'))
for p in W.iterdir():
    if p.is_file() and p.name!='HANDOFF.md' and p.suffix in ('.py','.gd','.md','.log','.json','.diff','.png'):
        shutil.copy2(p,E/p.name)
handoff=L/'docs/team/CODEX_HANDOFF_2026-10-26_opening_input.md';assert not handoff.exists();shutil.copy2(W/'HANDOFF.md',handoff)
result='''
## Codex result, October 26: A3 input slice / C7 and safe Storm skip

COMPLETE/INSTALLED: Storm/soul read UI.INPUT_ADVANCE and UI.pressed, soul choices use shared left/right including sticks and saved rebinds, one event advances once. Storm requires another press after release; echoes/held input/duplicate down do not skip. A binding-aware Skip / Press again to skip hint appears after4s or on arming, keyboard/pad/rebound names live. Title prelude/back and focused buttons accept shared inputs; obsolete _ensure_menu_inputs definition/call removed, project pad accept/back map preserved. C7 is landed; runtime UI.HEAD users absent and Claude's shared constant already removed. Native input85/85 plus real title-to-riverbank28/28 clean, including explicit first-Enter gate then second-Enter scene switch. Official opening_flow/soul_prologue/input_map/rebind4 PASS, exit0; known raw exit noise retained. First real-flow test caught viewport access after scene detach; input is now consumed before changing scenes, and all final checks reran successfully. Story, prior flash fixes, logo reveal, settings save/Continue and creature/partner handoffs preserved. [Preview, originals, commands, checks and diff](../ui/opening-input-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_opening_input.md).

Source issues for Claude: UI.pressed returns before neutral motion bookkeeping; the three owned opening entry points feed motion into existing UI._motion_edge before reading actions, so centre/repress works. Please fold that into the shared public helper when ready; shared UI source untouched. Public opening_flow_check still presses Enter once then waits for natural completion. Minimal proposal/opening-flow-two-press.diff is staged in the evidence; equivalent private driver tested28/28, live active check untouched for Claude to rebase/install. No cross-chat message sent; these notes notify C7 completion. Proposed installed instruction words: Skip; Press again to skip. C6 remains OFF until Preston picks words. Private profiles/saves only, concurrent Claude/Grok work preserved; no art/generation/paid call/rules/Route1/commit. A3 not fully closed: next white-out transitions, then C8 art/sounds/hint contrast, C9 top bar/shafts and Storm pixel light; town/exterior art HOLD unchanged.
'''
queue=L/'docs/team/CODEX_TASKS_2026-10-26.md';raw=queue.read_bytes();assert raw==(W/'docs-before-publication/docs/team/CODEX_TASKS_2026-10-26.md').read_bytes()
nl=b'\r\n' if b'\r\n' in raw else b'\n';queue.write_bytes(raw+result.encode().replace(b'\n',nl))
collab=L/'docs/AI_COLLABORATION.md';raw=collab.read_bytes();assert raw==(W/'docs-before-publication/docs/AI_COLLABORATION.md').read_bytes()
head,sep,rest=raw.partition(b'\n');nl=b'\r\n' if b'\r\n' in raw else b'\n'
entry='''
## Codex: C7 opening inputs and two-press Storm skip (October 26, 2026)

C7/A3 INPUT SLICE COMPLETE: shared advance/movement actions, saved rebinds, stick centre/repress, one event once. Storm first press arms, release then another skips; binding-aware hint after4s or on arming. Title shared inputs, no _ensure_menu_inputs/map patch. Native85/85 plus real flow28/28 clean; official opening_flow/soul_prologue/input_map/rebind4 PASS, known raw exit warnings retained. C7 landed; no runtime UI.HEAD users, shared constant already removed by Claude. Story/flash/settings/Continue/logo preserved; four owned opening scripts only. [Preview/evidence](ui/opening-input-2026-10-26/README.md); [handoff](team/CODEX_HANDOFF_2026-10-26_opening_input.md). Source follow-ups: owned handlers feed neutral motion to existing UI._motion_edge because UI.pressed ignores centre events; fold into public helper later. Public opening_flow_check needs second-press assertion: minimal candidate staged, equivalent private driver passes28/28. Live active check/shared UI left intact. Scene-detach input error caught/fixed before final reruns. Proposed hint words Skip / Press again to skip; C6 OFF, private saves only, Claude/Grok changes preserved. No art/paid call/rules/Route1/message/commit. Next A3 white-outs; C8/C9/light/art remainder still pending, town/exterior HOLD.

'''
collab.write_bytes(head+sep+entry.encode().replace(b'\n',nl)+rest)
assert queue.read_bytes().startswith((W/'docs-before-publication/docs/team/CODEX_TASKS_2026-10-26.md').read_bytes())
assert collab.read_bytes().endswith((W/'docs-before-publication/docs/AI_COLLABORATION.md').read_bytes().partition(b'\n')[2])
for p,h in installed.items():assert sha(L/p)==h,p
after=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h]
late=[p for p in after if p not in owned|docs|set(concurrent)]
for p in late:
    if (L/p).is_file():
        d=E/'concurrent-during-publication'/p;d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/p,d)
(E/'publication.json').write_text('{}');links=0
for p in (E/'README.md',handoff):
    for target in re.findall(r'\]\(([^)]+)\)',p.read_text(encoding='utf-8')):
        assert (p.parent/target).exists(),(p,target)
        links+=1
receipt={'protected_baseline_files':len(base),'owned_production_changes':sorted(owned),'concurrent_source_changes_preserved':concurrent,'concurrent_during_publication':late,'all_changed_existing_paths':after,'prior_docs_preserved':True,'native_input':'85/85 clean','native_real_flow':'28/28 clean','official':'4 PASS, exit0, known raw exit noise retained','C7':'complete; HEAD already removed by Claude','public_check_followup':'candidate only; private equivalent tested','A3_remainder':'white-outs, cards, light shafts/pixel soul pending','prompt_default':'C6 OFF, unchanged','local_links_checked':links,'evidence':str(E),'handoff':str(handoff)}
(W/'publication.json').write_text(json.dumps(receipt,indent=2));shutil.copy2(W/'publication.json',E/'publication.json');print(json.dumps(receipt,indent=2))
