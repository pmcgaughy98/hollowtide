from pathlib import Path
import difflib,hashlib,json,re,shutil
from PIL import Image,ImageDraw
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');E=L/'docs/ui/storm-lightning-2026-10-26'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'protected-before.json').read_text());installed=json.loads((W/'installed-files.json').read_text());owned=set(installed)
for p,h in installed.items():assert sha(L/p)==h,p
assert not E.exists()
for phase,count in [('before',6),('after',33)]:assert json.loads((W/(phase+'-result.json')).read_text())['passed']==count
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
    im=Image.open(W/phase/'forwarded-peak.png').convert('RGB');assert im.size==(1152,648)
    contact.paste(im.resize((576,324),Image.Resampling.NEAREST),(i*576,24));d.text((i*576+8,6),phase+' / Reduce motion / rendered peak',fill='white')
contact.save(W/'before-after.png')
E.mkdir(parents=True)
for folder in ('originals','prepared','before','after','runner','attempts','before-shared-recheck','tested-shared','concurrent-at-finish','docs-before-publication'):
    if (W/folder).exists():shutil.copytree(W/folder,E/folder,ignore=shutil.ignore_patterns('__pycache__','*.pyc'))
for p in W.iterdir():
    if p.is_file() and p.name!='HANDOFF.md' and p.suffix in ('.py','.gd','.md','.log','.json','.diff','.png'):
        shutil.copy2(p,E/p.name)
handoff=L/'docs/team/CODEX_HANDOFF_2026-10-26_storm_lightning.md';assert not handoff.exists();shutil.copy2(W/'HANDOFF.md',handoff)
result='''
## Codex result, October 26: A1 / ACC-10 reduced-motion lightning

COMPLETE/INSTALLED in storm_open.gd only. Saved UI preference and title-forwarded Reduce motion both work. Each reduced strike is one pulse initialized0.4, fading over0.35s; strike waits1.4/1.9/1.2s are no longer compressed. Normal double pulse/0.85 peak, shared wind/thunder/SFX tail, rain/soul art, input, destination and save behavior otherwise preserved. Native33/33 clean across normal, forwarded-only and saved-only cases; reduced runs each3 monotonic pulses, actual shader peak0.362 after first tween step, sampled nonzero fade0.333s, later gaps1.93/1.23s. Normal retains6 pulses at0.85. All three cases verify3 thunders, freeze/grey, landing, existing soul destination and exact private save hashes. Official storm_open/opening_flow2 PASS, exit0, known raw exit warnings retained. Final native33 and official2 rerun after Claude's shared pref recovery/HEAD edits; current pref helpers match tested snapshot, earlier passes archived. [Native preview, originals, frame samples, commands and diff](../ui/storm-lightning-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_storm_lightning.md).

Source issues for Claude: no new lightning-path issue. A2 soul flash and A3 full white-outs remain pending. Pass8 plan L04 proposes enabling C6, but this dedicated queue explicitly keeps it OFF until Preston chooses words; flag unchanged. Shared C1 copy/backup-reader edits landed concurrently and were preserved; their broader recovery validation stays in Claude's pass8 lane. Initial capture diagnostic sampled state before the shader, corrected to shader-peak capture; initial passing attempt retained. Private profiles/saves only, Claude/Grok changes preserved and listed in receipt; no art/generation/paid call/creature rules/Route1/message/commit. Next ordered slice A2 / ACC-14 reduced soul flash. Town/exterior/sign/lettering art remains on HOLD until slots exist.
'''
queue=L/'docs/team/CODEX_TASKS_2026-10-26.md';raw=queue.read_bytes();assert raw==(W/'docs-before-publication/docs/team/CODEX_TASKS_2026-10-26.md').read_bytes()
nl=b'\r\n' if b'\r\n' in raw else b'\n';queue.write_bytes(raw+result.encode().replace(b'\n',nl))
collab=L/'docs/AI_COLLABORATION.md';raw=collab.read_bytes();assert raw==(W/'docs-before-publication/docs/AI_COLLABORATION.md').read_bytes()
head,sep,rest=raw.partition(b'\n');nl=b'\r\n' if b'\r\n' in raw else b'\n'
entry='''
## Codex: ACC-10 reduced-motion lightning, new queue A1 (October 26, 2026)

COMPLETE/INSTALLED in storm_open.gd only: saved and forwarded Reduce motion honored, one0.4 pulse with0.35s fade per strike and full1.4/1.9/1.2s waits. Normal double0.85 flashes and thunder tail preserved. Native33/33 clean, reduced3 pulses versus old6, shader peak about0.362 after first tween step; official storm_open/opening_flow2 PASS, known raw exit warnings retained. Final native/official runs repeated after Claude pref recovery/HEAD edits; pref helper bodies match tested snapshot. Claude/Grok concurrent work preserved; private saves exact. [Preview/evidence](ui/storm-lightning-2026-10-26/README.md); [handoff](team/CODEX_HANDOFF_2026-10-26_storm_lightning.md). Source issues: no new lightning issue, soul/full white-outs pending; pass8 L04 conflicts with dedicated queue's C6 wording hold, so flag stays OFF. Claude's shared recovery edits preserved; broader validation stays his lane. No real save/art/generation/paid call/rules/Route1/message/commit. Next A2 ACC-14 soul flash. Town/exterior art stays on HOLD.

'''
collab.write_bytes(head+sep+entry.encode().replace(b'\n',nl)+rest)
assert queue.read_bytes().startswith((W/'docs-before-publication/docs/team/CODEX_TASKS_2026-10-26.md').read_bytes())
assert collab.read_bytes().endswith((W/'docs-before-publication/docs/AI_COLLABORATION.md').read_bytes().partition(b'\n')[2])
for p,h in installed.items():assert sha(L/p)==h,p
after=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h]
late=[p for p in after if p not in owned|docs|set(concurrent)]
# Another lane may continue while evidence is copied. Record new paths without touching them.
for p in late:
    if (L/p).is_file():
        d=E/'concurrent-during-publication'/p;d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/p,d)
(E/'publication.json').write_text('{}');links=0
for p in (E/'README.md',handoff):
    for target in re.findall(r'\]\(([^)]+)\)',p.read_text(encoding='utf-8')):
        assert (p.parent/target).exists(),(p,target)
        links+=1
receipt={'protected_baseline_files':len(base),'owned_production_changes':sorted(owned),'concurrent_source_changes_preserved':concurrent,'concurrent_during_publication':late,'all_changed_existing_paths':after,'prior_docs_preserved':True,'native':'33/33 clean','official':'2 PASS; exit0; known raw exit warnings retained','shared_recheck':'Claude updated pref reader/copy recovery; final tests rerun; snapshots archived','prompt_default':'C6 OFF, unchanged','local_links_checked':links,'evidence':str(E),'handoff':str(handoff)}
(W/'publication.json').write_text(json.dumps(receipt,indent=2));shutil.copy2(W/'publication.json',E/'publication.json');print(json.dumps(receipt,indent=2))
