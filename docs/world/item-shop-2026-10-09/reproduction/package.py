from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def cp(s,d):d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(s,d)
owned=['scripts/creature_opening.gd','assets/sprites/world/item_shop_2026_10_09/item_shop_native.png','scripts/town/item_shop_painter.gd','scripts/town/highbank_ground_painter.gd']
baseline=json.loads((W/'baseline.json').read_text())
rebased=json.loads((W/'rebase-owned.json').read_text())
for r in owned:
    if r in baseline:assert sha(L/r)==rebased.get(r,baseline[r]),'Concurrent edit: '+r
    else:assert not (L/r).exists(),'Concurrent new file: '+r
concurrent={r:{'before':h,'now':sha(L/r) if (L/r).exists() else None} for r,h in baseline.items() if not (L/r).exists() or sha(L/r)!=h}
(W/'concurrent-before-install.json').write_text(json.dumps(concurrent,indent=2))
for name in ['title_check','shop_check','hall_approach_check','fallback_check']:
    s=(W/(name+'.log')).read_text()
    assert not any(e in s for e in ['SCRIPT ERROR','Parse Error','Error loading'])
assert 'passes=13 failures=0' in (W/'shop_check.log').read_text()
assert 'passes=6 failures=0' in (W/'hall_approach_check.log').read_text()
assert 'foreground_actors_and_shadows=0 title_ready=true new_game_opens_prologue=true' in (W/'title_check.log').read_text()
assert 'previous ground/blockout exact: true' in (W/'fallback_check.log').read_text()
P=W/'archive';P.mkdir(exist_ok=True)
for folder in ['originals','candidate','review','sources']:shutil.copytree(W/folder,P/folder,dirs_exist_ok=True)
for f in W.glob('*.log'):cp(f,P/'logs'/f.name)
for ext in ['*.gd','*.py','*.ps1']:
    for f in W.glob(ext):cp(f,P/'reproduction'/f.name)
for f in ['baseline.json','concurrent-before-install.json','concurrent-at-menu-rebase.json','rebase-owned.json','art-preparation.json','generation-prompts.txt']:cp(W/f,P/f)
(P/'.gdignore').write_text('')
(P/'README.md').write_text('''# Title cleanup, Item Shop and Hall approach, October 9, 2026

Preston requested removal of title creatures, continuation from Home, and a wider Hall approach. The title now shows the village and lettering without the foreground Punchybun/Cinderhide sprites or their shadows. Original animation PNGs, lighting actor script and backups are retained. The inherited ambient/launch loop continues; New Game still opens the creature prologue.

Claude concurrently added the title theme. Creature removal was rebased onto his current file, retaining the exact music hookup and Options volume behavior. Both initial menu and current-with-theme originals are retained. The rebased native title smoke also checks the theme resource.

## Shop exterior proposal

One new transparent native 144x120 sprite: `assets/sprites/world/item_shop_2026_10_09/item_shop_native.png`. Moss/root roof and sandstone match Home and Hall; a muted red canopy shelters berries, lamp oil and stones. `scripts/town/item_shop_painter.gd` blends only within world (744,72), size 144x120. Door remains tile (33,7), native centre (60,108), opaque and dark. The existing shop service remains a description; purchases/economy are not built here.

One built-in imagegen call, generate mode, transparent background; zero Retro calls. Prompt is `generation-prompts.txt`, untouched generated source is `sources/shop_generated_original.png`. Technical alpha > 1 padding crop and nearest resize to the fixed footprint; alpha inside retained. No palette edit or creative Python edits. No existing asset replaced. Cost is not inferred without receipts. Installed Home/Hall inspected before generation; no external game assets/code copied.

## Hall approach correction

Preston: “the door for wayline hall isn't lined up with the path could just used widened.” The visible paving is now three tiles wide, x23..25 at y7..8, world (552,168), size 72x48. Its centre x588 matches the unchanged door tile (24,6). Tile x25 was already walkable grass. No layout/collision/door change, no Hall sprite edit. Joined paving can also change the two-pixel seam with Market Street at y216..217. Every pixel outside Shop and the bounded Hall apron/seam rectangle (552,168), 72x50, remains byte-exact. This cosmetic paving extension is recorded for Claude here; his canonical `PATHS` and controller are untouched.

## Verification

13 Shop native assertions pass: correct dimensions, replacement, bounded pixel preservation, immutable layout, doorway, determinism, real walking/E, facade and shared Finish. Six Hall assertions pass: exterior byte-exact, visible extension, already-walkable strip, real movement from it to approach, native E guild service and exact doorway. Title smoke confirms zero foreground actors/shadows, visible menu/title and New Game button opening the prologue. Removing Shop painter physically returns the exact wider-apron ground/Home/Hall baseline; the requested apron is independently retained.

Native captures reviewed: title, Shop service/overview, Hall wider approach. Overview captures use review-only camera and hidden HUD/labels; actual service captures use the game camera. Southern normal views can crop roofs as before. No runtime camera edit. Logs contain no script/resource errors; the pre-existing Windows certificate diagnostic remains. Live import/render verification and preservation hashes are recorded in final logs and `installation.json`. No full dungeon-clear claim.

F5 shows the title. F6 on `scenes/hub_town.tscn` shows the town. Face north from (33,8) and press E for Shop; (24,7) for Hall. Services/disk saves remain Claude's later work. Next exterior: Storage, then Scroll Keeper, one at a time.

Runtime scope: menu script removal, new Shop PNG/painter, small capture/hook and visual apron mask in the ground painter. Creature art, title art, Home/Hall, original backups, Claude dungeon/state and project settings are preserved. No commit, reset, revert or stash. Source-of-truth remains the hub-layout handoff and `town_layout.gd`.
''',encoding='utf-8')
entry='''## Codex: title creatures removed, Item Shop exterior, wider Hall approach (October 9, 2026)

Preston requested removal of title creatures and continuation after Home, then flagged Hall/approach alignment. Removed foreground Punchybun/Cinderhide and their shadows from `scripts/creature_opening.gd`; preserved original animation assets/lighting script, village, wordmark and New Game prologue. Installed Item Shop exterior at exact (744,72) 144x120, unchanged door (33,7). One built-in imagegen call, source/prompt archived; zero Retro calls.

Hall paving is now visually three tiles wide, x23..25 y7..8, centred at x588 on door (24,6). The added strip was already open grass. Claude: this is cosmetic paving only; `town_layout.gd`, `PATHS`, collisions and controller are unchanged. Original Hall PNG and painted exterior remain byte-exact. Joined street seam may change within the bounded 72x50 apron/seam rectangle (552,168).

13 Shop plus six Hall native assertions pass; real movement/native E still reach both service descriptions. Title smoke confirms no foreground actors/shadows, ready title and New Game button opening the prologue. Outside Shop and Hall apron/seam every pixel compares exact. Physically absent Shop painter preserves the corrected ground/Home/Hall baseline. No rule/state/dungeon/camera/settings change or full-clear claim, original art/backups preserved, no commit. Shop architecture remains a visual proposal; economy and disk saves are later. Next: Storage, then Scroll Keeper. [Previews, original source/prompt, backups, checks and preservation manifest](world/item-shop-2026-10-09/README.md).

'''
r='docs/AI_COLLABORATION.md';old=(L/r).read_bytes();cp(L/r,P/'originals'/r)
nl='\r\n' if b'\r\n' in old else '\n';split=old.index(b'\n')+1
(W/'collaboration.planned').write_bytes(old[:split]+nl.encode()+entry.replace('\n',nl).encode()+old[split:])
manifest=[{'path':r,'before':sha(L/r),'source':str(W/'collaboration.planned')}]
for r in owned:manifest.append({'path':r,'before':sha(L/r) if (L/r).exists() else None,'source':str(W/'candidate'/r)})
(W/'pending-install.json').write_text(json.dumps(manifest,indent=2))
print('Packaged',len(manifest),'guarded writes. Concurrent files preserved:',len(concurrent))
