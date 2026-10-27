from pathlib import Path
import difflib,hashlib,json,re,shutil
from PIL import Image,ImageDraw
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');E=L/'docs/ui/soul-light-2026-10-26'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'protected-before.json').read_text());installed=json.loads((W/'installed-files.json').read_text());owned=set(installed)
for p,h in installed.items():assert sha(L/p)==h,p
assert not E.exists()
assert json.loads((W/'after-result.json').read_text())['passed']==20
sheet=Image.new('RGB',(1152,352),'#242b25');d=ImageDraw.Draw(sheet)
for i,phase in enumerate(('before','after')):
    im=Image.open(W/phase/'speaking.png').convert('RGB');assert im.size==(1152,648)
    sheet.paste(im.resize((576,324),Image.Resampling.NEAREST),(i*576,24));d.text((i*576+8,6),phase+' / held speaking pose',fill='white')
sheet.save(W/'before-after.png')
sheet=Image.new('RGB',(1152,704),'#242b25');d=ImageDraw.Draw(sheet)
for row,key in enumerate(('wide','tall')):
    for col,phase in enumerate(('before','after')):
        im=Image.open(W/phase/(key+'.png')).convert('RGB');scale=min(576/im.width,324/im.height);size=(round(im.width*scale),round(im.height*scale))
        im=im.resize(size,Image.Resampling.NEAREST);x=col*576+(576-size[0])//2;y=row*352+24+(324-size[1])//2
        sheet.paste(im,(x,y));d.text((col*576+8,row*352+6),phase+' / '+key,fill='white')
sheet.save(W/'resize-contact.png')
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
(W/'source.diff').write_text(diff,encoding='utf-8');E.mkdir(parents=True)
for folder in ('originals','prepared','before','after','runner','earlier-native','concurrent-at-finish','docs-before-publication'):
    if (W/folder).exists():shutil.copytree(W/folder,E/folder,ignore=shutil.ignore_patterns('__pycache__','*.pyc'))
for p in W.iterdir():
    if p.is_file() and p.name!='HANDOFF.md' and p.suffix in ('.py','.gd','.md','.log','.json','.diff','.png'):
        shutil.copy2(p,E/p.name)
handoff=L/'docs/team/CODEX_HANDOFF_2026-10-26_soul_light.md';assert not handoff.exists();shutil.copy2(W/'HANDOFF.md',handoff)
result='''
## Codex result, October 26: C9 / A3 top band and light shafts

COMPLETE/INSTALLED in soul_prologue.gd only. Removed the3px native speaking strip, which became the roughly9px grey top band at3x. Baseline384x216 already filled the authored16:9 viewport; no source-art recut needed. Shafts now use per-vertex alpha, zero at their lower vertices, so no hard end at native y150/view y450. Backdrop/flash cover expanded windows, UI/world stay centered on whole art pixels, and the caller's stretch policy restores on exit without overwriting a destination's new choice. Native20/20 clean:1152x648,1536x648,960x720, pixel probes, corners, flash extent, wide mouse selection, private save hashes and lifecycle. Added top-strip brightness0.302 to0; shaft-end0.0405 to0, midpoint still0.0131. Baseline3/3 clean; official soul_prologue/opening_flow2 PASS, exit0, known raw exit warnings retained. Story constants, input/advance, card art/geometry/scales, animation, flash timing and recent black-fade methods preserved. [Before/after, native sizes, originals, commands and diff](../ui/soul-light-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_soul_light.md).

Source issues for Claude: no new C9 issue; the grey band was the scaled speaking strip. Expansion is scene-local and respects a destination's stretch policy. Shared UI and active Claude/Grok sources untouched/preserved; concurrent paths listed in receipt. Earlier native passes archived, final20 includes queued-exit guard. C7 neutral-motion/public-check follow-ups remain in its handoff. A3 still pending C8 starter choice safety, card art/sounds/hint contrast and Storm pixel soul. C6 remains OFF pending words, town/exterior art HOLD until slot queue readiness. Private profiles/saves only; no assets/generation/paid call/rules/Route1/message/commit. Next C8 choice protection and presentation, one checked slice.
'''
queue=L/'docs/team/CODEX_TASKS_2026-10-26.md';raw=queue.read_bytes();assert raw==(W/'docs-before-publication/docs/team/CODEX_TASKS_2026-10-26.md').read_bytes()
nl=b'\r\n' if b'\r\n' in raw else b'\n';queue.write_bytes(raw+result.encode().replace(b'\n',nl))
collab=L/'docs/AI_COLLABORATION.md';raw=collab.read_bytes();assert raw==(W/'docs-before-publication/docs/AI_COLLABORATION.md').read_bytes()
head,sep,rest=raw.partition(b'\n');nl=b'\r\n' if b'\r\n' in raw else b'\n'
entry='''
## Codex: C9 soul band, viewport and soft shaft ends (October 26, 2026)

C9 COMPLETE in soul_prologue.gd only. Speaking strip removed (the grey9px band at3x), lower shaft alpha fades to0, expanded backdrop/flash fill wide/tall windows with centered whole-pixel UI/world. Guarded stretch restoration respects the caller/destination. Native20/20 clean plus official soul_prologue/opening_flow2 PASS, known raw exit warnings retained. Top added brightness0.302 to0; shaft end0.0405 to0. [Before/after/evidence](ui/soul-light-2026-10-26/README.md); [handoff](team/CODEX_HANDOFF_2026-10-26_soul_light.md). Story/input/cards/animation/flash and recent fade methods exact; Claude/Grok work preserved. No new source issue; native16:9 already filled, band was the speaking strip. C7 follow-ups still in prior handoff. Next C8 choice safety/presentation; Storm pixel soul pending. C6 OFF, town/exterior HOLD until slot queue readiness. No real save/assets/generation/paid call/rules/Route1/message/commit.

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
receipt={'protected_baseline_files':len(base),'owned_production_changes':sorted(owned),'concurrent_source_changes_preserved':concurrent,'concurrent_during_publication':late,'all_changed_existing_paths':after,'prior_docs_preserved':True,'native':'20/20 clean','baseline':'3/3 clean','official':'2 PASS, known raw exit warnings retained','preserved':'story/input/cards/flash/black-fade methods','remaining':'C8 choice safety/presentation; Storm pixel soul','local_links_checked':links,'evidence':str(E),'handoff':str(handoff)}
(W/'publication.json').write_text(json.dumps(receipt,indent=2));shutil.copy2(W/'publication.json',E/'publication.json');print(json.dumps(receipt,indent=2))
