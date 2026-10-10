from pathlib import Path
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
for name in ['hub_town_check','town_walk_check','dungeons_check','hall_door_check']:
 s=(L/('tools/debug/'+name+'.gd')).read_text(encoding='utf-8')
 if name=='hub_town_check':
  s=s.replace('const OUT := "res://docs/world/hub-layout-2026-10-09/"','const OUT := "D:/dev/hollowtide-town-selout-20261010/review/town-check/"')
  s=s.replace('\tLayout.new()\n','')
  s=s.replace('\tquit()','\ttown.queue_free()\n\tfor k in 4: await process_frame\n\tquit()')
 elif name=='town_walk_check':
  s=s.replace('\tquit()','\ttown.queue_free()\n\tfor k in 4: await process_frame\n\tquit(1 if bad else 0)')
 elif name=='dungeons_check':
  s=s.replace('\tquit()','\tawait _frames(4)\n\tquit(1 if fails else 0)')
 else:s=s.replace('\tquit()','\tquit(1 if bad else 0)')
 (W/(name+'.gd')).write_text(s,encoding='utf-8')
print('Current Claude checks copied with outputs redirected and explicit fixture cleanup.')
