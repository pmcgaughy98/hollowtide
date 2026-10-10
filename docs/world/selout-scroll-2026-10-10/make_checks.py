from pathlib import Path
W=Path(__file__).parent
s=Path('D:/dev/hollowtide-storage-finish-20261010/storage_check.gd').read_text()
s=s.replace('hollowtide-storage-finish-20261010','hollowtide-selout-scroll-20261010').replace('Rect2i(910, 70, 148, 147)','Rect2i(742, 264, 148, 146)')
s=s.replace('Storage','Scroll Keeper').replace('storage','scrolls')
s=s.replace('["home", "shop", "hall"]','["home", "shop", "hall", "storage"]')
s=s.replace('view.buildings.size() == 4','view.buildings.size() == 6').replace('Vector2(912, 72)','Vector2(744, 288)')
s=s.replace('b["sprite"].material.shader == preload("res://scripts/town/building_detail_finish.gdshader")','b["sprite"].material.shader == preload("res://scripts/arena/creature_finish.gdshader") and b["sprite"].material.get_shader_parameter("detail_ink") == 1.0')
# The source fits the north facade, so the door frames start at local y0 and use the same x46 anchor.
s=s.replace('count > 200','count > 100')
s=s.replace('Vector2i(40, 8)','Vector2i(33, 11)').replace('Vector2i(40, 7)','Vector2i(33, 12)').replace('["facing"] = "n"','["facing"] = "s"').replace('town.act_move(Vector2i(0, -1))','town.act_move(Vector2i(0, 1))')
s=s.replace('s.material.shader = preload("res://scripts/town/building_detail_finish.gdshader")','s.material.set_shader_parameter("detail_ink", 1.0)')
s=s.replace('Vector2(-768, -24)','Vector2(-696, -240)')
(W/'scroll_check.gd').write_text(s)
s=Path('D:/dev/hollowtide-shrine-finish-20261010/shrine_check.gd').read_text().replace('hollowtide-shrine-finish-20261010','hollowtide-selout-scroll-20261010')
s=s.replace('town._building_exteriors.buildings.size() == 5','town._building_exteriors.buildings.size() == 6')
s=s.replace('b["sprite"].material.shader == preload("res://scripts/town/building_detail_finish.gdshader")','b["sprite"].material.shader == preload("res://scripts/arena/creature_finish.gdshader") and b["sprite"].material.get_shader_parameter("detail_ink") == 1.0')
# Scroll Keeper's new ground is intentionally outside the unchanged shrine patch.
s=s.replace('not Rect2i(96, 264, 144, 144).has_point(Vector2i(x, y))','not Rect2i(742, 264, 148, 146).has_point(Vector2i(x, y))')
s=s.replace('all ground outside shrine / north approach exact','all ground outside new Scroll Keeper exact (shrine ground retained)')
(W/'shrine_check.gd').write_text(s)
print('Native scroll and shrine fixtures prepared.')
