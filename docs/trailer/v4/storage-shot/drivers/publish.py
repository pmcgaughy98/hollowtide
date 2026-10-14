from pathlib import Path
import json,hashlib,shutil,re
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):
    h=hashlib.sha256()
    with p.open('rb') as f:
        for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
    return h.hexdigest()
protected=json.loads((W/'protected.json').read_text(encoding='utf-8'))
assert all(sha(R/r)==h for r,h in protected.items()),'Concurrent source or V3 media edit; inspect.'
receipt=json.loads((W/'delivery/verification.json').read_text(encoding='utf-8'))
assert receipt['native_checks']==12 and not receipt['full_eight_segment_branch_recorded']
log=(W/'review/record.log').read_text(encoding='utf-8',errors='replace');assert 'ERROR:' not in log and 'STORAGE SHOT: 12/12' in log
rel='docs/trailer/v4/storage-shot';dst=R/rel;assert not dst.exists()
tool=R/'tools/trailer/record_pitch_v4.gd';assert not tool.exists()
status='Capture follow-up COMPLETE: added tools/trailer/record_pitch_v4.gd as a new derivative of Claude\'s preserved V3, with one shared current indoor Storage segment and --storage-only mode. Native live Movie Maker12/12 checks: actual door/three-member party/walks/counter/deposit/withdraw/exit/private save, clean log. Delivered a16.167s1152x648/30fps MP4 with engine audio,8.67s768x432/15fps GIF,503-frame raw AVI, frame markers, exact FFmpeg edits and reviewed movie frames: '+rel+'/README.md. MP4 has485 frames; audio peak-7.1dB. All554 protected current source/old trailer/V3-root/four-GIF files exact; no existing game/V3 file edited, no real save, generation, paid call or commit. Full V4 script parse-check passes, but only its shared Storage segment was recorded; no full eight-segment V4 pitch or V4 cutter is claimed. October14 queue and game integrations remain complete. A full current pitch recording/cut is the remaining optional media follow-up.'
changes={}
start=R/'docs/team/CODEX_START_HERE_2026-10-14.md';raw=start.read_bytes();txt=raw.decode('utf-8-sig').replace('\r\n','\n');a=txt.index('## Current status\n');b=txt.index('\n## Read before work',a)
txt=txt[:a]+'## Current status\n\n'+status+'\n'+txt[b:];changes[start]=(raw,txt)
tasks=R/'docs/team/CODEX_TASKS_2026-10-14.md';raw=tasks.read_bytes();txt=raw.decode('utf-8-sig').replace('\r\n','\n')+'\n\nCodex, October14 (capture follow-up after Preston: "next"): '+status+'\n';changes[tasks]=(raw,txt)
collab=R/'docs/AI_COLLABORATION.md';raw=collab.read_bytes();txt=raw.decode('utf-8-sig').replace('\r\n','\n');title='# Working Together on Hollowtide\n';assert txt.startswith(title)
txt=txt.replace(title,title+'\n## Codex: V4 Storage capture workflow and fresh shot (October14,2026)\n\n'+status+'\n',1);changes[collab]=(raw,txt)
inv=R/'docs/pitch/ai-asset-inventory.md';raw=inv.read_bytes();txt=raw.decode('utf-8-sig').replace('\r\n','\n')
anchor=re.search(r'^\| \*\*Four feedback GIFs\*\*.*\|$',txt,re.M);assert anchor
row='| **V4 Storage-only recording**, October14 | **Recorded engine gameplay with AI-assisted capture/editing**, not generative video. [Native-resolution MP4](../trailer/v4/storage-shot/storage_room.mp4):16.167s,1152x648,30fps,485 frames,H.264/AAC with existing engine audio; [GIF](../trailer/v4/storage-shot/storage_room.gif):8.67s,768x432,15fps,130 frames. [New V4 recorder](../../tools/trailer/record_pitch_v4.gd) walks through the installed room and shows a real one-berry deposit/withdraw and exit, in scripted private test state. [Raw take, source receipt, frame markers and exact encoder commands](../trailer/v4/storage-shot/README.md). Visible art/UI/audio retain their generated/assisted source classifications above; no new model output. Twelve native capture checks pass. The full eight-segment V4 branch is parse-checked only, not recorded or cut into a new full pitch. |'
txt=txt.replace(anchor.group(),anchor.group()+'\n'+row,1)
changes[inv]=(raw,txt)
dst.mkdir(parents=True)
for p in (W/'delivery').iterdir():
    if p.is_file():shutil.copy2(p,dst/p.name)
for name in ['raw.avi','record.log','parse.log','shot-markers.json','record-process.json','parse-process.json']:
    shutil.copy2(W/'review'/name,dst/name)
for p in (W/'review').glob('0*.png'):
    d=dst/'native-stills';d.mkdir(exist_ok=True);shutil.copy2(p,d/p.name)
for name in ['prepare.py','record.py','encode.py','publish.py','storage-segment.gdpart','protected.json','original-record_pitch_v3.gd']:
    d=dst/'drivers';d.mkdir(exist_ok=True);shutil.copy2(W/name,d/name)
shutil.copy2(W/'prepared/tools/trailer/record_pitch_v4.gd',dst/'record_pitch_v4.gd')
(dst/'.gdignore').write_text('',encoding='utf-8')
(dst/'README.md').write_text('''# Fresh indoor Storage shot and V4 capture workflow, October14,2026

The current Storage room is now recorded from the running live game, using `tools/trailer/record_pitch_v4.gd --storage-only`. The new V4 file derives from Claude's V3 but replaces its obsolete outside-panel block with the actual room/door/counter route. Both full-mode and Storage-only mode call **the same** `_storage_shot` function, so its12 checked steps are the production recording segment. Other V3 shot logic is inherited. Every shot stays on the recorder's private save path, with cleanup at the end; the old V3 reset to the real default path is not carried forward.

**Scope:** this is a finished Storage shot plus a parse-checked new recorder. The full eight-segment V4 run has **not** been recorded or reviewed, and no V4 full-pitch cutter/output is supplied. V3 timings and media remain historical; do not feed a new full recording through the V3 cutter without adapting its timings. A future full V4 should capture current Parcel/water/dialogue/Storage visuals and use a new cutter/output folder.

## Watch

- `storage_room.mp4`: **16.167s**,1152x648,30fps,485 frames,H.264/AAC, native viewport size with no resize. Actual engine audio retained (peak-7.1dB); no added music/model or generated video.
- `storage_room.gif`: **8.67s**,768x432,15fps,130 frames,128-colour palette with nearest resizing; a quick looping view of shelves/counter/deposit/withdraw, not the native pixel reference.
- `contact-sheet.png` and `storage_*.png`: samples extracted from the raw movie; `native-stills/` contains the direct engine stills. All five sampled movie moments were inspected, including bag x1/kept x1 after deposit and bag x2/kept x0 after withdrawal.

## Evidence and editing

Native Movie Maker recorded **503 frames** at30fps into `raw.avi`, with12/12 assertions and a clean final log. Checks cover actual unlocked door, three party members, walked access behind/front of counter, live panel, exact berry deposit/withdraw, walked south exit, real town return location, unchanged party and private save path. The take uses scripted party/levels/door placement, inherited from V3, followed by actual scene transitions and room steps; it is not a continuous player playthrough or new balance test. It does not edit gameplay, assets or rules.

`shot-markers.json`, `record.log`, `verification.json` and `edit-commands.json` preserve the exact captured timeline/codec commands and measured output. Full clip trims raw frame indices9..493; GIF uses144..403, sampled at15fps. Recorded process count502 is one below the raw movie's503 frames; this measured offset is explicitly noted, and the review frames are indexed from the actual raw movie. MP4 audio is trimmed to the same range and checked for non-silence; no separate waveform/music identity claim is made. Generated art and existing generated music/sound keep their inventory classifications after filming/encoding. Exact image/music model versions remain as recorded in the inventory, including unknowns.

The complete V4 script passes Godot `--headless --check-only`. `drivers/` retains the source generator, wrapper, encoder, original V3 source and protection manifest. FFmpeg/Pillow measure and encode existing captures; they do not generate game content. A Python f-string escape warning in the encoder was corrected to a raw f-string without changing the emitted FFmpeg argument; the existing successful media was not needlessly re-encoded.

## Reproduce safely

Work folder: `D:/dev/hollowtide-storage-capture-20261014`. `record.py` uses the live project, Dummy audio, fixed30fps, separate APPDATA/LOCALAPPDATA, its own save, and outputs only under that work folder. It manages only its own Godot subprocess. `record.py --parse` checks syntax; `record.py` records Storage-only; `encode.py` creates delivery media and measurements. The wrapper refuses to overwrite its existing capture/log; use a fresh work copy/output folder for a new take. Preserve the current raw/output/markers as a set. `HT_CAPTURE_REVIEW` chooses direct still/marker output in V4; without it, those go to its user profile.

For a new full take, create a **fresh** movie/output folder, keep the isolated profile setup from the wrapper, and run the new recorder without `--storage-only`. Review every scene and measure new segment markers before constructing a V4 cutter. That full-mode execution is the remaining media follow-up, not part of this checked shot.

All554 protected current scripts/scenes/data/dialogue/old trailer files, V3 root outputs (including raw AVI hashes) and four prior GIFs are exact before/after publication. Only the new recorder, this new V4 folder, inventory and handoff docs were added/updated. V3 is neither overwritten nor claimed repaired; use V4 for the new indoor segment. No existing game source, real player save, Claude proposal, training file, generation, paid API call, export, post, message to another chat or commit. Preston's visual approval remains his.

![Storage movie review](contact-sheet.png)
''',encoding='utf-8')
for p,(raw,txt) in changes.items():
    d=dst/'original-docs'/p.relative_to(R);d.parent.mkdir(parents=True,exist_ok=True);d.write_bytes(raw)
shutil.copy2(W/'prepared/tools/trailer/record_pitch_v4.gd',tool)
for p,(raw,txt) in changes.items():
    assert p.read_bytes()==raw,'Concurrent doc edit; stop.'
    nl='\r\n' if b'\r\n' in raw else '\n';p.write_bytes(txt.replace('\n',nl).encode('utf-8'))
handoff=R/'docs/team/CODEX_HANDOFF_2026-10-14_storage_capture.md';assert not handoff.exists()
handoff.write_text('# V4 Storage shot complete\n\n'+status+'\n',encoding='utf-8')
assert all(sha(R/r)==h for r,h in protected.items())
assert sha(tool)==sha(W/'prepared/tools/trailer/record_pitch_v4.gd')
links=0
for label,ref in re.findall(r'\[([^\]]+)\]\(([^)]+)\)',inv.read_text(encoding='utf-8')):
    if ref.startswith(('http://','https://')):continue
    assert (inv.parent/ref.split('#')[0]).resolve().exists(),ref;links+=1
(dst/'installed-verification.json').write_text(json.dumps({'protected_files_exact':len(protected),'inventory_local_links':links,'recorder_sha256':sha(tool),'native_storage_checks':12,'full_run_recorded':False},indent=2),encoding='utf-8')
manifest={p.relative_to(dst).as_posix():sha(p) for p in dst.rglob('*') if p.is_file()}
(dst/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print('Published V4 recorder and',len(manifest),'shot/evidence files;',len(protected),'protected files exact;',links,'inventory links resolve.')
