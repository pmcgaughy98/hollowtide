from pathlib import Path
import hashlib,json,shutil,difflib
from PIL import Image
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide')
source=R/'docs/creatures/arena-starters-2026-10-07/forms/wayling_arena_front_chosen.png'
assert source.read_bytes()==(W/'original.png').read_bytes(),'Chosen front changed; rebase first.'
protected=json.loads((W/'protected.json').read_text())
for rel,sha in protected.items():assert hashlib.sha256((R/rel).read_bytes()).hexdigest()==sha,rel
dest=R/'docs/art/wayling-source-margin-2026-10-11'
assert not dest.exists()
dest.mkdir(parents=True)
for name in ['original.png','candidate.png','prepare.py','pad.gd','run_pad.py','pad.log','verify.py','verification.json','protected.json','install.py']:
    shutil.copy2(W/name,dest/name)
readme='''# Wayling chosen-front canvas margin, October 11, 2026

Completed the remaining Small things item from Claude's Codex master queue. The chosen front had alpha bounds (8,8)-(75,96) on a 96×96 canvas, touching its bottom edge. Its source canvas is now 96×104, with eight fully transparent rows below it. Every original RGBA pixel and its coordinates remain exact. No outpainting, inferred anatomy, resizing, recolouring or resampling. This adds space around the existing feet; it does not reconstruct any missing anatomy.

The chosen source remains at docs/creatures/arena-starters-2026-10-07/forms/wayling_arena_front_chosen.png. Existing 40×40 portrait source crop (30,8)-(70,48) is exact. All 165 protected full-size/town/dungeon textures and imports, portraits, portrait builder, SceneKit and guild crew source files remain exact. Game facings, walks and portrait were not rebuilt. Native Godot Image loading/blit plus independent RGBA/alpha/crop verification confirms the mechanical preparation. Runtime gameplay was not replayed for this source-only margin change. The headless staging log includes the existing Windows certificate-store diagnostic.

Original PNG, candidate, source-preservation manifest, measurement receipt and reproducible native Godot builder are archived here. No image generator or paid call, game/rule/save edit or commit. Existing Retro Diffusion source provenance is unchanged; this is AI-assisted mechanical asset preparation, not newly drawn creature art.

![Padded chosen front](candidate.png)

All six master tasks on Codex's side, Rootbank Warren and this small source-margin follow-up are completed. Claude's six prepared crew standing-idle swap remains pending. No additional Codex job is assigned in the current master handoff.
'''
(dest/'README.md').write_text(readme,encoding='utf-8')
note="Wayling chosen-front source margin completed: 96x96 to 96x104, eight transparent rows below the feet; every original RGBA pixel/coordinate and the existing portrait crop exact. All 165 protected Wayling game sprites/imports, portraits and related tools/scripts exact. Source-only mechanical canvas preparation; no generation, gameplay change or commit. Evidence: docs/art/wayling-source-margin-2026-10-11/README.md. All currently assigned Codex work is complete; Claude's production crew-idle swap remains pending."
plans={}
for rel in ['docs/team/CODEX_TASKS_2026-10-11.md','docs/team/CODEX_START_HERE_2026-10-11.md','docs/AI_COLLABORATION.md']:
    p=R/rel;original=p.read_bytes();text=original.decode('utf-8-sig')
    if rel.endswith('CODEX_TASKS_2026-10-11.md'):
        old="- Wayling's chosen front touches the bottom edge of its canvas (its game facings are fine)."
        assert old in text
        text=text.replace(old,"- **DONE:** Wayling's chosen front now has eight transparent rows below its original pixels; game facings remain exact. See docs/art/wayling-source-margin-2026-10-11/README.md.",1)
        text+='\n\n## Wayling source margin completed, Codex October 11\n\n'+note+'\n'
    elif rel.endswith('CODEX_START_HERE_2026-10-11.md'):
        old="Small follow-up from the master list: Wayling's chosen front touches its bottom canvas edge; game facings are fine. Preserve those facings."
        assert old in text
        text=text.replace(old,'**Small follow-up DONE:** '+note,1)
        text=text.replace('## Latest completed work\n','## Latest completed work\n\n**Wayling source margin:** '+note+'\n',1)
        text=text.replace('The six-task master queue is complete except Claude\'s production task 2 idle swap.',"The six-task master queue and Wayling follow-up are complete on Codex's side. Claude's production task 2 idle swap remains pending.",1)
    else:
        text=text.replace('# Working Together on Hollowtide\n','# Working Together on Hollowtide\n\n## Codex: Wayling source margin completed (October 11, 2026)\n\n'+note+'\n',1)
    backup=dest/'originals-docs'/p.name;backup.parent.mkdir(exist_ok=True);backup.write_bytes(original)
    (dest/(p.name+'.diff')).write_text(''.join(difflib.unified_diff(original.decode('utf-8-sig').splitlines(True),text.splitlines(True),fromfile='original/'+rel,tofile='installed/'+rel)))
    plans[rel]=(original,text.encode('utf-8'))
for rel,(old,new) in plans.items():assert (R/rel).read_bytes()==old
shutil.copy2(W/'candidate.png',source)
for rel,(_,new) in plans.items():(R/rel).write_bytes(new)
assert source.read_bytes()==(W/'candidate.png').read_bytes()
for rel,sha in protected.items():assert hashlib.sha256((R/rel).read_bytes()).hexdigest()==sha,rel
a=Image.open(W/'original.png').convert('RGBA');b=Image.open(source).convert('RGBA')
assert b.crop((0,0,96,96)).tobytes()==a.tobytes()
manifest={p.relative_to(dest).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in dest.rglob('*') if p.is_file()}
(dest/'manifest.json').write_text(json.dumps(manifest,indent=2))
print('Installed padded chosen front, original archive and three scoped handoff updates. 165 protected files exact.')
