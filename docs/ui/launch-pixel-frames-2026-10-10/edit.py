from pathlib import Path
W=Path(__file__).parent;C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def edit(name,changes):
    raw=(W/'originals/scripts'/name).read_bytes();crlf=b'\r\n' in raw
    text=raw.decode('utf-8').replace('\r\n','\n')
    for a,b in changes:
        assert text.count(a)==1,(name,a[:80]);text=text.replace(a,b)
    (C/'scripts'/name).write_bytes(text.replace('\n','\r\n').encode('utf-8') if crlf else text.encode('utf-8'))
edit('main_menu.gd',[
 ('func _panel(node_name:', 'const UI := preload("res://scripts/ui/ui_style.gd")\n\nfunc _panel(node_name:'),
 ('var box := StyleBoxFlat.new()\n\tbox.bg_color = SLATE\n\tbox.border_color = SILT\n\tbox.set_border_width_all(4)\n\tbox.set_content_margin_all(18)','var box := UI.frame("panel").duplicate()\n\tbox.set_content_margin_all(24)'),
 ('slider.custom_minimum_size = Vector2(0, 32)','slider.custom_minimum_size = Vector2(0, 52)'),
 ('var track := StyleBoxFlat.new()\n\ttrack.bg_color = SILT.darkened(0.4)\n\ttrack.content_margin_top = 4\n\ttrack.content_margin_bottom = 4\n\tvar fill := track.duplicate() as StyleBoxFlat\n\tfill.bg_color = EMBER.darkened(0.15)','var track := UI.frame("panel_dim").duplicate()\n\tvar fill := UI.frame("panel_focus").duplicate()'),
 ('var outline := StyleBoxFlat.new()\n\toutline.bg_color = Color.TRANSPARENT\n\toutline.border_color = EMBER\n\toutline.set_border_width_all(2)','var outline := UI.frame("panel_focus").duplicate()\n\t# The focus frame sits behind the slider, keeping its grabber visible.\n\tring.show_behind_parent = true'),
 ('b.custom_minimum_size = Vector2(0, 44)','b.custom_minimum_size = Vector2(0, 52)'),
 ('var plain := StyleBoxFlat.new()\n\tplain.bg_color = SLATE\n\tplain.set_content_margin_all(8)\n\tplain.content_margin_left = 40\n\tvar focus := plain.duplicate() as StyleBoxFlat\n\tfocus.bg_color = SLATE.lightened(0.08)\n\tfocus.border_color = EMBER\n\tfocus.set_border_width_all(2)','var plain := UI.frame("panel").duplicate()\n\tplain.content_margin_top = 8\n\tplain.content_margin_bottom = 8\n\tplain.content_margin_left = 40\n\tvar focus := UI.frame("panel_focus").duplicate()\n\tfocus.content_margin_top = 8\n\tfocus.content_margin_bottom = 8\n\tfocus.content_margin_left = 40')])
edit('creature_opening.gd',[
 ('var box:=StyleBoxFlat.new()\n\tbox.bg_color=Color("#202920")\n\tbox.border_color=Color("#8e805c")\n\tbox.set_border_width_all(1)\n\tbox.set_content_margin_all(20)\n\tbox.shadow_color=Color(0.04,0.06,0.05,0.7)\n\tbox.shadow_size=0\n\tbox.shadow_offset=Vector2(7,7)','var box:=UI.frame("panel").duplicate()\n\tbox.set_content_margin_all(24)'),
 ('panel.add_child(trim)\n\treturn panel','panel.add_child(trim)\n\ttrim.hide() # Shared frame supplies its own corner studs and joinery.\n\treturn panel'),
 ('var plain:=StyleBoxFlat.new()\n\tplain.bg_color=Color("#202920")\n\tplain.set_content_margin_all(8)\n\tplain.content_margin_left=40\n\tvar active:=plain.duplicate() as StyleBoxFlat\n\tactive.bg_color=Color("#344333")\n\tactive.border_color=Color("#e4ca8e")\n\tactive.set_border_width_all(1)','var plain:=UI.frame("panel").duplicate()\n\tplain.content_margin_top=8\n\tplain.content_margin_bottom=8\n\tplain.content_margin_left=40\n\tvar active:=UI.frame("panel_focus").duplicate()\n\tactive.content_margin_top=8\n\tactive.content_margin_bottom=8\n\tactive.content_margin_left=40'),
 ('_options_panel.position=Vector2(666,222)','_options_panel.position=Vector2(666,180)'),
 ('var track := StyleBoxFlat.new()\n\t\t\ttrack.bg_color=Color("#52614b")\n\t\t\ttrack.content_margin_top=4\n\t\t\ttrack.content_margin_bottom=4\n\t\t\tvar fill := track.duplicate() as StyleBoxFlat\n\t\t\tfill.bg_color=Color("#d3b780")','var track := UI.frame("panel_dim").duplicate()\n\t\t\tvar fill := UI.frame("panel_focus").duplicate()'),
 ('var edge := StyleBoxFlat.new()\n\t\t\tedge.bg_color=Color.TRANSPARENT\n\t\t\tedge.border_color=Color("#e4ca8e")\n\t\t\tedge.set_border_width_all(2)','var edge := UI.frame("panel_focus").duplicate()'),
 ('var primary := StyleBoxFlat.new()\n\t\t\tprimary.bg_color=Color("#354333")\n\t\t\tprimary.border_color=Color("#a38e60")\n\t\t\tprimary.set_border_width_all(1)\n\t\t\tprimary.set_content_margin_all(8)\n\t\t\tprimary.content_margin_left=40','var primary := UI.frame("panel_focus").duplicate()\n\t\t\tprimary.content_margin_top=8\n\t\t\tprimary.content_margin_bottom=8\n\t\t\tprimary.content_margin_left=40')])
edit('creature_prologue.gd',[
 ('const TITLE=','const UI=preload("res://scripts/ui/ui_style.gd")\nconst TITLE='),
 ('var veil:ColorRect','var veil:ColorRect\nvar dialogue:Node2D'),
 ('panel.position=Vector2(102,338)\n\tpanel.custom_minimum_size=Vector2(948,286)\n\tvar style:=StyleBoxFlat.new()\n\tstyle.bg_color=Color("#1f1b36")\n\tstyle.border_color=Color("#8e6fb4")\n\tstyle.set_border_width_all(3)\n\tstyle.set_content_margin_all(18)','panel.position=Vector2(102,468)\n\tpanel.custom_minimum_size=Vector2(948,160)\n\tvar style:=UI.frame("panel_dim").duplicate()\n\tstyle.set_content_margin_all(24)'),
 ('list.add_child(title)\n\tprose=label','title.position=Vector2(270,268)\n\tui.add_child(title)\n\tprose=label'),
 ('list.add_child(prose)\n\tchoices=','prose.hide() # Remains the story text model; the shared dialogue draws it.\n\tui.add_child(prose)\n\tdialogue=preload("res://scripts/ui/opening_dialogue.gd").new()\n\tdialogue.source=self\n\tui.add_child(dialogue)\n\tchoices='),
 ('Vector2(652,44)','Vector2(648,52)'),('Vector2(236,44)','Vector2(236,52)'),
 ('var style:=StyleBoxFlat.new()\n\tstyle.bg_color=Color("#332d4c")\n\tstyle.border_color=Color("#8e6fb4")\n\tstyle.set_border_width_all(2)','b.custom_minimum_size.y=52\n\tvar style:=UI.frame("panel").duplicate()\n\tstyle.content_margin_top=8\n\tstyle.content_margin_bottom=8'),
 ('var focus:=style.duplicate()\n\tfocus.border_color=Color("#7fe3d0")\n\tfocus.set_border_width_all(3)','var focus:=UI.frame("panel_focus").duplicate()\n\tfocus.content_margin_top=8\n\tfocus.content_margin_bottom=8'),
 ('Vector2(290 if phase==0 else 444,46)','Vector2(290 if phase==0 else 444,52)'),
 ('confirm.grab_focus.call_deferred()','dialogue.queue_redraw()\n\tconfirm.grab_focus.call_deferred()')])
edit('first_partner_arrival.gd',[
 ('var creature:','const UI := preload("res://scripts/ui/ui_style.gd")\nvar creature:'),
 ('Vector2(752, 478)','Vector2(710, 464)'),('Vector2(352, 118)','Vector2(394, 148)'),
 ('var box := StyleBoxFlat.new()\n\tbox.bg_color = Color("#1f1b36")\n\tbox.border_color = accent\n\tbox.set_border_width_all(2)\n\tbox.set_content_margin_all(14)','var box := UI.frame("panel").duplicate()\n\tbox.set_content_margin_all(24)')])
print('Prepared shared launch frames and preserved all story/state methods.')
