from pathlib import Path
W=Path(__file__).parent
t=Path('D:/dev/hollowtide-training-yard-20261010/yard_check.gd').read_text()
t=t.replace('hollowtide-training-yard-20261010','hollowtide-job-board-20261010').replace('Rect2i(912, 264, 168, 144)','Rect2i(624, 168, 50, 48)').replace('Yard / north approach','Board / reading spot').replace('view.buildings.size() == 7','view.buildings.size() == 8').replace('view.buildings["yard"]','view.buildings["board"]').replace('Yard joins all six finished services','Board joins all seven finished services').replace('Vector2(912, 288)','Vector2(624, 168)').replace('Vector2(168, 120)','Vector2(48, 24)').replace('original Yard position and 168x120 footprint','original Board position and 48x24 footprint')
t=t.replace('b["base"].z_index == 0 and not b.has("door")','b["base"].z_index == 191 and b["pad"].z_index == 0 and not b.has("door")').replace('open-air ring remains under creatures','board foot sorts behind south reader; reading feedback is ground-level')
a=t.index('\tvar open := true');b=t.index('\tvar src: Image',a)
t=t[:a]+'''\tcheck(town.open_at(Vector2i(26, 7)) and town.open_at(Vector2i(27, 7)) and town.open_at(Vector2i(26, 8)), "all original Board / reading tiles stay walkable")
\tcheck(b["pad"].position == Vector2(624, 192), "response corners frame the exact reading tile")
''' +t[b:]
t=t.replace('src.get_pixel(167, 119)','src.get_pixel(47, 23)').replace('Vector2i(336, 120)','Vector2i(96, 24)').replace('k * 168','k * 48').replace('range(8, 112)','range(3, 22)').replace('range(8, 160)','range(3, 45)').replace('x + k * 168','x + k * 48').replace('dark[0] + 20','dark[0] + 5').replace('black internal stone / root / ring detail','black internal timber / paper / moss contours')
t=t.replace('Vector2i(41, 11)','Vector2i(26, 9)').replace('Vector2i(41, 12)','Vector2i(26, 8)').replace('["facing"] = "s"','["facing"] = "n"').replace('town.act_move(Vector2i.DOWN)','town.act_move(Vector2i.UP)').replace('unchanged north Yard activation tile','unchanged south Board reading tile').replace('town.panel.get("id", "") == "yard"','town.panel.get("id", "") == "board"').replace('town.panel.get("service", "") == "arena"','town.panel.get("service", "") == "jobs"').replace('town.last_sfx == "door"','town.last_sfx == "board_paper"').replace('arena description / service sound','jobs description / paper-rustle sound')
t=t.replace('target sign','reading-pad corners').replace('north approach','south approach').replace('yard_service','board_service').replace('yard_exterior','board_exterior').replace('yard_active_sign','board_reading_active').replace('Yard','Board')
a=t.index('\ttown.team[0]["pos"] = Vector2i(41, 14)');b=t.index('\ttown.set_process(false)',a)
t=t[:a]+'''\ttown.team[0]["pos"] = Vector2i(26, 8)
\ttown._place(town.team[0])
\tawait town.act_move(Vector2i.RIGHT)
\tawait town.act_move(Vector2i.LEFT)
\tcheck(town.team[0]["pos"] == Vector2i(26, 8), "leader walks across the original reading approach")
''' +t[b:]
t=t.replace('Vector2(-768, -240)','Vector2(-432, -24)')
(W/'board_check.gd').write_text(t)
t=Path('D:/dev/hollowtide-training-yard-20261010/fallback_check.gd').read_text().replace('hollowtide-training-yard-20261010','hollowtide-job-board-20261010').replace('buildings.size() == 6','buildings.size() == 7').replace('buildings.has("yard")','buildings.has("board")').replace('Vector2i(41, 12)','Vector2i(26, 8)').replace('get("id", "") == "yard"','get("id", "") == "board"').replace('get("service", "") == "arena"','get("service", "") == "jobs"').replace('previous six exteriors','previous seven exteriors').replace('Yard service retained','Board service retained')
(W/'fallback_check.gd').write_text(t)
print('Board native and missing-source checks prepared')
