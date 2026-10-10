from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def cp(s,d):d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(s,d)
owned=['assets/sprites/world/wayline_hall_2026_10_09/wayline_hall_native.png','scripts/town/wayline_hall_painter.gd','scripts/town/highbank_ground_painter.gd']
baseline=json.loads((W/'baseline.json').read_text())
assert sha(L/owned[-1])==baseline[owned[-1]],'Concurrent ground painter change; rebase first'
for r in owned[:-1]:assert not (L/r).exists(),'Concurrent new asset/painter: '+r
concurrent={r:{'before':h,'now':sha(L/r) if (L/r).exists() else None} for r,h in baseline.items() if not (L/r).exists() or sha(L/r)!=h}
(W/'concurrent-before-install.json').write_text(json.dumps(concurrent,indent=2))
for name in ['hall_check','fallback_check']:
    txt=(W/(name+'.log')).read_text()
    assert 'SCRIPT ERROR' not in txt and 'Parse Error' not in txt and 'Error loading' not in txt
assert 'passes=13 failures=0' in (W/'hall_check.log').read_text()
assert 'previous ground/blockout exact: true' in (W/'fallback_check.log').read_text()
P=W/'archive';P.mkdir(exist_ok=True)
for folder in ['originals','candidate','review','sources']:
    shutil.copytree(W/folder,P/folder,dirs_exist_ok=True)
for f in W.glob('*.log'):cp(f,P/'logs'/f.name)
for ext in ['*.gd','*.py','*.ps1']:
    for f in W.glob(ext):cp(f,P/'reproduction'/f.name)
for f in ['baseline.json','concurrent-before-install.json','art-preparation.json','generation-prompts.txt']:cp(W/f,P/f)
(P/'.gdignore').write_text('')
(P/'README.md').write_text('''# Wayline Hall exterior proposal, October 9, 2026

The second Highbank art slice, following Claude's hub-layout handoff and Preston's “go.” A dedicated moss-roofed stone-and-root guild exterior replaces only the existing Hall block. Amber round windows and lanterns connect it to the approved creature-village menu. This is an implemented exterior proposal for Preston to review, not new canon or a completed guild service.

## Installed

- One native 240x144 transparent PNG, `assets/sprites/world/wayline_hall_2026_10_09/wayline_hall_native.png`.
- One small `scripts/town/wayline_hall_painter.gd` that restores the existing ground under alpha corners and blends only within the Hall's fixed footprint.
- A short hook in `scripts/town/highbank_ground_painter.gd`. No town controller, camera, layout, path, door, collision, service rule, creature, menu, prologue, save or dungeon edit.

The footprint is exactly (456,24), 240x144; the existing door remains tile (24,6), local (120,120), with its centre inside the dark entrance. The first generated entrance was too far right, so a second imagegen call corrected the front portal before native preparation. Source PNGs and both prompts are archived untouched. Nearly invisible outer padding was cropped using alpha > 1 bounds; all alpha inside the crop was retained; nearest-neighbour preparation provides the native canvas. No palette edit, creative Python image edit or old sprite replacement. Two built-in imagegen calls, zero Retro Diffusion calls; no dollar cost is inferred from unavailable receipts.

## Verification

13 native assertions pass: exact native dimensions; Hall rectangle visibly replaced; every pixel outside that rectangle byte-exact to installed ground; immutable collision/layout; entrance centre opaque and dark; repeatable rendering; real movement to approach and exact door; native E key through the current controller opens the existing guild panel; facade neighbours blocked; shared creature finish remains. With the optional Hall painter physically absent from the isolated review copy, the previous ground/blockout picture returns byte-for-byte.

The source, prepared PNG, full town picture, normal approach/service native captures and full-building native capture were inspected. `hall_overview.png` uses a review-only camera composition and hides labels/HUD to show the whole exterior. `hall_approach.png` and `hall_service.png` use the actual game camera. Normal camera scroll can crop the roof near the southern approach, as in the existing layout; the camera was not changed.

Final native logs contain no script/resource errors; the existing Windows root-certificate diagnostic remains. This slice does not certify a full dungeon clear. Prior town-loop testing is retained in the ground archive, and its controller/state/dungeon files were not edited here.

Run F6 on `scenes/hub_town.tscn`, or New Game through the creature opening. Walk north from Market Street to the Hall's steps, face north, and press E. The current guild panel remains Claude's service description; jobs, roster rules and disk saves are later work. Other buildings remain blockout.

## Handoff

Authority: `docs/world/hub-layout-2026-10-09/README.md` and `scripts/town/town_layout.gd`. Visual references inspected: installed `creature_village_2026_10_09.png` and prior `dispatch_hall_complete.png`; no old artwork overwritten. No external game code, images, maps, text, music or numbers copied.

Next art slice: Home, exactly 120x120 at (72,72), door tile (5,7), then the shop/storage/scroll buildings one at a time. Keep the native 24px scale, creature-village architecture and dark material outlines. Preserve Claude's service/state ownership. No commit, revert, reset or stash.
''',encoding='utf-8')
entry='''## Codex: Wayline Hall exterior (October 9, 2026)

Preston's “go” advanced the hub handoff to its second art slice. Installed one original moss-roofed stone/root Hall exterior at Claude's exact (456,24) 240x144 footprint. Door tile (24,6) is untouched; native walking and E still reach the existing guild service. Two built-in imagegen calls (new exterior, entrance correction), then conservative padding crop/nearest native preparation. No Retro charge or old asset overwrite.

Runtime scope: new `scripts/town/wayline_hall_painter.gd`, one PNG, and a short optional hook/ground capture in the installed ground painter. The actual native ground continues under transparent corners. All pixels outside the Hall's footprint compare byte-exact to the installed ground. 13 native assertions pass; physically absent-painter fallback returns the previous picture exactly. Native source/prepared/map/approach/service/overview reviewed; no final script/resource errors, existing root-certificate diagnostic remains. No dungeon-clear claim, controller/state/rules/menu/settings edit or commit.

Architecture is implemented as a proposal awaiting Preston's visual review. The service panel is still Claude's description; jobs/roster/disk saves remain later. Next: Home at its fixed 120x120 footprint. [Native previews, untouched generated sources, prompts, original painter, checks and preservation manifest](world/wayline-hall-2026-10-09/README.md).

'''
r='docs/AI_COLLABORATION.md';old=(L/r).read_bytes();cp(L/r,P/'originals'/r)
nl='\r\n' if b'\r\n' in old else '\n';split=old.index(b'\n')+1
planned=old[:split]+nl.encode()+entry.replace('\n',nl).encode()+old[split:]
(W/'collaboration.planned').write_bytes(planned)
manifest=[{'path':r,'before':sha(L/r),'source':str(W/'collaboration.planned')}]
for r in owned:manifest.append({'path':r,'before':sha(L/r) if (L/r).exists() else None,'source':str(W/'candidate'/r)})
(W/'pending-install.json').write_text(json.dumps(manifest,indent=2))
print('Packaged',len(manifest),'guarded live writes; preserved concurrent files:',len(concurrent))
