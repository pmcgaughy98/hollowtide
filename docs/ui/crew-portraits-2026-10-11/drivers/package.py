from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;C=Path('C:/Users/pmcga/dev/hollowtide');A=C/'docs/ui/crew-portraits-2026-10-11'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert 'CREW PORTRAITS 49/49 PASS' in (W/'verify.log').read_text()
assert 'CREW PORTRAITS 49/49 PASS' in (W/'live-verify.log').read_text()
audit=json.loads((W/'final-audit.json').read_text());assert not audit['final_protected_changes']
for rel,r in audit['concurrent_changes_preserved'].items():assert sha(C/rel)==r['concurrent_sha256'],f'New concurrent edit: {rel}'
for r in json.loads((W/'evidence/manifest.json').read_text()):assert sha(C/r['output'])==r['output_sha256']
assert not A.exists(),'Preserve previous archives.'
A.mkdir(parents=True)
for name in ['README.md','protected.json','source_meta.json','imports.json','install-audit.json','final-audit.json','concurrent.json','reviewed-final-concurrent.json','source_grid.png','reference_portraits.png']:
    shutil.copy2(W/name,A/name)
for name in ['originals','prepared','evidence','review','concurrent']:shutil.copytree(W/name,A/name)
(A/'drivers').mkdir()
for p in W.iterdir():
    if p.suffix in ['.py','.gd','.log']:shutil.copy2(p,A/'drivers'/p.name)
def read(rel):
    raw=(C/rel).read_bytes();text=raw.decode();return raw,text.replace('\r\n','\n'),'\r\n' if '\r\n' in text else '\n'
def write(rel,raw,text,nl):
    assert (C/rel).read_bytes()==raw,f'Concurrent documentation edit: {rel}'
    (C/rel).write_bytes(text.replace('\n',nl).encode())
rel='docs/team/CODEX_TASKS_2026-10-11.md';raw,text,nl=read(rel)
old="**Status, Codex October 11:** tasks 1 and 3, plus task 2 asset preparation, are installed and verified. Claude owns task 2's production idle swap. Task 4 (six crew dialogue portraits) is next for Codex."
new="**Status, Codex October 11:** tasks 1, 3 and 4, plus task 2 asset preparation, are installed and verified. Claude owns task 2's production idle swap. Task 5 (AI asset inventory for the pitch) is next for Codex. [Crew portrait evidence](../ui/crew-portraits-2026-10-11/README.md)."
assert text.count(old)==1;text=text.replace(old,new)
text+="\nCodex, October 11: task 4 complete. Six new normal crew dialogue portraits from current chosen fronts, existing recolour rules on copies, manually selected square head crops, palette-locked 40px resample and the existing black outline tool (357 rim pixels, alpha/interiors exact). Six native imports and one scoped reproducible preparation tool; no game-code or existing-portrait changes. Current SceneKit/UI speaker lookup works automatically. Native Godot 49/49 staging and live: exact imported RGBA and nearest 3x frame rendering, all six real NPC conversations, deferred expression fallback and unknown-speaker behavior. 2,902 files exact since the fresh initial hashes, three concurrent Claude soul music/roll-call/room-landing edits preserved; all 2,905 exact against reviewed versions at install. Native galleries, six conversations, original fronts/crops/pre-outline copies, manifest/audits and drivers: docs/ui/crew-portraits-2026-10-11/README.md. Task 5 (AI asset inventory) is next; tasks 5 and 6 remain pending. Task 2 assets ready, Claude idle wiring still pending; no generation, paid calls or commit. Visual proposal for Preston.\n"
write(rel,raw,text,nl)
rel='docs/team/CODEX_START_HERE_2026-10-11.md';raw,text,nl=read(rel)
old="Preston's latest completed request: task 3, finished Hall fixtures on Claude's current corrected placements and perspectives. Installed and verified 49/49 staging/live; task 4, six crew dialogue portraits, is next for Codex. Task 2 idle assets are ready; Claude still owns the production standing-south swap. Preserve earlier art and Claude's concurrent code."
new="Preston's latest completed request: task 4, six crew normal dialogue portraits. Installed and verified 49/49 staging/live, including all six real Hall conversations. Task 5, the evidence-backed AI asset inventory for the pitch, is next for Codex. Task 2 idle assets are ready; Claude still owns the production standing-south swap. Preserve current art and Claude's concurrent code."
assert text.count(old)==1;text=text.replace(old,new)
old='3. `docs/world/world-selout-2026-10-11/README.md` and `docs/world/hall-floors-finish-2026-10-11/README.md` for latest installed scope/evidence.'
new='3. `docs/ui/crew-portraits-2026-10-11/README.md`, `docs/world/hall-fixtures-finish-2026-10-11/README.md` and `docs/world/world-selout-2026-10-11/README.md` for current scope/evidence. Older Hall-floor snapshots predate Claude\'s corrected fixtures.'
assert text.count(old)==1;text=text.replace(old,new)
entry="**Six crew dialogue portraits:** task 4 complete. New 40px normal headshots from current chosen fronts, matching existing recolour/crop/resample/black-outline rules. Exact native RGBA and 3x frame rendering; all six current Hall conversations resolve automatically, expressions fall back to normal. Native 49/49 staging/live. No game-script or prior portrait changes; Claude's concurrent soul music, roll-call staging and room landings preserved. `docs/ui/crew-portraits-2026-10-11/README.md`. Task 5 is next.\n\n"
assert text.count('## Latest completed work\n\n')==1;text=text.replace('## Latest completed work\n\n','## Latest completed work\n\n'+entry)
text=text.replace('`. Task 4 is next.','`. Task 4 is now complete; task 5 is next.')
text=text.replace('task 3 is now complete, task 4 is next for Codex.','tasks 3 and 4 are now complete; task 5 is next for Codex.')
text=text.replace('4. **NEXT: Six crew dialogue portraits:**','4. **DONE: Six crew dialogue portraits:**')
text=text.replace('5. **AI asset inventory for the pitch:**','5. **NEXT: AI asset inventory for the pitch:**')
anchor='- Current Hall fixture work:'
assert text.count(anchor)==1
text=text.replace(anchor,'- Current portrait work: `D:/dev/hollowtide-crew-portraits-20261011`, `python run.py verify --live`. New builder: `tools/ui/build_crew_dialogue_portraits.py`, using fresh output/evidence directories. Existing dialogue portraits, chosen sources and old builder outputs must be preserved. Native import and six Hall conversations are verified.\n'+anchor)
write(rel,raw,text,nl)
rel='docs/AI_COLLABORATION.md';raw,text,nl=read(rel)
entry="## Codex: six crew dialogue portraits installed (October 11, 2026)\n\nTask 4 complete: Grubbit, Stillwade, Wickglow, Muskin, Slipjaw and Rinsepaw normal headshots from current chosen fronts, same 40px townsfolk framing, existing recolour rules on copies, palette-locked resample and exact outline_portrait black-edge pass. Six new PNGs/imports and one scoped reproducible builder; original chosen art, current walks/idles, previous portraits and all game scripts preserved. Existing SceneKit/UI lookup resolves them automatically. Expression faces remain deferred and fall back to normal. No generation, paid calls or commit.\n\nNative Godot 49/49 staging/live: imported RGBA exact, hard alpha/outline interiors intact, native 3x frame exact and all six real Hall NPC conversations show the correct portraits. 2,902 existing files exact since the initial hashes; three concurrent Claude changes (soul music, roll-call staging, room landings) reviewed and preserved, all 2,905 exact at guarded install. [Gallery, six conversation captures, original fronts/crops/pre-outline copies, manifests, audits and drivers](ui/crew-portraits-2026-10-11/README.md). Visual proposal for Preston. **Task 5, the AI asset inventory for the pitch, is next; task 6 remains pending.** Task 2 idle assets are installed, Claude production standing-south wiring remains pending. No message sent to another chat.\n\n"
assert text.startswith('# Working Together on Hollowtide\n\n');text=text.replace('# Working Together on Hollowtide\n\n','# Working Together on Hollowtide\n\n'+entry,1)
write(rel,raw,text,nl)
print('Archived crew portraits and live proof; updated master queue/start-here/collaboration to task 5 next.')
