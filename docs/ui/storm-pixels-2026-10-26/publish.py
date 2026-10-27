from pathlib import Path
import json,hashlib,shutil,re
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');E=L/'docs/ui/storm-pixels-2026-10-26'
hashes=json.loads((W/'installed-files.json').read_text())
for rel,h in hashes.items():assert hashlib.sha256((L/rel).read_bytes()).hexdigest()==h,rel
assert json.loads((W/'after-result.json').read_text())['failed']==0
assert len(json.loads((W/'real-flow-result.json').read_text()))==2
assert 'PASS 2' in (W/'official.log').read_text()
E.mkdir(parents=True,exist_ok=True)
for p in W.iterdir():
 if p.is_file() and p.suffix in ('.py','.gd','.json','.log','.md','.png','.diff'):shutil.copy2(p,E/p.name)
for folder in ('before','after','normal','reduced','runner','originals','prepared','first-baseline','first-flow','concurrent-at-finish'):
 if (W/folder).exists():shutil.copytree(W/folder,E/folder,dirs_exist_ok=True)
# The team handoff and the evidence copy have different relative link roots.
(E/'HANDOFF.md').write_text((W/'HANDOFF.md').read_text().replace('../ui/storm-pixels-2026-10-26/README.md','README.md'),encoding='utf-8')
for rel in ('docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-26.md'):
 p=W/'docs-before-publication'/rel;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,p)
hand=L/'docs/team/CODEX_HANDOFF_2026-10-26_storm_pixels.md';shutil.copy2(W/'HANDOFF.md',hand)
entry='''## Codex: C20 Storm pixel soul, A3 completed (October 26, 2026)

C20 PIXEL LIGHT COMPLETE/INSTALLED in storm_open.gd only. Four circles replaced by authored25x25 cluster, stepped blue-white values, whole-pixel row runs and rounded bloom on the existing native transparent3x layer. All10 other original methods/state fields, bob/opacity inputs and white overlay exact, including reduced lightning, animation, skip/audio/black handoff. Native visual21/21 clean; baseline15/15 clean; actual natural normal/reduced title-to-riverbank68/68 clean verbose, descent/landing captures plus starter/partner/correct-team checks. Official storm_open/opening_flow2 PASS, known raw exit warnings retained. [Before/after, sources and proof](ui/storm-pixels-2026-10-26/README.md); [handoff](team/CODEX_HANDOFF_2026-10-26_storm_pixels.md). Source issues: none new, shared neutral-motion follow-up still documented. Claude's hub_town/walk_fix edits preserved/archived. A3 tracked opening pieces now complete; next ordered A4/C5 splash return visit, auto-dismiss/key mismatch. C6 OFF, town/exterior HOLD pending named slot queue. Codex-reviewed visuals, Preston approval not claimed. No real save/new assets/generation/paid call/rules/Route1/message/commit.

'''
p=L/'docs/AI_COLLABORATION.md';s=p.read_text(encoding='utf-8');title,rest=s.split('\n',1);p.write_text(title+'\n\n'+entry+rest.lstrip('\n'),encoding='utf-8')
p=L/'docs/team/CODEX_TASKS_2026-10-26.md';s=p.read_text(encoding='utf-8');p.write_text(s.rstrip()+'''\n\n## Codex result, October 26: C20 Storm pixel soul, A3 completed

COMPLETE/INSTALLED in storm_open.gd only. Four circle calls replaced by authored25x25 pixel cluster, white core, stepped blue-white light and faint uneven halo. Horizontal row runs and rounded rectangle edges keep the existing native384x216 transparent layer/nearest3x bloom crisp. Old outer growth reach retained. All10 other original methods, state fields, bob/opacity inputs and full-screen white draw exact; reduced lightning, descent, rain/shader, audio, skip and black handoff preserved. No new image assets or copy. Native21/21 visual assertions clean, original baseline15/15 clean; actual natural normal/reduced title-to-riverbank68/68 clean verbose logs, captured descent/landing, starter confirmation, both partner options and expected team. Official storm_open/opening_flow2 PASS, known raw exit-resource warnings retained. [Before/after, originals, diff, commands, logs and source verification](../ui/storm-pixels-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_storm_pixels.md).

Source issues for Claude: none new. Prior shared UI.pressed neutral-motion follow-up remains documented, owned handlers already feed neutral events. Public regression source untouched this turn. Concurrent hub_town.gd and walk_fix tool changes preserved/archived. First paused-fixture veil/teardown issue and first natural34-pass run with2 exit objects retained; established private shared-blip cleanup yielded clean final native flows, no production teardown fix claimed. A3's tracked input/skip, hints, white-outs, C8 cards/confirmation/sound, C9 band/shaft/backdrop and Storm pixel light are now complete. Next ordered A4/C5 splash return-visit skip, auto-dismiss/key wording and remaining LV-24. C6 New Game replacement prompt stays OFF, town/exterior HOLD pending named slot queue. No real save/new assets/generation/paid call/rules/Route1/message/commit. Native visuals reviewed by Codex, Preston approval not claimed.
''',encoding='utf-8')
for p in (E/'README.md',E/'HANDOFF.md',hand):
 for target in re.findall(r'\]\(([^)]+)\)',p.read_text()):
  if '://' not in target:assert (p.parent/target).exists(),(p,target)
for rel,h in hashes.items():assert hashlib.sha256((L/rel).read_bytes()).hexdigest()==h
print('Published checked Storm pixel light, handoff and appended queue result. One owned production file.')
