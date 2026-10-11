from pathlib import Path
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
for name in ['field_menu_check','soul_prologue_check']:
    s=(L/'tools/debug'/(name+'.gd')).read_text(encoding='utf-8')
    if name=='soul_prologue_check':
        s=s.replace('res://docs/design/soul-prologue-2026-10-10/','D:/dev/hollowtide-launch-frames-20261010/review/soul/')
        s=s.replace('\tquit()','\tnext.queue_free()\n\tfor n in root.get_children(): n.queue_free()\n\tawait process_frame\n\tawait process_frame\n\tquit(0 if ok_hand and ok_wake else 1)')
    else:
        s=s.replace('\tquit()','\tawait _frames(12)\n\tfor n in root.get_children(): n.queue_free()\n\tload("res://scripts/audio/music.gd")._inst=null\n\tawait _frames(12)\n\tquit(0 if bad==0 else 1)')
    (W/(name+'.gd')).write_text(s,encoding='utf-8')
print('Copied current Claude checks; only output isolation, cleanup and failure exit added.')
