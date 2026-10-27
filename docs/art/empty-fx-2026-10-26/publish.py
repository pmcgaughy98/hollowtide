from pathlib import Path
import hashlib,json,re,shutil,subprocess,sys
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');E=L/'docs/art/empty-fx-2026-10-26';T=L/'docs/team/CODEX_HANDOFF_2026-10-26_empty_fx.md';Q=L/'docs/team/CODEX_TASKS_2026-10-26.md';C=L/'docs/AI_COLLABORATION.md'
subprocess.run([sys.executable,str(W/'verify.py')],check=True)
assert not E.exists() and not T.exists()
marker='## Codex result, October 26: FX-01 empty effect slots'
assert marker not in Q.read_text(encoding='utf-8-sig')
q=Q.read_bytes();c=C.read_text(encoding='utf-8-sig');heading='# Working Together on Hollowtide';assert c.startswith(heading)
for p in (Q,C):
 d=W/'docs-before-publication'/p.relative_to(L);d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,d)
E.mkdir(parents=True)
for p in W.iterdir():
 if p.is_file():shutil.copy2(p,E/p.name)
for name in ('originals','prepared','rebuild-fixture','runner','docs-before-publication'):
 shutil.copytree(W/name,E/name,ignore=shutil.ignore_patterns('.godot','__pycache__'))
h=(W/'HANDOFF.md').read_text();T.write_text(h,encoding='utf-8');(E/'HANDOFF.md').write_text(h.replace('../art/empty-fx-2026-10-26/README.md','README.md'),encoding='utf-8')
result='''

## Codex result, October 26: FX-01 empty effect slots

INSTALLED: six blank PNG slots repaired with exact neighboring-frame holds, not recovered/new drawings. Original sheet cells are also fully transparent. Sail Slash f04<-f03, f08<-f07, f12<-f11; Mark Glyph f00<-f15 (cyclic), f12/f13<-f11. Paths remain assets/sprites/arena/vfx/{sail_slash,mark_glyph}/fNN.png, already wired. Cutter now reproduces the six holds only for empty source cells, accepts future painted replacements, rejects an empty donor. Six PNGs plus cutter only; other 26 frames byte-exact, 16-frame timing/32x32 canvas/palette/registration preserved. [Native strips/loops, source audit, originals, manifest/diff and logs](../art/empty-fx-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_empty_fx.md).

Native 67/67 clean, all 32 frames imported/pixel-exact/nonempty and visibly selected by actual dungeon draw; private save hash exact. Maintained dungeon_vfx PASS, raw 23 ObjectDB/9-resource exit diagnostics retained, not clean teardown. Private editor import emitted plugin/theme/audio-UID diagnostics; final native clean. Source issues for Claude: six missing drawings remain source-art quality work, and Sail Slash's unchanged fragmentary/cell-edge cuts remain; holds only close the empty-slot defect. No new art or broad polish claimed. Dungeon/arena/TeamState/UI/project/export settings and all other snapshotted sources exact, Claude/Grok dirty work preserved. No repoint or creature-set rebuild needed. Next ART-08 Muskin back view. Portrait crops await Preston's look; C6 OFF, town/exterior HOLD, C11 full Windows export QA pending templates. No paid/generative art/real save/rules/Route1/message/commit; Codex review only.
'''
note='''

## Codex: FX-01 empty effect slots repaired (October 26, 2026)

Six runtime blanks now exact neighboring-frame holds: sail_slash f04/f08/f12 from f03/f07/f11, mark_glyph f00/f12/f13 from f15/f11/f11. Original source cells truly empty; no recovered/new drawing claim. Cutter reproduces holds only for empty cells, future nonempty source wins. Six PNGs plus cutter, original sheets and 26 other cuts exact, timelines/canvas/palette unchanged. Paths unchanged under assets/sprites/arena/vfx, already wired. Native 67/67 clean via actual dungeon loader/draw; maintained dungeon_vfx PASS with raw 23 ObjectDB/9-resource exit noise retained. Private editor import plugin/theme/audio-UID diagnostics archived, no clean-import claim. [Native preview, audit and evidence](art/empty-fx-2026-10-26/README.md); [handoff](team/CODEX_HANDOFF_2026-10-26_empty_fx.md). Source issues: source drawings absent; Sail's unchanged fragmentary cuts need separate art polish. All other snapshotted sources and Claude/Grok dirty work preserved. No creature-set rebuild needed. Next ART-08 Muskin back view. C6 OFF, town/exterior HOLD, C11 full Windows export QA awaits templates. No paid/generative art/real save/rules/Route1/message/commit; Codex review only.
'''
Q.write_bytes(q+result.encode('utf-8'));C.write_text(heading+note+c[len(heading):],encoding='utf-8')
for p in (E/'README.md',E/'HANDOFF.md',T):
 for target in re.findall(r'\]\(([^)]+)\)',p.read_text(encoding='utf-8')):
  if '://' not in target:assert (p.parent/target).exists(),target
for rel,h in json.loads((W/'installed-files.json').read_text()).items():assert hashlib.sha256((L/rel).read_bytes()).hexdigest()==h
assert Q.read_bytes().startswith(q) and C.read_text(encoding='utf-8').endswith(c[len(heading):])
receipt={'evidence':str(E),'handoff':str(T),'queue_appended':True,'collaboration_prepended':True,'links_valid':True,'owned_hashes_match':True}
(W/'publication.json').write_text(json.dumps(receipt,indent=2));shutil.copy2(W/'publication.json',E/'publication.json');print(json.dumps(receipt,indent=2))
