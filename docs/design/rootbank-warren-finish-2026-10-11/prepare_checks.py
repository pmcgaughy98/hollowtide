from pathlib import Path
W=Path(__file__).parent
R=Path('C:/Users/pmcga/dev/hollowtide')
src=(R/'tools/debug/dungeons_check.gd').read_text()
src=src.replace('\tquit()','\tvar music := root.get_node_or_null("HollowtideMusic")\n\tif music != null: music.queue_free()\n\tawait _frames(4)\n\tquit(0 if fails == 0 else 1)')
(W/'dungeons.gd').write_text(src)
src=(R/'tools/debug/crew_scene_capture.gd').read_text()
src=src.replace('const OUT := "res://docs/design/rival-crew-2026-10-10/crew_scene/"','const OUT := "D:/dev/hollowtide-rootbank-finish-20261011/crew/"')
src=src.replace('\tdg = load', '\troot.size = Vector2i(1152,648)\n\tdg = load',1)
src=src.replace('\tquit()', '\tvar music := root.get_node_or_null("HollowtideMusic")\n\tif music != null: music.queue_free()\n\tdg.queue_free()\n\tfor k in 4: await process_frame\n\tquit(0 if ok_all else 1)')
(W/'crew.gd').write_text(src)
print('Prepared isolated existing gameplay and crew cinematic checks.')
