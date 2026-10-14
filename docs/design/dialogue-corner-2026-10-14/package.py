from pathlib import Path
import hashlib,json,shutil
from PIL import Image,ImageChops
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
protected=json.loads((W/'protected.json').read_text(encoding='utf-8'))
changed=[r for r,h in protected.items() if sha(R/r)!=h]
assert not changed,changed
exact={}
for name in ['gallery-narration','gallery-shared-panels']:
    a=Image.open(W/'before'/f'{name}.png').convert('RGBA');b=Image.open(W/'after'/f'{name}.png').convert('RGBA')
    exact[name]=a.tobytes()==b.tobytes();assert exact[name]
for phase in ['before','after']:
    for name in ['flood','gallery']:
        log=(W/phase/(name+'.log')).read_text(encoding='utf-8')
        assert 'FAIL' not in log and 'ERROR' not in log and ('all ok' in log if name=='flood' else '5/5' in log)
receipt={'protected_live_files_exact':len(protected),'native_flood_assertions':{'before':5,'proposal':5},'native_gallery_assertions':{'before':5,'proposal':5},'pixel_exact_controls':exact,'geometry_screen_pixels':{'old_portrait_frame_left':15,'new_portrait_frame_left':27,'ornament_right_exclusive':21,'new_clearance':6,'new_name_to_portrait_frame_gap':9,'new_text_to_portrait_frame_gap':15,'old_text_width':540,'new_text_width':528},'live_layout_changed':False}
(W/'verification.json').write_text(json.dumps(receipt,indent=2),encoding='utf-8')
archive=W/'package';archive.mkdir(exist_ok=True)
for name in ['prepare.py','run.py','flood.gd','gallery.gd','package.py','original-ui_style.gd','candidate-ui_style.gd','candidate.diff','protected.json','verification.json']:
    shutil.copy2(W/name,archive/name)
for phase in ['before','after']:
    dst=archive/phase;dst.mkdir(exist_ok=True)
    for p in (W/phase).glob('*'):
        if p.is_file():shutil.copy2(p,dst/p.name)
originals=archive/'original-frame';originals.mkdir(exist_ok=True)
for p in (R/'assets/sprites/ui/frame').glob('*.png'):shutil.copy2(p,originals/p.name)
shutil.copy2(R/'tools/ui/build_frames.py',originals/'build_frames.py')
(archive/'.gdignore').write_text('',encoding='utf-8')
(archive/'README.md').write_text('''# Dialogue corner: checked layout proposal, October 14, 2026

Task 4 PROPOSAL COMPLETE. Claude applies the two shared layout values. Live UI source and all frame PNGs remain unchanged. This follows the task's explicit alternative: propose values for Claude rather than alter the shared ornament used by every panel. No additional frame variant.

| Shared value | Live | Proposed |
| --- | --- | --- |
| PORTRAIT_INSET | 150.0 | **162.0** |
| Portrait offset | Vector2(30, -34) | **Vector2(42, -34)** |

`candidate.diff` is the complete two-line proposal; original and full candidate source are preserved. Apply only that diff after checking the current shared file; do not replace any later Claude edits with the snapshot.

The portrait well starts 15 screen pixels left of the portrait image. The old outer frame began at box x+15 and covered the last six pixels of the 21-pixel corner ornament. The proposed frame begins at x+27, leaving six pixels clear after the stud. The image remains 120x120 (40x40 at 3x). Vertical offset, frame sizes, face backgrounds, name lift, arrow, fonts, panel art and all callers stay as they are. Nameplate and prose move with the image: their 9px and 15px gaps after its outer frame remain the same. On the standard 760px box, prose width is 528 rather than 540; normal wrapping handles that cost.

## Native evidence

- `before/3_partner.png` and `after/3_partner.png`: actual flood talk at 1152x648, native 3x UI; Rimefin choice and portrait.
- Both flood runs: **5/5** narration, other starters offered, second choice selects Rimefin, speaker/face and actual riverbank transition with the right party.
- Both gallery runs: **5/5** actual portrait lookup, cached shared panel, multi-page long text, last-page completion and measured text widths at the existing 760px/948px widths.
- Deterministic `gallery-narration.png` and `gallery-shared-panels.png` are pixel-exact before/after. Those covers ordinary, dim and focused shared panels; no-portrait narration keeps its full width.
- All **814** protected existing source/data/dialogue/UI files match their starting hashes; all original frame PNGs preserved. `verification.json` records the result.

Flood rain/actors animate, so full scene images are visual comparisons, not whole-screen pixel controls. The deterministic gallery supplies the pixel controls. Gallery text is private test prose. No story, rules, state, save, room/collision, plugin, source art or training changes. No image generation, paid call or commit.

## Reproduce / play

Work folder: `D:/dev/hollowtide-dialogue-corner-20261014`; staged game: `D:/dev/hollowtide-world-refinement-20261008/project`. `prepare.py` copies current live sources to that existing stage, saves hashes and changes only the two proposed UI values there. Native `run.py before` uses live and `run.py after` uses stage; add `gallery` for the deterministic controls. Both use isolated APPDATA/LOCALAPPDATA and Dummy audio, and own only their subprocess. Python/Godot absolute paths are in the drivers. Native flood teardown clears its in-memory Dialogue Manager expression cycle only after the scene is gone.

To inspect interactively, open the staged project in Godot and run `scenes/creature_prologue.tscn`; E advances, arrows select. This staged preview is a proposal. Claude still owns applying the two values to the live shared UI. The packaged drivers preserve the original work paths for traceability; copy them to that work folder to rerun. Original frame recipes and PNGs are under `original-frame/`.

Task 5 (AI inventory refresh) is next. Storage room wiring remains Claude's separate pending integration.
''',encoding='utf-8')
manifest={str(p.relative_to(archive)).replace('\\','/'):sha(p) for p in archive.rglob('*') if p.is_file()}
(archive/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print(json.dumps(receipt,indent=2));print('Packaged',len(manifest),'files')
