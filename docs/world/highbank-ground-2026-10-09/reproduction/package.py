from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def cp(s,d):d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(s,d)
owned=['scripts/town/hub_town.gd','scripts/town/highbank_ground_painter.gd']
baseline=json.loads((W/'baseline.json').read_text())
assert sha(L/owned[0])==baseline[owned[0]], 'Concurrent town edit; rebase before installing'
assert not (L/owned[1]).exists(), 'Painter already installed by someone else'
concurrent={r:{'before':h,'now':sha(L/r) if (L/r).exists() else None} for r,h in baseline.items() if not (L/r).exists() or sha(L/r)!=h}
(W/'concurrent-before-install.json').write_text(json.dumps(concurrent,indent=2))
for name in ['ground_check','hub_town_check','town_loop_check','fallback_check']:
    txt=(W/(name+'.log')).read_text()
    assert 'SCRIPT ERROR' not in txt and 'Parse Error' not in txt and 'Error loading' not in txt
assert 'passes=13 failures=0' in (W/'ground_check.log').read_text()
assert 'original blockout exact: true' in (W/'fallback_check.log').read_text()
P=W/'archive';P.mkdir(exist_ok=True)
for folder in ['originals','candidate','review']:
    shutil.copytree(W/folder,P/folder,dirs_exist_ok=True)
for f in W.glob('*.log'):cp(f,P/'logs'/f.name)
for f in W.glob('*.gd'):cp(f,P/'reproduction'/f.name)
for f in W.glob('*.py'):cp(f,P/'reproduction'/f.name)
for f in ['baseline.json','concurrent-before-install.json']:cp(W/f,P/f)
(P/'.gdignore').write_text('')
(P/'README.md').write_text('''# Highbank ground pass, October 9, 2026

Implemented proposal: the first art slice in Claude's hub-layout handoff. Moss-green bluff, warm stone paving along the exact road mask, earthen terraces, cut clay ledges, stair treads at the two existing cliff crossings, and muted river water. Ground is drawn from scratch in Godot at native 24px scale. Broad close-tone islands replace the first review's noisy patchwork. No image generation, paid art calls, asset PNG edits, or external game data.

Runtime edits: new `scripts/town/highbank_ground_painter.gd`; `hub_town.gd` adds a painter delegation and names the original `paint_blockout()`. Its complete original picture remains the fallback when the painter is absent. The remainder of the controller is unchanged.

Claude's `town_layout.gd` is the exact contract. No doors, path tiles, footprints, collision, service roles, team state, creature sprites, menu, prologue or dungeon rules changed. Existing building and service-spot pixels remain exact. Open area rectangles get a quiet perimeter and ground underneath; their service locations remain exact. Buildings are still the blockout, deliberately awaiting the next art slice. This is not a finished town or implemented shop/job/roster service.

## Native verification

- `ground_check`: 13 assertions pass, including native D-key state through the current controller, movement across both stairs, blocked cliff/water, all 13 open doors, exact building/spot pixels, repeatable texture, dimensions and shared creature finish.
- `hub_town_check`: no building overlaps, all 13 doors reachable from Home, ferry reachable; real four-step movement and partner following; all 12 non-dungeon places answer; walking into the Mouth triggers dispatch.
- `town_loop_check`: actual prologue to town scene change after three presses; Mouth to dungeon with the chosen party; forced clear returns bag, taught moves, IQ and clear count to the Hall steps; the next run receives them; forced faint returns with the existing bag-loss policy. This checks transitions/state transfer, not an organically played full dungeon or combat balance.
- `fallback_check`: with the new painter physically absent in the isolated review copy, the original blockout returns byte-for-byte.
- Native map and five viewport stills inspected. Final logs have no script/resource errors. Existing Windows root-certificate diagnostic remains.

Run F6 on `scenes/hub_town.tscn`, or New Game through the installed creature opening. WASD/arrows move; E interacts. Claude already wired the scene loop before this art pass, and that work is preserved. Team data still lasts only for the running session; disk saves remain Claude's work.

## References and next handoff

Authority: `docs/world/hub-layout-2026-10-09/README.md` and `scripts/town/town_layout.gd`; Claude's synthesis and positions are used without reinterpretation. Existing `docs/research/pmd-video-notes-2026-10-09.md` supplies scale/context. No foreign images, maps or sprites are imported.

Before the new hub handoff arrived, Firecrawl was used for a bounded rescue-board inspection: [pmd-red include index](https://github.com/PikalaxALT/pmd-red/tree/master/include) and [mail interface](https://github.com/PikalaxALT/pmd-red/blob/master/include/pokemon_mail.h). The GitHub targeted query yielded no useful content; reading the raw header only verified separate headline/body responsibilities, not a complete job lifecycle. That research did not determine the terrain or add services. No code, data, numbers, game text, art or music from the reference was copied.

Next art slice: Wayline Hall, exactly 240x144px at (456,24), door tile (24,6). It remains a creature village building proposal for Preston to review. Shop/storage/job rules stay with Claude. No commit, reset, revert or stash.
''',encoding='utf-8')
entry='''## Codex: Highbank ground and Market Street (October 9, 2026)

Preston supplied Claude's hub-layout handoff while the guild slice was being inspected. Adopted the new town contract and existing prologue/town/Hollow/return wiring; no competing hall/session wrapper was built. Installed the first art slice: native moss ground, warm stone paving, clay cliff edges, quiet terraces/river and stair treads on the existing two cliff crossings. Only runtime edit to Claude's controller is paint delegation; original complete blockout stays as fallback. New painter in `scripts/town/highbank_ground_painter.gd`.

13 native ground assertions pass; existing hub check reports all doors/ferry reachable, all 12 services answer, movement/following and Mouth dispatch intact. Existing town-loop check confirms real scene changes and record carry on forced clear/faint; no organically completed dungeon claimed. Physically absent-painter fallback returns exact original pixels. Native previews inspected, no script/resource errors; existing root-certificate diagnostic remains. Exact layout, buildings/spot pixels, menu, creature art, prior backups and Claude's state/dungeon changes preserved. No generation, PNG changes, settings edit or commit.

Initial ground art is implemented and native-reviewed, not visually approved by Preston. Buildings remain blockout; next is Wayline Hall at its fixed 240x144 footprint and door. Services/disk saves stay with Claude. [Previews, original controller, tests and preservation manifest](world/highbank-ground-2026-10-09/README.md).

'''
r='docs/AI_COLLABORATION.md';old=(L/r).read_bytes();cp(L/r,P/'originals'/r)
nl='\r\n' if b'\r\n' in old else '\n';split=old.index(b'\n')+1
planned=old[:split]+nl.encode()+entry.replace('\n',nl).encode()+old[split:]
(W/'collaboration.planned').write_bytes(planned)
manifest=[{'path':r,'before':sha(L/r),'source':str(W/'collaboration.planned')}]
for r in owned:manifest.append({'path':r,'before':sha(L/r) if (L/r).exists() else None,'source':str(W/'candidate'/r)})
(W/'pending-install.json').write_text(json.dumps(manifest,indent=2))
print('Packaged review and guarded',len(manifest),'live writes; concurrent files preserved:',list(concurrent))
