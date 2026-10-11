from pathlib import Path
import shutil,json,hashlib
W=Path(__file__).parent;C=Path('C:/Users/pmcga/dev/hollowtide');A=C/'docs/world/hall-fixtures-finish-2026-10-11'
audit=json.loads((W/'audit.json').read_text())
assert not audit['missing'] and set(audit['changed'])==set(audit['concurrent_changes_preserved'])
for rel,record in audit['concurrent_changes_preserved'].items():
    assert hashlib.sha256((C/rel).read_bytes()).hexdigest()==record['after_sha256'],f'New concurrent edit: {rel}; refresh audit.'
assert not A.exists(),'Archive exists; inspect before writing.'
A.mkdir(parents=True)
for name in ['README.md','baseline.json','audit.json','hooks.patch']:
    shutil.copy2(W/name,A/name)
for name in ['originals','prepared','review','concurrent']:shutil.copytree(W/name,A/name)
(A/'drivers').mkdir()
for p in W.iterdir():
    if p.suffix in ['.py','.gd','.log']:shutil.copy2(p,A/'drivers'/p.name)
def read(rel):
    raw=(C/rel).read_bytes();t=raw.decode();return raw,t.replace('\r\n','\n'),'\r\n' if '\r\n' in t else '\n'
def write(rel,raw,t,nl):
    assert (C/rel).read_bytes()==raw,f'Concurrent documentation change: {rel}'
    (C/rel).write_bytes(t.replace('\n',nl).encode())
rel='docs/team/CODEX_TASKS_2026-10-11.md';raw,t,nl=read(rel)
old='**Status, Codex October 11:** task 1 and task 2 asset preparation are installed and verified. Claude owns task 2\'s production idle swap. Task 3 is next for Codex.'
new='**Status, Codex October 11:** tasks 1 and 3, plus task 2 asset preparation, are installed and verified. Claude owns task 2\'s production idle swap. Task 4 (six crew dialogue portraits) is next for Codex. [Hall fixture evidence](../world/hall-fixtures-finish-2026-10-11/README.md).'
assert t.count(old)==1;t=t.replace(old,new)
t+='\nCodex, October 11: task 3 complete. Finished Claude\'s current corrected Hall fixtures in native pixel code: overhead edge-on doors/hatch, shortened back-wall cases, empty overhead pegs, dark-down/lit-up arched stairs, warm cut stone/timber/brass. One helper and three presentation hooks; current room definitions/solids/links, source PNGs, creature palettes/walks, Guildmaster desk and chamber exit preserved. Native Godot 36/36 art plus all 13 Hall route/interaction checks, staging and live (49/49 each); 30 reachable services, zero outside fixture paint/mask, all unselected GPU floor pixels exact. 30,712 protected files exact; the three Claude concurrent flood/crew audio hooks preserved and archived separately. Original snapshots, diff, audit and native before/after: docs/world/hall-fixtures-finish-2026-10-11/README.md. Task 4 (six crew portraits) is next; tasks 4 through 6 remain pending. Task 2 assets are ready, Claude production idle swap still pending. Visual proposal for Preston; no generation or commit.\n'
write(rel,raw,t,nl)
rel='docs/team/CODEX_START_HERE_2026-10-11.md';raw,t,nl=read(rel)
old='Preston\'s latest completed request: task 2 asset preparation, six crew idle stills with job objects. Installed and verified; Claude still owns the production standing-south swap. Task 3, current Hall fixture art, is next for Codex. The earlier outline, Shrine, world and Hall work remains installed. Do not redo finished work or overwrite Claude\'s concurrent code.'
new='Preston\'s latest completed request: task 3, finished Hall fixtures on Claude\'s current corrected placements and perspectives. Installed and verified 49/49 staging/live; task 4, six crew dialogue portraits, is next for Codex. Task 2 idle assets are ready; Claude still owns the production standing-south swap. Preserve earlier art and Claude\'s concurrent code.'
assert t.count(old)==1;t=t.replace(old,new)
new_entry='**Current Hall fixtures:** task 3 complete. Native pixel finish over Claude\'s corrected fixtures: edge-on doors/hatch, shortened back-wall cases, empty pegs, dark-down/lit-up arched stairs. One helper and three art/mask hooks, no PNG/layout/system changes. Native 36/36 art plus 13/13 route/interaction checks staging/live; 30,712 protected files exact; three concurrent Claude audio hooks preserved. Current screenshots, originals, diff and audit: `docs/world/hall-fixtures-finish-2026-10-11/README.md`. Task 4 is next.\n\n'
assert t.count('## Latest completed work\n\n')==1;t=t.replace('## Latest completed work\n\n','## Latest completed work\n\n'+new_entry)
t=t.replace('Claude owns production idle wiring; task 3 is next for Codex.','Claude owns production idle wiring; task 3 is now complete, task 4 is next for Codex.')
t=t.replace('3. **NEXT: Finish current Hall fixtures:**','3. **DONE: Finish current Hall fixtures:**')
t=t.replace('4. **Six crew dialogue portraits:**','4. **NEXT: Six crew dialogue portraits:**')
t=t.replace('- Latest fixture work: `D:/dev/hollowtide-world-selout-20261011`; Hall fixtures: `D:/dev/hollowtide-hall-floors-finish-20261011`. Both run.py scripts use isolated APPDATA profiles and hidden native Godot processes; `python run.py verify --live` for world; Hall `art_check` and `hall_floors` modes.', '- Current Hall fixture work: `D:/dev/hollowtide-hall-fixtures-20261011`; `python run.py check --live` and `python run.py hall_floors --live`, with isolated APPDATA profiles and hidden native Godot processes. Older `hollowtide-hall-floors-finish-20261011/art_check.gd` predates Claude\'s fixture corrections; its snapshots are historical. World work: `D:/dev/hollowtide-world-selout-20261011`, `python run.py verify --live`.')
write(rel,raw,t,nl)
rel='docs/AI_COLLABORATION.md';raw,t,nl=read(rel)
entry='## Codex: current Hall fixtures finished (October 11, 2026)\n\nTask 3 is installed on Claude\'s corrected placements/perspectives. Native pixel finish adds limestone jambs/arched stairwells, worn timber, iron hinges and brass details; side openings remain edge-on, shortened cases remain on the back wall and runners\' pegs stay empty. Dark-down/lit-up stairs preserved. One helper plus three presentation/mask hooks; no source PNG, creature, layout/collision/link, system/story/rule/save, shader or settings changes. Guildmaster desk/cleared mask and chamber exit exact.\n\nNative Godot staging/live: 36/36 art checks plus all 13 current Hall route/interaction assertions (49/49 each), all 30 services reachable, zero paint/mask outside fixture regions, all unselected GPU floor exact. 30,712 protected files exact; three concurrent Claude audio hooks preserved; guarded installation matched fresh source snapshots. [Native before/after, originals, diff, audit and drivers](world/hall-fixtures-finish-2026-10-11/README.md). Visual proposal for Preston; no generation, paid calls or commit. **Task 4, six crew dialogue portraits, is next.** Task 2 idle assets are ready; Claude\'s production standing-south swap remains pending. Codex is out of the two shared room-art files; no message sent to another chat.\n\n'
assert t.startswith('# Working Together on Hollowtide\n\n');t=t.replace('# Working Together on Hollowtide\n\n','# Working Together on Hollowtide\n\n'+entry,1)
write(rel,raw,t,nl)
print('Archived verified current fixture pass and updated the three shared queue/handoff documents.')
