from pathlib import Path
W=Path(__file__).parent;S=Path('D:/dev/hollowtide-world-refinement-20261008/project');(W/'checks').mkdir(exist_ok=True)
for name in ['storage_check','town_room_check','hall_floors_check']:
    text=(S/f'tools/debug/{name}.gd').read_text(encoding='utf-8')
    import re
    text=re.sub(r'const OUT := "[^"]+"',f'var OUT := "D:/dev/hollowtide-storage-integration-20261014/" + OS.get_cmdline_user_args()[0] + "/{name}/"',text)
    text=text.replace('func _run() -> void:\n','func _run() -> void:\n\troot.size = Vector2i(1152,648)\n\tTeamState.save_path = "user://'+name+'.save"\n\tDirAccess.make_dir_recursive_absolute(OUT)\n',1)
    if name!='storage_check':
        text=text.replace('\tquit()', '\tquit(1 if fails else 0)')
        text=text.replace('\tquit(1 if fails else 0)', '\tawait _frames(4)\n\tvar music = root.get_node_or_null("HollowtideMusic")\n\tif music != null: music.queue_free()\n\tawait _frames(4)\n\tquit(1 if fails else 0)')
    (W/'checks'/(name+'.gd')).write_text(text,encoding='utf-8')
print('Prepared three isolated current native checks.')
