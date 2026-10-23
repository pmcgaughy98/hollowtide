from pathlib import Path
import hashlib,json,shutil,sys
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');F=R/'docs/art/canvaswing-diagonal-walk-2026-10-22';B=json.loads((W/'protected-before.json').read_text());I=json.loads((W/'installed-files.json').read_text());external=json.loads((W/'concurrent-at-install.json').read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,t):p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(t.replace('\r\n','\n').replace('\n','\r\n').encode('utf-8'))
assert all(sha(R/rel)==h for rel,h in I.items())
for stage in ['candidate','live']:
    log=(W/('native-'+stage+'.log')).read_text(encoding='utf-8');assert 'CANVASWING WALK: 64/64' in log and not any(x in log for x in ['ERROR','WARNING','FAIL'])
changes=[rel for rel,h in B.items() if sha(R/rel)!=h and rel not in I]
assert all(rel.startswith('scripts/') for rel in changes),changes
assert not F.exists();F.mkdir(parents=True);write(F/'.gdignore','')
for folder in ['review','references','native-candidate','native-live','original-installed','concurrent-at-install','raw-builder-output']:
    shutil.copytree(W/folder,F/folder)
for name in ['source_inventory.py','prepare.py','finish_preparation.py','build.py','rebuild_finished.py','build_final.py','install.py','import_assets.py','native_check.gd','run_native.py','publish.py','preparation.json','generation-ledger.json','generated-raw.png','protected-before.json','final-build.json','build-comparison.json','finished-build.json','installed-files.json','concurrent-at-install.json','native-candidate.log','native-live.log','native-candidate-command.json','native-live-command.json','import.log','import-command.json']:
    shutil.copy2(W/name,F/name)
for rel in I:
    dst=F/'installed'/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(R/rel,dst)
for rel in changes:
    dst=F/'concurrent-at-finish'/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(R/rel,dst)
unaffected=len(B)-len(I)-len(changes)
receipt={'date':'2026-10-22','task':1,'installed_files':I,'protected_total':len(B),'unchanged_other_files':unaffected,'concurrent_source_changes_preserved':{rel:sha(R/rel) for rel in changes},'native_candidate':'64/64','native_live':'64/64','first_three_source_frames':'exact original RGBA','runtime_unselected':'all stills, other facings/actions and diagonal f0-f2 exact original bytes','new_colour_range':[18,23],'generation_calls':1,'tool':'built-in image_gen.imagegen','model_version':'not exposed','external_paid_calls':0,'commits':0}
(F/'receipt.json').write_text(json.dumps(receipt,indent=2),encoding='utf-8')
source_issues=('Source issues for Claude: rebuilding current recoloured sheets/stills does not reproduce the installed palette pixel choices (216 set PNGs differ), and rebuilding from the preserved pre-recolour inputs plus the old colour transform still differs. This pass keeps all unselected installed bytes and locks only the30 changed rebuild outputs to installed f0-f2 palette colours. Please document/unify the complete finishing order before a bulk rebuild; do not replace the approved sets with a bare builder run. Generated walk jobs also need per-frame body/edge/colour checks before being accepted: the original job was nominally eight frames but five were damaged. The headless editor import also reports Dialogue Manager theme_values.gd:51 Nil-to-int errors and an unresolved default-audio-bus UID (uid://blm6ps3r8bf7l); process exit0 and reimport completes, but that import log is not clean. Final native live resources match all48 candidate PNGs pixel-for-pixel and the runtime64/64 log is clean. No game-source fix was made for these editor-only diagnostics.')
summary=(f'Task1 COMPLETE/INSTALLED: Canvaswing SE source frames f3-f7 replaced with five complete poses matching the intact f0-f2; SW rebuilt as exact mirrors. Original source f0-f2 RGBA and every unselected runtime sprite remain exact. Rebuilt dungeon/town/small with the current named builders (town --set=town --scale=1.5; small scale0.95), retaining installed palette colours on the30 changed frames. All repaired runtime frames have clear edges, opaque body mass within the good-frame range and18-23 colours. Native64/64 candidate plus64/64 installed live:48 diagonal textures and16 actual Rootbank animation selections across even/odd steps. Originals, one built-in imagegen raw/prompt, source/PNG hashes, builders, native logs/captures and slowed before/after GIF: docs/art/canvaswing-diagonal-walk-2026-10-22/README.md. {unaffected} other protected files exact; {len(changes)} concurrent script edits preserved and archived, including title/settings edits made by another session. No game code, rules, save, paid external call or commit by this pass. Task2, Skimlet/Ozbender/Valvekin portraits, is next; tasks3/4 have concurrent source edits and are not claimed checked or completed here.')
readme=f'''# Canvaswing diagonal walk repaired, October 22, 2026

[Before / after, slowed](review/before-after.gif) · [Dungeon loop](review/dungeon-walk.gif) · [Town loop](review/town-walk.gif) · [Small loop](review/small-walk.gif)

Task1 of [Claude's October22 queue](../../team/CODEX_TASKS_2026-10-22.md) is installed. Source SE f3-f7 are five complete new poses; source f0-f2 remain exact RGBA. Dungeon/town/small SE and mirrored SW f3-f7 account for30 changed runtime PNGs. No duplicate-f1 shortcut or remaining slab/ghost frame. Existing dimensions are39x39,59x59 and41x41. All stills, action frames, other directions and diagonal f0-f2 are exact original files.

## Art and provenance

One built-in `image_gen.imagegen` edit used the original4x2 sheet, enlarged three intact frames and the approved SE still as references. [Exact prompt/ledger](generation-ledger.json), [unmodified generated output](generated-raw.png), [original source/contact](references/original-contact-2x.png). Exact image-model version is not exposed by the tool. The five generated cells were cropped, reduced to native128px cells, alpha hardened and locked to the existing26-colour good-frame source palette; the original first three cells were copied back unchanged. This remains AI-generated source art with AI-assisted preparation, not human-drawn art or a new creature design.

The source sheet remains512x256 in the original4x2 layout. Native generated frames have24 colours, complete bodies and at least17px margins. Runtime frames have18-23 colours and278-695 opaque pixels according to set, versus the old outline-only ghosts and full-frame tan square. The exact per-frame measurements are in [final-build.json](final-build.json); boundaries and SE/SW mirrors are asserted. Preview GIFs are enlarged and slowed for review; they do not change game timing.

## Build and preservation

The unchanged builders were run for Canvaswing only:

```text
python tools/arena/build_dungeon_set.py canvaswing
python tools/arena/build_dungeon_set.py canvaswing --set=town --scale=1.5
python tools/arena/build_small.py canvaswing
```

Current small scale is0.95; dungeon mass target and town1.5 factor remain unchanged. A bare rebuild differs in palette choices from the installed finish, so only the30 repaired results were palette-locked to the installed f0-f2 colour sets; all unselected rebuilt PNGs were restored from fresh originals. [Actual commands, selected paths and metrics](final-build.json). No builder, actor, gameplay or material code changed.

[Receipt](receipt.json):31 installed files including the source sheet; {unaffected} other protected files exact. {len(changes)} concurrent script changes were detected before installation, preserved and separately archived. Installed files are guarded by their original hashes. `original-installed/` is the exact replaced scope; `installed/` is the final scope. No stash/reset/commit or external paid generation call.

## Native verification

Godot4.7.2, OpenGL Compatibility, fixed30fps, isolated APPDATA/LOCALAPPDATA and private save:

- **64/64 candidate and64/64 installed live**, with clean final logs.
- All48 SE/SW textures across the three sets load and retain visible body/transparent margins; native material gallery reviewed: [live sets](native-live/sets.png).
- A real private Rootbank instance creates Canvaswing through `_make(8,0,1,...)`. Its actual `_process` and `_set_tex` select all16 expected textures: frames0-3 on even turns and4-7 on odd turns, both diagonals. Candidate textures were injected only in the private fixture; final live verification loads installed `res://` resources after import.
- [Rootbank actor](native-live/rootbank-actor.png), [native driver](native_check.gd), [live log](native-live.log), [live command/profile](native-live-command.json), [import log](import.log). No natural dungeon-clear or full pilot-chain claim.

## Source issues for Claude

{source_issues}

## Reproduction and earlier diagnostics

The actual source-generation prompt and raw image are preserved. `finish_preparation.py` records native slicing/palette/alpha preparation from the raw; `build_final.py` records the successful builders, bounded palette preservation, unselected-file restoration and review exports. `prepare.py`/`build.py`/`rebuild_finished.py` preserve earlier staging attempts and the palette-reproduction mismatch, not successful baseline claims. A scratch file initially called `inspect.py` shadowed Python's standard module; it was renamed `source_inventory.py` before the successful preparation. No failed staging output was installed. Use a fresh D-work folder and retain the original scope snapshots when reproducing; do not bulk-copy scratch sets into live.

Task2 portraits are next. Title Options/settings files changed concurrently during this art pass; those tasks are not marked verified here. All artwork still follows Preston's review authority.
'''
write(F/'README.md',readme)
for rel in ['docs/team/CODEX_TASKS_2026-10-22.md','docs/AI_COLLABORATION.md','docs/pitch/ai-asset-inventory.md']:
    p=R/rel;backup=F/'before-docs'/rel;backup.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,backup);t=p.read_text(encoding='utf-8')
    if 'CODEX_TASKS' in rel:t+='\n\n## Codex result, October22: task1\n\n'+summary+'\n\n'+source_issues+'\n'
    elif 'AI_COLLABORATION' in rel:
        first=t.index('\n')+1;t=t[:first]+'\n## Codex: Canvaswing diagonal walk repaired (October22,2026)\n\n'+summary+'\n\n'+source_issues+'\n'+t[first:]
    else:
        needle='## Current player-facing content';assert needle in t
        note='October22 addition: **Canvaswing SE walk source f3-f7 and30 derived SE/SW dungeon/town/small frames** use one built-in `image_gen.imagegen` edit, with the existing three good poses and still as references. Exact model/version is not exposed. Native crops, palette lock and unchanged builders/installed-palette preservation are AI-assisted preparation; the new pose source remains AI-generated. Original three source frames and all unselected artwork are preserved. [Prompt, raw output, original snapshots and native verification](../art/canvaswing-diagonal-walk-2026-10-22/README.md).\n\n'
        t=t.replace(needle,note+needle,1)
    assert sha(p)==sha(backup),rel;write(p,t)
write(R/'docs/team/CODEX_HANDOFF_2026-10-22_canvaswing_walk.md','# Canvaswing diagonal walk handoff, October22,2026\n\n'+summary+'\n\n'+source_issues+'\n')
assert all(sha(R/rel)==h for rel,h in I.items())
print(json.dumps(receipt,indent=2));print('PUBLISHED',F)
