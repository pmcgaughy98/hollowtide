from pathlib import Path
import hashlib,json,shutil,difflib
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
required={'finish_check':'RESULT 21/21 checks pass','hub_town_check':'Places: 12 of 12 answered E','town_walk_check':'RESULT: the team walks','dungeons_check':'DUNGEONS: all ok','hall_door_check':'RESULT: the hall door meets the steps'}
for name,marker in required.items():
 log=(W/(name+'.log')).read_text(encoding='utf-8')
 assert marker in log and all(err not in log for err in ['SCRIPT ERROR','SHADER ERROR','FAIL ','FAILED','WRONG']),name
for name in ['building_exteriors','growth_shrine_painter','training_yard_painter','job_board_painter','hollow_mouth_painter']:
 r='scripts/town/'+name+'.gd'
 assert (W/'originals'/r).read_bytes().replace(b'res://scripts/arena/creature_finish.gd',b'res://scripts/town/exterior_finish.gd')==(W/'candidate'/r).read_bytes(),r
r='scripts/arena/sel_out.gdshaderinc'; original=(W/'originals'/r).read_bytes()
nl=b'\r\n' if b'\r\n' in original else b'\n'
anchor=b'\t#ifdef SEL_OUT_MASKED_MAP'+nl+b'\t// Map floors'
insert=nl.join([b'\t#ifdef SEL_OUT_SELECTIVE',b'\t// Opt-in outer rim only; the original internal detail finish above stays exact.',b'\tc.rgb = selective_rim(TEXTURE, UV, TEXTURE_PIXEL_SIZE, c);',b'\t#endif',b''])
assert original.replace(anchor,insert+anchor)==(W/'candidate'/r).read_bytes(),r
# Collaboration note merges current live text; no stale whole-document replacement.
note='''## Codex: job 11 town outer rims, painter helper and creature A/Bs (October 10, 2026)

Read Claude's updated handoff and latest Highbank ground first. Nine service exteriors now opt into material-coloured outer rims with top-left lighting; Preston's near-black internal windows, doors, carvings and joints stay pixel-exact. Door/default creature shaders, foundations/signs/feedback, original PNGs, palettes, layouts and contact ground are unchanged. HighbankPainter, crew/dungeon finish and Claude's current code preserved.

Job 11(b): scripts/art/selout.gd returns a new Image for a filled Image mask, Rect2i or transparent silhouette; example/native before-after on the actual Lookout wall is archived. Claude can wire the helper into his painters. No painter rewired in this pass. Job 11(c): Cinderhide, Oxbowarchon and Whinet native A/B previews only; shipped creature finish remains current until Preston chooses.

21 native comparisons pass: nine alpha/thickness and all interior pixels exact; all 35 installed creature south views and four dungeon looks byte-exact; helper input/interior/outside mask exact and lit rim verified. Hub's 12 services, walking, two Hall door tiles and Claude's dungeons_check pass. Original sources, native town views, A/Bs, code and preservation audit: [town sel-out handoff](world/town-selout-2026-10-10/README.md). No source art generation, PNG edit, settings edit or commit. Visual direction remains proposal for Preston. Next open launch/UI job: handoff 8, pixel frames for launch boxes; the title painting and wordmark stay.

'''
r='docs/AI_COLLABORATION.md';raw=(L/r).read_bytes()
q=W/'originals-current'/r;q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(raw)
header=b'# Working Together on Hollowtide\r\n\r\n'
if not raw.startswith(header):header=b'# Working Together on Hollowtide\n\n'
assert raw.startswith(header)
q=W/'candidate'/r;q.parent.mkdir(parents=True,exist_ok=True)
q.write_bytes(header+note.replace('\n','\r\n').encode('utf-8')+raw[len(header):])
readme='''# Town sel-out, October 10, 2026

Handoff job 11: installed selective outer rims on Wayline Hall, Home, Item Shop, Storage, Scroll Keeper cellar, Job Board, Growth Shrine, Training Yard and Mouth of the Hollow. The rim takes a darker neighbouring material swatch, with top-left edges lighter. This is a subtle integration pass against Claude's new ground. Existing near-black interior detail stays exact, retaining Preston's distinction between services and background decoration.

## Scope

Five town scripts change only their Finish preload to a town wrapper. That wrapper calls the existing shared finish and switches only detailed service art to the optional shader. Doors take the same default finish as before. The shared include adds one preprocessor-gated call; creature and masked dungeon shaders compile with that branch absent. No source PNG, palette, outline width, collision, position, doorway, door animation, contact shadow, sign, feedback drawing, prologue/title/menu, save, gameplay, balance or project-settings change. Crossroads remains the existing quiet floor inlay. Seven-form refinements, Oxbowarchon's jade and Sparkwick correction preserved.

## Painter helper for Claude, job 11(b)

`scripts/art/selout.gd`: `selout(img: Image, mask_or_rect = null) -> Image`. Returns a duplicate, leaving the input unchanged. Pass a filled `Rect2i` of the material shape, or an image-size filled white shape mask on black/transparent background. Only opaque selected rim pixels change. Alpha, interior blocks, unselected floor and canvas extents remain exact. Rectangles are bounded before iteration. Null uses the existing transparent silhouette. Top-left lighting and local two-pixel material selection use the same shading recipe as the optional rim shader; the CPU helper does not add the shared shader's separate detail ink or expand contours.

For wall lips, select the entire lip strip; for a plank, select its whole solid shape. Do not pass only a line-shaped edge mask, which cannot identify the inward material or lighting normal. The example uses the actual HighbankPainter Lookout wall: `Rect2i(lookout.position * 24, Vector2i(lookout.width * 24, 7))`. The example crop has four pixels of margin. Native before/after: [original wall](review/proof/lookout-helper-before.png), [helper wall](review/proof/lookout-helper-after.png). Claude owns wiring this helper into riverbank/ruin/valley/highbank painters; those files were not edited here.

## Creature A/Bs, job 11(c), review only

[Cinderhide, Oxbowarchon and Whinet side by side](review/proof/creature-ab-review-only.png). Left: installed ink. Right: selective outer rim proposal, same art, alpha and detail flags. Preview shader saved beside the current wrapper under `review/`. No alternate creature finish is enabled by any game scene. Preston has not chosen the variant or approved this visual direction.

## Native verification

Godot 4.7.2, native NVIDIA OpenGL Compatibility renderer. 21 comparisons pass: all nine exterior silhouettes/alpha/width and every internal pixel exact; 3,804 rim pixels changed; all 35 installed creature south views exact to the previous shader, including rivals, Sparkwick and Oxbowarchon; riverbank/ruin/bank/valley dungeon finishes exact; door wrapper takes the original default shader. Helper input, outside selection and inside masonry unchanged; mask/rectangle outputs equal and top rim lighter than bottom. This is not a full new animation audit: existing source sets and previous animation verification are preserved.

Current Claude checks copied for review with outputs redirected here and explicit fixture cleanup: hub_town_check (13 places reachable, 12 services answer E, team follows, gate starts a run), town_walk_check (current town team walks/returns to standing), hall_door_check (both door tiles connect to steps), dungeons_check (rival scene, Rot Spit/Drain Bite, valley/ruin, Warden scene and town dungeon selection). Original test tools are not overwritten. Test preferences use an isolated APPDATA directory; no user saves or settings touched.

Review/native town captures are in `review/before/` and `review/after/`; native side-by-side service textures in `review/proof/`. Review runs report Windows root-certificate-store read errors in this sandbox, unrelated to shaders/gameplay. The initial shader-scope diagnostic is retained; corrected shader compiles with no shader or script errors in final checks. Installation is guarded against concurrent file changes; originals and exact candidates are retained here. Final live verification/audit added after installation.

## Next open tasks

Handoff 8: launch boxes into UI.frame pixel borders, preserving title painting/wordmark and New Game story flow. Earlier field-page styling and hall/guild presentation also remain open. Claude's task 11 painter wiring and Preston's creature variant choice remain separate from this completed town pass. No commit, revert or stash.
'''
(W/'README.md').write_text(readme,encoding='utf-8')
archive=W/'archive';archive.mkdir(exist_ok=True)
for folder in ['originals','originals-current','candidate','review']:
 shutil.copytree(W/folder,archive/folder,dirs_exist_ok=True)
for name in ['README.md','baseline.json','setup.py','edit.py','run.py','package.py','capture.gd','finish_check.gd','prepare_checks.py','capture-shader-scope-failure.log']+list(required)+[n+'.gd' for n in required]+[n+'.log' for n in required]:
 if (W/name).is_file():shutil.copy2(W/name,archive/name)
shutil.copy2(C/'scripts/arena/creature_finish.gdshader',archive/'review/current_creature_finish.gdshader')
shutil.copy2(C/'scripts/town/exterior_finish.gdshader',archive/'review/creature_finish_selout_preview.gdshader')
baseline=json.loads((W/'baseline.json').read_text(encoding='utf-8'))
pending=[]
for q in (W/'candidate').rglob('*'):
 if not q.is_file():continue
 r=q.relative_to(W/'candidate').as_posix()
 before=hashlib.sha256(raw).hexdigest() if r=='docs/AI_COLLABORATION.md' else baseline.get(r)
 assert (sha(L/r) if (L/r).exists() else None)==before,('Concurrent owned file changed',r)
 pending.append({'path':r,'before':before,'after':sha(q)})
pending.sort(key=lambda d:(d['before'] is not None,d['path']=='docs/AI_COLLABORATION.md',d['path']))
(W/'pending-install.json').write_text(json.dumps(pending,indent=2),encoding='utf-8')
print('Validated checks and six exact bounded code diffs; packed',len(pending),'guarded files and review archive.')
