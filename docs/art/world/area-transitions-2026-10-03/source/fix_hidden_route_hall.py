from pathlib import Path
p=Path(r"C:/Users/pmcga/dev/hollowtide/scripts/route1_crossing.gd");t=p.read_text()
old='find_children("*", "StaticBody2D")'
assert t.count(old)==1
p.write_text(t.replace(old,'find_children("*", "StaticBody2D", true, false)'),encoding="utf-8")
print("Included dynamically created hall collisions when removing the old route hall.")
