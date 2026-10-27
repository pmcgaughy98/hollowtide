from pathlib import Path
import hashlib,json,shutil,re
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');E=L/'docs/ui/continue-load-2026-10-26'
hashes=json.loads((W/'installed-files.json').read_text())
for rel,h in hashes.items():assert hashlib.sha256((L/rel).read_bytes()).hexdigest()==h,rel
for phase in ('before','after'):assert json.loads((W/(phase+'-result.json')).read_text())['failed']==0
assert 'PASS 2' in (W/'official.log').read_text()
E.mkdir(parents=True,exist_ok=True)
for p in W.iterdir():
 if p.is_file() and p.suffix in ('.py','.gd','.md','.json','.log','.diff','.png'):shutil.copy2(p,E/p.name)
for folder in ('before','after','runner','originals','prepared','first-baseline','first-installed-attempt','concurrent-at-finish'):
 if (W/folder).exists():shutil.copytree(W/folder,E/folder,dirs_exist_ok=True)
(E/'HANDOFF.md').write_text((W/'HANDOFF.md').read_text().replace('../ui/continue-load-2026-10-26/README.md','README.md'),encoding='utf-8')
for rel in ('docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-26.md'):
 p=W/'docs-before-publication'/rel;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,p)
hand=L/'docs/team/CODEX_HANDOFF_2026-10-26_continue_load.md';shutil.copy2(W/'HANDOFF.md',hand)
entry='''## Codex: A5 Continue load under black (October 26, 2026)

A5/LF7-15 COMPLETE in main_menu.gd only. Confirm/title/music fade first, save and threaded destination load/poll after opaque black, covered instantiate/state transfer. Highbank inherits shared cover/reveals it; dungeon uses its own card, suspend consumed only after accepted dispatch. Failure restores menu/music/focus, preserves suspend bytes, retry works; missing save disables Continue without loading. Handler779.303 ms baseline to0.175 normal/0.232 reduced/0.161 Warren, not total-arrival/audio latency. Native52/52 functional, baseline8/8, official save_check/opening_flow2 PASS; raw exit warnings216 baseline/309 matrix retained and untriaged, no clean-exit claim. [Captures, metrics, source and logs](ui/continue-load-2026-10-26/README.md); [handoff](team/CODEX_HANDOFF_2026-10-26_continue_load.md). Current campaign already skipped old route preload; legacy opening_flow actually uses it, now requested only on legacy New Game, Begin verified. Route1 untouched, no901 ms boot claim. Forty-seven other menu methods and critical shared/destination sources exact, prior Claude work preserved. Source issues: no new functional Continue issue; resource exit retention/prior neutral-motion follow-up remain. Proposed recovery toast documented. Next B7 icon/plain splash/Windows preset, check templates before export. C6 OFF, town/exterior HOLD. No real save/art/generation/paid call/rules/Route1/message/commit.

'''
p=L/'docs/AI_COLLABORATION.md';s=p.read_text(encoding='utf-8');title,rest=s.split('\n',1);p.write_text(title+'\n\n'+entry+rest.lstrip('\n'),encoding='utf-8')
p=L/'docs/team/CODEX_TASKS_2026-10-26.md';s=p.read_text(encoding='utf-8');p.write_text(s.rstrip()+'''\n\n## Codex result, October 26: A5 / LF7-15 Continue without visible loading freeze

COMPLETE/INSTALLED in main_menu.gd only. Confirm and existing title/music fade start before save/destination work. Opaque black is rendered before load_threaded_request/poll; getter only after LOADED, instantiate/state transfer covered. Highbank keeps shared black for its own card/build/reveal; suspended dungeon uses its existing card, shared cover releases, take_suspended called only after accepted scene change. Failure restores menu/music/focus and preserves suspend bytes; real retry resumes. Missing save disables Continue and starts no load. Proposed utility toast 'Could not continue. Please try again.' Native52/52 functional: normal/cold and reduced/cached Highbank, Warren B2F party/seed/HP/turn/suspend-once, duplicates, opaque covers at request, save preservation through load/failure, retry/missing save, lazy legacy route. Baseline8/8; official save_check/opening_flow2 PASS. Handler779.303 ms to0.175 normal/0.232 reduced/0.161 Warren; confirmation-player creation778.428 to0.065 ms, not total arrival or audible latency. Native raw exit warnings216 baseline/309 matrix retained/untriaged, no clean-exit claim. [Captures, frame/response metrics, commands/logs, originals, diff and hashes](../ui/continue-load-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_continue_load.md).

Source issues for Claude: no new functional Continue issue. The unused-route condition was false for legacy: opening_flow._begin_journey instantiates _route_scene. Campaign already no-ops that preload. Boot request removed from base; legacy New Game alone requests it, guarded against duplicate requests/polls, Begin verified. FIRST_SCENE/Route1 files retained, no campaign901 ms boot improvement claimed. Forty-seven other menu methods exact including C1/C6/input/sound/settings/journey dispatch; TeamState/Highbank/dungeon/opening/creature/shared UI/project exact, prior uncommitted Claude work preserved. Fixture half-read warm-up shutdown and freed-node lambda errors corrected, diagnostic logs retained; no production repair after install. Resource-exit retention/prior shared neutral-motion follow-up remain documented. Next actionable B7 icon/plain splash/Windows preset; check export templates before test export. C6 OFF pending words, town/exterior HOLD pending named slot queue. No real save/new art/generation/paid call/rules/Route1/message/commit. Native visuals reviewed by Codex, Preston approval not claimed.
''',encoding='utf-8')
for p in (E/'README.md',E/'HANDOFF.md',hand):
 for target in re.findall(r'\]\(([^)]+)\)',p.read_text()):
  if '://' not in target:assert (p.parent/target).exists(),(p,target)
for rel,h in hashes.items():assert hashlib.sha256((L/rel).read_bytes()).hexdigest()==h
print('Published A5 evidence/handoff and appended queue result. One owned source file.')
