from pathlib import Path
from PIL import Image
import shutil,json
W=Path(__file__).parent; L=Path('C:/Users/pmcga/dev/hollowtide')
def cp(s,d): d.parent.mkdir(parents=True,exist_ok=True); shutil.copy2(s,d)
for rel in ['scripts/town/wayline_hall_painter.gd','scripts/ui/game_pause_menu.gd','project.godot','assets/sprites/world/wayline_hall_2026_10_09/wayline_hall_native.png']:
    cp(L/rel,W/'originals'/rel)
# Prepare only the generated entrance insert; no original sprite pixel is edited.
native=Image.open(W/'review/generated_native.png')
patch=native.crop((114,72,170,144)).resize((72,72),Image.Resampling.NEAREST)
asset=W/'candidate/assets/sprites/world/wayline_hall_2026_10_10/hall_entrance_native.png'
asset.parent.mkdir(parents=True,exist_ok=True); patch.save(asset)
meta=json.loads((W/'asset-preparation.json').read_text())
meta.update({'generated_native_crop':[114,72,170,144],'insert_size':[72,72],'hall_local_insert_rect':[92,72,72,72],'world_insert_rect':[548,96,72,72],'original_sprite':'untouched; runtime blit confined to insertion rectangle'})
(W/'asset-preparation.json').write_text(json.dumps(meta,indent=2))
rel='scripts/town/highbank_ground_painter.gd'
text=(L/rel).read_text()
text=text.replace('## Highbank ground proposal. Claude\'s collision layout stays immutable; Preston widened the Hall\'s visible approach.','## Highbank ground proposal. Claude\'s collision layout and multi-tile doorway are the contract.')
text=text.replace('\t# Preston: centre the visible three-tile approach on the existing Hall door (24,6).\n\t# Tile (25,7..8) is already open grass; this paints paving without changing collision.\n\tif Rect2i(23, 7, 3, 2).has_point(Vector2i(x, y)):\n\t\treturn true\n','\t# October 10: the two-tile Hall doorway now meets the authored two-tile steps.\n')
text=text.replace('\t\t\tvar d: Vector2i = place["door"] * T\n\t\t\timg.fill_rect(Rect2i(d + Vector2i(7, 17), Vector2i(10, 2)), Color("#d0b891"))','\t\t\tfor door in Layout.door_tiles(place):\n\t\t\t\tvar d: Vector2i = door * T\n\t\t\t\timg.fill_rect(Rect2i(d + Vector2i(7, 17), Vector2i(10, 2)), Color("#d0b891"))')
text=text.replace('\t\t\tvar d: Vector2i = place["door"] * T\n\t\t\timg.blit_rect(blockout, Rect2i(d + Vector2i(6, 4), Vector2i(T - 12, T - 4)), d + Vector2i(6, 4))','\t\t\tfor door in Layout.door_tiles(place):\n\t\t\t\tvar d: Vector2i = door * T\n\t\t\t\tif place["kind"] == "building" and Layout.door_tiles(place).size() > 1:\n\t\t\t\t\timg.fill_rect(Rect2i(d + Vector2i(0, 4), Vector2i(T, T - 4)), Color("#2a1a12"))\n\t\t\t\telse:\n\t\t\t\t\timg.blit_rect(blockout, Rect2i(d + Vector2i(6, 4), Vector2i(T - 12, T - 4)), d + Vector2i(6, 4))')
assert 'place["door"]' not in text
(W/'candidate'/rel).write_text(text)
rel='scripts/town/wayline_hall_painter.gd'; text=(L/rel).read_text()
text=text.replace('const ART =','const ENTRANCE = "res://assets/sprites/world/wayline_hall_2026_10_10/hall_entrance_native.png"\nconst ENTRANCE_RECT = Rect2i(92, 72, 72, 72)\nconst ART =',1)
text=text.replace('\treturn img\n', '\treturn img\n',1)
needle='\timg.blend_rect(art, Rect2i(Vector2i.ZERO, art.get_size()), px.position)\n\treturn img'
replacement='''\timg.blend_rect(art, Rect2i(Vector2i.ZERO, art.get_size()), px.position)
\t# Retain the original roof/windows/exterior; only the new entrance bay is overlaid.
\tif ResourceLoader.exists(ENTRANCE):
\t\tvar entrance: Image = load(ENTRANCE).get_image()
\t\tif entrance.get_size() == ENTRANCE_RECT.size:
\t\t\timg.blit_rect(entrance, Rect2i(Vector2i.ZERO, entrance.get_size()), px.position + ENTRANCE_RECT.position)
\t\telse:
\t\t\tpush_warning("Hall entrance insert has the wrong native size; keeping the original.")
\treturn img'''
assert needle in text; text=text.replace(needle,replacement)
(W/'candidate'/rel).write_text(text)
rel='project.godot'; text=(L/rel).read_text()
assert 'run/main_scene="res://scenes/hollow_floor.tscn"' in text
text=text.replace('run/main_scene="res://scenes/hollow_floor.tscn"','run/main_scene="res://scenes/creature_opening.tscn"')
(W/'candidate'/rel).write_text(text)
# Keep Claude's field pages; avoid truncating the now-nine-button dungeon main page.
rel='scripts/ui/game_pause_menu.gd'; text=(L/rel).read_text()
text=text.replace('            _label("Real-time fights: WASD / arrows move; J / click attacks; Space dodges; 1-3 use moves; Q / E cycles targets. Y / N answers a recruit after a fight.",20)','            _label("Dungeon combat is turn-based. Y / N answers a recruit. The Training Yard is the separate arena mode.",20)')
text=text.replace('    for i in controls.size():\n','    # Field pages added more rows; keep the dungeon main menu inside the fixed viewport.\n    if page == "main" and in_hollow:\n        content.add_theme_constant_override("separation",6)\n        for b in controls: b.custom_minimum_size.y = 42\n    else:\n        content.add_theme_constant_override("separation",10)\n    for i in controls.size():\n',1)
(W/'candidate'/rel).parent.mkdir(parents=True,exist_ok=True)
(W/'candidate'/rel).write_text(text)
print('Staged bounded entrance insert, authored approach, field-menu fit, accurate controls and F5 opening.')
