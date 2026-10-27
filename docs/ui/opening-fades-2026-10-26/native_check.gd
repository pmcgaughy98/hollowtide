extends SceneTree
const W := "D:/dev/hollowtide-opening-fades-20261026"
const UI := preload("res://scripts/ui/ui_style.gd")
const Team := preload("res://scripts/town/team_state.gd")
var phase := "before"
var total := 0
var failed := 0
var facts: Array=[]
var metrics: Array=[]
func _initialize() -> void:_run.call_deferred()
func frames(n: int) -> void:
    for i in n:await process_frame
func check(label: String, good: bool) -> void:
    total+=1
    if not good:failed+=1
    facts.append({"check":label,"passed":good});print("FADE_CHECK ",label," -> ","ok" if good else "FAIL")
func tag() -> String:
    return current_scene.scene_file_path.get_file() if is_instance_valid(current_scene) else "none"
func overlay() -> float:
    var alpha:=0.0
    for child in root.get_children():
        if child is CanvasLayer and child.name.begins_with("UIFade"):
            var r=child.get_node_or_null("Rect")
            if r!=null:alpha=maxf(alpha,r.color.a)
    return alpha
func key(down: bool) -> void:
    var e:=InputEventKey.new();e.keycode=KEY_ENTER;e.physical_keycode=KEY_ENTER;e.pressed=down;Input.parse_input_event(e)
func one(reduced: bool, skip: bool) -> void:
    var name: String=("reduced" if reduced else "normal")+("-skip" if skip else "-natural")
    var folder:=W+"/"+phase+"/"+name;DirAccess.make_dir_recursive_absolute(folder)
    var cfg:=ConfigFile.new();cfg.set_value("menu","reduce_motion",reduced);cfg.save("user://menu_preferences.cfg");UI.reload_prefs()
    var before:=FileAccess.get_sha256(Team.save_path)
    var s: Node=load("res://scenes/storm_open.tscn").instantiate();s.reduce_motion=reduced;change_scene_to_node(s)
    while tag()!="storm_open.tscn":await process_frame
    var entries: Array=[];var storm_rows: Array=[];var bank_rows: Array=[]
    var saw_soul:=false;var soul_ready:=false;var started_flight:=false;var armed_ok:=not skip
    var capture_storm:=false;var capture_bank:=false;var storm_after:=0;var bank_after:=0
    var storm_cut: Dictionary={};var bank_cut: Dictionary={};var input_before:=-1.0;var input_checked:=false;var input_blocked:=true
    var peak_white:=0.0;var hand_ok:=false;var hidden_build:=true
    for f in 1800:
        if skip and f==3:key(true)
        if skip and f==4:key(false)
        if skip and f==6:
            armed_ok=tag()=="storm_open.tscn" and not current_scene.leaving
            key(true)
        if skip and f==7:key(false)
        await process_frame;await RenderingServer.frame_post_draw
        var scene:=tag();var active=current_scene
        var cover:=overlay();var white:=0.0;var flash:=0.0;var veil:=-1.0
        if scene=="storm_open.tscn":
            white=active.white;peak_white=maxf(peak_white,white)
            if white>0.55 or (reduced and white>0.20) or (skip and f>=5):capture_storm=true
        elif scene=="soul_prologue.tscn":
            if not saw_soul:
                saw_soul=true;storm_cut={"frame":f,"cover":cover}
                if phase=="after":
                    input_before=active.shown
                    var e:=InputEventKey.new();e.physical_keycode=KEY_E;e.keycode=KEY_E;e.pressed=true;Input.parse_input_event(e)
            if phase=="after" and not input_checked and f>int(storm_cut.get("frame",f)):
                input_blocked=active.shown<=input_before+(200.0 if reduced else 46.0)/30.0+0.01
                var e:=InputEventKey.new();e.physical_keycode=KEY_E;e.keycode=KEY_E;e.pressed=false;Input.parse_input_event(e);input_checked=true
            if not soul_ready and storm_after>=25:
                soul_ready=true
                if not skip:
                    active.stage="after";active.line=active.AFTER.size()-1;active.chosen=1;active.pick=1;active.shown=active._text().length()
            if soul_ready and not skip and not started_flight:
                UI.finish_line();active.advance()
                started_flight=active.stage=="fly"
            flash=active._flash
            if flash>0.0:capture_bank=true
        elif scene=="creature_prologue.tscn":
            veil=active.veil.color.a if is_instance_valid(active.veil) else -1.0
            if bank_cut.is_empty():bank_cut={"frame":f,"cover":cover,"veil":veil}
            hand_ok=active.hero==1 and active.partner==active._others()[0] and not active.partner_sprite.visible and active.chosen_by_soul and active.reduce_motion==reduced
            if bank_after<4 and veil<0.99:hidden_build=false
        var capture: bool=(capture_storm and storm_after<30) or capture_bank
        if capture:
            var im:=root.get_texture().get_image();var sum:=0.0;var n:=0
            for y in range(12,648,24):
                for x in range(12,1152,24):
                    var c:=im.get_pixel(x,y);sum+=c.r*0.2126+c.g*0.7152+c.b*0.0722;n+=1
            var row: Dictionary={"frame":f,"scene":scene,"luma":sum/n,"shared_black":cover,"white":white,"flash":flash,"veil":veil}
            entries.append(row)
            if capture_storm and storm_after<30:storm_rows.append(row)
            if capture_bank:bank_rows.append(row)
            im.save_png(folder+"/f%04d.png"%f)
        if saw_soul:storm_after+=1
        if scene=="creature_prologue.tscn":bank_after+=1
        if skip and soul_ready:break
        if scene=="creature_prologue.tscn" and bank_after>35 and active.line!=null and veil<=0.001:break
    var down_storm:=0.0;var down_bank:=0.0
    for list in [storm_rows,bank_rows]:
        for i in range(1,list.size()):
            var down: float=list[i-1]["luma"]-list[i]["luma"]
            if list==storm_rows:down_storm=maxf(down_storm,down)
            else:down_bank=maxf(down_bank,down)
    var result: Dictionary={"case":name,"storm_cut":storm_cut,"bank_cut":bank_cut,"max_storm_drop":down_storm,"max_bank_drop":down_bank,"peak_storm_white":peak_white,"samples":entries}
    metrics.append(result);print("FADE_METRIC ",name," drops ",down_storm," / ",down_bank," cuts ",storm_cut," / ",bank_cut)
    check(name+" reaches actual soul",saw_soul)
    check(name+" first Enter cannot skip",armed_ok)
    check(name+" saved journey bytes unchanged",FileAccess.get_sha256(Team.save_path)==before)
    if not skip:
        check(name+" bank keeps hero, setting and pending partner choice",hand_ok)
        check(name+" bank still reveals and starts dialogue",tag()=="creature_prologue.tscn" and current_scene.line!=null and current_scene.veil.color.a<=0.001)
    if phase=="after":
        check(name+" Storm swap covered by shared black",float(storm_cut.get("cover",0.0))>=0.99)
        check(name+" input blocked while soul begins under black",input_checked and input_blocked)
        check(name+" no abrupt falling luminance at Storm exit",down_storm<0.30)
        if not skip:
            check(name+" no abrupt falling luminance at soul exit",down_bank<0.30)
            check(name+" bank construction stays black",hidden_build and float(bank_cut.get("veil",0.0))>=0.99)
            check(name+" reduced final Storm white stays capped",peak_white<=0.4001 if reduced else peak_white>=0.99)
    if is_instance_valid(current_scene):current_scene.queue_free();current_scene=null
    await frames(6)
func _run() -> void:
    if OS.get_cmdline_user_args().has("after"):phase="after"
    root.size=Vector2i(1152,648);root.content_scale_size=root.size
    Team.save_path="user://opening-fades-private.save";Team.erase_save();Team.data={"party":[[0,0]],"levels":{0:{"lv":8}}};Team.save()
    await one(false,false);await one(true,false)
    if phase=="after":await one(false,true);await one(true,true)
    Team.erase_save()
    if is_instance_valid(UI._blip):UI._blip.free()
    var music:=root.get_node_or_null("HollowtideMusic")
    if music!=null:music.queue_free()
    await frames(6)
    var dialogue: Resource=load("res://dialogue/flood_bank.dialogue");dialogue.set("lines",{});dialogue=null
    var result: Dictionary={"phase":phase,"total":total,"passed":total-failed,"failed":failed,"checks":facts,"cases":metrics}
    var file:=FileAccess.open(W+"/"+phase+"-result.json",FileAccess.WRITE);file.store_string(JSON.stringify(result,"\t"));file.close()
    print("FADE RESULT ",JSON.stringify({"total":total,"passed":total-failed,"failed":failed}));quit(0 if failed==0 else 1)
