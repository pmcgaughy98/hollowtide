from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def cp(s,d):d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(s,d)
owned=['assets/sprites/world/home_2026_10_09/home_native.png','scripts/town/home_painter.gd','scripts/town/highbank_ground_painter.gd']
baseline=json.loads((W/'baseline.json').read_text())
assert sha(L/owned[-1])==baseline[owned[-1]],'Concurrent ground change: rebase first'
for r in owned[:-1]:assert not (L/r).exists(),'Concurrent new file: '+r
concurrent={r:{'before':h,'now':sha(L/r) if (L/r).exists() else None} for r,h in baseline.items() if not (L/r).exists() or sha(L/r)!=h}
(W/'concurrent-before-install.json').write_text(json.dumps(concurrent,indent=2))
for name in ['home_check','fallback_check']:
    s=(W/(name+'.log')).read_text()
    assert not any(e in s for e in ['SCRIPT ERROR','Parse Error','Error loading'])
assert 'passes=13 failures=0' in (W/'home_check.log').read_text()
assert 'previous ground/blockout exact: true' in (W/'fallback_check.log').read_text()
P=W/'archive';P.mkdir(exist_ok=True)
for folder in ['originals','candidate','review','sources']:shutil.copytree(W/folder,P/folder,dirs_exist_ok=True)
for f in W.glob('*.log'):cp(f,P/'logs'/f.name)
for ext in ['*.gd','*.py','*.ps1']:
    for f in W.glob(ext):cp(f,P/'reproduction'/f.name)
for f in ['baseline.json','concurrent-before-install.json','art-preparation.json','generation-prompts.txt']:cp(W/f,P/f)
(P/'.gdignore').write_text('')
(P/'README.md').write_text('''# Highbank Home exterior proposal, October 9, 2026

The third hub art slice follows Preston's “go”: a cozy moss-roofed root-and-stone home for the creature team. One round amber window and a doorway lantern carry the installed Wayline Hall and village menu materials into a smaller building. This is an implemented visual proposal, not new lore or a completed sleep/save service.

## Installed and runnable

- `assets/sprites/world/home_2026_10_09/home_native.png`, native 120x120, transparent corners.
- `scripts/town/home_painter.gd`, restores native ground and blends only inside Home.
- Small Home ground capture and optional painter hook in `scripts/town/highbank_ground_painter.gd`. Existing Hall composition is retained.

Claude's footprint is unchanged: world (72,72), size 120x120. Door remains tile (5,7), local (48,96), centre (60,108), inside the dark entrance. No door, collision, layout, path, town controller, camera, menu, creature, dungeon, state or project-settings edit.

F6 on `scenes/hub_town.tscn`, or New Game through the creature opening. Home is the initial spawn landmark. Face north from tile (5,8) and press E to open Claude's existing Home description. The description mentions sleep/save; those systems remain unimplemented here.

## Generation and preparation

One built-in imagegen generation call, transparent background, zero Retro Diffusion calls. Final prompt is in `generation-prompts.txt`. The untouched source is in `sources/home_generated_original.png`. No previous sprite was replaced. Technical alpha > 1 padding crop and nearest-neighbour resize to the exact footprint; all alpha inside the crop retained, original source untouched. No creative Python image edits or palette changes. Dollar cost is not inferred without receipts.

Inspected installed Hall, menu village and old human Garden Home before generation; the new asset follows the current creature village architecture. No external game assets or code were copied.

## Verification and review

13 native assertions pass: art/map dimensions, visible replacement, every pixel outside Home byte-exact to installed ground (including Hall), immutable layout/collision, opaque dark doorway centre, repeatable rendering, actual movement to approach/door, native E input opening the Home service, solid adjacent facade, shared creature finish retained. With Home painter physically absent from the isolated copy, the previous ground/Hall picture returns byte-exact. Final logs have no script/resource errors; the existing Windows certificate diagnostic remains.

`review/home_approach.png` and `review/home_service.png` show the actual game camera. `review/home_overview.png` is a native engine capture using review-only camera (0,-24) and hidden labels/HUD to display the whole building. The normal southern approach crops the roof as the existing camera scrolls; no runtime camera changes. `town_before.png`, `town_after.png` and the native surroundings crop are retained.

Live import and map comparison are recorded in `installation.json` and final logs after installation. This slice does not certify a full dungeon clear. Existing town loop and service ownership remain with Claude. Source backups and checks are retained here; no commit, reset, revert or stash.

Next: Item Shop at its existing 144x120 footprint, then Storage and Scroll Keeper, one at a time. Authority remains the hub-layout handoff and `scripts/town/town_layout.gd`.
''',encoding='utf-8')
entry='''## Codex: Highbank Home exterior (October 9, 2026)

Preston's “go” advanced the hub handoff to Home. Installed a cozy moss-roofed root/stone exterior at Claude's exact (72,72) 120x120 footprint, door tile (5,7). One built-in imagegen call, transparent source archived untouched, padding crop/nearest native preparation; zero Retro calls or original asset replacement.

Runtime scope: one new PNG, `scripts/town/home_painter.gd`, and small capture/optional hook in the existing ground painter. 13 native assertions pass including real movement and native E input to Home, opaque/dark door centre, immutable layout and every pixel outside Home byte-exact (Hall included). Physically absent Home painter returns the exact installed ground/Hall picture. Native overview and actual service captures inspected. No controller/camera/state/dungeon/menu/creature/settings edit, full-dungeon-clear claim or commit.

Exterior is implemented as a proposal for visual review. The Home panel remains Claude's description; sleep and disk saves are later work. Next: Item Shop, then Storage and Scroll Keeper. [Native previews, original source/prompt, backups, checks and preservation manifest](world/home-2026-10-09/README.md).

'''
r='docs/AI_COLLABORATION.md';old=(L/r).read_bytes();cp(L/r,P/'originals'/r)
nl='\r\n' if b'\r\n' in old else '\n';split=old.index(b'\n')+1
(W/'collaboration.planned').write_bytes(old[:split]+nl.encode()+entry.replace('\n',nl).encode()+old[split:])
manifest=[{'path':r,'before':sha(L/r),'source':str(W/'collaboration.planned')}]
for r in owned:manifest.append({'path':r,'before':sha(L/r) if (L/r).exists() else None,'source':str(W/'candidate'/r)})
(W/'pending-install.json').write_text(json.dumps(manifest,indent=2))
print('Packaged',len(manifest),'guarded writes. Concurrent files preserved:',list(concurrent))
