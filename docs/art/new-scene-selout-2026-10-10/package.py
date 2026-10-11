from pathlib import Path
import hashlib,json,shutil,re
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else None
baseline=json.loads((W/'install-baseline.json').read_text())
paths=['scripts/arena/creature_finish.gd','scripts/town/board_scene.gd','scripts/town/hub_town.gd','scripts/ui/ui_style.gd','scripts/ui/crew_portrait_canvas.gd']
for name,mark in {'selout_check':'SELOUT 9/9 PASS','board_scene_check':'BOARD SCENE: all ok','hub_town_check':'Places: 12 of 12 answered','dungeons_check':'DUNGEONS: all ok','portrait_scene_check':'PORTRAIT SCENES PASS'}.items():
    s=(W/(name+'.log')).read_text(errors='replace')
    assert mark in s and not any(e in s for e in ['SCRIPT ERROR','SHADER ERROR','FAIL','leaked']),name
for r in paths:
    assert sha(L/r)==baseline[r],('Concurrent source changed',r)
    q=W/'candidate'/r;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(C/r,q)
# Exact presentation-only hooks preserve every original statement around them.
r='scripts/town/board_scene.gd'
assert (W/'candidate'/r).read_text().replace('.apply(sprite, false, form)','.apply(sprite)')==(W/'originals-current'/r).read_text()
r='scripts/ui/ui_style.gd'
assert (W/'candidate'/r).read_text().replace('.portrait_target(tex.resource_path)','.crew_detail(tex.resource_path) > 0.0')==(W/'originals-current'/r).read_text()
r='scripts/town/hub_town.gd'
s=(W/'candidate'/r).read_text()
s=s.replace('\tvar crew_portraits := preload("res://scripts/ui/crew_portrait_canvas.gd").new()\n\tcrew_portraits.name = "CrewPortraitFinish"\n\t_hud.add_child(crew_portraits)\n','').replace('\t_hud.get_node("CrewPortraitFinish").clear()\n','')
assert s==(W/'originals-current'/r).read_text()
note='''## Codex: new creature/scene sel-out and Starward/Gruntle portraits (October 10, 2026)

Preston requested a finish pass for the newly added art and clarified Starward/Gruntle portraits. Applied the existing Hollowtide Sprite contour finish to their base and expression portraits; Gruntle also gets the rival crew's bounded internal ink. Starward keeps its pale approved palette and normal contour preset. Mirekit/Whinet expression variants now follow their existing rival preset. Town HUD now has the creature-only portrait layer already used in dungeons; pooled individual sprites follow texture changes with native source-pixel outline thickness. Frames, emotion backgrounds/marks and text stay outside that finish. Gruntle's path-less Board NPC fallback receives its known identity. No source PNG, shared shader, face drawing, story, state, rules, layout, settings or commit edits.

9 native GPU comparisons pass across 3,808 new town/root textures and 27 installed crew/Starward portraits. Other forms remain byte-exact, including Oxbowarchon jade and Sparkwick correction; Gruntle alpha/bright highlights exact; frames/marks/dismissal exact. Actual town/dungeon Gruntle and Starward portraits, full first-visit Board scene, 12 town services/door access and current two-dungeon rule checks pass. Original code, previews and guarded preservation audit: [new scene sel-out handoff](art/new-scene-selout-2026-10-10/README.md). Preserve original artwork, rejected variants/backups, seven-form refinements and concurrent Claude edits. Visual finish implemented/reviewed; Preston's art approval is not assumed. Job12 pilot waking remains next from the handoff.

'''
r='docs/AI_COLLABORATION.md';raw=(L/r).read_bytes();prefix=b'\n'.join(raw.split(b'\n',2)[:2])+b'\n'
assert raw.startswith(b'# Working Together on Hollowtide')
for folder,content in [('originals-current',raw),('candidate',prefix+note.replace('\n','\r\n').encode()+raw[len(prefix):])]:
    q=W/folder/r;q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(content)
paths.append(r)
pending=[{'path':r,'before':sha(L/r),'after':sha(W/'candidate'/r)} for r in paths]
pending.sort(key=lambda d:(d['path']=='docs/AI_COLLABORATION.md',d['path']))
(W/'pending-install.json').write_text(json.dumps(pending,indent=2))
install=Path('D:/dev/hollowtide-launch-frames-20261010/install.ps1').read_text().replace('hollowtide-launch-frames-20261010','hollowtide-new-scene-selout-20261010').replace('docs/ui/launch-pixel-frames-2026-10-10','docs/art/new-scene-selout-2026-10-10')
(W/'install.ps1').write_text(install)
archive=W/'archive';archive.mkdir(exist_ok=True)
for folder in ['originals','originals-current','candidate','review']:shutil.copytree(W/folder,archive/folder,dirs_exist_ok=True)
for p in W.iterdir():
    if p.is_file() and p.suffix in ['.py','.ps1','.gd','.log','.json','.md']:shutil.copy2(p,archive/p.name)
print('Prepared six guarded files. Town/Board/UI hooks preserve original code exactly.')
