from pathlib import Path
import shutil
P=Path(r"C:/Users/pmcga/dev/hollowtide");W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an");D=W/"historic-street-review"
p=P/"scripts/historic_street.gd";s=p.read_text();shutil.copy2(p,D/"historic_street.full-trip-version.gd")
s=s.replace('_label("CurrentShopAddress","18",Vector2(537,327))','_sign("CurrentShopAddress","18",Vector2(538,332),8)')
s=s.replace('_label("OldShopLintel","6",Vector2(541,353))','_label("OldShopLintel","6",Vector2(541,363))')
s=s.replace('_label("LedgerCaption","STREET LEDGER",Vector2(168,410))','_sign("LedgerCaption","LEDGER",Vector2(212,341),6)')
needle="func nearest_site() -> String:"
helper='''func _sign(label:String,text:String,at:Vector2,size:int) -> Label:
\tvar ink:=_label(label,text,at)
\tink.add_theme_font_size_override("font_size",size)
\tink.add_theme_color_override("font_color",Color("#49362a"))
\tink.add_theme_constant_override("outline_size",0)
\treturn ink
'''
assert needle in s;s=s.replace(needle,helper+"\n"+needle)
p.write_text(s,encoding="utf-8",newline="\n")
for folder in ["final-render","final-city-check"]:(D/folder).mkdir(exist_ok=True)
# Keep traversal/interaction/collision logic exactly that of the passing full trip.
old=(D/"historic_street.full-trip-version.gd").read_text()
for name in ["nearest_site","interaction_hint","interact","_process","visit_board","visit_shop","visit_ledger","offer_handoff_if_requested","_record_handoff","_update_board","objective_text","board_summary","notes_text"]:
 def part(text):
  start=text.index("func "+name+"(");end=text.find("\nfunc ",start+1)
  return text[start:] if end<0 else text[start:end]
 assert part(old)==part(s),name
t=(W/"historic_street_walkthrough.gd").read_text().replace("historic-street-review/trip/","historic-street-review/final-city-check/")
start=t.index("func _run() -> void:");end=t.index("func finish() -> void:",start)
run='''func _run() -> void:
\tjourney=load("res://scenes/world_journey.tscn").instantiate()
\tjourney.initial_area="riverfront";journey.set_courier_model(model)
\troot.add_child(journey);current_scene=journey
\troute=journey.route
\tawait frames(45)
\tparty_id=root.get_node("PlayerParty").active_member().get_instance_id()
\troute_id=route.get_instance_id()
\tif not await path([Vector2(384,512),Vector2(512,456)]):finish();return
\tif not await interaction(Vector2(512,400),"CITY COURIER","city_arrival_registered"):finish();return
\tif not await path([Vector2(512,456),Vector2(640,512)]):finish();return
\tif not await interaction(Vector2(816,512),"CITY ROUTES","city_directions_read"):finish();return
\tif not await historic_loop():finish();return
\tfinish()
'''
t=t[:start]+run+t[end:];(W/"historic_street_final_city_check.gd").write_text(t,encoding="utf-8",newline="\n")
