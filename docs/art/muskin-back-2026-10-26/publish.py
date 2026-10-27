from pathlib import Path
import hashlib,json,re,shutil,subprocess,sys
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');E=L/'docs/art/muskin-back-2026-10-26';T=L/'docs/team/CODEX_HANDOFF_2026-10-26_muskin_back.md';Q=L/'docs/team/CODEX_TASKS_2026-10-26.md';C=L/'docs/AI_COLLABORATION.md'
subprocess.run([sys.executable,str(W/'verify.py')],check=True)
assert not E.exists() and not T.exists()
marker='## Codex result, October 26: ART-08 Muskin back palette'
assert marker not in Q.read_text(encoding='utf-8-sig')
q=Q.read_bytes();c=C.read_text(encoding='utf-8-sig');heading='# Working Together on Hollowtide';assert c.startswith(heading)
for p in (Q,C):
 d=W/'docs-before-publication'/p.relative_to(L);d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,d)
E.mkdir(parents=True)
for p in W.iterdir():
 if p.is_file():shutil.copy2(p,E/p.name)
for name in ('originals','prepared','build-dependencies','docs-before-publication'):
 shutil.copytree(W/name,E/name,ignore=shutil.ignore_patterns('.godot','__pycache__'))
h=(W/'HANDOFF.md').read_text();T.write_text(h,encoding='utf-8');(E/'HANDOFF.md').write_text(h.replace('../art/muskin-back-2026-10-26/README.md','README.md'),encoding='utf-8')
result='''

## Codex result, October 26: ART-08 Muskin back palette

COMPLETE/INSTALLED. Existing assets/sprites/arena/muskin/n.png snapped to unchanged s.png's 23-color palette: source 129->21 colors; rebuilt dungeon/n.png 70->18, town/n.png 92->20, all exact front-palette members and below 30. Alpha/canvas/silhouette/registration exact (128x128/37x37/55x55); black edge finish retained. Current builder run for Muskin dungeon and town (--set=town --scale=1.5), baseline/updated delta only these two north outputs. Three PNGs installed, all other 318 snapshotted Muskin asset/import/source-walk files exact, including walks, seven facings, chosen front and south job-object idle. Paths already wired; no repoint or further rebuild needed. [Native comparison, metrics, originals, commands and logs](../art/muskin-back-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_muskin_back.md).

Native 28/28 clean: imported RGBA exact, native shared shader, actual dungeon loader/_set_tex north/original foot row, actual SceneKit.spawn north/south job idle/eight walks per facing, private save SHA exact. Minimal three-texture import clean; existing .import metadata preserved and only owned cache pairs installed. Source issues for Claude: bare baseline rebuild differs from 144 installed finished PNGs; all unselected installed bytes retained, do not blanket-copy a bare rebuild over them. No script/tool/scene/settings/rule change or concurrent source difference, Claude/Grok dirty work preserved. Next ART-03 village image 384x216. Portrait crops await Preston's look; C6 OFF, town/exterior HOLD, C11 full Windows export QA pending templates. No generation/paid call/real save/Route1/message/commit; Codex visual review only.
'''
note='''

## Codex: ART-08 Muskin back palette complete (October 26, 2026)

Three PNGs installed at existing muskin/n.png, dungeon/n.png, town/n.png. Colors 129->21, 70->18, 92->20, all from unchanged front's 23-color palette, alpha/canvas/registration exact. Both named current Muskin set builds ran, only north outputs promoted; other 318 Muskin asset/import/source-walk files exact. Native 28/28 clean via actual dungeon loader/_set_tex and town factory, shared shader, private save SHA. Minimal texture import clean, .import metadata unchanged. [Preview, metrics, commands and evidence](art/muskin-back-2026-10-26/README.md); [handoff](team/CODEX_HANDOFF_2026-10-26_muskin_back.md). Source issue: bare baseline rebuild differs from 144 installed finished PNGs; unselected bytes retained, no blanket rebuild. No further Claude path/set patch required. Scripts/tools/scenes/settings and dirty Claude/Grok work preserved. Next ART-03 village image 384x216. C6 OFF, town/exterior HOLD, C11 export QA pending templates. No generation/paid call/real save/rules/Route1/message/commit; Codex review only.
'''
Q.write_bytes(q+result.encode('utf-8'));C.write_text(heading+note+c[len(heading):],encoding='utf-8')
for p in (E/'README.md',E/'HANDOFF.md',T):
 for target in re.findall(r'\]\(([^)]+)\)',p.read_text(encoding='utf-8')):
  if '://' not in target:assert (p.parent/target).exists(),target
for rel,h in json.loads((W/'installed-files.json').read_text()).items():assert hashlib.sha256((L/rel).read_bytes()).hexdigest()==h
assert Q.read_bytes().startswith(q) and C.read_text(encoding='utf-8').endswith(c[len(heading):])
receipt={'evidence':str(E),'handoff':str(T),'queue_appended':True,'collaboration_prepended':True,'links_valid':True,'owned_hashes_match':True}
(W/'publication.json').write_text(json.dumps(receipt,indent=2));shutil.copy2(W/'publication.json',E/'publication.json');print(json.dumps(receipt,indent=2))
