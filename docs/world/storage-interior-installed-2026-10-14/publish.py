from pathlib import Path
import json,hashlib,shutil,re
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');S=Path('D:/dev/hollowtide-world-refinement-20261008/project')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
receipt=json.loads((W/'live-audit.json').read_text(encoding='utf-8'));assert receipt['native_total']==53
for rel,h in receipt['installed_file_hashes'].items():assert sha(R/rel)==h,rel
protected=json.loads((W/'protected.json').read_text(encoding='utf-8'))
assert sorted(r for r,h in protected.items() if sha(R/r)!=h)==sorted(receipt['expected_changed_files'])
rel='docs/world/storage-interior-installed-2026-10-14';dst=R/rel;assert not dst.exists()
status='Storage integration INSTALLED after Preston asked for the next slice: the unlocked town door enters the painted17x13 room; the solid counter opens the existing Storage panel at166,64. Shared panel extracted without changing Storage.open/rows/move or state/save format; three-tile exit, furniture collision, separate foot-sorted props and existing0.75 finish. Pause Return to title now uses the existing town save call inside Storage; actual Continue restores counts. Native53/53 staging and53/53 live: Storage11, real route/keys/sorting/exits20, pause/Continue5, Home/Hall4, Hall floors13. All108 open tiles connected; no keeper. All five final native suites finish cleanly after private fixture teardown. Four existing files changed, two helpers and eight native PNGs added;1087 other protected source/data/dialogue/UI files exact. Evidence, originals, patch and captures: '+rel+'/README.md. No new generation, paid call, balance/story/state-schema/training edit or commit. All October14 queue deliverables and both follow-up integrations are now installed/complete. Historical v3 recorder still assumes the old outside Storage panel and needs its shot adapted before rerunning; Claude-owned v3 tools/proposal art preserved.'
changes={}
start=R/'docs/team/CODEX_START_HERE_2026-10-14.md';raw=start.read_bytes();txt=raw.decode('utf-8-sig').replace('\r\n','\n');a=txt.index('## Current status\n');b=txt.index('\n## Read before work',a)
txt=txt[:a]+'## Current status\n\n'+status+'\n'+txt[b:]
txt=txt.replace("Storage art staged; dialogue corner correction installed; AI inventory refreshed. Claude's Storage integration remains pending.","Storage interior and dialogue corner correction installed; AI inventory refreshed. All five deliverables and their game integrations are complete.")
changes[start]=(raw,txt)
tasks=R/'docs/team/CODEX_TASKS_2026-10-14.md';raw=tasks.read_bytes();txt=raw.decode('utf-8-sig').replace('\r\n','\n');assert '3. **ART COMPLETE/STAGED:' in txt
txt=txt.replace('3. **ART COMPLETE/STAGED:','3. **DONE / INSTALLED:',1)+'\n\nCodex, October14 (Storage follow-up after Preston: "next"): '+status+'\n';changes[tasks]=(raw,txt)
collab=R/'docs/AI_COLLABORATION.md';raw=collab.read_bytes();txt=raw.decode('utf-8-sig').replace('\r\n','\n');title='# Working Together on Hollowtide\n';assert txt.startswith(title)
txt=txt.replace(title,title+'\n## Codex: Storage interior integrated and played (October14,2026)\n\n'+status+'\n',1);changes[collab]=(raw,txt)
handoff=R/'docs/team/CODEX_HANDOFF_2026-10-14_storage_art.md';raw=handoff.read_bytes();txt=raw.decode('utf-8-sig').replace('\r\n','\n');a=txt.index('\n')
txt=txt[:a]+'\n\n**Later same day: INSTALLED by Codex after Preston requested the next integration.** Room/door/counter/collision, sorted art and save-on-quit hook are live,53/53 staging/live assertions; see `'+rel+'/README.md`. Do not reapply the proposal. Original staging handoff below is preserved as history.\n'+txt[a:];changes[handoff]=(raw,txt)
inv=R/'docs/pitch/ai-asset-inventory.md';raw=inv.read_bytes();txt=raw.decode('utf-8-sig').replace('\r\n','\n')
pattern=r'^\| \*\*Storage interior, October 14\*\*.*\|$'
row=re.search(pattern,txt,re.M);assert row
oldrow=row.group()
newrow='| **Installed Storage interior**, `assets/sprites/world/storage_interior_2026_10_14/` | **AI-generated shell and six-prop source sheet**, from the earlier two built-in `image_gen.imagegen` edits; exact model/version **unknown**. [Original generation ledger/prompts](../world/storage-art-proposal-2026-10-14/generation-ledger.json), [native crops and preparation](../world/storage-art-proposal-2026-10-14/README.md), [live integration and checks](../world/storage-interior-installed-2026-10-14/README.md). Reuses generated Hall flooring, preserves seven finished source PNGs byte-exact, adds a code-authored shell mask and uses separate foot-sorted props with the existing shader once. No new generation during integration; existing exterior/service/data keep their provenance. No keeper added. |'
txt=txt.replace(oldrow+'\n','',1)
anchor=re.search(r'^\| \*\*Installed dialogue corner layout correction\*\*.*\|$',txt,re.M);assert anchor
txt=txt.replace(anchor.group(),anchor.group()+'\n'+newrow,1)
txt=txt.replace('the later installed dialogue offset or integration of the staged Storage room.','the later installed dialogue offset or Storage interior.')
changes[inv]=(raw,txt)
dst.mkdir(parents=True)
for name in ['prepare.py','import_art.py','drivers.py','run.py','audit.py','install.py','publish.py','storage_room_art.gd','protected.json','stage-audit.json','live-audit.json','changes.diff','imported-files.json','import-art.log']:
    shutil.copy2(W/name,dst/name)
for folder in ['prepared','originals','checks']:shutil.copytree(W/folder,dst/folder)
for phase in ['stage','live']:
    for p in (W/phase).rglob('*'):
        if p.is_file() and 'profile' not in p.relative_to(W/phase).parts:
            out=dst/p.relative_to(W);out.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,out)
for item in json.loads((W/'imported-files.json').read_text(encoding='utf-8')):
    assert sha(S/item)==sha(R/item),item
    out=dst/'native-imports'/item;out.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(S/item,out)
(dst/'.gdignore').write_text('',encoding='utf-8')
(dst/'README.md').write_text('''# Storage interior installed, October14,2026

The existing route-unlocked Storage now has a real room: enter its town door after Rootbank Warren, walk to the counter and press E. W/S selects, E puts one in, R takes one out, Escape closes. Walk through any of the three south threshold tiles to return beside the Storage door. No keeper or placeholder creature.

The native17x13/408x312 room uses the staged Hall-style shell and six finished props. All seven copied source PNGs are byte-exact; a new shell-only mask avoids applying prop detail to the floor. CPU rim is already baked into those copies; the shared0.75 shader is applied once. Seven separately drawn instances sort by their front-foot depths: cabinets112, counter156, crates264, basket260, lamps56. The imagegen originals and exact prompts remain untouched in [the original proposal](../storage-art-proposal-2026-10-14/README.md); this integration made no generator calls. It retains AI-generated art provenance, with AI-assisted native preparation and code hooks; exact image model unknown.

The room starts floor at row3, blocks the five proposed furniture bodies, keeps the three-tile central aisle, and opens all three exit tiles. All108 open tiles connect. The team uses the existing town creature size, footsteps/movement and foot sorting. Other rooms retain their original floor/exit defaults. `storage_room_art.gd` handles only art, `storage_panel.gd` shares the old panel/control bodies between hosts. Existing `Storage.open/rows/move`, unlock, parcel refusal, ten-kind cap, loss rules and TeamState save format are unchanged. The panel keeps its166,64 origin and current row layout.

Moving the service indoors needed one pause-menu condition: Storage now calls the same `_record`/`autosave` path as Highbank on Return to title or Quit. Without it, a player could leave the new room before town arrival saved the last deposit. The actual pause Return to title and title Continue were verified with a private save; no new save format or suspend rule.

## Verification

**53/53 staging and53/53 installed live assertions:** updated production Storage11, actual room/keyboard route20, real pause/Continue5, Home/Hall4, Hall-floor links/NPC13. `stage-audit.json`/`live-audit.json` name the exact selected logs and diagnostics. `live/integration/` contains entry, counter panel, behind/front sorting and town-return captures. The three-member party spawns on distinct open tiles; actual E/R/W/S/Escape and walked left exit work, and the right exit is checked too. Actual automatic town-arrival save and pause/Continue restore stored counts.

All five final native suites have clean logs. An earlier Hall run reported a shutdown warning for2 ObjectDB instances/1 resource still in use; the final staged and live native runs with private persistent-music teardown are clean. One staged native Hall window exited before producing assertions; its incomplete log was not counted. The headless Hall attempt passed its assertions but emitted existing shader-helper compilation diagnostics; it is not the visual verification. The final clean native Hall log is selected explicitly by the audit; earlier diagnostics remain archived as separate attempts.

Early attempts are preserved: missing explicit Dictionary type in the extracted helper; copied UI sound function needed its `last_sfx` field; route fixture initially omitted `TeamState.give_to` for its third party member and looked up a prop by a float-formatted node name; Continue fixture initially pressed before title boot completed. Fixed before the final passing runs. The production service check now uses its own save path from the beginning and frees its owned persistent music at teardown. Native runs use isolated APPDATA/LOCALAPPDATA, Dummy audio, fixed30fps and own only their subprocess; no real save or user editor/training process was touched.

Four existing files change: `hub_town.gd`, `town_room.gd`, one condition in `game_pause_menu.gd`, and `tools/debug/storage_check.gd`. Two new helpers, eight native PNGs and native import metadata/cache installed. All1087 other protected existing source/data/dialogue/UI files exact; prior Parcel Board hook, water finish, shared dialogue correction, Storage rules, creature/rule/state files and Claude's other proposals preserved. See `originals/`, `changes.diff`, `prepared/` and hash receipts. No commit or export-package test.

## Play and reproduce

F5 the live game; after the Warren road is clear, use the Storage building's door and walk north to the counter. Existing saves need no migration. Generic `town_room.tscn` still defaults to Home when run alone; enter Storage through town to use its room id.

Work folder `D:/dev/hollowtide-storage-integration-20261014`; stage `D:/dev/hollowtide-world-refinement-20261008/project`. `run.py integration --live`, `run.py storage_check --live`, `run.py quit_check --live`, `run.py town_room_check --live`, `run.py hall_floors_check --live` reproduce checks; omit --live for stage. Drivers retain their original work output paths, with separate profiles and archived prior logs. `prepare.py`/`install.py` record and guard pre-install originals; do not rerun them blindly against an installed/changed checkout. `native-imports/` records eight lossless/no-mipmap imports from a minimal project, without a full game editor scan. No new image-generation skill needed: existing finished PNGs were copied exactly.

**Remaining development-tool limitation:** the historical Claude-owned `record_pitch_v3.gd` Storage segment still expects the outside-door panel and keeps a reference to that town scene. It needs an adapted room/counter shot before recording again. The old v3 MP4s/GIFs remain valid historical captures; no v3 tool or footage was overwritten, per the queue's preservation rule. A new capture should use a new version and include the current Parcel, water, dialogue and Storage visuals.

All October14 queue deliverables and both follow-up integrations are complete. Original proposal archives are preserved with their earlier pending wording; current start-here and inventory supersede those statuses. No message to another chat or new paid call. Preston's visual review remains his.

![Installed counter and party](live/integration/4_front_counter.png)
''',encoding='utf-8')
for p,(raw,txt) in changes.items():
    saved=dst/'original-docs'/p.relative_to(R);saved.parent.mkdir(parents=True,exist_ok=True);saved.write_bytes(raw)
for p,(raw,txt) in changes.items():
    assert p.read_bytes()==raw,'Concurrent documentation edit; stop.'
    nl='\r\n' if b'\r\n' in raw else '\n';p.write_bytes(txt.replace('\n',nl).encode('utf-8'))
newhandoff=R/'docs/team/CODEX_HANDOFF_2026-10-14_storage_installed.md';assert not newhandoff.exists()
newhandoff.write_text('# Storage interior installed\n\n'+status+'\n',encoding='utf-8')
for r,h in receipt['installed_file_hashes'].items():assert sha(R/r)==h
links=0
for label,ref in re.findall(r'\[([^\]]+)\]\(([^)]+)\)',inv.read_text(encoding='utf-8')):
    if ref.startswith(('https://','http://')):continue
    assert (inv.parent/ref.split('#')[0]).resolve().exists(),ref;links+=1
manifest={p.relative_to(dst).as_posix():sha(p) for p in dst.rglob('*') if p.is_file()}
(dst/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print('Published',len(manifest),'evidence files;',links,'inventory links resolve; Storage integration complete.')
