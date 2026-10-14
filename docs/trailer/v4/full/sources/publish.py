from pathlib import Path
import hashlib,json,shutil,sys
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');D=W/'delivery-final';T=W/'take3';F=R/'docs/trailer/v4/full'
def sha(p):
    h=hashlib.sha256()
    with p.open('rb') as f:
        for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
    return h.hexdigest()
def write(p,text):
    p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(text.replace('\r\n','\n').replace('\n','\r\n').encode('utf-8'))
baseline=json.loads((W/'protected.json').read_text(encoding='utf-8'))
mode=sys.argv[1]
if mode=='install':
    verification=json.loads((D/'verification.json').read_text());assert verification['visual_review']=='passed'
    changed=[rel for rel,h in baseline.items() if sha(R/rel)!=h];assert not changed,changed
    assert not F.exists();assert not (R/'tools/trailer/cut_pitch_v4.py').exists()
    assert sha(T/'recorded-script.gd')==sha(W/'prepared/tools/trailer/record_pitch_v4.gd')
    F.mkdir(parents=True);write(F/'.gdignore','')
    for p in D.iterdir():
        if p.is_file():shutil.copy2(p,F/p.name)
    shutil.copytree(D/'qa',F/'qa')
    for name in ['raw.avi','shot-markers.json','record.log','recorded-script.gd','process.json','parse.log','parse-process.json']:
        target='capture-process.json' if name=='process.json' else name
        shutil.copy2(T/name,F/target)
    (F/'native-stills').mkdir()
    for p in T.glob('*.png'):shutil.copy2(p,F/'native-stills'/p.name)
    (F/'sources').mkdir()
    for name in ['original-record_pitch_v4.gd','original-cut_pitch_v3.py','prepare.py','refine.py','polish.py','prepare_cut.py','record.py','cut.py','verify.py','publish.py','installed_parse.py','protected.json','flood.gdpart']:
        shutil.copy2(W/name,F/'sources'/name)
    shutil.copy2(R/'tools/trailer/record_pitch_v4.gd',F/'sources/original-record_pitch_v4-bytes.gd')
    shutil.copy2(R/'tools/trailer/cut_pitch_v3.py',F/'sources/original-cut_pitch_v3-bytes.py')
    shutil.copy2(W/'prepared/tools/trailer/cut_pitch_v4.py',F/'sources/final-cut_pitch_v4.py')
    inputs=['docs/design/videos-2026-10-11/01_storm_open.mp4','docs/design/videos-2026-10-11/03_ruin_rises.mp4','docs/trailer/v2/hollow.avi','assets/audio/music/hollow_flute.mp3','assets/sprites/menu/creature_village_2026_10_09.png','assets/fonts/Jersey10-Regular.ttf','assets/fonts/AlegreyaSansSC-Bold.ttf']
    (F/'source-inputs.json').write_text(json.dumps({rel:{'sha256':sha(R/rel),'bytes':(R/rel).stat().st_size} for rel in inputs},indent=2),encoding='utf-8')
    for take in ['take1','take2']:
        folder=F/'diagnostics'/take;folder.mkdir(parents=True)
        for name in ['record.log','recorded-script.gd','shot-markers.json','process.json']:
            if (W/take/name).exists():shutil.copy2(W/take/name,folder/name)
    for rel in ['tools/trailer/record_pitch_v4.gd','tools/trailer/cut_pitch_v4.py']:
        p=W/'prepared'/rel
        # Preserve the existing file's newline convention.
        original=R/rel
        b=p.read_bytes()
        if original.exists() and b'\r\n' in original.read_bytes():b=b.replace(b'\r\n',b'\n').replace(b'\n',b'\r\n')
        original.write_bytes(b)
    assert (R/'tools/trailer/record_pitch_v4.gd').read_text(encoding='utf-8')==(F/'recorded-script.gd').read_text(encoding='utf-8')
    print('Installed V4-only tools and full evidence. Docs await installed parse check.')
elif mode=='docs':
    parse=(F/'installed-parse.log').read_text(encoding='utf-8');assert 'Godot Engine v4.7.2' in parse and 'ERROR' not in parse and 'WARNING' not in parse
    v=json.loads((F/'verification.json').read_text());m=v['media']['hollowtide_pitch_v4.mp4'];s=v['media']['hollowtide_pitch_v4_share.mp4']
    seconds=m['seconds'];peak=v['audio_sample_peak_db'];frames=m['frames']
    summary=(f'Full V4 pitch COMPLETE: {seconds:.3f}s,1920x1080/30fps H.264/AAC, {frames} frames; full and {s["bytes"]/1000000:.1f}MB share MP4s in docs/trailer/v4/full/. Nine current native engine segments passed26/26 capture checks, including fresh flood portraits, Parcel, painted water, defeat, real indoor Storage deposit/withdraw, growth and Warden/stone return. The27-shot edit retains three historical storm/ruin/V2-combat cutaways plus existing title painting, proposed cards and Suno-origin hollow_flute music; it is staged private-state footage, not an uninterrupted playthrough or generative video. Full/share streams decode cleanly; all27 shots reviewed at start/middle/end; audio sample peak{peak:.1f}dBFS. Updated only the V4 recorder, added its marker-based cutter; installed parse check clean. All581 other protected files exact, including V3 and the earlier Storage-shot outputs. Raw take, frame markers, exact edit commands, source/provenance records and QA: docs/trailer/v4/full/README.md. Original October14 queue and both game integrations remain complete. No core game/rule/save-format edits, new generation, paid calls, training change, export, posting or commit.')
    rels=['docs/team/CODEX_START_HERE_2026-10-14.md','docs/team/CODEX_TASKS_2026-10-14.md','docs/AI_COLLABORATION.md','docs/pitch/ai-asset-inventory.md','docs/pitch/pitch-kit.md']
    updates={}
    for rel in rels:
        p=R/rel;backup=F/'sources'/'before-docs'/rel;backup.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,backup)
        t=p.read_text(encoding='utf-8')
        if 'START_HERE' in rel:
            a=t.index('## Current status\n')+len('## Current status\n');b=t.index('## Read before work',a);t=t[:a]+'\n'+summary+'\n\n'+t[b:]
        elif 'CODEX_TASKS' in rel:t+='\n\nCodex, October14: '+summary+'\n'
        elif 'AI_COLLABORATION' in rel:
            first=t.index('\n')+1;t=t[:first]+'\n## Codex: full V4 pitch recorded and edited (October14,2026)\n\n'+summary+'\n'+t[first:]
        elif 'ai-asset-inventory' in rel:
            old='The full eight-segment V4 branch is parse-checked only, not recorded or cut into a new full pitch.'
            assert old in t;t=t.replace(old,'This was the initial Storage-only deliverable; the later full V4 recording/edit is documented in the next row.',1)
            needle='\nThese October 12 recordings predate'
            row=(f'| **Full pitch V4**, October14 | [Full MP4](../trailer/v4/full/hollowtide_pitch_v4.mp4), [share MP4](../trailer/v4/full/hollowtide_pitch_v4_share.mp4): **{seconds:.3f}s,1920x1080,30fps,{frames} frames,H.264/AAC**. Nine freshly recorded native segments pass26/26 checks and show the installed Parcel, water, shared portrait layout and indoor Storage. The27-shot edit also uses three retained October11 storm/ruin and V2 combat clips, existing generated end painting, proposed cards and Suno-origin `hollow_flute`; exact model versions remain unknown where recorded above. **Recorded engine rendering and AI-assisted GDScript/Python/Pillow/FFmpeg capture/editing**, no new generative video/image/audio. Private scripted state and scene transitions; not an uninterrupted player run. [Raw, markers, provenance, exact edit commands and QA](../trailer/v4/full/README.md); [V4 recorder](../../tools/trailer/record_pitch_v4.gd), [cutter](../../tools/trailer/cut_pitch_v4.py). Both streams decode cleanly; all27 shots visually reviewed. V3, its GIFs and earlier Storage-only outputs are preserved. |\n')
            assert needle in t;t=t.replace(needle,row+needle,1)
        elif 'pitch-kit' in rel:
            old=('`docs/trailer/v3/hollowtide_pitch_v3.mp4` (102 s, 2026-10-12; the `_share` copy is the one to send; card lines\nare proposals in `tools/trailer/cut_pitch_v3.py`).')
            new=(f'[V4 share MP4](../trailer/v4/full/hollowtide_pitch_v4_share.mp4) ({seconds:.3f} s, 2026-10-14;\n[full MP4 and capture/QA notes](../trailer/v4/full/README.md); card lines remain proposals in\n`tools/trailer/cut_pitch_v4.py`). V4 adds current Parcel, painted water, shared portraits and indoor Storage,\nwith nine freshly staged engine segments and three retained storm/ruin/V2-combat cutaways. It is an edited\nprivate-state capture; V3 remains preserved as history.')
            assert old in t;t=t.replace(old,new,1)
        updates[rel]=t
    changed=[rel for rel,h in baseline.items() if rel!='tools/trailer/record_pitch_v4.gd' and sha(R/rel)!=h];assert not changed,changed
    for rel in updates:assert sha(R/rel)==sha(F/'sources'/'before-docs'/rel),f'Concurrent documentation change: {rel}'
    for rel,t in updates.items():write(R/rel,t)
    write(R/'docs/team/CODEX_HANDOFF_2026-10-14_full_pitch.md','# Full V4 pitch handoff, October14,2026\n\n'+summary+'\n\nBest preview: [V4 share MP4](../trailer/v4/full/hollowtide_pitch_v4_share.mp4). Evidence/reproduction: [full V4 README](../trailer/v4/full/README.md).\n\nNo mandatory October14 Codex queue work remains. Outside playtests, publisher decisions and posting remain Preston\'s; no chat or external site was messaged. Preserve Claude\'s concurrent creature proposals and training workspace.\n')
    readme=f'''# Hollowtide full pitch V4 — October14,2026

[Play the share MP4](hollowtide_pitch_v4_share.mp4) · [Full-quality MP4](hollowtide_pitch_v4.mp4)

Completed under Preston's “go” after the checked Storage-only shot. Both outputs: **{seconds:.3f}s,1920x1080,30fps,H.264/AAC,{frames} frames**. Full {m['bytes']/1000000:.1f}MB; share {s['bytes']/1000000:.1f}MB. No external post, upload, export or commit.

## What is in the edit

Nine new native Godot Movie Maker segments: flood partner conversation using the corrected shared portrait layout; title/Continue; mail call; Job Board with actual Parcel; painted rising water; defeat and information; installed Storage room with real walking/deposit/withdraw/exit; shrine growth; awake Warden stand-off and stone carried home. The party is Kithflare, Tallowroot and Cutbank Listener in the staged main shots. The recorder sets private scene/team/story state and uses an isolated user profile/save; this is **edited staged engine footage**, not an uninterrupted playthrough or balance test.

The27-shot edit also keeps three historical cutaways: `docs/design/videos-2026-10-11/01_storm_open.mp4` (start1.6s), `03_ruin_rises.mp4` (start0.6s), and `docs/trailer/v2/hollow.avi` (start28.3s). The cold storm retains game sound. The music bed is existing `assets/audio/music/hollow_flute.mp3` (“Hollow in the Cottonwoods”, Suno origin; exact model/version unknown). The existing generated village painting, proposed V3 text cards and OFL fonts remain. Visible generated assets and narrative retain their [AI inventory classifications](../../../pitch/ai-asset-inventory.md); the new filming/editing is AI-assisted GDScript/Python/Pillow/FFmpeg work, with **no new image/audio/video model output or paid calls**.

## Verification

- Native take3: **26/26 checks**, nine segments, clean finalized log;9680 raw frames/322.667s at1152x648/30fps. Engine prints RECORDED9679 before its final frame. [Raw AVI](raw.avi), [capture log](record.log), [frame markers/checks](shot-markers.json), [actual recorded source](recorded-script.gd), [exact native command/profile](capture-process.json).
- Source ranges resolve against measured markers and segment bounds, rather than V3's timing. [Timeline/source paths](edit-timeline.json); [exact encoder commands](edit-commands.json). Planned44 bars/99.622642s; encoded duration is measured above, including frame/audio rounding.
- Full and share streams decoded end-to-end without errors; codec/FPS/frame counts checked. [Verification](verification.json), [raw ffprobe records](media-probes.json), [QA commands](verification-commands.json). Audio sample peak **{peak:.1f}dBFS**, mean{v['audio_mean_db']:.1f}dBFS; mixer loudnorm target-18LUFS/true peak-2dB. No listening-session claim: audio verified through source continuity, mix commands and numerical analysis.
- All27 final shots reviewed at start/middle/end, plus native key frames: [middle1](qa/contact-middle-1.jpg), [middle2](qa/contact-middle-2.jpg), start/end sheets and individual samples in `qa/`; native scene PNGs in `native-stills/`. Shoreline capture framing keeps the party above the bottom HUD. End fade to black is intentional.
- [Installed recorder parse check](installed-parse.log) clean. Only existing V4 recorder updated; new V4 cutter added. All581 other protected source/media files exact, including V3/four GIFs/Storage-only media; [protection receipt](protection-receipt.json), [before hashes](sources/protected.json). No core game/rule/save schema change. Original V4 and V3 cutter plus pre-edit docs retained in `sources/`.

## Capture timing repairs and evidence

The first full take exposed old fixed mail/Warden windows ending before the scenes. Take2 completed both scenes but checked the return during its deferred transition. The recorder now waits for mail completion, advances actual typed pages with a hold, allows the Warden scene to finish, and waits six frames for the town scene. Take3 passes every check. A private shore placement/camera adjustment clears the HUD; no production camera or water rule changes. The first edit's visual review caught a black Continue fade; the final edit uses two measured title/town excerpts around that transition. That review edit remains at `D:/dev/hollowtide-full-pitch-v4-20261014/delivery`; final outputs came from `delivery-final`. Diagnostic logs/source snapshots are in `diagnostics/`; failed raw takes remain at `D:/dev/hollowtide-full-pitch-v4-20261014/take1` and `take2`, not published as successful captures.

## Reproduce without overwriting this deliverable

Installed tools: [recorder](../../../../tools/trailer/record_pitch_v4.gd), [cutter](../../../../tools/trailer/cut_pitch_v4.py), derived from preserved V3. Capture with the exact command in `capture-process.json`, substituting a fresh output/profile/review directory and the installed V4 script. Use Godot4.7.2, Compatibility renderer, Dummy audio, fixed30fps; set `HT_CAPTURE_REVIEW` to that fresh directory. Keep APPDATA/LOCALAPPDATA isolated. The recorder also supports `-- --storage-only`; the earlier dedicated [Storage shot](../storage-shot/README.md) remains untouched.

For a new cut, set `HT_PITCH_ROOT` to the live repo, `HT_PITCH_OUT` to a **fresh** directory, `HT_PITCH_RAW` to this `raw.avi`, and `HT_PITCH_MARKERS` to this `shot-markers.json`, then run the installed cutter with Python/Pillow and FFmpeg/ffprobe. It refuses existing final MP4 paths. `sources/` preserves the actual preparation/record/cut/verification drivers; their D-work paths are historical execution evidence. `_work` intermediate encodes remain in the D workspace and can be regenerated. The README's measured facts and JSON evidence supersede old timing assumptions.
'''
    write(F/'README.md',readme)
    receipt={'protected_total':len(baseline),'unchanged':len(baseline)-1,'allowed_existing_change':'tools/trailer/record_pitch_v4.gd','unexpected_changes':changed,'new_tool':'tools/trailer/cut_pitch_v4.py','v4_recorder_installed_sha256':sha(R/'tools/trailer/record_pitch_v4.gd'),'recorded_script_sha256':sha(F/'recorded-script.gd'),'v4_cutter_sha256':sha(R/'tools/trailer/cut_pitch_v4.py'),'docs_updated':list(updates),'native_parse':'passed','real_save_and_core_game_source':'unchanged; isolated private capture profile','new_generation_paid_calls_external_posts_commits':False}
    (F/'protection-receipt.json').write_text(json.dumps(receipt,indent=2),encoding='utf-8')
    # Copied/published media must match the reviewed D outputs.
    for name,info in v['media'].items():assert sha(F/name)==info['sha256'],name
    print(json.dumps(receipt,indent=2));print('PUBLISHED',F)
else:raise ValueError(mode)
