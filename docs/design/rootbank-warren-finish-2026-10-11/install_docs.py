from pathlib import Path
import json,shutil,hashlib,difflib
W=Path(__file__).parent;P=W/'package'
R=Path('C:/Users/pmcga/dev/hollowtide')
evidence='docs/design/rootbank-warren-finish-2026-10-11/README.md'
summary='Rootbank Warren finish is installed on Claude\'s restored textured painter: varied exposed roots/clover, raised clay side reveals and a rooted Shortcut Crew den. USE_TILE_ART remains false in all three painters. New artwork is clipped to WALL tiles; walking floors/stairs and topology exact in raw/native shader output. Native material 21/21 across three seeds; all four installed floor captures match staging; existing dungeon checks5/5 staging/live; final live crew scene passes fight/flop/escape/parcel/beaten. Only riverbank_painter plus new rootbank_detail change runtime. 794 existing source files checked: only the owned painter changed. No rule/save/actor/cinematic/audio/settings/raster edits, image generation, paid calls or commit. Visual proposal for Preston. Originals, exact diff, captures, private drivers and receipts: '+evidence+'. Claude\'s task 2 standing idle wiring remains pending.'
plans={}
def plan(rel,transform):
    path=R/rel;original=path.read_bytes();text=original.decode('utf-8-sig');result=transform(text)
    assert result!=text,rel
    backup=P/'originals-docs'/rel;backup.parent.mkdir(parents=True,exist_ok=True);backup.write_bytes(original)
    plans[rel]=(original,result.encode('utf-8'))
    diff=''.join(difflib.unified_diff(text.splitlines(True),result.splitlines(True),fromfile='original/'+rel,tofile='installed/'+rel))
    target=P/'docs-diffs'/(path.name+'.diff');target.parent.mkdir(parents=True,exist_ok=True);target.write_text(diff)
def start(text):
    old='**Latest active request: finish Rootbank Warren dungeon presentation**, using current Claude wiring/layouts and preserving rules.'
    assert old in text
    text=text.replace(old,'**Latest completed request: Rootbank Warren designs**, installed on the restored textured painter; evidence: `'+evidence+'`.',1)
    text=text.replace('## Latest completed work\n','## Latest completed work\n\n**Rootbank Warren:** '+summary+'\n',1)
    text=text.replace("Rootbank Warren presentation is now the user's active additional request.","Rootbank Warren presentation subsequently completed; see above.",1)
    return text
plan('docs/team/CODEX_START_HERE_2026-10-11.md',start)
def tasks(text):
    old="Preston's latest additional request is finishing Rootbank Warren's dungeon presentation; that is next for Codex."
    assert old in text
    return text.replace(old,"Preston's additional Rootbank Warren design request is now completed; see the final handoff below.",1)+'\n\n## Rootbank Warren completed, Codex October 11\n\n'+summary+'\n'
plan('docs/team/CODEX_TASKS_2026-10-11.md',tasks)
def collab(text):
    text=text.replace('## Codex: current opening checks complete; Rootbank Warren next (October 11, 2026)','## Codex: current opening checks complete (October 11, 2026)',1)
    old="**Preston additionally asked to finish Rootbank Warren designs.** This is now the active Codex request, using the existing clay/root dungeon, current floor topology and Shortcut Crew boss wiring. Inspect native current floors before choosing the art slice. Claude's task 2 idle wiring remains his pending integration."
    assert old in text
    text=text.replace(old,"Preston's additional Rootbank Warren design request subsequently completed; see the latest entry above. Claude's task 2 idle wiring remains his pending integration.",1)
    return text.replace('# Working Together on Hollowtide\n','# Working Together on Hollowtide\n\n## Codex: Rootbank Warren designs installed (October 11, 2026)\n\n'+summary+'\n',1)
plan('docs/AI_COLLABORATION.md',collab)
def inventory(text):
    old='current consumer `scripts/dungeon/dungeon_tile_art.gd`.'
    assert old in text
    text=text.replace(old,'retained consumer `scripts/dungeon/dungeon_tile_art.gd`. **Later October 11:** Preston restored the textured code painters; `USE_TILE_ART` is false in riverbank/valley/ruin. Atlases remain on disk but those three looks currently use the code-painted terrain.',1)
    text=text.replace('Highbank river/ground fallbacks, lookout/landing/dock, doors/hatches/signs, Hall corrections, Warden pond,','Highbank river/ground fallbacks, lookout/landing/dock, doors/hatches/signs, Hall corrections, textured dungeon terrain, Rootbank wall roots/crew-den canopy, Warden pond,',1)
    text=text.replace('[world sel-out](../world/world-selout-2026-10-11/README.md);','[world sel-out](../world/world-selout-2026-10-11/README.md), [Rootbank code-painted finish](../design/rootbank-warren-finish-2026-10-11/README.md);',1)
    return text
plan('docs/pitch/ai-asset-inventory.md',inventory)
handoff='# Rootbank Warren — Codex handoff, October 11\n\n'+summary+'\n\nPreserve the new `scripts/dungeon/rootbank_detail.gd` and the final-image call in riverbank_painter when editing the dungeon. Floor terrain remains Claude\'s textured code painting; do not re-enable the atlas switch. Dungeon, crew scene, other painters and shared finish are unchanged. No message was sent to another chat.\n'
handoff_path=R/'docs/team/CODEX_HANDOFF_2026-10-11_rootbank_warren.md'
assert not handoff_path.exists()
for rel,(original,result) in plans.items():assert (R/rel).read_bytes()==original,rel
for rel,(original,result) in plans.items():(R/rel).write_bytes(result)
handoff_path.write_text(handoff,encoding='utf-8')
manifest={p.relative_to(P).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in P.rglob('*') if p.is_file() and p.name!='manifest.json'}
(P/'manifest.json').write_text(json.dumps(manifest,indent=2))
dest=R/'docs/design/rootbank-warren-finish-2026-10-11'
assert not dest.exists()
shutil.copytree(P,dest)
for rel,(_,result) in plans.items():assert (R/rel).read_bytes()==result
for rel,sha in manifest.items():assert hashlib.sha256((dest/rel).read_bytes()).hexdigest()==sha
print('Installed evidence, four scoped status/provenance updates and Claude handoff. Files verified:',len(manifest))
