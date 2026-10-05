from pathlib import Path
import shutil
P=Path(r"C:/Users/pmcga/dev/hollowtide"); W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an")
D=W/"area-transition-review"
for name in ["render.out.log","render.err.log","installed-home-gameplay.png","installed-home-overview.png","installed-route-approach.png","installed-riverfront-gameplay.png","installed-riverfront-overview.png"]:
    shutil.copy2(D/name,D/("initial-"+name))
p=P/"scripts/area_landscape.gd";text=p.read_text()
text=text.replace('material.shader = CANOPY\n    tree.material','material.shader = CANOPY\n    material.set_shader_parameter("canopy_opacity",1.0)\n    tree.material')
text=text.replace('ground.tile_set = TILESET','ground.tile_set = TILESET\n    ground.rendering_quadrant_size = 128')
p.write_text(text,encoding="utf-8")
p=P/"scripts/route1_approach.gd";text=p.read_text()
text=text.replace('canopy.shader = LANDSCAPE.CANOPY\n        tree.material','canopy.shader = LANDSCAPE.CANOPY\n        canopy.set_shader_parameter("canopy_opacity",1.0)\n        tree.material')
text=text.replace('terrain.tile_set = TILESET','terrain.tile_set = TILESET\n    terrain.rendering_quadrant_size = 128')
p.write_text(text,encoding="utf-8")
print("Initialized each tree fade; removed terrain quadrant shade seams in new areas.")
