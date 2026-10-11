from pathlib import Path
import hashlib,json,shutil
from PIL import Image
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');P=L/'docs/design/pilot-waking-2026-10-10'
for name,marker in [('waking_check','WAKING 95/95 PASS'),('soul_check','RESULT: the soul prologue works'),('town_loop_check','TOWN LOOP PASS')]:
    s=(W/('live-'+name+'.log')).read_text(encoding='utf-8')
    assert marker in s,name
    assert not any(x in s for x in ['SCRIPT ERROR','Parse Error','ObjectDB instances leaked','Resources still in use','FAIL']),name
assert 'BEFORE captured' in (W/'live-before_check.log').read_text(encoding='utf-8')
for phase in range(3):
    p=W/('review/live/wake-'+str(phase)+'.png')
    with Image.open(p) as im:assert im.size==(1152,648) and len(im.getcolors(1000000) or [])>100
for folder in ['review','candidate','concurrent']:
    if (W/folder).exists():shutil.copytree(W/folder,P/folder,dirs_exist_ok=True)
for name in ['setup.py','edit.py','restore_marker.py','prepare_checks.py','package.py','install.ps1','pending.json','refine.py','refine-install.ps1','refine-pending.json','baseline.json','audit.py','audit.json','publish.py','run.py','waking_check.gd','soul_check.gd','town_loop_check.gd','before_check.gd']:
    q=P/'checks'/name;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(W/name,q)
for p in W.glob('*.log'):
    q=P/'checks'/p.name;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
audit=json.loads((W/'audit.json').read_text(encoding='utf-8'))
text='''# Pilot waking scene, handoff job 12

Implemented October 10, 2026. The first three beats follow Preston's approved pilot outline. The new lines and distant architecture are proposals for his review, not newly approved canon.

## In the game

The generic enclosed room becomes a freshly collapsed, wet clay bank. Loose sealed letters lead toward the trainee; across the river, light spills from the risen Hollow and its wet stone approach. Existing Rootbank clay and Hollow stone materials supply the native 384×216 staging, nearest 3×. Water reflections drift gently; Reduce Motion freezes them. The creatures keep their installed sprite finish and stand above the heading, with contact shadows.

The awakening names the collapse, rising Hollow and some memory of being human. The voice belongs to a Wayline trainee collecting mail the river tore loose, drawn down by a quiet call. The agreement names the no-solo-route rule and the trainee's repeated refusal for lacking a partner: the player needs a guide, the trainee needs a partner, and they head for Highbank together.

| Original waking | Installed waking |
| --- | --- |
| ![Original waking](review/before/wake-0.png) | ![Riverbank waking](review/live/wake-0.png) |
| ![Original companion](review/before/wake-1.png) | ![Wayline trainee](review/live/wake-1.png) |
| ![Original agreement](review/before/wake-2.png) | ![Highbank agreement](review/live/wake-2.png) |

Original previews render the exact archived script, using the same Tallowroot/Rimefin pairing as installed previews. The hero/partner selector, soul-selected identity, dialogue frame/portrait, focus/input, fade, town transition and team metadata are retained. The eight existing actor, form, label, button, choice, Back, advance and input methods compare exactly with the original.

## Verification

- Installed native Godot Compatibility run: **95/95 waking checks**. All three soul identities and all six permitted pairings, fitted two/three-line dialogue, aligned 948px choice panels in every phase, house-finished actors/portraits, animated/frozen river, clear heading, actual mouse/Enter/Back and the selected Rimefin/Kithflare team arriving in Highbank. The final Back label is shortened to “Change partner” so it fits its existing button width.
- Claude's current soul check reaches chosen Tallowroot, retains its Roots line and offers no second starter picker.
- Claude's current town-loop check, with added result assertions, exercises real scene changes: prologue → town → dungeon → clear → town → second run → faint → town. Items, taught moves and IQ carry through the clear; carried oil is lost on faint. The existing fresh-run reedberry remains, as dungeon.gd explicitly specifies. An initial overly strict empty-bag assertion was corrected to this existing rule; gameplay was not changed.
- Final live logs contain no script/parse errors or cleanup leaks. Review issues were corrected before final verification. Draft preparation scripts are working history; the installed source is archived in `candidate/`.

## Scope and preservation

Installed only `scripts/creature_prologue.gd`, the new presentation-only `scripts/ui/waking_bank.gd`, and a prepended collaboration note. Original code/notes are in `originals/`. No original PNG, title painting/wordmark, shared creature shader, palette, rules, save/state method, project settings or commit changed. The seven-form refinements, Oxbowarchon's darker jade, Sparkwick correction, Skimlet leg correction, Gruntle portrait clipping and prior art backups remain in place.

The painter borrows the existing riverbank ground primitives and Hollow material constants, without modifying their sources or dungeon layouts. Keep those contracts available when changing the dungeon painters.

Preservation audit: '''+str(audit['installed_files_exact'])+''' installed files and both original backups hash-exact; prior collaboration body retained; '''+str(audit['protected_files_exact'])+'''/'''+str(audit['protected_files'])+''' baseline protected files and '''+str(audit['asset_files_exact'])+'''/'''+str(audit['asset_files'])+''' original asset files exact. Concurrent changed paths retained: '''+str(len(audit['concurrent_changed_paths_retained']))+'''. Details: `checks/audit.json`.

## Next handoff

Job 12 is implemented and engine-verified; Preston's review of final dialogue/staging remains open. Claude owns the Guildmaster and town introduction plus later pilot story/state. No Guildmaster scene was written here. The title remains the approved creature-village painting and bare choices, and F5 remains the current development setting. Play the launch from `scenes/creature_opening.tscn` (F6), or test this slice directly from `scenes/creature_prologue.tscn` (F6).
'''
(P/'README.md').write_text(text,encoding='utf-8')
manifest={p.relative_to(P).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in P.rglob('*') if p.is_file() and p.name!='manifest.json'}
(P/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print('Published',len(manifest),'files:',P/'README.md')
