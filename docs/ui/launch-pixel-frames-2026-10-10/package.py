from pathlib import Path
import hashlib,json,shutil,re
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else None
for n,mark in {'frame_check':'FRAMES 34/34 PASS','field_menu_check':'RESULT: field menu works','soul_prologue_check':'RESULT: the soul prologue works'}.items():
    log=(W/(n+'.log')).read_text(encoding='utf-8')
    assert mark in log and not any(e in log for e in ['SCRIPT ERROR','SHADER ERROR','FAIL ','WRONG','leaked']),n
paths=['scripts/'+n for n in ['main_menu.gd','creature_opening.gd','creature_prologue.gd','first_partner_arrival.gd','ui/opening_dialogue.gd']]
baseline=json.loads((W/'baseline.json').read_text(encoding='utf-8'))
for r in paths:
    assert sha(L/r)==baseline.get(r),('Concurrent source changed',r)
    q=W/'candidate'/r;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(C/r,q)
allowed={'main_menu.gd':['_panel','_volume_control','_button'],'creature_opening.gd':['_panel','_button','_build_menu','_build_help_panel'],'creature_prologue.gd':['_ready','button','refresh'],'first_partner_arrival.gd':['_ready']}
def functions(text):
    text=text.replace('const UI := preload("res://scripts/ui/ui_style.gd")\n\n','')
    hits=list(re.finditer(r'^func (\w+)\(',text,re.M))
    return {m.group(1):text[m.start():hits[k+1].start() if k+1<len(hits) else len(text)] for k,m in enumerate(hits)}
for name,changed in allowed.items():
    a=functions((W/'originals/scripts'/name).read_text(encoding='utf-8'));b=functions((W/'candidate/scripts'/name).read_text(encoding='utf-8'))
    assert a.keys()==b.keys(),name
    assert all(a[k]==b[k] for k in a if k not in changed),('Non-presentation method changed',name)
note='''## Codex: launch pixel frames, handoff job 8 (October 10, 2026)

Finished the next open UI slice after Home/Hall. Title Options/Help/Quit, inherited launch controls and partner welcome use the existing moss/brass pixel nine-slices. Frame copies have local margins, 52px controls, roomy sliders and corrected panel placement. Title village, wordmark, bare four-choice text composition/underline/pointer, boot and routes retained. Waking uses UI.dialogue with a framed finished portrait, speaker tab and next arrow, separate framed choices below. Original title/prose remain the text model for Claude's checks; story lines, identity/companion selection, soul handoff, town transition and state methods stay unchanged. No new art generation/PNG/shader/settings/rules/commit edit.

34 native layout/input/render checks pass, including both real New Game routes to the soul scene, all waking choices into selected town team, framed legacy welcome and creature finish. Current Claude field-menu check passes, including actual item turn; current soul check reaches chosen Tallowroot waking with no starter buttons. Original sources, engine previews/logs and guarded hashes: [launch frame handoff](ui/launch-pixel-frames-2026-10-10/README.md). Preserve source art, creature palettes/backups/Home/Board/Hall and concurrent Claude code. F5 remains Claude's current dungeon development setting. Job12 pilot waking text/staging is next; read its story brief first. Hall art and these frames remain ready for Preston's visual review.

'''
r='docs/AI_COLLABORATION.md';raw=(L/r).read_bytes();prefix=b'\n'.join(raw.split(b'\n',2)[:2])+b'\n'
assert raw.startswith(b'# Working Together on Hollowtide')
for folder,content in [('originals-current',raw),('candidate',prefix+note.replace('\n','\r\n').encode('utf-8')+raw[len(prefix):])]:
    q=W/folder/r;q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(content)
paths.append(r)
pending=[{'path':r,'before':sha(L/r),'after':sha(W/'candidate'/r)} for r in paths]
pending.sort(key=lambda d:(d['before'] is not None,d['path']=='docs/AI_COLLABORATION.md',d['path']))
(W/'pending-install.json').write_text(json.dumps(pending,indent=2),encoding='utf-8')
install=Path('D:/dev/hollowtide-hall-interior-20261010/install.ps1').read_text(encoding='utf-8').replace('hollowtide-hall-interior-20261010','hollowtide-launch-frames-20261010').replace('docs/world/hall-interior-finish-2026-10-10','docs/ui/launch-pixel-frames-2026-10-10')
(W/'install.ps1').write_text(install,encoding='utf-8')
archive=W/'archive';archive.mkdir(exist_ok=True)
for folder in ['originals','originals-current','candidate','review']:shutil.copytree(W/folder,archive/folder,dirs_exist_ok=True)
for p in W.iterdir():
    if p.is_file() and p.suffix in ['.py','.ps1','.gd','.txt','.log','.json','.md']:shutil.copy2(p,archive/p.name)
print('Prepared',len(pending),'guarded files; non-presentation methods exact.')
