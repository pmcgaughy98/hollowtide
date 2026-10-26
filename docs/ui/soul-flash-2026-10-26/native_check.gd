extends SceneTree
const W := "D:/dev/hollowtide-soul-flash-20261026"
const UI := preload("res://scripts/ui/ui_style.gd")
const Team := preload("res://scripts/town/team_state.gd")
var phase := "before"
var total := 0
var failed := 0
var cases: Array = []
var rows: Array = []
func _initialize() -> void:_run.call_deferred()
func frames(n: int) -> void:
    for i in n:await process_frame
func check(label: String, good: bool) -> void:
    total+=1
    if not good:failed+=1
    print("SOUL_FLASH_CHECK ",label," -> ","ok" if good else "FAIL")
func one(tag: String, forwarded: bool, saved: bool, hero: int) -> void:
    var config:=ConfigFile.new();config.set_value("menu","reduce_motion",saved);config.save("user://menu_preferences.cfg");UI.reload_prefs()
    var before:=FileAccess.get_sha256(Team.save_path)
    var s: Node=load("res://scenes/soul_prologue.tscn").instantiate();s.reduce_motion=forwarded
    root.add_child(s)
    # Start on the existing last after-choice line; advance through its real shared-dialogue gate.
    s.stage="after";s.line=s.AFTER.size()-1;s.chosen=hero;s.pick=hero;s.shown=s._text().length()
    for i in 12:
        await frames(2);UI.finish_line();s.advance()
        if s.stage=="fly":break
    check(tag+" real advance enters flight",s.stage=="fly")
    var peak:=0.0;var monotone:=true;var previous:=0.0;var started:=false;var first:=-1;var zero:=-1;var done:=-1;var flash_rows:=0
    var corner:=Color.BLACK;var at_peak:=Vector2.ZERO;var scale_peak:=0.0;var image_peak_frame:=-1
    for f in 120:
        await process_frame;await RenderingServer.frame_post_draw
        var value: float=s._flash
        rows.append({"case":tag,"hero":hero,"frame":f,"flash":value,"stage":s.stage,"soul":[s._soul.x,s._soul.y],"scale":s._soul_scale})
        if value>0.0:
            if not started:first=f;started=true
            flash_rows+=1
        elif started and zero<0:zero=f
        if started and previous>0.0 and value>previous+0.001:monotone=false
        if value>peak:
            peak=value;at_peak=s._soul;scale_peak=s._soul_scale
        # The async flight can set _flash after this frame's void draw. Judge the rendered pixels.
        if started and flash_rows<=3:
            var im:=root.get_texture().get_image();var sample:=im.get_pixel(18,48)
            if sample.r+sample.g+sample.b>corner.r+corner.g+corner.b:
                corner=sample;image_peak_frame=f;im.save_png(W+"/"+phase+"/"+tag+"-peak.png")
        previous=value
        if s.has_meta("handoff"):done=f;break
    var next: Node=s.get_meta("handoff",null)
    var reduced: bool=forwarded or saved
    var target:=Vector2(64+hero*128,100)
    var metrics: Dictionary={"case":tag,"hero":hero,"forwarded":forwarded,"saved":saved,"effective_reduce":s.reduce_motion,"peak":peak,"corner_rgb":[corner.r,corner.g,corner.b],"image_peak_frame":image_peak_frame,"first_flash":first,"first_zero":zero,"handoff_frame":done,"nonzero_samples":flash_rows}
    cases.append(metrics);print("SOUL_FLASH_METRIC ",JSON.stringify(metrics))
    check(tag+" flight reaches chosen creature before flash",at_peak.distance_to(target)<0.01 and absf(scale_peak-0.2)<0.001)
    check(tag+" flash decays monotonically",monotone and started)
    check(tag+" existing handoff delay retained",first>=0 and done-first>=19 and done-first<=23)
    check(tag+" chosen hero and partner survive handoff",next!=null and next.hero==hero and next.partner==(hero+1)%3 and next.chosen_by_soul)
    check(tag+" private saved team bytes unchanged",FileAccess.get_sha256(Team.save_path)==before)
    if phase=="after":
        check(tag+" setting reaches soul and next scene",s.reduce_motion==reduced and next!=null and next.reduce_motion==reduced)
        if reduced:
            check(tag+" reduced starting flash capped at 0.4",peak>0.33 and peak<=0.4001)
            check(tag+" native flash stays below full white",maxf(corner.r,maxf(corner.g,corner.b))<0.6 and minf(corner.r,minf(corner.g,corner.b))>0.25)
            check(tag+" reduced flash clears before existing handoff",zero>first and zero<done)
        else:
            check(tag+" normal starting flash remains 1.6",peak>=1.55 and peak<=1.6001)
            check(tag+" normal full-white native peak retained",minf(corner.r,minf(corner.g,corner.b))>0.98)
    if next!=null:next.free()
    s.queue_free();await frames(4)
func _run() -> void:
    if OS.get_cmdline_user_args().has("after"):phase="after"
    DirAccess.make_dir_recursive_absolute(W+"/"+phase)
    root.size=Vector2i(1152,648);root.content_scale_size=root.size
    Team.save_path="user://soul-flash-private.save";Team.erase_save();Team.data={"party":[[0,0]],"levels":{0:{"lv":8}}};Team.save()
    if phase=="before":await one("forwarded-1",true,false,1)
    else:
        for hero in 3:await one("normal-%d"%hero,false,false,hero)
        for hero in 3:await one("forwarded-%d"%hero,true,false,hero)
        for hero in 3:await one("saved-%d"%hero,false,true,hero)
    Team.erase_save()
    if is_instance_valid(UI._blip):UI._blip.free()
    var music:=root.get_node_or_null("HollowtideMusic")
    if music!=null:music.queue_free()
    await frames(4)
    var result: Dictionary={"phase":phase,"total":total,"passed":total-failed,"failed":failed,"cases":cases}
    var file:=FileAccess.open(W+"/"+phase+"-result.json",FileAccess.WRITE);file.store_string(JSON.stringify(result,"\t"));file.close()
    file=FileAccess.open(W+"/"+phase+"-frames.json",FileAccess.WRITE);file.store_string(JSON.stringify(rows));file.close()
    print("SOUL FLASH RESULT ",JSON.stringify(result));quit(0 if failed==0 else 1)
