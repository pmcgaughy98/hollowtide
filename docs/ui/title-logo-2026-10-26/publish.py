from pathlib import Path
import difflib,hashlib,json,re,shutil
from PIL import Image,ImageDraw
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');E=L/'docs/ui/title-logo-2026-10-26'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'protected-before.json').read_text());installed=json.loads((W/'installed-files.json').read_text());owned=set(installed)
for p,h in installed.items():assert sha(L/p)==h,p
assert not E.exists()
assert json.loads((W/'verification.json').read_text())['installed_native'].startswith('66/66')
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
def pair(frame):
    sheet=Image.new('RGB',(1152,352),'#242b25');d=ImageDraw.Draw(sheet)
    for col,phase in enumerate(('before','after')):
        im=Image.open(W/phase/('normal-auto-f%03d.png'%frame)).convert('RGB');assert im.size==(1152,648)
        sheet.paste(im.resize((576,324),Image.Resampling.NEAREST),(col*576,24));d.text((col*576+8,6),phase+' / frame '+str(frame),fill='white')
    return sheet
contact=Image.new('RGB',(1152,1056),'#242b25')
for row,frame in enumerate((60,70,80)):contact.paste(pair(frame),(0,row*352))
contact.save(W/'before-after.png')
frames=[pair(f) for f in (1,53,60,66,70,74,80)]
frames[0].save(W/'transition.webp',save_all=True,append_images=frames[1:],duration=[1733,233,200,133,133,200,1000],loop=0,lossless=True)
with Image.open(W/'transition.webp') as im:assert im.n_frames==7
E.mkdir(parents=True)
for folder in ('originals','prepared','before','after','after-legacy','runner','attempts','concurrent-at-finish','docs-before-publication'):
    if (W/folder).exists():shutil.copytree(W/folder,E/folder,ignore=shutil.ignore_patterns('__pycache__','*.pyc'))
for p in W.iterdir():
    if p.is_file() and p.name!='HANDOFF.md' and p.suffix in ('.py','.gd','.md','.log','.json','.diff','.png','.webp'):
        shutil.copy2(p,E/p.name)
handoff=L/'docs/team/CODEX_HANDOFF_2026-10-26_title_logo.md';assert not handoff.exists();shutil.copy2(W/'HANDOFF.md',handoff)
result='''
## Codex result, October 26: pass 7 title items 1-4 / L7-20 logo sequence

Section10 items1-3 are CLOSED by the existing C2-C4 work: title Options/shared sliders/full rows, TYPE roles and live ControlsText Help; current official ui_fit48 still passes. Actual TYPE contract remains authoritative (Jersey prose/headings, Silkscreen labels/buttons), not the stale Pixelify description. Section10 item4 L7-20 now COMPLETE/INSTALLED: centered launch logo/tagline/continue caption fade away completely, then the upper wordmark/menu/key hint fade in over0.25s. Reduce motion swaps instantly. Prelude ends hidden at alpha0, skip input cannot trigger New Game, and initial focus is silent. Native baseline36/36 clean measured14 overlapping frames in each normal auto/Enter/A/mouse case; installed campaign66/66 clean measures0 in all six cases. Legacy normal/reduced20/20 also zero overlap (known101-instance ObjectDB exit warning retained). Official opening_flow and ui_fit2 PASS, exit0, known raw exit noise retained. Native frame logs and matched PNGs reviewed. [Before/after, originals, commands, diff and evidence](../ui/title-logo-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_title_logo.md).

One production method only: opening_flow.gd _finish_boot. All other1002 baseline source/scene/data/dialogue/tool/project/docs files exact before this handoff; main/creature scripts, C1 safe save, C6 default-off prompt, Continue, campaign entry, Storm/soul/shared Claude sources preserved. New pass7 ordering was discovered before edits, so Storm was inspected and left untouched. Initial baseline fixture accidentally injected Enter after reduced menu readiness; failed attempt archived, corrected driver used for both final baseline and installed runs. No real saves, art/generation/paid calls/rules/Route1/message/commit. C5 return-visit skip, splash auto-dismiss/key wording mismatch and remaining LV-24 still pending; C6 prompt remains OFF pending Preston's words. C1 shared preference recovery gap/candidate remains OPEN/staged only. Next ordered slice is section10 item5 ACC-10 reduced-motion lightning, then item6 ACC-14 soul flash, then item7 Storm/soul C7-C9 and white-outs; other opening/export/art work pending.
'''
queue=L/'docs/team/CODEX_TASKS_2026-10-22.md';raw=queue.read_bytes();assert raw==(W/'docs-before-publication/docs/team/CODEX_TASKS_2026-10-22.md').read_bytes()
nl=b'\r\n' if b'\r\n' in raw else b'\n';queue.write_bytes(raw+result.encode().replace(b'\n',nl))
collab=L/'docs/AI_COLLABORATION.md';raw=collab.read_bytes();assert raw==(W/'docs-before-publication/docs/AI_COLLABORATION.md').read_bytes()
head,sep,rest=raw.partition(b'\n');nl=b'\r\n' if b'\r\n' in raw else b'\n'
entry='''
## Codex: L7-20 title logo sequence (October 26, 2026)

Pass7 CODEX_TASKS section10 items1-3 CLOSED by prior C2-C4/current ui_fit48; item4 L7-20 COMPLETE/INSTALLED. Launch logo/tagline/caption clear before upper wordmark/menu/hint fade in; reduced motion swaps instantly, prelude ends hidden/alpha0, skip stays consumed and initial focus is silent. One opening_flow _finish_boot method only. Campaign native66/66 clean: zero overlap across six auto/keyboard/pad/mouse/reduced cases, versus14 normal overlap frames in baseline36/36. Legacy20/20 also zero, known101-instance ObjectDB exit warning retained. Official opening_flow/ui_fit2 PASS; known raw exit warnings retained. [Preview/evidence](ui/title-logo-2026-10-26/README.md); [handoff](team/CODEX_HANDOFF_2026-10-26_title_logo.md). All other baseline sources exact; C1/C6/Continue/shared Claude/Storm/soul preserved. No real save/art/generation/paid call/rules/Route1/message/commit. C5 return skip and splash key/auto-dismiss mismatch remain pending; C6 wording flag OFF, C1 shared prefs recovery candidate still staged only. Newest queue takes precedence: next ACC-10 reduced lightning (item5), ACC-14 soul flash (item6), then Storm/soul input/light/cards/white-out rows (item7).

'''
collab.write_bytes(head+sep+entry.encode().replace(b'\n',nl)+rest)
assert queue.read_bytes().startswith((W/'docs-before-publication/docs/team/CODEX_TASKS_2026-10-22.md').read_bytes())
assert collab.read_bytes().endswith((W/'docs-before-publication/docs/AI_COLLABORATION.md').read_bytes().partition(b'\n')[2])
for p,h in installed.items():assert sha(L/p)==h,p
after=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h]
assert set(after)<=owned|docs|set(concurrent),after
for p in concurrent:
    if (L/p).is_file():assert sha(L/p)==sha(W/'concurrent-at-finish'/p),f'Concurrent change during publication: {p}'
(E/'publication.json').write_text('{}');links=0
for p in (E/'README.md',handoff):
    for target in re.findall(r'\]\(([^)]+)\)',p.read_text(encoding='utf-8')):
        assert (p.parent/target).exists(),(p,target)
        links+=1
receipt={'protected_baseline_files':len(base),'protected_unchanged_after_docs':len(base)-len(after),'owned_production_changes':sorted(owned),'concurrent_source_changes_preserved':concurrent,'all_changed_existing_paths':after,'prior_docs_preserved':True,'native_campaign':'66/66 clean; zero overlap','native_legacy':'20/20; known101-instance exit warning','official':'2 PASS; exit0; known raw warnings retained','prompt_default':'C6 OFF, unchanged','shared_preference_gap':'OPEN; prior candidate not installed','local_links_checked':links,'evidence':str(E),'handoff':str(handoff)}
(W/'publication.json').write_text(json.dumps(receipt,indent=2));shutil.copy2(W/'publication.json',E/'publication.json');print(json.dumps(receipt,indent=2))
