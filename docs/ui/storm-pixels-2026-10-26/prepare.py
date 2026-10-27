from pathlib import Path
import json,hashlib,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');rel='scripts/storm_open.gd'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert not (W/'protected-before.json').exists()
base={p.relative_to(L).as_posix():sha(p) for f in ('scripts','scenes','data','dialogue','tools') for p in (L/f).rglob('*') if p.is_file() and '__pycache__' not in p.parts}
base['project.godot']=sha(L/'project.godot');(W/'protected-before.json').write_text(json.dumps(base,indent=2))
for path in (rel,'scripts/soul_prologue.gd','scripts/ui/ui_style.gd','tools/debug/opening_flow_check.gd','docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-26.md'):
 dest=W/'originals'/path;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/path,dest)
# Hand-shaped row spans: a slightly uneven halo, stepped inner light and a white core.
outer=[(11,13),(8,15),(7,17),(5,18),(4,20),(3,21),(2,22),(2,23),(1,23),(1,24),(0,24),(0,24),(1,24),(0,23),(0,23),(1,22),(2,22),(2,21),(4,20),(5,19),(5,18),(7,17),(8,16),(10,14),(11,13)]
grid=[[' ']*25 for _ in range(25)]
for y,(a,b) in enumerate(outer):grid[y][a:b+1]=['.']*(b-a+1)
for y,(a,b) in enumerate([(10,14),(8,16),(7,17),(6,18),(5,19),(5,19),(5,19),(5,19),(5,19),(6,18),(6,18),(7,17),(8,16),(9,15),(10,14)],5):grid[y][a:b+1]=['+']*(b-a+1)
for y,(a,b) in enumerate([(10,13),(9,15),(8,16),(8,16),(8,16),(8,16),(9,15),(10,14),(11,13)],8):grid[y][a:b+1]=['o']*(b-a+1)
for y in range(11,14):grid[y][11:14]=['#']*3
grid[10][11]='#'
rows=[''.join(row) for row in grid]
constants='''# Authored on the same 384x216 pixel grid as the riverbank and rain.
# Each glyph is a light value; row runs become whole-pixel rectangles, never vector circles.
const SOUL_PIXELS := [
'''+''.join('\t"'+row+'",\n' for row in rows)+''']
const SOUL_COLOURS := {
\t".": Color(0.75, 0.85, 1.0, 0.10),
\t"+": Color(0.85, 0.92, 1.0, 0.325),
\t"o": Color(0.95, 0.97, 1.0, 0.73),
\t"#": Color.WHITE,
}

'''
s=(L/rel).read_text();s=s.replace('var reduce_motion := false',constants+'var reduce_motion := false',1)
a=s.index('\t\tsoul.draw_circle');b=s.index('\tif white > 0.0:',a)
s=s[:a]+'''\t\t_draw_soul_cluster(at, k, 1.0 + big * 14.0 / 12.0)
'''+s[b:]
at=s.index('func _unhandled_input(')
s=s[:at]+'''func _draw_soul_cluster(at: Vector2, opacity: float, growth: float) -> void:
\t# Keep the old outer reach (12 + big*14), but grow the authored pixels with crisp edges.
\tfor y in SOUL_PIXELS.size():
\t\tvar row: String = SOUL_PIXELS[y]
\t\tvar x := 0
\t\twhile x < row.length():
\t\t\tvar mark := row.substr(x, 1)
\t\t\tvar end := x + 1
\t\t\twhile end < row.length() and row.substr(end, 1) == mark: end += 1
\t\t\tif SOUL_COLOURS.has(mark):
\t\t\t\tvar colour: Color = SOUL_COLOURS[mark]
\t\t\t\tvar begin := (at + Vector2(x - 12, y - 12) * growth).round()
\t\t\t\tvar finish := (at + Vector2(end - 12, y - 11) * growth).round()
\t\t\t\tsoul.draw_rect(Rect2(begin, finish - begin), Color(colour, colour.a * opacity))
\t\t\tx = end


'''+s[at:]
p=W/'prepared'/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s,encoding='utf-8')
print('Prepared one production script, protected',len(base),'files.')
