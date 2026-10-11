from pathlib import Path
import shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
shutil.copy2(L/'scripts/arena/arena_prototype.gd',C/'scripts/arena/arena_prototype.gd')
p=W/'scene_check.gd';s=p.read_text();start=s.index('\t# New wilds lack a BASIC lookup');end=s.index('\tawait frames(6)',start)
s=s[:start]+'\tvar p:Control=load("res://scripts/ui/party_screen.gd").new();root.add_child(p);p.setup(town)\n'+s[end:]
start=s.index('\tvar index:=0');end=s.index('\tawait snap("dungeon-new-team")',start)
s=s[:start]+'''\tfor e in dg.ents:
\t\tif e["team"]==0:check(e["sprite"].material.get_shader_parameter("detail_ink")==0.65,"dungeon "+String(e["form"])+" material")
'''+s[end:]
s=s.replace('dg.party=[[0,0],[1,0]]','dg.party=[[103,0],[104,0],[105,0]]')
p.write_text(s)
print('Synced concurrent kit fix; scene fixture now verifies real three-creature team and dungeon actors.')
