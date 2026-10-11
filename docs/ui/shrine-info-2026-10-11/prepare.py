from pathlib import Path
import re
W=Path(__file__).parent
C=Path('C:/Users/pmcga/dev/hollowtide')
for mode in ['evolution_check','hub_town_check','field_menu_check']:
    source=(C/'tools/debug'/f'{mode}.gd').read_text(encoding='utf-8')
    source=re.sub(r'const OUT := "[^"]+"',f'const OUT := "{W.as_posix()}/"',source)
    source=source.replace('\tquit()', '\tfor child in root.get_children(): child.queue_free()\n\tload("res://scripts/audio/music.gd")._inst=null\n\tawait _frames(16)\n\tquit()')
    if 'func _frames(' not in source:
        source+='\nfunc _frames(n: int) -> void:\n\tfor k in n: await process_frame\n'
    (W/f'{mode}.gd').write_text(source,encoding='utf-8')
