from pathlib import Path
import hashlib,json,shutil,re
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');E=L/'docs/ui/title-return-2026-10-26'
hashes=json.loads((W/'installed-files.json').read_text())
for rel,h in hashes.items():assert hashlib.sha256((L/rel).read_bytes()).hexdigest()==h,rel
for phase in ('before','after','after-legacy'):assert json.loads((W/(phase+'-result.json')).read_text())['failed']==0
assert 'PASS 2' in (W/'official.log').read_text()
E.mkdir(parents=True,exist_ok=True)
for p in W.iterdir():
 if p.is_file() and p.suffix in ('.py','.gd','.json','.log','.md','.png','.diff'):shutil.copy2(p,E/p.name)
for folder in ('before','after','after-legacy','runner','originals','prepared','first-installed-attempt','concurrent-at-finish'):
 if (W/folder).exists():shutil.copytree(W/folder,E/folder,dirs_exist_ok=True)
(E/'HANDOFF.md').write_text((W/'HANDOFF.md').read_text().replace('../ui/title-return-2026-10-26/README.md','README.md'),encoding='utf-8')
for rel in ('docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-26.md'):
 p=W/'docs-before-publication'/rel;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,p)
hand=L/'docs/team/CODEX_HANDOFF_2026-10-26_title_return.md';shutil.copy2(W/'HANDOFF.md',hand)
entry='''## Codex: C5 splash and return visit (October 26, 2026)

C5/LV-24 COMPLETE. Fresh process keeps the timed card; in-session return opens main before first draw,77 wait frames to0, with full-alpha menu and silent focus. Process-local seen flag, no new preference. Auto-splash says Skip with live shared bindings/click. Prelude/captions hidden at alpha0. opening_flow.gd plus exactly one creature_opening hint assignment; main_menu/shared UI/title_settings/project exact. Native campaign105/105 clean, legacy35/35 with known102-instance exit warning retained; baseline11/11 clean; official opening_flow/ui_fit2 PASS, raw headless diagnostics retained. [Preview, originals, logs, diff and metrics](ui/title-return-2026-10-26/README.md); [handoff](team/CODEX_HANDOFF_2026-10-26_title_return.md). Actual keyboard/pad/mouse/Q Options input plays one confirm and no initial-focus cursor; this was already fixed, no sound code changed. Real pause confirmation component returns correctly on a disposable host, not an autosave/suspend test. Both preference files byte exact on return, private save exact, concurrent Claude edits preserved/archived. Source issues: none new; legacy warning/prior shared neutral-motion follow-up still documented. Next A5/LF7-15 Continue loading/preload. C6 OFF, town/exterior HOLD. No real save/art/generation/paid call/rules/Route1/message/commit; Preston visual approval not claimed.

'''
p=L/'docs/AI_COLLABORATION.md';s=p.read_text(encoding='utf-8');title,rest=s.split('\n',1);p.write_text(title+'\n\n'+entry+rest.lstrip('\n'),encoding='utf-8')
p=L/'docs/team/CODEX_TASKS_2026-10-26.md';s=p.read_text(encoding='utf-8');p.write_text(s.rstrip()+'''\n\n## Codex result, October 26: A4/C5 splash and return visit, LV-24

COMPLETE/INSTALLED. In-session return to title skips the prelude and opens main at full opacity before first draw; baseline77 wait frames, installed0. First process launch keeps the existing timed card/reduced timing and sequential wordmark reveal. Process-local flag only, no new saved setting. Auto-splash hint now says Skip with live UI.binding_text values/click, and prelude/captions explicitly hide at alpha0. Only opening_flow.gd plus one creature_opening.gd hint assignment changed. Native campaign105/105 clean across auto/Enter/pad/mouse/reduced/Q first-launch and returns, plus actual pause-menu Enter confirmation on a disposable host. Legacy35/35 with known102-instance exit warning retained; original baseline11/11 clean. Maintained opening_flow/ui_fit2 PASS, known raw headless diagnostics retained. [Preview, commands/logs, originals, diff and preservation report](../ui/title-return-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_title_return.md).

Source issues for Claude: none new. LV-24 first-focus/Options sounds already correct in fresh baseline, now verified through actual keyboard/pad/mouse/rebound events: one confirm, quiet initial shared focus. No sound/helper change. Main menu/shared UI/title settings/project exact; input/close/journey handlers exact, C6 OFF. Both preference files byte exact on return and private save SHA exact; existing non-title preference migration respected. Concurrent Mouth/town/board/check edits preserved/archived. Fixture parse/preload/migration/frame-count corrections retained; production C5 needed no repair. Legacy exit warning/prior shared neutral-motion follow-up remain documented, no clean legacy exit claim. Next ordered A5/LF7-15 Continue sound/fade before threaded Highbank load and inspect unused FIRST_SCENE preload, Route1 untouched. Town/exterior HOLD pending named slot queue. No real save/art/generation/paid call/rules/Route1/message/commit. Native visuals reviewed by Codex, Preston approval not claimed.
''',encoding='utf-8')
for p in (E/'README.md',E/'HANDOFF.md',hand):
 for target in re.findall(r'\]\(([^)]+)\)',p.read_text()):
  if '://' not in target:assert (p.parent/target).exists(),(p,target)
for rel,h in hashes.items():assert hashlib.sha256((L/rel).read_bytes()).hexdigest()==h
print('Published C5 evidence, handoff and appended result; two source hashes still exact.')
