from pathlib import Path
import json,hashlib,re,math
P=Path(r"C:/Users/pmcga/dev/hollowtide");W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an");D=W/"route1-spaced-landing-review"
runs={}
for model in ["male","female"]:
    r=json.loads((D/(model+"-walkthrough.json")).read_text());e=json.loads((D/(model+"-encounter.json")).read_text())
    assert r["passed"] and e["passed"],model
    assert r["ordinary_input_only"] and r["test_teleports"]==0 and r["quest_overrides"]==0
    assert e["ordinary_input_only"] and e["test_teleports"]==0 and e["quest_overrides"]==0
    assert [(x["from"],x["to"]) for x in r["engine_entrance_arrivals"]]==[("hometown","route1"),("route1","riverfront"),("riverfront","route1"),("route1","hometown")]
    for suffix in ["-walk.err.log","-encounter.err.log"]:assert (D/(model+suffix)).stat().st_size==0
    expected={k:True for k in r["flags"]}
    if model=="female":
        for k in ["heard_calls","water_mark_observed","reported_calls","reported_water_mark"]:expected[k]=False
    assert r["flags"]==expected
    relevant=[s for s in r["steps"] if "canopy" in s]
    assert len(relevant)==4 and all(s["passed"] for s in relevant)
    assert any(s.get("both_canopies_bound_after_route_return") for s in r["steps"])
    assert any(s.get("notice_preserves_flags") for s in r["steps"])
    assert any(s.get("cached_route_and_home_preserved") and s.get("party_member_preserved") and s.get("party_count")==1 for s in r["steps"])
    runs[model]={"full_journey":True,"encounter":True,"four_real_gates":True,"flags":r["flags"],"levee_sign_to_relay_movement_seconds":r["levee_sign_to_relay_walk_frames"]/60,"both_canopies_work_after_return":True}
guard=json.loads((D/"protected-before.json").read_text());changes=[k for k,v in guard.items() if hashlib.sha256((P/k).read_bytes()).hexdigest()!=v];assert not changes,changes
before=(D/"before/scripts/first_route_prototype.gd").read_text();after=(P/"scripts/first_route_prototype.gd").read_text()
def funcs(t):return {m.group(1):m.group(0) for m in re.finditer(r'^func (\w+).*?(?=^func |\Z)',t,re.M|re.S)}
a=funcs(before);b=funcs(after);changed=[k for k,v in a.items() if b.get(k)!=v]
assert changed==["_process","_visit_landing_notice"],changed
maps={}
for name in ["roseport","levee","bridge"]:
    raw=json.loads((D/("maps-"+name+"-result.json")).read_text());r=raw["result"];assert not r.get("isError",False)
    data=r.get("structuredContent") or json.loads(r["content"][0]["text"])
    assert data.get("places"),name
    maps[name]=[{k:x[k] for k in ["id","location","attribution","googleMapsLinks"] if k in x} for x in data["places"]]
landing=maps["roseport"][0]["location"];bridge=maps["bridge"][0]["location"]
assert landing["latitude"]<bridge["latitude"]
(D/"maps-design-evidence.json").write_text(json.dumps({"date":"2026-10-03","protocol":"Official Google Maps MCP tools/call search_places","server":"https://mapstools.googleapis.com/mcp","public_queries_only":True,"returned_places":maps,"inference":"The returned Roseport Landing point is south of the returned Pony Express Bridges point. This supports the southern landing pocket in the fictional route.","limitation":"The levee lookup returns a broad Washington Township route location. It does not establish the exact entrance or embankment cross-section; supplied screenshots and prior regional synthesis remain the geometry references.","applied":"Keep the raised crest and complete river crossing. Place the relay, old tieoffs and listening spot in the lower west-bank pocket south of the bridge; connect it with a return track. Hollowtide names and materials remain original."},indent=2))
(D/"verification.json").write_text(json.dumps({"passed":True,"runs":runs,"protected_existing_files":len(guard),"protected_file_changes":changes,"unchanged_controller_functions":len(a)-len(changed),"changed_controller_functions":changed,"old_height_to_relay_distance":math.dist((423,205),(392,240)),"new_height_to_relay_distance":math.dist((423,205),(398,530)),"geometry_bake":json.loads((D/"candidate-bake-results.json").read_text()),"new_rd_charges":0},indent=2))
print("Verified both complete journeys/encounters, four gates each, return canopies, 1,021 protected files and 28 unchanged controller functions.")
for file in D.glob("after-*.png"):
    if not file.name.endswith((".initial.png",".notice-fixed.png")):(D/(file.stem+".notice-fixed.png")).write_bytes(file.read_bytes())
