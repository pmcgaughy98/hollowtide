extends SceneTree
const W := "D:/dev/hollowtide-storm-lightning-20261026"
const UI := preload("res://scripts/ui/ui_style.gd")
const Team := preload("res://scripts/town/team_state.gd")
var phase := "before"
var total := 0
var failed := 0
var cases: Array = []
var rows: Array = []
var thunder := 0
func _initialize() -> void: _run.call_deferred()
func frames(n: int) -> void:
    for i in n:await process_frame
func check(label: String, good: bool) -> void:
    total+=1
    if not good:failed+=1
    print("LIGHTNING_CHECK ",label," -> ","ok" if good else "FAIL")
func sound(child: Node) -> void:
    if child is AudioStreamPlayer and child.stream.resource_path.ends_with("thunder.wav"):thunder+=1
func one(tag: String, passed: bool, saved: bool) -> void:
    var config:=ConfigFile.new();config.set_value("menu","reduce_motion",saved);config.save("user://menu_preferences.cfg");UI.reload_prefs()
    var before:=FileAccess.get_sha256(Team.save_path)
    var s: Node=load("res://scenes/storm_open.tscn").instantiate();s.reduce_motion=passed
    thunder=0;root.add_child(s);s.child_entered_tree.connect(sound)
    var previous:=0.0;var peak:=0.0;var shader_peak:=0.0;var pulses:=0;var groups: Array=[];var current: Dictionary={}
    var greys:=false;var landed:=false;var done_frame:=-1;var monotone:=true
    for f in 1200:
        await process_frame;await RenderingServer.frame_post_draw
        var value: float=s.flash
        var shader: float=s.display.material.get_shader_parameter("flash")
        rows.append({"case":tag,"frame":f,"flash":value,"shader_flash":shader,"frozen":s.frozen,"grey":s.grey})
        if value>previous+0.02:pulses+=1
        if value>0.001 and previous<=0.001:current={"start":f,"peak":value}
        if not current.is_empty():current["peak"]=maxf(current["peak"],value)
        if value<=0.001 and previous>0.001:
            current["end"]=f;current["seconds"]=float(f-current["start"])/30.0;groups.append(current);current={}
        peak=maxf(peak,value)
        if shader>shader_peak:
            shader_peak=shader;root.get_texture().get_image().save_png(W+"/"+phase+"/"+tag+"-peak.png")
        if previous>0.001 and value>previous+0.002:monotone=false
        greys=greys or (s.frozen and s.grey>0.99)
        landed=landed or (s.soul_glow>0.9 and s.soul_at.distance_to(s.WAKE_AT)<1.0)
        previous=value
        if s.has_meta("next"):done_frame=f;break
    var metrics: Dictionary={"case":tag,"passed_reduce":passed,"saved_reduce":saved,"effective_reduce":s.reduce_motion,"peak":peak,"shader_peak":shader_peak,"pulses":pulses,"strikes":groups,"thunder_count":thunder,"done_frame":done_frame}
    cases.append(metrics);print("LIGHTNING_METRIC ",JSON.stringify(metrics))
    check(tag+" three completed strikes",groups.size()==3)
    check(tag+" one thunder per strike on existing SFX path",thunder==3)
    check(tag+" time stops and greys",greys)
    check(tag+" soul still lands at waking spot",landed)
    check(tag+" automatic handoff remains soul prologue",done_frame>=0 and s.get_meta("next","")==s.NEXT)
    check(tag+" existing private save remains byte exact",FileAccess.get_sha256(Team.save_path)==before)
    if phase=="after":
        var reduced: bool=passed or saved
        check(tag+" respects title or shared preference",s.reduce_motion==reduced)
        if reduced:
            check(tag+" one pulse per strike",pulses==3)
            check(tag+" state and rendered shader peak at most 0.4",peak>0.35 and peak<=0.4001 and shader_peak>0.35 and shader_peak<=0.4001 and groups.all(func(g):return g["peak"]<=0.4001))
            check(tag+" each flash fades monotonically",monotone)
            check(tag+" each fade lasts about 0.35 seconds",groups.all(func(g):return g["seconds"]>=0.30 and g["seconds"]<=0.40))
            check(tag+" no accelerated strike intervals",groups.size()==3 and float(groups[1]["start"]-groups[0]["end"])/30.0>=1.85 and float(groups[2]["start"]-groups[1]["end"])/30.0>=1.15)
        else:
            check(tag+" normal flashes keep their two pulses",pulses==6)
            check(tag+" normal peak remains 0.85",is_equal_approx(peak,0.85))
    s.queue_free();await frames(4)
func _run() -> void:
    if OS.get_cmdline_user_args().has("after"):phase="after"
    DirAccess.make_dir_recursive_absolute(W+"/"+phase)
    root.size=Vector2i(1152,648);root.content_scale_size=root.size
    Team.save_path="user://lightning-private.save";Team.erase_save();Team.data={"party":[[0,0]],"levels":{0:{"lv":8}}};Team.save()
    if phase=="before":await one("forwarded",true,true)
    else:
        await one("normal",false,false)
        await one("forwarded",true,false)
        await one("saved",false,true)
    Team.erase_save()
    if is_instance_valid(UI._blip):UI._blip.free()
    var music:=root.get_node_or_null("HollowtideMusic")
    if music!=null:music.queue_free()
    await frames(4)
    var result: Dictionary={"phase":phase,"total":total,"passed":total-failed,"failed":failed,"cases":cases}
    var file:=FileAccess.open(W+"/"+phase+"-result.json",FileAccess.WRITE);file.store_string(JSON.stringify(result,"\t"));file.close()
    file=FileAccess.open(W+"/"+phase+"-frames.json",FileAccess.WRITE);file.store_string(JSON.stringify(rows));file.close()
    print("LIGHTNING RESULT ",JSON.stringify(result));quit(0 if failed==0 else 1)
