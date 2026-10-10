from pathlib import Path
p=Path(__file__).parent/'title_check.gd'
p.write_text(p.read_text().replace(chr(92)+'t',chr(9)))
