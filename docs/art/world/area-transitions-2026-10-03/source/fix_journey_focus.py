from pathlib import Path
import shutil
P=Path(r"C:/Users/pmcga/dev/hollowtide");W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an")
D=W/"area-transition-review"
for name in ["menu-entry.json","menu-entry.out.log","menu-entry.err.log","menu-to-hometown-male.png"]:
    shutil.copy2(D/name,D/("initial-"+name))
p=P/"scripts/main_menu.gd";t=p.read_text()
old='''\t\t_courier_buttons[1].focus_neighbor_right = _courier_buttons[0].get_path()
\tfirst.grab_focus.call_deferred()'''
new='''\t\t_courier_buttons[1].focus_neighbor_right = _courier_buttons[0].get_path()
\t\tfor card in _courier_buttons:
\t\t\tcard.focus_neighbor_bottom = _begin_button.get_path()
\t\t_begin_button.focus_neighbor_top = _courier_buttons[0 if _selected_courier == "Male" else 1].get_path()
\tfirst.grab_focus.call_deferred()'''
assert old in t;t=t.replace(old,new)
old='''func _update_courier_selection() -> void:
\tfor i in _courier_buttons.size():'''
new='''func _update_courier_selection() -> void:
\tif _begin_button != null:
\t\t_begin_button.focus_neighbor_top = _courier_buttons[0 if _selected_courier == "Male" else 1].get_path()
\tfor i in _courier_buttons.size():'''
assert old in t;t=t.replace(old,new)
t=t.replace("before opening Route 1.","before opening the hometown.")
t=t.replace("Route 1 could not be opened. Please try again.","The journey could not be opened. Please try again.")
p.write_text(t,encoding="utf-8")
print("Down from either courier now reaches Begin without changing the selection.")
