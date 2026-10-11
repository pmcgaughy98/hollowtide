from pathlib import Path
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
for name in ['town_room_check','hub_town_check','job_board_check']:
    s=(L/('tools/debug/'+name+'.gd')).read_text(encoding='utf-8')
    for old in ['res://docs/world/highbank-rooms-2026-10-10/','res://docs/world/hub-layout-2026-10-09/','res://docs/design/job-board-2026-10-10/']:
        s=s.replace(old,W.as_posix()+'/review/'+name+'/')
    if name=='town_room_check':
        s=s.replace('\tquit()','\tawait _frames(4)\n\tquit(1 if fails else 0)')
    elif name=='hub_town_check':
        s=s.replace('\tLayout.new()\n','')
        s=s.replace('\tquit()','\ttown.queue_free()\n\tfor k in 4: await process_frame\n\tquit()')
    else:
        s=s.replace('\tTeamState.start([[0, 0], [1, 0]])','\tDirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))\n\tTeamState.start([[0, 0], [1, 0]])')
        s=s.replace('\tquit()','\tawait _frames(4)\n\tquit(1 if fails else 0)')
    (W/(name+'.gd')).write_text(s,encoding='utf-8')
print('Prepared latest Claude checks with isolated screenshots.')
