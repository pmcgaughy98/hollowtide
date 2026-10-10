from pathlib import Path
W=Path(__file__).parent
t=Path('D:/dev/hollowtide-crossroads-20261010/crossroads_check.gd').read_text().replace('hollowtide-crossroads-20261010','hollowtide-hollow-mouth-20261010')
t=t[:t.index('\tvar lane: Image')]
t=t.replace('var allowed := Rect2i(432, 264, 288, 144)','var allowed := Rect2i(792,648,50,50)\n\tvar apron := Rect2i(768,624,24,72)').replace('if allowed.has_point(Vector2i(x, y)):','if allowed.has_point(Vector2i(x, y)) or apron.has_point(Vector2i(x, y)):').replace('Crossroads footprint','Hollow Mouth and bounded west approach')
t+='''\tvar roads_same := true
\tfor r in Layout.PATHS:
\t\tvar px := Rect2i(r.position * 24,r.size * 24)
\t\tfor y in range(px.position.y,px.end.y):
\t\t\tfor x in range(px.position.x,px.end.x): roads_same = roads_same and before.get_pixel(x,y) == after.get_pixel(x,y)
\tcheck(roads_same,"all authored town / ferry road pixels stay exact")
\tvar town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
\troot.add_child(town)
\tawait frames(10)
\tvar view: Node2D = town._building_exteriors
\tcheck(view.buildings.size() == 10 and view.buildings.has("plaza") and view.buildings.has("board") and view.buildings.has("yard") and view.buildings.has("shrine"),"Mouth joins all nine finished service views")
\tvar b: Dictionary = view.buildings["gate"]
\tcheck(b["base"].position == Vector2(792,648) and b["sprite"].texture.get_size() == Vector2(48,48),"exact original 48x48 Mouth footprint at (33,27)")
\tcheck(b["base"].z_index == 0 and not b.has("door"),"low scour recess draws below creatures, no artificial door")
\tcheck(b["sprite"].material.shader == preload("res://scripts/arena/creature_finish.gdshader") and b["sprite"].material.get_shader_parameter("detail_ink") == 1.0,"same purposeful sel-out detail preset")
\tvar open := true
\tfor y in range(27,29):
\t\tfor x in range(33,35): open = open and town.open_at(Vector2i(x,y))
\tcheck(open and town.open_at(Vector2i(32,28)),"all four footprint tiles and west approach remain walkable")
\tcheck(Layout.place_at(Vector2i(33,28)).get("id","") == "gate" and Layout.place_at(Vector2i(34,28)).is_empty(),"only unchanged south-west activation tile starts the Hollow")
\tvar src: Image = b["sprite"].texture.get_image()
\tcheck(src.get_pixel(0,0).a < 0.1 and src.get_pixel(47,47).a < 0.1,"transparent native corners show actual terrace")
\tvar cleft := 0.0
\tvar foothold := 0.0
\tfor y in range(20,28):
\t\tfor x in range(20,28): cleft += src.get_pixel(x,y).get_luminance()
\tfor y in range(33,41):
\t\tfor x in range(9,17): foothold += src.get_pixel(x,y).get_luminance()
\tcheck(foothold > cleft + 6.4,"source foothold reads lighter than the descending recess, on entry tile")
\tprint("Source foothold / cleft mean ",foothold / 64.0," / ",cleft / 64.0)
\tvar proof := SubViewport.new()
\tproof.size = Vector2i(96,48)
\tproof.transparent_bg = true
\tproof.render_target_update_mode = SubViewport.UPDATE_ALWAYS
\troot.add_child(proof)
\tfor k in 2:
\t\tvar s := Sprite2D.new()
\t\ts.centered = false
\t\ts.position.x = k * 48
\t\ts.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
\t\ts.texture = b["sprite"].texture
\t\tpreload("res://scripts/arena/creature_finish.gd").apply(s,k == 1)
\t\tproof.add_child(s)
\tawait frames(3)
\tawait RenderingServer.frame_post_draw
\tvar rendered := proof.get_texture().get_image()
\trendered.save_png(OUT + "mouth_native_finish.png")
\tvar dark := [0,0]
\tfor k in 2:
\t\tfor y in range(5,45):
\t\t\tfor x in range(4,44):
\t\t\t\tvar c := rendered.get_pixel(x + k * 48,y)
\t\t\t\tif c.a > 0.9 and maxf(c.r,maxf(c.g,c.b)) < 0.12: dark[k] += 1
\tcheck(dark[1] > dark[0],"actual native shader strengthens interior stone / root contours")
\tprint("Native detail ink pixels ",dark)
\tproof.queue_free()
\ttown.team[0]["pos"] = Vector2i(32,27)
\ttown.team[0]["facing"] = "s"
\ttown._place(town.team[0])
\tawait town.act_move(Vector2i.DOWN)
\tcheck(town.team[0]["pos"] == Vector2i(32,28) and not town.has_meta("entered"),"walk reaches approach without starting a run early")
\ttown.team[0]["facing"] = "e"
\ttown._place(town.team[0])
\tawait key(KEY_E)
\tcheck(town.get_meta("entered",false),"native E facing original activation tile still starts entry")
\ttown.remove_meta("entered")
\ttown.team[0]["pos"] = Vector2i(33,27)
\ttown._place(town.team[0])
\tawait town.act_move(Vector2i.RIGHT)
\tcheck(town.team[0]["pos"] == Vector2i(34,27) and not town.has_meta("entered"),"walk crosses open north rim without starting a run")
\ttown.team[0]["pos"] = Vector2i(32,28)
\ttown.team[1]["pos"] = Vector2i(31,28)
\ttown._place(town.team[0])
\ttown._place(town.team[1])
\ttown.set_process(false)
\ttown._world.position = Vector2(-624,-552)
\ttown._hud.queue_redraw()
\ttown._labels.queue_redraw()
\tawait frames(3)
\tawait snap("mouth_exterior")
\ttown.set_process(true)
\ttown.poll_input = false
\t# Real scene transition, including Claude's current carried-job state.
\tvar State = preload("res://scripts/town/team_state.gd")
\tState.start(town.party)
\tvar carried: Array = [preload("res://scripts/town/jobs.gd").post(7)[0]]
\tState.data["jobs"] = carried.duplicate(true)
\tState.data["rank"] = preload("res://scripts/town/jobs.gd").RANK_STEPS[1]
\tcurrent_scene = town
\tawait town.act_move(Vector2i.RIGHT)
\tawait frames(8)
\tcheck(current_scene != null and current_scene.scene_file_path == "res://scenes/dungeon.tscn","walking onto (33,28) changes to actual dungeon scene")
\tvar dg: Node2D = current_scene
\tcheck(dg.return_to_town and dg.party == [[0,0],[1,0]],"actual run retains party and return-to-town flag")
\tcheck(dg.jobs == carried and dg.rank == State.data["rank"],"actual entrance preserves Claude's carried jobs and rank")
\tawait snap("dungeon_arrival")
\tdg.queue_free()
\tawait frames(4)
\tprint("RESULT ",checks," checks, ",bad," failures")
\tquit(0 if bad == 0 else 1)
'''
(W/'mouth_check.gd').write_text(t)
t=Path('D:/dev/hollowtide-crossroads-20261010/fallback_check.gd').read_text().replace('hollowtide-crossroads-20261010','hollowtide-hollow-mouth-20261010').replace('== 8','== 9').replace('has("plaza")','has("gate")').replace('Vector2i(24, 14)','Vector2i(33, 28)').replace('== "plaza"','== "gate"').replace('town.panel.get("service", "") == "waymark"','town.get_meta("entered", false)').replace('previous eight','previous nine').replace('Crossroads service','Hollow entry')
(W/'fallback_check.gd').write_text(t)
print('Native footprint / input / real transition / jobs preservation checks ready.')
