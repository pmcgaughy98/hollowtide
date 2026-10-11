from pathlib import Path
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
for name in ['dungeons_check','town_walk_check']:
 s=(L/'tools/debug'/f'{name}.gd').read_text(encoding='utf-8')
 s=s.replace('\tquit()','\tfor child in root.get_children():child.queue_free()\n\tload("res://scripts/audio/music.gd")._inst=null\n\tfor frame in 12:await process_frame\n\tquit()')
 (W/f'{name}.gd').write_text(s,encoding='utf-8')
print('Copied latest rule/walking fixtures with native cleanup only.')
