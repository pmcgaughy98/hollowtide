from pathlib import Path
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
for name in ['board_scene_check','dungeons_check','hub_town_check']:
    s=(L/'tools/debug'/(name+'.gd')).read_text(encoding='utf-8')
    if name=='board_scene_check':
        s=s.replace('res://docs/design/board-scene-2026-10-10/','D:/dev/hollowtide-new-scene-selout-20261010/review/scene/')
        s=s.replace('\tquit()','\tfor n in root.get_children(): n.queue_free()\n\tload("res://scripts/audio/music.gd")._inst=null\n\tfor k in 12: await process_frame\n\tquit(0 if fails==0 else 1)')
    if name=='hub_town_check':
        # Existing shrine scene owns a short timer; let it finish before closing its tree.
        s=s.replace('\ttown.queue_free()','\tawait create_timer(2.0).timeout\n\ttown.queue_free()')
    (W/(name+'.gd')).write_text(s,encoding='utf-8')
print('Prepared current scene/game checks with isolated screenshots and cleanup only.')
