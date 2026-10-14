from pathlib import Path
import shutil,hashlib,json,difflib
W=Path(__file__).parent
R=Path('C:/Users/pmcga/dev/hollowtide')
S=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
protected={}
for folder in ['scripts','scenes','data','dialogue','assets/sprites/ui','tools/ui']:
    for p in (R/folder).rglob('*'):
        if p.is_file() and p.suffix not in ['.pyc']:
            rel=p.relative_to(R);protected[str(rel).replace('\\','/')]=digest(p)
            dst=S/rel;dst.parent.mkdir(parents=True,exist_ok=True)
            if not dst.exists() or digest(dst)!=digest(p):shutil.copy2(p,dst)
for name in ['project.godot','default_bus_layout.tres']:
    shutil.copy2(R/name,S/name)
(W/'protected.json').write_text(json.dumps(protected,indent=2),encoding='utf-8')
original=(R/'scripts/ui/ui_style.gd').read_text(encoding='utf-8')
candidate=original.replace('const PORTRAIT_INSET := 150.0','const PORTRAIT_INSET := 162.0').replace('box.position + Vector2(30, -34)','box.position + Vector2(42, -34)')
assert candidate!=original and candidate.count('Vector2(42, -34)')==1
(W/'original-ui_style.gd').write_text(original,encoding='utf-8')
(W/'candidate-ui_style.gd').write_text(candidate,encoding='utf-8')
(W/'candidate.diff').write_text(''.join(difflib.unified_diff(original.splitlines(True),candidate.splitlines(True),fromfile='live/scripts/ui/ui_style.gd',tofile='proposal/scripts/ui/ui_style.gd')),encoding='utf-8')
(S/'scripts/ui/ui_style.gd').write_text(candidate,encoding='utf-8')
driver=(R/'tools/debug/flood_talk_check.gd').read_text(encoding='utf-8')
driver=driver.replace('const OUT := "res://docs/design/flood-talk-2026-10-11/"','var OUT := "D:/dev/hollowtide-dialogue-corner-20261014/" + OS.get_cmdline_user_args()[0] + "/"')
driver=driver.replace('func _run() -> void:\n','func _run() -> void:\n\troot.size = Vector2i(1152,648)\n')
driver=driver.replace('\tquit(1 if fails else 0)','\tif current_scene != null:\n\t\tcurrent_scene.queue_free()\n\tawait _frames(5)\n\tvar music = root.get_node_or_null("Music")\n\tif music != null: music.queue_free()\n\tawait _frames(3)\n\tvar talk = load("res://dialogue/flood_bank.dialogue")\n\ttalk.lines = {}\n\tquit(1 if fails else 0)')
(W/'flood.gd').write_text(driver,encoding='utf-8')
print('Prepared proposal; protected',len(protected),'live files. No live edits.')
