from pathlib import Path
W=Path(__file__).parent
text=(W/'originals/scripts/town/hub_town.gd').read_text().replace('res://scripts/town/highbank_ground_painter.gd',(W/'originals/scripts/town/highbank_ground_painter.gd').as_posix())
(W/'baseline_hub.gd').write_text(text)
