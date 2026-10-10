from pathlib import Path
W=Path(__file__).parent
old=(W/'originals/scripts/town/highbank_ground_painter.gd').read_text().replace('\t\tif place["kind"] == "area":','\t\tif place["id"] == "plaza": continue\n\t\tif place["kind"] == "area":')
(W/'lane_ground.gd').write_text(old)
old=(W/'originals/scripts/town/hub_town.gd').read_text().replace('res://scripts/town/highbank_ground_painter.gd',(W/'lane_ground.gd').as_posix())
(W/'lane_hub.gd').write_text(old)
t=Path('D:/dev/hollowtide-job-board-20261010/board_check.gd').read_text().replace('hollowtide-job-board-20261010','hollowtide-crossroads-20261010')
t=t[:t.index('\tvar town: Node2D')]
t=t.replace('Rect2i(624, 168, 50, 48)','Rect2i(432, 264, 288, 144)').replace('Board / reading spot','Crossroads footprint')
t+='''\tvar lane: Image = load("D:/dev/hollowtide-crossroads-20261010/lane_hub.gd").paint()
\tvar path_same := true
\tfor y in range(264, 408):
\t\tfor x in range(552, 600):
\t\t\tpath_same = path_same and after.get_pixel(x, y) == lane.get_pixel(x, y)
\tcheck(path_same, "all 6912 authored ferry-lane ground pixels exact, including street / south joins")
\tvar town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
\troot.add_child(town)
\tawait frames(10)
\tvar view: Node2D = town._building_exteriors
\tcheck(view.buildings.size() == 9 and view.buildings.has("board") and view.buildings.has("shrine") and view.buildings.has("yard"), "Crossroads joins all eight previous finished services")
\tvar b: Dictionary = view.buildings["plaza"]
\tcheck(b["base"].position == Vector2(576, 336) and b["sprite"].texture.get_size() == Vector2(24, 24), "waymark on exact activation tile (24,14), native 24x24")
\tcheck(b["base"].z_index == 0 and not b.has("door"), "flat floor inlay stays below creatures, no false upright door")
\tcheck(b["sprite"].material.shader == preload("res://scripts/arena/creature_finish.gdshader") and b["sprite"].material.get_shader_parameter("detail_ink") == 1.0, "shared purposeful sel-out detail preset")
\tvar open := true
\tfor y in range(11,17):
\t\tfor x in range(18,30): open = open and town.open_at(Vector2i(x,y))
\tcheck(open, "all 72 plaza tiles remain walkable")
\tvar src: Image = b["sprite"].texture.get_image()
\tcheck(src.get_pixel(0,0).a == 0.0 and src.get_pixel(23,23).a == 0.0, "inlay transparent corners show authored lane")
\tcheck(b["frames"][0].get_image().get_data() != b["frames"][1].get_image().get_data() and b["frames"][1].get_image().get_data() != b["frames"][2].get_image().get_data(), "three distinct quiet carved-inlay response states")
\tvar proof := SubViewport.new()
\tproof.size = Vector2i(48,24)
\tproof.transparent_bg = true
\tproof.render_target_update_mode = SubViewport.UPDATE_ALWAYS
\troot.add_child(proof)
\tfor k in 2:
\t\tvar s := Sprite2D.new()
\t\ts.centered = false
\t\ts.position.x = k * 24
\t\ts.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
\t\ts.texture = b["sprite"].texture
\t\tpreload("res://scripts/arena/creature_finish.gd").apply(s,k == 1)
\t\tproof.add_child(s)
\tawait frames(3)
\tawait RenderingServer.frame_post_draw
\tvar rendered := proof.get_texture().get_image()
\trendered.save_png(OUT + "waymark_native_finish.png")
\tvar dark := [0,0]
\tfor k in 2:
\t\tfor y in range(5,20):
\t\t\tfor x in range(3,21):
\t\t\t\tvar c := rendered.get_pixel(x + k * 24,y)
\t\t\t\tif c.a > 0.9 and maxf(c.r,maxf(c.g,c.b)) < 0.12: dark[k] += 1
\tcheck(dark[1] > dark[0], "actual native sel-out strengthens interior limestone joints")
\tprint("Native detail ink pixels ",dark)
\tproof.queue_free()
\tfor k in 3: b["frames"][k].get_image().save_png(OUT + "waymark_frame_" + str(k) + ".png")
\ttown.team[0]["pos"] = Vector2i(24,13)
\ttown.team[0]["facing"] = "s"
\ttown._place(town.team[0])
\tawait frames(2)
\tawait town.act_move(Vector2i.DOWN)
\tcheck(town.team[0]["pos"] == Vector2i(24,14), "native walk reaches exact Crossroads activation tile")
\tvar sound_before: String = town.last_sfx
\tawait key(KEY_E)
\tcheck(town.panel.get("id", "") == "plaza" and town.panel.get("service", "") == "waymark", "native E opens original Crossroads waymark description")
\tcheck(town.last_sfx == sound_before, "waymark retains original quiet service, no added door sound")
\tawait frames(3)
\tcheck(b["frame"] == 1, "carved inlay transitions through middle state")
\tawait frames(8)
\tcheck(b["frame"] == 2, "carved glyph brightens with existing open waymark panel")
\tawait snap("crossroads_service")
\tawait key(KEY_ESCAPE)
\tawait frames(12)
\tcheck(town.panel.is_empty() and b["frame"] == 0, "Esc closes service and settles carved waymark")
\ttown.team[0]["pos"] = Vector2i(24,13)
\ttown._place(town.team[0])
\tawait key(KEY_E)
\tcheck(town.panel.get("id", "") == "plaza", "native E works facing waymark from north approach")
\tawait key(KEY_ESCAPE)
\tawait frames(12)
\ttown.team[0]["pos"] = Vector2i(24,14)
\ttown._place(town.team[0])
\tawait town.act_move(Vector2i.LEFT)
\tawait town.act_move(Vector2i.RIGHT)
\tcheck(town.team[0]["pos"] == Vector2i(24,14), "leader crosses unchanged two-tile ferry lane")
\ttown.set_process(false)
\ttown._world.position = Vector2(-384,-216)
\tawait frames(3)
\tawait snap("crossroads_exterior")
\tview.set_process(false)
\tb["sprite"].texture = b["frames"][2]
\tawait frames(3)
\tawait snap("crossroads_inlay_active")
\ttown.queue_free()
\tawait frames(4)
\tprint("RESULT ",checks," checks, ",bad," failures")
\tquit(0 if bad == 0 else 1)
'''
(W/'crossroads_check.gd').write_text(t)
t=Path('D:/dev/hollowtide-job-board-20261010/fallback_check.gd').read_text().replace('hollowtide-job-board-20261010','hollowtide-crossroads-20261010').replace('== 7','== 8').replace('has("board")','has("plaza")').replace('Vector2i(26, 8)','Vector2i(24, 14)').replace('== "board"','== "plaza"').replace('== "jobs"','== "waymark"').replace('previous seven','previous eight').replace('Board service','Crossroads service')
(W/'fallback_check.gd').write_text(t)
print('Native input / ground / route / preservation / fallback checks prepared.')
