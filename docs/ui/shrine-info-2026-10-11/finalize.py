from pathlib import Path
import hashlib,json,shutil,re
W=Path(__file__).parent
C=Path('C:/Users/pmcga/dev/hollowtide')
for mode,expected in [('check','SHRINE INFO: 27/27 passed'),('evolution_check','RESULT: evolving at the Growth Shrine works'),('field_menu_check','RESULT: field menu works'),('hub_town_check','Places: 12 of 12 answered E from their door')]:
    log=(W/f'live-{mode}.log').read_text(encoding='utf-8')
    assert expected in log,(mode,log[-1000:])
    assert not any(x in log for x in ['SCRIPT ERROR','ERROR:','FAIL','WRONG']),mode
owned=['scripts/town/hub_town.gd','scripts/ui/shrine_info.gd']
assert (C/owned[1]).read_bytes()==(W/'shrine_info.gd').read_bytes()
old=(W/'originals/live-before-install-hub_town.gd').read_bytes().decode().replace('\r\n','\n')
text=(C/owned[0]).read_bytes().decode().replace('\r\n','\n')
reverse=text.replace('\n\tpreload("res://scripts/ui/shrine_info.gd").attach(self)','').replace('\tif get_node("ShrineInfo").poll():\n\t\treturn\n','').replace('\tif panel.get("service", "") in ["growth", "stone_ask", "evolve_ask"]:\n\t\treturn # The browsable ShrineInfo panel owns this presentation.\n','')
assert reverse==old,'Concurrent town change: preserve it and refresh the audit.'
protected=json.loads((W/'protected-before-install.json').read_text())
audit={p:{'before':h,'after':hashlib.sha256((C/p).read_bytes()).hexdigest()} for p,h in protected.items()}
(W/'preservation-audit.json').write_text(json.dumps(audit,indent=2),encoding='utf-8')
(W/'installed-hashes.json').write_text(json.dumps({p:hashlib.sha256((C/p).read_bytes()).hexdigest() for p in owned},indent=2),encoding='utf-8')
archive=C/'docs/ui/shrine-info-2026-10-11'
archive.mkdir(parents=True,exist_ok=True)
for file in W.iterdir():
    if file.is_file():shutil.copy2(file,archive/file.name)
shutil.copytree(W/'originals',archive/'originals',dirs_exist_ok=True)
shutil.copy2(C/owned[0],archive/'installed-hub_town.gd')
collab=C/'docs/AI_COLLABORATION.md'
source=collab.read_bytes()
body=source.decode('utf-8')
assert '## Codex: Growth Shrine information screen (October 11, 2026)' not in body
note='''## Codex: Growth Shrine information screen (October 11, 2026)

Preston said go from the current start-here handoff. Installed job4: browsable team portraits, level/IQ/next form and four condition bars, plus separate Moves page for known kits/current and next-form LEARN, unavailable WAITING moves and queued next-run choices. Existing pixel frames and shared creature finish; no new art or rule numbers. New ui/shrine_info helper and three small hub_town hooks only. Preserved current world/Hall/exterior art, pond-stone gate, stone installation, evolution animation/results, moves/body rules, save/state and Claude's current code. Default ready confirmation remains; selecting another teammate offers only the existing Evolution.ready result.

Native checks26/26 staging; final live27/27 including cutscene input priority. Real keyboard and mouse, scrolling, all current forms, final/unfinished/empty states, condition fit, portrait clipping, stone installation, full-kit evolution and queued next-run move all pass. Current town routes/services/Hollow entry, existing evolution and field-menu checks pass. Protected hashes/audit, originals, exact hooks, native images and private drivers: [Shrine information handoff](ui/shrine-info-2026-10-11/README.md). This completes the formerly pending Shrine information job; the exterior/evolution work from October10 remains intact. Visual proposal for Preston's review. Codex is out of hub_town; no commit, reset, stash, revert or paid generation.

'''
first,rest=body.split('\n',1)
updated=first+'\n\n'+note+rest.lstrip('\r\n')
assert collab.read_bytes()==source
collab.write_text(updated,encoding='utf-8',newline='')
start=C/'docs/team/CODEX_START_HERE_2026-10-11.md'
source=start.read_bytes()
body=source.decode('utf-8').replace('\r\n','\n')
shutil.copy2(start,archive/'originals/CODEX_START_HERE_before.md')
body=body.replace("Preston's latest requests: finish sel-out on the world, then prepare a new-chat handoff to save usage. The preceding request was detail/sel-out on Claude's rebuilt Wayline Hall wiring. Both visible slices are installed. Do not redo finished work or overwrite Claude's concurrent code.","Preston's latest completed request: continue from this handoff and finish the Growth Shrine information screen (job4). It is installed and verified, alongside the finished Highbank world sel-out and rebuilt Wayline Hall. Do not redo finished work or overwrite Claude's concurrent code.")
body=body.replace('## Latest completed work\n','## Latest completed work\n\n**Growth Shrine information screen:** new `scripts/ui/shrine_info.gd` plus three small `hub_town` hooks. Browsable team portraits, level/IQ/next form/four condition bars, Growth and Moves pages, current/next LEARN, unavailable WAITING and queued next-run choices, using existing frames and creature finish. Pond-stone gate, stone installation, evolution and rules unchanged. Native26/26 staging; final live27/27, plus current town/evolution/field-menu checks. Full handoff/evidence: `docs/ui/shrine-info-2026-10-11/README.md`. Codex is out of hub_town; no generation or commit.\n')
body=re.sub(r'(## Next when Preston says “next”\n\n).*?(\n\nThe user wants)',r'\1Inspect the newest handoff and collaboration entries first. The Growth Shrine detailed information screen (handoff job4) is now finished and installed. Its exterior and evolution presentation were completed October10, and its new information view is in `docs/ui/shrine-info-2026-10-11/README.md`. Do not reinstall stale Shrine staging scripts or regenerate its exterior. No further visual task is selected in this handoff; follow Preston\'s latest direction and verify current Claude work before choosing the next slice.\2',body,flags=re.S)
assert start.read_bytes()==source
start.write_text(body,encoding='utf-8',newline='')
print('Archived native evidence and updated current handoff. Protected sources with concurrent changes:',[p for p,h in audit.items() if h['before']!=h['after']])
