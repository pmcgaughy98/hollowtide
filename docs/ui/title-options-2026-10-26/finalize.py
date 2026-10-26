from pathlib import Path
import hashlib,json,re,shutil
from PIL import Image,ImageDraw
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');E=L/'docs/ui/title-options-2026-10-26'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
installed=json.loads((W/'installed-files.json').read_text());base=json.loads((W/'protected-before.json').read_text());owned=set(installed)
for p,h in installed.items():assert sha(L/p)==h,p
for phase,number in [('after',30),('restart',19)]:
    r=json.loads((W/(phase+'-result.json')).read_text());assert r['failed']==0 and r['passed']==number
    log=(W/(phase+'.log')).read_text();assert not any(s in log for s in ('SCRIPT ERROR','ERROR:','ObjectDB instances were leaked'))
assert 'ui fit: all ok (0 failed)' in (W/'ui_fit.log').read_text()
assert 'Totals: PASS 3' in (W/'runner-result.md').read_text()
for folder in ('native-after','native-restart','runner','ui-fit','before-concurrent-recheck'):
    shutil.copytree(W/folder,E/folder,dirs_exist_ok=True)
for name in ('README.md','after.log','after-result.json','after-command.json','restart.log','restart-result.json','restart-command.json','ui_fit.log','ui_fit-command.json','ui_fit_private.gd','prepare_ui_fit.py','verification.json','runner-result.md','finalize.py'):
    shutil.copy2(W/name,E/name)
handoff=L/'docs/team/CODEX_HANDOFF_2026-10-26_title_options.md';shutil.copy2(W/'HANDOFF.md',handoff)
sheet=Image.new('RGB',(1152,704),'#242b25');draw=ImageDraw.Draw(sheet)
for row,key in enumerate(('options','controls-keyboard')):
    for col,phase in enumerate(('before','after')):
        im=Image.open(E/('native-'+phase)/(key+'.png')).convert('RGB')
        sheet.paste(im.resize((576,324),Image.Resampling.NEAREST),(col*576,row*352+24));draw.text((col*576+8,row*352+5),phase+': '+key,fill='white')
sheet.save(E/'before-after.png')
contact=Image.new('RGB',(1152,480),'#242b25');draw=ImageDraw.Draw(contact)
for i,key in enumerate(('options','rebind','controls-keyboard','controls-keyboard-bottom','controls-pad','controls-pad-bottom')):
    x=(i%3)*384;y=(i//3)*240;im=Image.open(E/'native-after'/(key+'.png')).convert('RGB')
    contact.paste(im.resize((384,216),Image.Resampling.NEAREST),(x,y+24));draw.text((x+6,y+5),key,fill='white')
contact.save(E/'native-contact.png')
note='''

C4 final concurrency recheck, October26: Claude's shared UI chord/Rebind and ui_fit log-clock updates landed during archive publication. Preserved them and reran native30/30, fresh-launch19/19, updated native ui_fit48/48, and official opening_flow/rebind/ui_fit3 PASS, all successful. Previous passing logs retained separately; final evidence contains the newer shared sources and check copy. Original task4 shared-save gap still open. No further game-source edits by Codex.
'''
queue=L/'docs/team/CODEX_TASKS_2026-10-22.md';raw=queue.read_bytes();snapshot=W/'docs-before-finalization'/queue.relative_to(L);snapshot.parent.mkdir(parents=True,exist_ok=True);snapshot.write_bytes(raw)
nl=b'\r\n' if b'\r\n' in raw else b'\n';queue.write_bytes(raw+note.encode().replace(b'\n',nl));assert queue.read_bytes().startswith(raw)
collab=L/'docs/AI_COLLABORATION.md';raw=collab.read_bytes();snapshot=W/'docs-before-finalization'/collab.relative_to(L);snapshot.parent.mkdir(parents=True,exist_ok=True);snapshot.write_bytes(raw)
head,sep,rest=raw.partition(b'\n');nl=b'\r\n' if b'\r\n' in raw else b'\n'
entry='''
## Codex: C4 final shared-source recheck (October 26, 2026)

Claude landed chord/UI/Rebind and ui_fit log-clock updates while the C4 archive was being published. They remain intact. Reran native30/30 +restart19/19, updated current native ui_fit48/48, and official opening_flow/rebind/ui_fit3 PASS successfully; all final native logs clean. Final evidence and shared-file snapshots updated, older passes retained separately under [C4 evidence](ui/title-options-2026-10-26/README.md). No further owned game-source edit. Shared preference recovery follow-up remains open, next independent slice C6 with its wording flag off.

'''
collab.write_bytes(head+sep+entry.encode().replace(b'\n',nl)+rest);assert collab.read_bytes().endswith(rest)
docs={'docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-22.md'}
changed=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h]
concurrent=[p for p in changed if p not in owned|docs]
shared_hashes={}
for p in concurrent:
    if (L/p).is_file():
        dest=E/'concurrent-at-final-recheck'/p;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/p,dest);shared_hashes[p]=sha(L/p)
shutil.copytree(W/'docs-before-finalization',E/'docs-before-finalization',dirs_exist_ok=True)
receipt=json.loads((W/'publication.json').read_text());receipt.update({'protected_unchanged_after_docs':len(base)-len(changed),'concurrent_source_changes_preserved':concurrent,'all_changed_existing_paths':changed,'final_shared_source_recheck':{'native_settings':'30/30 clean','fresh_launch':'19/19 clean','updated_native_ui_fit':'48/48 clean','official_runner':'3 PASS exit0','shared_source_hashes':shared_hashes,'previous_logs':'before-concurrent-recheck/'}})
links=0
for p in (E/'README.md',handoff):
    for target in re.findall(r'\]\(([^)]+)\)',p.read_text(encoding='utf-8')):
        assert (p.parent/target).exists(),(p,target)
        links+=1
receipt['local_links_checked']=links
for p,h in installed.items():assert sha(L/p)==h,p
(W/'publication.json').write_text(json.dumps(receipt,indent=2));shutil.copy2(W/'publication.json',E/'publication.json')
print(json.dumps({'final_shared_recheck':'30/30 +19/19 +48/48 native; official3PASS','preserved_concurrent':concurrent,'local_links':links,'owned_hashes_exact':True},indent=2))
