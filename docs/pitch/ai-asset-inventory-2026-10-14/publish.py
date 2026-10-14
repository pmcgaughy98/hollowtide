from pathlib import Path
import hashlib,json,shutil,re,difflib
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
P=R/'docs/pitch/ai-asset-inventory.md'
assert P.read_bytes()==(W/'original-inventory.md').read_bytes(),'Inventory changed concurrently.'
evidence=json.loads((W/'evidence-sha256.json').read_text(encoding='utf-8'))
assert all(sha(R/r)==h for r,h in evidence.items()),'Evidence changed; recheck.'
protected=json.loads(Path('D:/dev/hollowtide-dialogue-corner-20261014/protected.json').read_text(encoding='utf-8'))
assert all(sha(R/r)==h for r,h in protected.items()),'Protected sources changed; inspect.'
rel='docs/pitch/ai-asset-inventory-2026-10-14';archive=R/rel
assert not archive.exists(),'Archive already present; inspect.'
status='Task 5 complete: refreshed docs/pitch/ai-asset-inventory.md for October12-14. Verified all12 Retro Diffusion crew expressions and their raw edits; six normal portraits exact to October11 prepared files. Probed both101.967s v3 MP4s and measured all four98-frame/6.54s gameplay GIFs; recorded actual engine footage/editing, generated source content and missing per-GIF encoding records separately. Ballastak (SpriteCook/Nano Banana plus GPT-Image-2 profile edits), Switchhold (PixelLab), palette/parts and local SD1.5/LoRA exams remain development proposals, not installed gameplay; the dated training note says parked, not a fresh process audit. Added installed Parcel/water provenance and staged Storage/imagegen and dialogue-value status; exact models/legacy unknowns remain explicit. Current entry scene corrected to creature_opening. Evidence, hashes and checks: '+rel+'/README.md;98 local links resolved; all814 protected existing source/data/dialogue/UI files exact. Documentation only; no generation, paid call, policy/terms research, game/media edit or commit. All five October14 queue deliverables complete: tasks1-2 installed, task3 Storage art staged and task4 dialogue values proposed. Claude still owns those two integrations; neither is claimed live.'
changes={P:((W/'original-inventory.md').read_bytes(),(W/'ai-asset-inventory.md').read_text(encoding='utf-8'))}
start=R/'docs/team/CODEX_START_HERE_2026-10-14.md';raw=start.read_bytes();txt=raw.decode('utf-8-sig').replace('\r\n','\n')
a=txt.index('## Current status\n');b=txt.index('\n## Read before work',a)
txt=txt[:a]+'## Current status\n\n'+status+'\n'+txt[b:]
txt=txt.replace('Five tasks, in order: the Parcel icon (complete), the painted\n   rising water (complete), the Storage room\'s art (staged), the dialogue frame\'s left corner, the AI asset inventory refresh.','All five deliverables complete: Parcel icon and painted rising water installed; Storage art staged; dialogue corner values proposed; AI inventory refreshed. Claude\'s Storage and dialogue integrations remain pending.')
changes[start]=(raw,txt)
tasks=R/'docs/team/CODEX_TASKS_2026-10-14.md';raw=tasks.read_bytes();txt=raw.decode('utf-8-sig').replace('\r\n','\n')
assert '5. **Refresh the AI asset inventory**' in txt
txt=txt.replace('5. **Refresh the AI asset inventory**','5. **DONE: Refresh the AI asset inventory**',1)
txt+='\n\nCodex, October 14: '+status+'\n'
changes[tasks]=(raw,txt)
collab=R/'docs/AI_COLLABORATION.md';raw=collab.read_bytes();txt=raw.decode('utf-8-sig').replace('\r\n','\n')
title='# Working Together on Hollowtide\n';assert txt.startswith(title)
txt=txt.replace(title,title+'\n## Codex: AI inventory refreshed; October 14 queue deliverables complete (October 14, 2026)\n\n'+status+'\n',1)
changes[collab]=(raw,txt)
archive.mkdir(parents=True)
for name in ['inspect.py','build.py','publish.py','facts.json','evidence-sha256.json','validation.json','original-inventory.md']:
    shutil.copy2(W/name,archive/name)
(archive/'inventory.diff').write_text(''.join(difflib.unified_diff(changes[P][0].decode('utf-8-sig').replace('\r\n','\n').splitlines(True),changes[P][1].splitlines(True),fromfile='October11/ai-asset-inventory.md',tofile='October14/ai-asset-inventory.md')),encoding='utf-8')
(archive/'README.md').write_text('''# Inventory refresh evidence, October 14, 2026

The parent [AI asset inventory](../ai-asset-inventory.md) now includes the October12-14 additions. This is a **targeted refresh**, not a replacement full media census, release export audit, provider-rights check or new policy review. The October11 full register/reference census remains preserved and explicitly dated.

`facts.json` records twelve40x40 crew expressions and raw-edit paths, all six normal portraits exact to October11 prepared PNGs, four576x324 GIFs (98frames/6.54s each), ffprobe metadata for both101.967s/1080p30 v3 MP4s, current title entry scene, absent export preset and scoped negative proposal/runtime API-marker scans. `evidence-sha256.json` identifies the reviewed local files, including provenance notes and source tools. It is a source receipt, not a claim of legal clearance or complete reachability.

Expression provenance is Retro Diffusion image_edit on Codex's crops; exact underlying edit model unknown. Video is edited engine footage whose assets retain their generated/assisted categories, with scripted scene setup. Per-GIF encoder/cut commands were not found and remain unknown. No claim is made that October12 footage shows October14 art fixes. Proposed Ballastak/Switchhold/palette/parts/model outputs stay separate from installed Parcel/water and from staged Storage/layout work. The local model's parked status comes from the dated design note; no process or training job was inspected or changed.

`inspect.py` reads source files/Pillow metadata and calls ffprobe; it makes no generation or network calls. It writes to its own work folder `D:/dev/hollowtide-inventory-refresh-20261014`. `build.py` prepares the amended Markdown and checks its local links. `publish.py` guards original/current hashes, publishes documentation and verifies again. Run these with the Python runtime recorded in the work-session handoff; do not run creature generation tools to reproduce this documentation task.

`validation.json`:98 local Markdown references resolve;12 expressions,6 unchanged normals,4 GIFs and2 videos verified. `original-inventory.md` and `inventory.diff` preserve the earlier inventory and exact revision. `original-docs/` preserves the queue/start/collaboration files before the final status update. All814 protected existing source/data/dialogue/UI files were checked exact before and after publication. Native game tests were not rerun for this documentation-only change; prior asset/gameplay checks are linked in their own evidence folders.

No game source, media, settings, old proposal, training file, export, post or message was changed/sent. No new image/audio generation, paid call, policy/terms research or commit. Exact assistant/generator model versions or legacy provenance that the records do not establish remain unknown.

All five queue deliverables are complete. Claude's live Storage room integration and application of the proposed shared dialogue values remain pending.
''',encoding='utf-8')
for p,(raw,txt) in changes.items():
    target=archive/'original-docs'/p.relative_to(R);target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(raw)
for p,(raw,txt) in changes.items():
    assert p.read_bytes()==raw,'Concurrent doc edit; stop.'
    newline='\r\n' if b'\r\n' in raw else '\n'
    p.write_bytes(txt.replace('\n',newline).encode('utf-8'))
handoff=R/'docs/team/CODEX_HANDOFF_2026-10-14_inventory.md';assert not handoff.exists()
handoff.write_text('# AI asset inventory refresh complete\n\n'+status+'\n\nNo new automatic next task was selected. Storage and dialogue remain Claude integrations; see their separate October14 handoffs. No message sent to another chat.\n',encoding='utf-8')
text=P.read_text(encoding='utf-8');links=[]
for label,ref in re.findall(r'\[([^\]]+)\]\(([^)]+)\)',text):
    if ref.startswith(('https://','http://')):continue
    assert (P.parent/ref.split('#')[0]).resolve().exists(),ref
    links.append(ref)
assert len(links)==98
assert all(sha(R/r)==h for r,h in protected.items())
assert all(sha(R/r)==h for r,h in evidence.items())
(archive/'installed-validation.json').write_text(json.dumps({'all_local_inventory_links_resolve':len(links),'protected_files_exact':len(protected),'evidence_files_exact':len(evidence),'documentation_only':True},indent=2),encoding='utf-8')
manifest={p.relative_to(archive).as_posix():sha(p) for p in archive.rglob('*') if p.is_file()}
(archive/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print('Published inventory and handoffs;',len(links),'local links resolve;',len(protected),'protected files and',len(evidence),'evidence files exact.')
