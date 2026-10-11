from pathlib import Path
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
for name in ['field_menu_check','dungeons_check']:
    s=(L/'tools/debug'/(name+'.gd')).read_text()
    if name=='field_menu_check':end='\tquit(0 if bad==0 else 1)'
    else:end='\tquit(0 if fails==0 else 1)'
    s=s.replace('\tquit()','\tfor child in root.get_children():child.queue_free()\n\tload("res://scripts/audio/music.gd")._inst=null\n\tawait _frames(12)\n'+end)
    (W/(name+'.gd')).write_text(s)
