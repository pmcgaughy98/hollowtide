from pathlib import Path
import runpy,shutil,json
W=Path(__file__).parent;S=Path('D:/dev/hollowtide-world-refinement-20261008/project')
grid=[
'................',
'................',
'......ooooo.....',
'....oo33332oo...',
'...o333332222o..',
'..o33333222221o.',
'..o22223322221o.',
'..o2223o322221o.',
'..o2223Gg22221o.',
'..o222gGGg2221o.',
'..o2222gg32221o.',
'..o22222322221o.',
'..o12222322111o.',
'..o11113111111o.',
'...ooooooooooo..',
'................',
]
assert len(grid)==16 and all(len(row)==16 for row in grid)
palette={'1':'#8a6a3a','2':'#d8c08a','3':'#f6ead0','g':'#8a1f2e','G':'#c84a5a'}
source=(W/'originals/tools/ui/build_icons.py').read_text()
entry='    # Sealed paper delivery parcel: the scroll\'s existing paper/wax palette.\n    "item/parcel": ('+repr(palette)+', [\n'+''.join('        '+repr(row)+',\n' for row in grid)+'    ]),\n'
needle='    "item/lamp_oil":'
assert needle in source and '"item/parcel"' not in source
source=source.replace(needle,entry+needle,1)
(W/'build_icons.py').write_text(source)
recipe=runpy.run_path(str(W/'build_icons.py'))
image=recipe['draw'](*recipe['ICONS']['item/parcel'])
image.save(W/'parcel.png')
image.resize((96,96),resample=0).save(W/'parcel-3x.png')
# Use only the scoped recipe, preserving every previously installed PNG/sheet.
dest=S/'assets/sprites/ui/item/parcel.png';shutil.copy2(W/'parcel.png',dest)
shutil.copy2(W/'build_icons.py',S/'tools/ui/build_icons.py')
town=(W/'originals/scripts/town/hub_town.gd').read_text()
needle='\t\tUI.text(h, r.position + Vector2(70, 27), Jobs.title(j), 20, UI.EDGE_LIGHT if on else UI.TEXT, 340)'
replacement='''\t\t# Delivery cargo has its own icon; the reward keeps its existing icon.
\t\tvar cargo := UI.item_icon("parcel") if j["kind"] == "delivery" else null
\t\tvar cargo_inset := 40 if cargo != null else 0
\t\tif cargo != null:
\t\t\th.draw_texture(cargo, r.position + Vector2(70, 11))
\t\tUI.text(h, r.position + Vector2(70 + cargo_inset, 27), Jobs.title(j), 20, UI.EDGE_LIGHT if on else UI.TEXT, 340 - cargo_inset)'''
assert needle in town
town=town.replace(needle,replacement,1)
needle='\t\tUI.text(h, r.position + Vector2(70, 51), "B%dF   %s" % [int(j["floor"]), where], 15, UI.MUTED, 340)'
assert needle in town
town=town.replace(needle,needle.replace('Vector2(70, 51)','Vector2(70 + cargo_inset, 51)').replace('UI.MUTED, 340)','UI.MUTED, 340 - cargo_inset)'),1)
(W/'hub_town.gd').write_text(town)
shutil.copy2(W/'hub_town.gd',S/'scripts/town/hub_town.gd')
(W/'recipe.json').write_text(json.dumps({'logical_size':[16,16],'file_size':[32,32],'palette':palette,'outline':[26,20,16,255],'grid':grid},indent=2))
print('Staged one native-grid parcel icon and delivery-only Board presentation hook. Generic item lookup/Bag already resolve the asset.')
