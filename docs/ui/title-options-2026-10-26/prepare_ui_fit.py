from pathlib import Path
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
s=(L/'tools/debug/ui_fit_check.gd').read_text(encoding='utf-8')
s=s.replace('const OUT := "res://docs/ui/ui-fit-2026-10-14/"','const OUT := "D:/dev/hollowtide-title-options-20261026/ui-fit/"')
s=s.replace('func _run() -> void:\n','func _run() -> void:\n\tload("res://scripts/town/team_state.gd").save_path="user://title-options-ui-fit-private.save"\n',1)
needle='\tprint("ui fit: %s (%d failed)"';assert s.count(needle)==1
s=s.replace(needle,'\tvar private_music=root.get_node_or_null("HollowtideMusic")\n\tif private_music!=null:private_music.queue_free()\n\tif is_instance_valid(UI._blip):UI._blip.queue_free()\n\tawait _frames(4)\n'+needle)
(W/'ui_fit_private.gd').write_text(s,encoding='utf-8')
print('Prepared current ui_fit assertions with private outputs/save and music/blip teardown.')
