from pathlib import Path
W=Path(__file__).parent
text=(W/'originals/scripts/town/highbank_ground_painter.gd').read_text()
for name in ['home_painter.gd','item_shop_painter.gd']:
    text=text.replace('res://scripts/town/'+name,(W/'originals/scripts/town'/name).as_posix())
(W/'baseline_ground.gd').write_text(text)
text=(W/'originals/scripts/town/hub_town.gd').read_text().replace('res://scripts/town/highbank_ground_painter.gd',(W/'baseline_ground.gd').as_posix())
(W/'baseline_hub.gd').write_text(text)
