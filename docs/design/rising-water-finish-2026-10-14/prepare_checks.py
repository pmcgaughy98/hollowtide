from pathlib import Path
W=Path(__file__).parent
src=(W/'originals/tools/debug/water_check.gd').read_text(encoding='utf-8')
src=src.replace('const OUT := "res://docs/design/water-2026-10-12/"','var OUT := "D:/dev/hollowtide-rising-water-20261014/"+("live/" if OS.get_cmdline_user_args().has("live") else "stage/")')
src=src.replace('func _run() -> void:\n','func _run() -> void:\n\troot.size=Vector2i(1152,648)\n',1)
src=src.replace('\tquit(1 if fails else 0)','\tvar music:=root.get_node_or_null("HollowtideMusic")\n\tif music!=null:music.queue_free()\n\tawait _frames(4)\n\tquit(1 if fails else 0)',1)
(W/'logic.gd').write_text(src,encoding='utf-8')
print('Prepared isolated original six-assertion water logic check; production check unchanged.')
