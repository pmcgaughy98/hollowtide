from pathlib import Path
W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an");D=W/"historic-street-review"
for folder in ["trip","render"]:(D/folder).mkdir(exist_ok=True)
s=(W/"courier_hall_final_walkthrough.gd").read_text().replace("courier-hall-review/final-trip/","historic-street-review/trip/")
needle='if not await interaction(Vector2(816,512),"CITY ROUTES","city_directions_read"):finish();return'
assert needle in s
s=s.replace(needle,needle+'\n\tif not await historic_loop():finish();return')
s=s.replace("func _run() -> void:",(W/"historic_street.loop.gd").read_text().replace("    ","\t")+"\nfunc _run() -> void:")
(W/"historic_street_walkthrough.gd").write_text(s,encoding="utf-8",newline="\n")
