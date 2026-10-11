from pathlib import Path
import hashlib,json,shutil,re
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else None
baseline=json.loads((W/'baseline.json').read_text())
for name,mark in {'finish_check':'NEW FINISH 6/6 PASS','scene_check':'NEW SCENES PASS','field_menu_check':'RESULT: field menu works'}.items():
    s=(W/(name+'.log')).read_text(errors='replace');assert mark in s and not any(t in s for t in ['SCRIPT ERROR','SHADER ERROR','FAIL','WRONG','leaked']),name
paths=['scripts/arena/creature_finish.gd','scripts/arena/sel_out.gdshaderinc','scripts/ui/party_screen.gd','scripts/ui/creature_detail_canvas.gd']
for r in paths:
    assert sha(L/r)==baseline.get(r),('Concurrent owned change',r)
    q=W/'candidate'/r;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(C/r,q)
# Only presentation methods change. Labels, input, moves, conditions and selection methods stay exact.
def methods(s):
	s=s.replace('var _new_creature_art: Node2D\n','')
	hits=list(re.finditer(r'^func (\w+)\(',s,re.M));return {m.group(1):s[m.start():hits[k+1].start() if k+1<len(hits) else len(s)] for k,m in enumerate(hits)}
a=methods((W/'originals/scripts/ui/party_screen.gd').read_text());b=methods((W/'candidate/scripts/ui/party_screen.gd').read_text())
assert a.keys()==b.keys()
assert all(a[k]==b[k] for k in a if k not in ['setup','_draw','_draw_left'])
note='''## Codex: nine new creatures sel-out and Skimlet leg dots (October 10, 2026)

Preston requested sel-out on newly added creatures and correction of Skimlet's left-leg white dots. Nine forms covered: Skimlet, Ozbender, Valvekin, Wayling, Swaphoard, Pouchbill, Inkhoot, Cairnshell, Crawdukes. Existing house silhouette/cluster finish plus 0.65 bounded internal ink follows their arena/town/dungeon/portrait textures. Team headshots and still breathing previews now have a separate finished creature layer only for these forms; missing arena headshots use existing dialogue portraits. Original geometry, tint, shadows, text, labels, controls and older forms remain unchanged. Skimlet-only display correction replaces the two exact pale swatches on sparsely supported thin edges with its leg brown before detail ink, keeping source alpha and central eye/body highlights. No PNG edits, regeneration, palette repaint, animation/layout/story/stat/rule/settings/commit edits.

6/6 native GPU checks across 1,323 new textures pass: finished alpha exact, other new forms' bright highlights exact, specified Skimlet dots corrected and eyes/central highlights exact, every prior form's south view exact including jade Oxbowarchon, Sparkwick and Gruntle. Native town materials, dialogue clipping/dismissal, Team presentation and dungeon art presentation pass; existing field-menu check passes. The two-dungeon check reports missing new-wild stat lookups, so it is not claimed clean. Originals, before/after, fixture scope and guarded audit: [new creatures finish](art/new-creatures-selout-2026-10-10/README.md). Preserve the original artwork/backups and Claude's concurrent code. Gruntle's approved outline and lower-left portrait clipping stay installed.

Claude/Grok gameplay follow-up: current basic_of and stat lookup do not yet include Skimlet/Ozbender/Valvekin; direct Team/dungeon construction and the ordinary Hollow generation check report missing keys (_make/basic_of, then max_hp/flash). No rule table was changed here. Art-only fixture cards and dungeon presentation sprites verify the finish without claiming those recruitment/gameplay paths work. The existing field-menu check passes separately. Six townsfolk currently have rotations/town stills; this pass supplies their finish, not NPC story/service placement. Job12 waking remains pending from the handoff.

'''
r='docs/AI_COLLABORATION.md';raw=(L/r).read_bytes();prefix=b'\n'.join(raw.split(b'\n',2)[:2])+b'\n'
for folder,content in [('originals-current',raw),('candidate',prefix+note.replace('\n','\r\n').encode()+raw[len(prefix):])]:
    q=W/folder/r;q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(content)
paths.append(r)
pending=[{'path':r,'before':sha(L/r),'after':sha(W/'candidate'/r)} for r in paths]
pending.sort(key=lambda d:(d['before'] is not None,d['path']=='docs/AI_COLLABORATION.md',d['path']))
(W/'pending-install.json').write_text(json.dumps(pending,indent=2))
install=Path('D:/dev/hollowtide-new-scene-selout-20261010/install.ps1').read_text().replace('hollowtide-new-scene-selout-20261010','hollowtide-wilds-selout-20261010').replace('docs/art/new-scene-selout-2026-10-10','docs/art/new-creatures-selout-2026-10-10')
(W/'install.ps1').write_text(install)
archive=W/'archive';archive.mkdir(exist_ok=True)
for folder in ['originals','originals-current','candidate','review']:shutil.copytree(W/folder,archive/folder,dirs_exist_ok=True)
for p in W.iterdir():
    if p.is_file() and p.suffix in ['.py','.ps1','.gd','.log','.json']:shutil.copy2(p,archive/p.name)
print('Prepared five guarded files. Non-presentation methods exact; original art untouched.')
