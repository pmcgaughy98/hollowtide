from pathlib import Path
W=Path(__file__).parent
for name,id in [('home_painter.gd','home'),('item_shop_painter.gd','shop')]:
    text=(W/'originals/scripts/town'/name).read_text()
    anchor='\t# This replaces the old opaque rectangle only inside its own footprint.'
    var='home' if id=='home' else 'shop'
    text=text.replace(anchor,'\t# Separate sprites receive the shared finish; absent module retains the original blit.\n\tif ResourceLoader.exists("res://scripts/town/building_exteriors.gd"):\n\t\tvar view = load("res://scripts/town/building_exteriors.gd")\n\t\tif view.available("'+id+'"):\n\t\t\treturn view.ground_apply(img, ground, '+var+')\n'+anchor)
    (W/'candidate/scripts/town'/name).write_text(text)
text=(W/'originals/scripts/town/hub_town.gd').read_text()
text=text.replace('var _keys_was := {}','var _keys_was := {}\nvar _building_exteriors: Node2D')
text=text.replace('\t_world.add_child(map)','\t_world.add_child(map)\n\tif ResourceLoader.exists("res://scripts/town/building_exteriors.gd"):\n\t\t_building_exteriors = load("res://scripts/town/building_exteriors.gd").attach(_world, self)')
text=text.replace('func _draw_labels() -> void:\n\tfor p in Layout.PLACES:','func _draw_labels() -> void:\n\tfor p in Layout.PLACES:\n\t\tif is_instance_valid(_building_exteriors) and _building_exteriors.buildings.has(p["id"]):\n\t\t\tcontinue   # Finished entrances have their own sign / lantern; other plaques stay.')
(W/'candidate/scripts/town/hub_town.gd').write_text(text)
print('Four runtime files staged; original PNGs and controllers backed up.')
