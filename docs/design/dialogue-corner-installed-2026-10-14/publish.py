from pathlib import Path
import json,hashlib,shutil,re
from PIL import Image
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');PREV=Path('D:/dev/hollowtide-dialogue-corner-20261014')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
protected=json.loads((W/'protected.json').read_text(encoding='utf-8'))
changed=[r for r,h in protected.items() if sha(R/r)!=h]
assert changed==['scripts/ui/ui_style.gd'],changed
p=R/changed[0];raw=p.read_bytes();old=(W/'original-ui_style.gd').read_bytes()
assert raw.replace(b'const PORTRAIT_INSET := 162.0',b'const PORTRAIT_INSET := 150.0').replace(b'box.position + Vector2(42, -34)',b'box.position + Vector2(30, -34)')==old
for kind in ['flood','gallery']:
    log=(W/'live'/(kind+'.log')).read_text(encoding='utf-8')
    assert 'FAIL' not in log and 'ERROR' not in log and ('all ok' in log if kind=='flood' else '5/5' in log)
controls={}
for name in ['gallery-narration','gallery-shared-panels']:
    a=Image.open(PREV/'before'/f'{name}.png').convert('RGBA');b=Image.open(W/'live'/f'{name}.png').convert('RGBA')
    controls[name]=a.tobytes()==b.tobytes();assert controls[name]
for name in ['gallery-long-page1','gallery-long-lastpage']:
    a=Image.open(PREV/'after'/f'{name}.png').convert('RGBA');b=Image.open(W/'live'/f'{name}.png').convert('RGBA')
    controls[name+'-matches-checked-proposal']=a.tobytes()==b.tobytes();assert controls[name+'-matches-checked-proposal']
receipt={'native_live_flood':5,'native_live_gallery':5,'other_protected_files_exact':len(protected)-1,'only_changed_source':changed[0],'source_reverse_two_values_equals_original_bytes':True,'pixel_controls':controls,'new_image_generation':False}
(W/'verification.json').write_text(json.dumps(receipt,indent=2),encoding='utf-8')
rel='docs/design/dialogue-corner-installed-2026-10-14';dst=R/rel;assert not dst.exists()
status='Follow-up complete: the checked shared dialogue corner correction is now INSTALLED in scripts/ui/ui_style.gd (PORTRAIT_INSET162.0, portrait offset42,-34). Portrait/name/prose move12px right together, clearing the complete brass stud with6px spare. Native installed flood5/5 plus gallery5/5; narration and ordinary/dim/focused shared panels pixel-exact to baseline; long-line first/final pages pixel-exact to the checked proposal. Exactly two value replacements; reverse patch restores original source bytes;813 other protected source/data/dialogue/UI files exact. Evidence, original source, patch and native captures: '+rel+'/README.md. All five October14 queue deliverables remain complete. The dialogue integration is no longer pending; only Claude\'s Storage room/door/collision/panel integration remains. No new frame/art, generation, paid call, state/rule/save/other proposal/training change or commit.'
changes={}
start=R/'docs/team/CODEX_START_HERE_2026-10-14.md';raw=start.read_bytes();txt=raw.decode('utf-8-sig').replace('\r\n','\n');a=txt.index('## Current status\n');b=txt.index('\n## Read before work',a)
txt=txt[:a]+'## Current status\n\n'+status+'\n'+txt[b:]
txt=txt.replace("dialogue corner values proposed; AI inventory refreshed. Claude's Storage and dialogue integrations remain pending.","dialogue corner correction installed; AI inventory refreshed. Claude's Storage integration remains pending.")
changes[start]=(raw,txt)
tasks=R/'docs/team/CODEX_TASKS_2026-10-14.md';raw=tasks.read_bytes();txt=raw.decode('utf-8-sig').replace('\r\n','\n');assert '4. **PROPOSAL COMPLETE:' in txt
txt=txt.replace('4. **PROPOSAL COMPLETE:','4. **DONE / INSTALLED:',1)+'\n\nCodex, October14 (follow-up after Preston: "next"): '+status+'\n'
changes[tasks]=(raw,txt)
collab=R/'docs/AI_COLLABORATION.md';raw=collab.read_bytes();txt=raw.decode('utf-8-sig').replace('\r\n','\n');title='# Working Together on Hollowtide\n';assert txt.startswith(title)
txt=txt.replace(title,title+'\n## Codex: shared dialogue correction installed (October14,2026)\n\n'+status+'\n',1);changes[collab]=(raw,txt)
inv=R/'docs/pitch/ai-asset-inventory.md';raw=inv.read_bytes();txt=raw.decode('utf-8-sig').replace('\r\n','\n')
oldrow='| **Dialogue corner layout proposal**; the shared frame PNGs and builder remain unchanged. | **AI-assisted layout correction**, no generated art. Proposed `PORTRAIT_INSET=162.0`, portrait offset `(42,-34)`; [two-line patch and native flood comparison](../design/dialogue-corner-2026-10-14/README.md). **Staged only: Claude still applies the values.** It is not an installed frame variant. |'
newrow='| **Installed dialogue corner layout correction**; shared frame PNGs and builder unchanged. | **AI-assisted layout correction**, no generated art. `PORTRAIT_INSET=162.0`, portrait offset `(42,-34)`; [original comparison](../design/dialogue-corner-2026-10-14/README.md), [live installation and native10/10 checks](../design/dialogue-corner-installed-2026-10-14/README.md). Installed in the follow-up after the inventory refresh; every box retains the one shared frame. |'
assert oldrow in txt;txt=txt.replace(oldrow,newrow)
txt=txt.replace('installation of the staged Storage room or dialogue offset.','the later installed dialogue offset or integration of the staged Storage room.')
changes[inv]=(raw,txt)
handoff=R/'docs/team/CODEX_HANDOFF_2026-10-14_dialogue_corner.md';raw=handoff.read_bytes();txt=raw.decode('utf-8-sig').replace('\r\n','\n');a=txt.index('\n')
txt=txt[:a]+'\n\n**Later same day: INSTALLED by Codex after Preston asked for the next integration.** The two shared values below are live; do not reapply the old proposal or replace later edits. Native flood5/5 and gallery5/5; evidence: `'+rel+'/README.md`. Original proposal handoff below is preserved as history. Storage wiring remains pending.\n'+txt[a:]
changes[handoff]=(raw,txt)
dst.mkdir(parents=True)
for name in ['prepare.py','install.py','run.py','publish.py','flood.gd','gallery.gd','protected.json','original-ui_style.gd','candidate-ui_style.gd','installed.diff','verification.json']:
    shutil.copy2(W/name,dst/name)
captures=dst/'live';captures.mkdir()
for p in (W/'live').iterdir():
    if p.is_file():shutil.copy2(p,captures/p.name)
(dst/'.gdignore').write_text('',encoding='utf-8')
(dst/'README.md').write_text('''# Shared dialogue corner installed, October14,2026

After the five queue deliverables, Preston asked for the next slice. Codex applied the already checked two-value visual correction to the live shared UI: `PORTRAIT_INSET=162.0` and portrait offset `Vector2(42,-34)`. Previous values150.0 and(30,-34); all three portrait/name/text move12px right. The outer portrait frame begins27px from the box's left edge, leaving6px clear after the21px stud. Standard760px-box prose width becomes528px rather than540px; vertical position and portrait size remain unchanged.

Native installed flood **5/5**: narration, starter offers, selecting Rimefin, its speaker/face and transition to the actual riverbank with Tallowroot/Rimefin. Native gallery **5/5**: actual portrait lookup, cached shared panel, multi-page long line, final-page completion, measured wrap fit at existing760/948px widths. Logs/captures are in `live/`, including `3_partner.png` and long-line first/last pages.

Deterministic narration and ordinary/dim/focused panels are pixel-exact to the original baseline; long-line first/last pages are pixel-exact to the checked proposal. All813 other protected existing source/data/dialogue/UI files match the starting hashes. Reversing exactly those two source values reproduces the original full file bytes, including line endings. Shared frame PNGs/builder, portrait art, fonts, text/state/save/choice rules, original water/Parcel work and all other current proposals are preserved. `verification.json` records these controls.

`original-ui_style.gd`, `candidate-ui_style.gd` and `installed.diff` preserve source/patch. For the earlier staged/baseline native evidence see [the original proposal](../dialogue-corner-2026-10-14/README.md). Its pending-language records the earlier state; this installation supersedes it. No additional frame variant or generated asset. Inventory updated to installed layout status; the October14 inventory evidence hashes remain the historical pre-install snapshot.

Drivers were run in `D:/dev/hollowtide-dialogue-install-20261014` with isolated APPDATA/LOCALAPPDATA, Dummy audio and fixed30fps. `run.py flood`/`run.py gallery` point at the live project and their private output; archive/relabel prior logs before a rerun. Only the owned subprocess is managed. The fixture's in-memory Dialogue Manager cleanup runs after scene teardown; no plugin or production-dialogue change. `prepare.py`/`install.py` intentionally guard the original before installing; do not rerun them against the already corrected live source. To play, F5 the live project and continue into the flood conversation, or F6 `scenes/creature_prologue.tscn`.

All five queue deliverables are complete. **Only Claude's Storage room/door/collision/panel integration remains pending.** No message to another chat, generation, paid call, training file or commit. Source/art review remains Preston's.
''',encoding='utf-8')
for p,(raw,txt) in changes.items():
    saved=dst/'original-docs'/p.relative_to(R);saved.parent.mkdir(parents=True,exist_ok=True);saved.write_bytes(raw)
for p,(raw,txt) in changes.items():
    assert p.read_bytes()==raw,'Concurrent documentation edit; stop.'
    newline='\r\n' if b'\r\n' in raw else '\n';p.write_bytes(txt.replace('\n',newline).encode('utf-8'))
newhandoff=R/'docs/team/CODEX_HANDOFF_2026-10-14_dialogue_installed.md';assert not newhandoff.exists()
newhandoff.write_text('# Shared dialogue correction installed\n\n'+status+'\n',encoding='utf-8')
assert [r for r,h in protected.items() if sha(R/r)!=h]==['scripts/ui/ui_style.gd']
count=0
for label,ref in re.findall(r'\[([^\]]+)\]\(([^)]+)\)',inv.read_text(encoding='utf-8')):
    if ref.startswith(('https://','http://')):continue
    assert (inv.parent/ref.split('#')[0]).resolve().exists(),ref;count+=1
manifest={p.relative_to(dst).as_posix():sha(p) for p in dst.rglob('*') if p.is_file()}
(dst/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print(json.dumps(receipt,indent=2));print('Published',len(manifest),'files;',count,'inventory links resolve.')
