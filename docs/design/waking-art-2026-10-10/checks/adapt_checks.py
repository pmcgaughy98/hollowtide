from pathlib import Path
W=Path(__file__).parent
p=W/'waking_check.gd';s=p.read_text().replace('current_scene.get_script().resource_path.ends_with("hub_town.gd")','current_scene.get_script().resource_path.ends_with("riverbank_journey.gd")').replace('real confirmation reaches Highbank with the chosen team','real confirmation reaches playable bank with the chosen team').replace('await shot("highbank-arrival")','await shot("playable-bank")\n\tawait key(KEY_H);await frames(12)\n\tcheck(current_scene.scene_file_path.ends_with("hub_town.tscn"),"Highbank continues the existing pilot story")\n\tawait shot("highbank-arrival")')
p.write_text(s)
p=W/'town_loop_check.gd';s=p.read_text()
s=s.replace('\tawait _frames(10)\n\tprint("Prologue:', '\tawait _frames(10)\n\tif _scene()=="waking_riverbank.tscn":\n\t\tcurrent_scene._town();await _frames(8)\n\tprint("Prologue:')
needle='\tawait _frames(8)\n\tdg = current_scene'
assert s.count(needle)==1
s=s.replace(needle,'\tawait _frames(8)\n\tif _scene()=="waking_riverbank.tscn":\n\t\tcurrent_scene._travel(true);await _frames(8)\n\t\tif _scene()=="hollow_entrance.tscn":\n\t\t\tcurrent_scene._enter_arch();await _frames(8)\n\tdg = current_scene')
p.write_text(s)
print('Adapted route expectations; original choice/state assertions retained.')
