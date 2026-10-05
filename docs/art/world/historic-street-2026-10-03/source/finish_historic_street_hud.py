from pathlib import Path
import shutil
P=Path(r"C:/Users/pmcga/dev/hollowtide");W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an");D=W/"historic-street-review";(D/"hud-check").mkdir()
for name in ["world_journey.gd","historic_street.gd"]:shutil.copy2(P/"scripts"/name,D/(name+".before-hud-finish"))
p=P/"scripts/world_journey.gd";s=p.read_text();old='cached["historic_street"].started):'
assert s.count(old)==1;s=s.replace(old,'cached["historic_street"].started and not cached["historic_street"].handoff_verified):')
p.write_text(s,encoding="utf-8",newline="\n")
p=P/"scripts/historic_street.gd";s=p.read_text()
old='''\t\t_route.call("_show_message", "CITY COURIER\\nThe shop route is already marked 18. The ledger and the old doorway agree on the building. Your first river-route report is unchanged.")'''
new='''\t\tvar report_note:String = "Your first route report is already on the hometown board." if _route.get("report_done") else "Your landing report still goes to the hometown dispatcher."
\t\t_route.call("_show_message", "CITY COURIER\\nThe shop route is already marked 18. The ledger and the old doorway agree on the building. " + report_note)'''
assert old in s;s=s.replace(old,new);p.write_text(s,encoding="utf-8",newline="\n")
t=(W/"historic_street_final_city_check.gd").read_text().replace("historic-street-review/final-city-check/","historic-street-review/hud-check/")
old='''\tif not correct:failed=true;return false
\tawait key(KEY_E)'''
new='''\tif not correct:failed=true;return false
\tawait frames(5)
\tvar route_objective:bool=route.get("_objective").text=="FIRST ROUTE  /  Speak to the dispatcher"
\tsteps.append({"primary_route_objective_restored_after_city_handoff":route_objective,"objective":route.get("_objective").text})
\tif not route_objective:failed=true;return false
\tawait key(KEY_E)
\tawait key(KEY_E)
\tvar reminder:bool=route.get("_body").text.contains("hometown dispatcher") and flags()==unchanged
\tsteps.append({"repeat_city_handoff_has_pending_report_reminder":reminder,"route_flags_preserved":flags()==unchanged})
\tif not reminder:failed=true;return false
\tawait key(KEY_E)'''
assert old in t;t=t.replace(old,new)
(W/"historic_street_hud_check.gd").write_text(t,encoding="utf-8",newline="\n")
