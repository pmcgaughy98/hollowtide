from pathlib import Path
import hashlib,json,shutil,re
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');E=L/'docs/ui/product-setup-2026-10-26'
hashes=json.loads((W/'installed-files.json').read_text())
for rel,h in hashes.items():assert hashlib.sha256((L/rel).read_bytes()).hexdigest()==h,rel
assert json.loads((W/'native-result.json').read_text())['failed']==0
assert json.loads((W/'editor-result.json').read_text())['failed']==0
assert json.loads((W/'export-probe-result.json').read_text())['pack_assertions']==10
assert json.loads((W/'window-icon-result.json').read_text())['passed']
E.mkdir(parents=True,exist_ok=True)
for p in W.iterdir():
 if p.is_file() and p.suffix in ('.py','.gd','.md','.json','.log','.diff','.png','.pck'):shutil.copy2(p,E/p.name)
for folder in ('originals','prepared','export-probe-existing-hook','first-probe','retired-duplicate-hook'):
 if (W/folder).exists():
  shutil.copytree(W/folder,E/folder,dirs_exist_ok=True,ignore=shutil.ignore_patterns('.godot','__pycache__'))
(E/'HANDOFF.md').write_text((W/'HANDOFF.md').read_text().replace('../ui/product-setup-2026-10-26/README.md','README.md'),encoding='utf-8')
for rel in ('docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-26.md'):
 p=W/'docs-before-publication'/rel;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,p)
hand=L/'docs/team/CODEX_HANDOFF_2026-10-26_product_setup.md';shutil.copy2(W/'HANDOFF.md',hand)
entry='''## Codex: C10 icon/plain splash, C11 preset ready (October 26, 2026)

C10 COMPLETE, C11 PRESET READY; actual Windows game export/painted-art/cache/EXE-icon QA PENDING TEMPLATES. Existing title burrow ornament cropped32x32/nearest8x into icon.png; normal Windows WM_GETICON capture matches RGB exactly. Engine splash image off, bg pure black. Windows Desktop/x86_64 preset, separate PCK, builds/windows output ignored; excludes tools/Godot AI/lab/builds/old SVG and archived docs code, keeps docs images until C22 and data. Existing Godot AI export hook used unchanged; no extra addon retained. Native9 clean + Windows icon1; tiny PCK10/10 clean actual export/run exclusions/autoload proof; hook matrix10/10 functional, custom-editor RID/209-object exit diagnostics retained. [Preview, source, commands and limitations](ui/product-setup-2026-10-26/README.md); [handoff](team/CODEX_HANDOFF_2026-10-26_product_setup.md). Five retained files, gameplay/wordmark/shared sources exact, original source helper/plugins retained, Claude work preserved. Source issues: templates absent in standard Godot folder; game/export-art success not claimed, exported room-worker change stays gated. Next C22 arena fronts into assets and path handoff. C6 OFF, town/exterior HOLD. No template download/real save/generative or paid art/rules/Route1/message/commit; Codex review only.

'''
p=L/'docs/AI_COLLABORATION.md';s=p.read_text(encoding='utf-8');title,rest=s.split('\n',1);p.write_text(title+'\n\n'+entry+rest.lstrip('\n'),encoding='utf-8')
p=L/'docs/team/CODEX_TASKS_2026-10-26.md';s=p.read_text(encoding='utf-8');p.write_text(s.rstrip()+'''\n\n## Codex result, October 26: B7 C10 complete, C11 preset ready

C10 COMPLETE/INSTALLED: icon.png from the exact existing title burrow/root ornament, native32x32 crop/nearest8x256. Real normal-launch Windows WM_GETICON image matches RGB exactly. Engine splash show_image=false, pure black bg matching clear colour; C5 launch card unchanged. Windows Desktop/x86_64 preset READY: separate PCK, builds/windows/Hollowtide.exe, icon/product fields; excludes tools/, addons/godot_ai/, scenes/_lab/, builds/, old icon.svg and archived docs code, keeps docs images until C22 plus JSON/dialogue data. Build outputs Git-ignored. Installed Godot AI addon already registers its export-strip hook, used unchanged; source debugger helper/plugins retained and no duplicate addon remains. Native9/9 clean, Windows icon1 exact, actual tiny PCK10/10 clean, hook matrix10/10 functional with custom-editor RID/209-object exit diagnostics retained. Five retained file changes/additions, gameplay/wordmark/UI sources exact. [Preview, normal Windows icon proof, native/package checks, sources/diff/hashes and diagnostic limits](../ui/product-setup-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_product_setup.md).

Source issues for Claude: no new gameplay issue. C11 full Windows game export and painted Highbank/Home desk/board/Hollow/cache-on-second-launch/EXE-icon QA remain PENDING TEMPLATES, not complete. Standard Roaming/Godot/export_templates still has no Windows templates; queue assigns matching4.7.2 download to Preston via Editor > Manage Export Templates > Download. Tiny PCK probe needs no executable stub and is not a game-build claim. Keep exported town_room worker-art change gated until actual exported QA. C22 arena-front relocation is next independent slice; docs assets have not moved, board path stays intact. Duplicate prototype retired safely; first loose-file/script-window/certificate/custom-editor diagnostics retained, final normal window icon and real tiny-PCK proof pass. No template download, real save, art generation/paid art, creature rules, Route1, cross-chat message or commit. C6 OFF, town/exterior HOLD; Codex-reviewed visuals, Preston approval not claimed.
''',encoding='utf-8')
for p in (E/'README.md',E/'HANDOFF.md',hand):
 for target in re.findall(r'\]\(([^)]+)\)',p.read_text()):
  if '://' not in target:assert (p.parent/target).exists(),(p,target)
for rel,h in hashes.items():assert hashlib.sha256((L/rel).read_bytes()).hexdigest()==h
print('Published C10 completion/C11 preset readiness and explicit template-dependent remainder.')
