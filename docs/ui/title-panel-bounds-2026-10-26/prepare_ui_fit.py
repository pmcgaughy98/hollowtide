from pathlib import Path
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
src=(L/'tools/debug/ui_fit_check.gd').read_text(encoding='utf-8')
assert src.count('const OUT := "res://docs/ui/ui-fit-2026-10-14/"')==1
src=src.replace('const OUT := "res://docs/ui/ui-fit-2026-10-14/"','const OUT := "D:/dev/hollowtide-title-bounds-20261026/ui-fit/"')
src=src.replace('func _run() -> void:\n','func _run() -> void:\n\tload("res://scripts/town/team_state.gd").save_path="user://title-ui-fit-private.save"\n',1)
needle='\tprint("ui fit: %s (%d failed)"'
assert src.count(needle)==1
src=src.replace(needle,'\tvar private_music=root.get_node_or_null("HollowtideMusic")\n\tif private_music!=null: private_music.queue_free()\n\tawait _frames(4)\n'+needle)
(W/'ui_fit_private.gd').write_text(src,encoding='utf-8')
print('Copied the unchanged ui_fit assertions to private capture/save paths and added music teardown.')
