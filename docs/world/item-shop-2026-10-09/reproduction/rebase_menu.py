from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def cp(s,d):d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(s,d)
b=json.loads((W/'baseline.json').read_text());changed={r:sha(L/r) if (L/r).exists() else None for r,h in b.items() if not (L/r).exists() or sha(L/r)!=h}
print('Concurrent changes:',list(changed))
(W/'concurrent-at-menu-rebase.json').write_text(json.dumps(changed,indent=2))
r='scripts/creature_opening.gd';cp(L/r,W/'originals/concurrent/creature_opening_with_theme.gd')
s=(L/r).read_text().replace('const Finish = preload("res://scripts/arena/creature_finish.gd")\n','').replace('var companions: Array[Sprite2D] = []\n','')
start=s.index('func _build_characters() -> void:');end=s.index('func _build_journey_panel()',start)
s=s[:start]+'''func _build_characters() -> void:
\t# The village carries the title scene; Preston removed the foreground creatures.
\tpass

'''+s[end:]
start=s.index('\nfunc _process(delta:float) -> void:');s=s[:start]+'\n'
(W/'candidate'/r).write_text(s)
(W/'rebase-owned.json').write_text(json.dumps({r:sha(L/r)},indent=2))
for r in changed:
    if r.startswith(('scripts/','scenes/','data/')) and r not in ['scripts/creature_opening.gd','scripts/town/highbank_ground_painter.gd']:
        cp(L/r,C/r)
r='assets/audio/music/title.mp3';cp(L/r,C/r)
# Verify the merged menu still uses Claude's music resource.
p=W/'title_check.gd';s=p.read_text()
s=s.replace('menu._buttons[0].emit_signal("pressed")','var music_ok = menu._music.stream.resource_path == "res://assets/audio/music/title.mp3"\n\tmenu._buttons[0].emit_signal("pressed")')
s=s.replace('" new_game_opens_prologue=",flow_ok)', '" new_game_opens_prologue=",flow_ok," claude_title_theme=",music_ok)')
s=s.replace('title_ok and flow_ok else 1','title_ok and flow_ok and music_ok else 1');p.write_text(s)
p=W/'package.py';s=p.read_text()
s=s.replace("for r in owned:\n    if r in baseline:assert sha(L/r)==baseline[r]", "rebased=json.loads((W/'rebase-owned.json').read_text())\nfor r in owned:\n    if r in baseline:assert sha(L/r)==rebased.get(r,baseline[r])")
s=s.replace("for f in ['baseline.json','concurrent-before-install.json','art-preparation.json','generation-prompts.txt']", "for f in ['baseline.json','concurrent-before-install.json','concurrent-at-menu-rebase.json','rebase-owned.json','art-preparation.json','generation-prompts.txt']")
s=s.replace('The inherited ambient/launch loop continues;', 'Claude concurrently added the title theme; the menu removal was rebased onto his current file and retains that exact music hookup. The pre-rebase and current-with-theme source backups are retained. The inherited ambient/launch loop continues;')
s=s.replace('New Game button opening the prologue.','New Game button opening the prologue and Claude\'s title theme resource retained.')
# Above sentence occurs inside triple-quoted document text, not executable Python strings.
p.write_text(s)
