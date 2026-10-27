from pathlib import Path
import hashlib,json,shutil,re
from PIL import Image,ImageDraw
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');E=L/'docs/ui/starter-cards-2026-10-26'
hashes=json.loads((W/'installed-files.json').read_text())
for rel,h in hashes.items():assert hashlib.sha256((L/rel).read_bytes()).hexdigest()==h,rel
assert json.loads((W/'after-result.json').read_text())['failed']==0
assert len(json.loads((W/'real-flow-result.json').read_text()))==3
assert 'PASS 2' in (W/'official.log').read_text()
# A comparison sheet from native screenshots, never a game art edit.
im=Image.new('RGB',(1152,1344),(12,14,24));draw=ImageDraw.Draw(im)
for i,(label,p) in enumerate([('BEFORE',W/'before/cards.png'),('AFTER',W/'after/cards.png')]):
 draw.text((16,i*672+7),label,fill=(240,225,180));im.paste(Image.open(p).convert('RGB'),(0,i*672+24))
im.save(W/'before-after.png')
E.mkdir(parents=True,exist_ok=True)
for p in W.iterdir():
 if p.is_file() and p.suffix in ('.py','.gd','.md','.json','.log','.diff','.png'):shutil.copy2(p,E/p.name)
for folder in ('before','after','hero0','hero1','hero2','runner','originals','prepared','first-attempt','concurrent-at-finish'):
 if (W/folder).exists():shutil.copytree(W/folder,E/folder,dirs_exist_ok=True)
(E/'HANDOFF.md').write_text((W/'HANDOFF.md').read_text().replace('../ui/starter-cards-2026-10-26/README.md','README.md'),encoding='utf-8')
# Snapshot fresh collaboration documents, then append/prepend without replacing anyone's work.
for rel in ('docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-26.md'):
 p=W/'docs-before-publication'/rel;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,p)
hand=L/'docs/team/CODEX_HANDOFF_2026-10-26_starter_cards.md';shutil.copy2(W/'HANDOFF.md',hand)
entry='''## Codex: C8 starter cards and fresh-press confirmation (October 26, 2026)

C8 COMPLETE/INSTALLED. Cards ignore accept for0.4s and need release/fresh press, then <Name>? Yes / No defaults to No; No/Cancel returns unchanged, Yes commits once. Full-body front idles centred at one shared whole scale1x, essence tint, title names, original prompt always visible, full-contrast binding hints, cursor/confirm/presence_swell sounds. Newest whole-scale direction supersedes older3x. Native47/47 plus actual title-to-riverbank3 runs87/87 clean, all starters/both partner options/reduced motion; official2 PASS, known raw exit warnings retained. [Before/after and proof](ui/starter-cards-2026-10-26/README.md); [handoff](team/CODEX_HANDOFF_2026-10-26_starter_cards.md). Public flow regression now covers two-press Storm and Yes confirmation, Claude's partner gate retained. Story, C9/fades/flash and concurrent Claude work preserved. No new source issue; prior shared neutral-motion follow-up remains. Next Storm pixel soul light, then C5. C6 OFF, town/exterior HOLD; hint labels proposed, Preston visual approval not claimed. Private profiles only, no real save/art/generation/paid call/rules/Route1/message/commit.

'''
p=L/'docs/AI_COLLABORATION.md';s=p.read_text(encoding='utf-8');title,rest=s.split('\n',1);p.write_text(title+'\n\n'+entry+rest.lstrip('\n'),encoding='utf-8')
p=L/'docs/team/CODEX_TASKS_2026-10-26.md';s=p.read_text(encoding='utf-8');p.write_text(s.rstrip()+'''\n\n## Codex result, October 26: C8 starter cards and confirmation

COMPLETE/INSTALLED. First0.4s plus release/fresh press protects the cards from a reading/held/early accept. <Name>? Yes / No defaults to No, No/Cancel returns to the same creature, Yes commits once. Existing full-body front idles centred at shared whole scale1x, essence tint, title-role names, immediate original choice prompt, full-contrast live binding hints. Cursor for movement; confirm plus presence_swell for commit, all on UI. Latest section11 item2's whole-scale instruction used; older3x does not fit these detailed bodies. Hint labels review/confirm/back remain proposed; story/creature constants exact. Native47/47 clean, real title-to-riverbank all3 starters87/87 clean with both partner options/reduced motion, official opening_flow/soul_prologue2 PASS with known raw exit warnings. Fresh baseline2/2. [Before/after, originals, commands, logs and diff](../ui/starter-cards-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_starter_cards.md).

Source issues for Claude: none new. Public opening_flow now tests first-press arming/second-press Storm skip plus starter confirmation, closing C7's staged driver follow-up; existing12-frame partner gate preserved. Shared UI.pressed neutral-motion follow-up still documented; owned handlers feed neutral events already. Eight methods exact including C9 and black handoffs. Concurrent mouth_escape.gd and road_check.gd preserved/archived. Only soul_prologue.gd and opening_flow_check.gd installed. Initial fixture failures retained/documented; early guard down consumption fixed and tested. Next Storm pixel soul light, then C5 splash/return visit. C6 stays OFF, town/exterior HOLD until named slot queue; no real save/art/generation/paid call/rules/Route1/message/commit. Native captures reviewed by Codex; Preston approval not claimed.
''',encoding='utf-8')
# Every local link in the authored evidence resolves.
for p in [E/'README.md',hand]:
 for target in re.findall(r'\]\(([^)]+)\)',p.read_text()):
  if '://' not in target:assert (p.parent/target).exists(),(p,target)
print('Published evidence, handoff and appended result; two owned source hashes still exact.')
