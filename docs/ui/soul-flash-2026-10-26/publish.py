from pathlib import Path
import difflib,hashlib,json,re,shutil
from PIL import Image,ImageDraw
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');E=L/'docs/ui/soul-flash-2026-10-26'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'protected-before.json').read_text());installed=json.loads((W/'installed-files.json').read_text());owned=set(installed)
for p,h in installed.items():assert sha(L/p)==h,p
assert not E.exists()
for phase,count in [('before',6),('after',87)]:
    r=json.loads((W/(phase+'-result.json')).read_text());assert r['passed']==count and r['failed']==0
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
contact=Image.new('RGB',(1152,352),'#242b25');d=ImageDraw.Draw(contact)
for i,phase in enumerate(('before','after')):
    im=Image.open(W/phase/'forwarded-1-peak.png').convert('RGB');assert im.size==(1152,648)
    contact.paste(im.resize((576,324),Image.Resampling.NEAREST),(i*576,24));d.text((i*576+8,6),phase+' / Reduce motion / rendered peak',fill='white')
contact.save(W/'before-after.png')
E.mkdir(parents=True)
for folder in ('originals','prepared','before','after','runner','attempts','concurrent-at-finish','docs-before-publication'):
    if (W/folder).exists():shutil.copytree(W/folder,E/folder,ignore=shutil.ignore_patterns('__pycache__','*.pyc'))
for p in W.iterdir():
    if p.is_file() and p.name!='HANDOFF.md' and p.suffix in ('.py','.gd','.md','.log','.json','.diff','.png'):
        shutil.copy2(p,E/p.name)
handoff=L/'docs/team/CODEX_HANDOFF_2026-10-26_soul_flash.md';assert not handoff.exists();shutil.copy2(W/'HANDOFF.md',handoff)
result='''
## Codex result, October 26: A2 / ACC-14 reduced-motion soul flash

COMPLETE/INSTALLED in soul_prologue.gd only. The arrival flash starts0.4 under Reduce motion, normal stays1.6. Saved shared preference and forwarded setting both work and reach the next scene. Existing decay,0.9s flight,0.7s handoff wait, creature/partner/chosen flag, words, art, card layout and input source otherwise exact. Native87/87 clean across all three creatures with normal, forwarded-only and saved-only settings; real final-line advance gate, target/scale, monotonic fade, handoff timing/identity/setting and exact private save bytes checked. Reduced native corner about99/99/109 versus white255/255/255; flash clears by sample40, handoff48, normal retains its old full-white void. Official soul_prologue/opening_flow2 PASS, exit0, known raw exit warnings retained. Shared preference helper bodies match tested baseline; Claude/Grok changes preserved. [Native preview, originals, commands, frame samples and diff](../ui/soul-flash-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_soul_flash.md).

Source issues for Claude: no new ACC-14 issue. A3's input/skip, broader white-out transition, card and shaft requests remain pending; no blanket opening-flash fix claim. C6 remains OFF pending Preston's wording. Initial image diagnostic caught the state a frame before rendering; corrected to rendered brightness among adjacent frames, attempt retained. One intermediate baseline had2-instance/1-resource shutdown noise; verbose baseline and final installed run clean, no teardown source repair claimed. Private profiles/saves only, no art/generation/paid call/rules/Route1/message/commit. Shared preference recovery left intact. Town/exterior/sign/lettering art stays on HOLD until slots exist. Next ordered slice A3, beginning with shared advance/input and skip safety, one checked slice at a time.
'''
queue=L/'docs/team/CODEX_TASKS_2026-10-26.md';raw=queue.read_bytes();assert raw==(W/'docs-before-publication/docs/team/CODEX_TASKS_2026-10-26.md').read_bytes()
nl=b'\r\n' if b'\r\n' in raw else b'\n';queue.write_bytes(raw+result.encode().replace(b'\n',nl))
collab=L/'docs/AI_COLLABORATION.md';raw=collab.read_bytes();assert raw==(W/'docs-before-publication/docs/AI_COLLABORATION.md').read_bytes()
head,sep,rest=raw.partition(b'\n');nl=b'\r\n' if b'\r\n' in raw else b'\n'
entry='''
## Codex: ACC-14 reduced-motion soul flash, new queue A2 (October 26, 2026)

COMPLETE/INSTALLED in soul_prologue.gd only: effective saved/forwarded Reduce motion, starting flash0.4 versus normal1.6. Existing decay/flight/wait, hero/partner handoff, words/art/cards/inputs otherwise exact. Native87/87 clean across all three heroes in normal/forwarded/saved modes; real advance gate, target/scale, fade, timing/identity/setting and saved bytes checked. Official soul_prologue/opening_flow2 PASS, known raw exit warnings retained. [Preview/evidence](ui/soul-flash-2026-10-26/README.md); [handoff](team/CODEX_HANDOFF_2026-10-26_soul_flash.md). Shared preference helpers match baseline; Claude/Grok work preserved. Source issues: no new ACC-14 issue, A3 broader white-outs/inputs/cards/light still pending; C6 OFF awaiting words, town/exterior art HOLD. One intermediate baseline shutdown diagnostic documented; final native logs clean, no teardown source repair claimed. No real save/art/generation/paid call/rules/Route1/message/commit. Next A3 opening advance/input and skip safety, one finished slice at a time.

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
receipt={'protected_baseline_files':len(base),'owned_production_changes':sorted(owned),'concurrent_source_changes_preserved':concurrent,'concurrent_during_publication':late,'all_changed_existing_paths':after,'prior_docs_preserved':True,'native':'87/87 clean; nine cases','official':'2 PASS; exit0; known raw exit warnings retained','preference_helpers':'match original tested bodies','prompt_default':'C6 OFF, unchanged by this slice','local_links_checked':links,'evidence':str(E),'handoff':str(handoff)}
(W/'publication.json').write_text(json.dumps(receipt,indent=2));shutil.copy2(W/'publication.json',E/'publication.json');print(json.dumps(receipt,indent=2))
