from pathlib import Path
import difflib,hashlib,json,re,shutil
from PIL import Image,ImageDraw
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');E=L/'docs/ui/opening-fades-2026-10-26'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'protected-before.json').read_text());installed=json.loads((W/'installed-files.json').read_text());owned=set(installed)
for p,h in installed.items():assert sha(L/p)==h,p
assert not E.exists()
after_result=json.loads((W/'after-result.json').read_text());assert after_result['passed']==34 and after_result['failed']==0
case=next(c for c in after_result['cases'] if c['case']=='normal-natural')
for boundary,offsets in [('storm',[-10,-6,-2,0,4,18]),('bank',[-10,-6,-2,0,4,26])]:
    cut=case[boundary+'_cut']['frame'];sheet=Image.new('RGB',(1152,480),'#242b25');d=ImageDraw.Draw(sheet)
    for i,offset in enumerate(offsets):
        frame=cut+offset;p=W/'after/normal-natural'/('f%04d.png'%frame);assert p.exists(),p
        im=Image.open(p).convert('RGB');x=(i%3)*384;y=(i//3)*240
        sheet.paste(im.resize((384,216),Image.Resampling.NEAREST),(x,y+24));d.text((x+8,y+6),boundary+' cut '+('%+d'%offset)+' frames',fill='white')
    sheet.save(W/(boundary+'-sequence.png'))
docs={'docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-26.md'}
changed=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h];concurrent=[p for p in changed if p not in owned|docs]
for p in concurrent:
    if (L/p).is_file():
        dest=W/'concurrent-at-finish'/p;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/p,dest)
for p in docs:
    dest=W/'docs-before-publication'/p;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/p,dest)
diff=''
for rel in sorted(owned):
    old=(W/'originals'/rel).read_text(encoding='utf-8');now=(L/rel).read_text(encoding='utf-8')
    diff+=''.join(difflib.unified_diff(old.splitlines(True),now.splitlines(True),fromfile='original/'+rel,tofile='installed/'+rel))
(W/'source.diff').write_text(diff,encoding='utf-8')
E.mkdir(parents=True)
for folder in ('originals','prepared','before','after','runner','attempts','concurrent-at-finish','docs-before-publication'):
    if (W/folder).exists():shutil.copytree(W/folder,E/folder,ignore=shutil.ignore_patterns('__pycache__','*.pyc'))
for p in W.iterdir():
    if p.is_file() and p.name!='HANDOFF.md' and p.suffix in ('.py','.gd','.md','.log','.json','.diff','.png','.csv'):
        shutil.copy2(p,E/p.name)
handoff=L/'docs/team/CODEX_HANDOFF_2026-10-26_opening_fades.md';assert not handoff.exists();shutil.copy2(W/'HANDOFF.md',handoff)
result='''
## Codex result, October 26: A3 white-out transitions

WHITE-OUT SLICE COMPLETE/INSTALLED in storm_open.gd and soul_prologue.gd. Natural Storm holds its end light two frames, fades to shared black, then swaps under that cover; skipped Storm also fades under black. Soul draws two frames, reveals with UI.fade_in and blocks advance until that reveal ends. Soul's outgoing flash gets a short hold and shared fade, then hands cover to the flood scene's existing opaque construction veil and existing reveal. Bank source untouched. Normal shared fades about10 frames at30fps; saved Reduce motion halves them, and final Storm bloom now capped0.4. Prior soul/lightning caps intact. Native baseline10/10 and installed34/34 clean, actual current_scene handoffs in natural/skip and normal/reduced modes. Largest normal falling sampled brightness steps improved0.8845 to0.1020 (Storm) and0.8323 to0.0864 (soul). First soul frame shared-black1; first bank frame veil1 and construction stays covered. Hero/pending story partner choice/settings, first dialogue and private save bytes checked. Official storm_open/soul_prologue/opening_flow3 PASS, exit0, known raw exit warnings retained. [Sequences, native frame CSV, originals, commands and diff](../ui/opening-fades-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_opening_fades.md).

Source issues for Claude: no new fade issue. Dedicated October26 queue and newer pass7/8 direction call for fades through black; this is deliberate continuous cover rather than the abrupt cuts in the older pass6 evidence. Existing non-current-scene metadata hooks keep check behavior and are not visual proof; actual-scene native tests cover the fade. Initial fixture's provisional-partner assumption corrected to the bank's existing pending-choice behavior, failed attempt retained, no gameplay fix for it. Shared fade helpers and bank source match baseline; story/input/lightning/flash-decay methods preserved. Pass8 section11 item4 C7, item5 A1/A2 and item9 logo already closed by prior results. A3 still pending C8 cards/choice protection/sounds/hint contrast, C9 top bar/grey band/shafts and Storm pixel light. Next C9 bar/band/shaft edges. C6 OFF pending words, town/exterior art HOLD unchanged. Private profiles/saves only, Claude/Grok work preserved; no art/generation/paid call/rules/Route1/message/commit.
'''
queue=L/'docs/team/CODEX_TASKS_2026-10-26.md';raw=queue.read_bytes();assert raw==(W/'docs-before-publication/docs/team/CODEX_TASKS_2026-10-26.md').read_bytes()
nl=b'\r\n' if b'\r\n' in raw else b'\n';queue.write_bytes(raw+result.encode().replace(b'\n',nl))
collab=L/'docs/AI_COLLABORATION.md';raw=collab.read_bytes();assert raw==(W/'docs-before-publication/docs/AI_COLLABORATION.md').read_bytes()
head,sep,rest=raw.partition(b'\n');nl=b'\r\n' if b'\r\n' in raw else b'\n'
entry='''
## Codex: A3 white-out handoffs through black (October 26, 2026)

WHITE-OUT SLICE COMPLETE in two owned scripts. Two-frame light hold, shared black fade across Storm/soul swaps, two-frame soul warm-up then reveal with input fenced; bank uses its existing covered construction/reveal unchanged. Normal shared fades about10 frames, halved with saved Reduce motion; Storm final bloom capped0.4. Native34/34 clean actual normal/reduced/natural/skip handoffs, baseline10/10; normal largest falling brightness steps0.8845 to0.1020 and0.8323 to0.0864. Official storm_open/soul_prologue/opening_flow3 PASS, known raw exit warnings retained. [Sequences/logs](ui/opening-fades-2026-10-26/README.md); [handoff](team/CODEX_HANDOFF_2026-10-26_opening_fades.md). Bank/shared helpers unchanged, hero/pending partner choice/settings/save bytes preserved. No new source issue; newer queue's through-black direction used, older no-black-frame wording superseded. Metadata check hooks retained, visual proof uses actual scene swaps. Claude/Grok work preserved; no real save/art/paid call/rules/Route1/message/commit. C7/A1/A2/logo-repeat items closed. Next C9 bar/band/shafts; C8 cards and Storm pixel light still pending. C6 OFF and town/exterior HOLD unchanged.

'''
collab.write_bytes(head+sep+entry.encode().replace(b'\n',nl)+rest)
assert queue.read_bytes().startswith((W/'docs-before-publication/docs/team/CODEX_TASKS_2026-10-26.md').read_bytes())
assert collab.read_bytes().endswith((W/'docs-before-publication/docs/AI_COLLABORATION.md').read_bytes().partition(b'\n')[2])
for p,h in installed.items():assert sha(L/p)==h,p
after=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h];late=[p for p in after if p not in owned|docs|set(concurrent)]
for p in late:
    if (L/p).is_file():
        dest=E/'concurrent-during-publication'/p;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/p,dest)
(E/'publication.json').write_text('{}');links=0
for p in (E/'README.md',handoff):
    for target in re.findall(r'\]\(([^)]+)\)',p.read_text(encoding='utf-8')):
        assert (p.parent/target).exists(),(p,target)
        links+=1
receipt={'protected_baseline_files':len(base),'owned_production_changes':sorted(owned),'concurrent_source_changes_preserved':concurrent,'concurrent_during_publication':late,'all_changed_existing_paths':after,'prior_docs_preserved':True,'native':'34/34 clean; actual scene handoffs','baseline_native':'10/10 clean','official':'3 PASS; known raw exit warnings retained','shared_fade_helpers_and_bank':'unchanged','normal_largest_drop_before_after':{'Storm':[0.8845,0.1020],'soul':[0.8323,0.0864]},'A3_remainder':'C8 cards, C9 bar/band/shafts, Storm pixel soul pending','local_links_checked':links,'evidence':str(E),'handoff':str(handoff)}
(W/'publication.json').write_text(json.dumps(receipt,indent=2));shutil.copy2(W/'publication.json',E/'publication.json');print(json.dumps(receipt,indent=2))
