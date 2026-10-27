extends SceneTree
const W := "D:/dev/hollowtide-soul-light-20261026"
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
    facts.append({"check":label,"passed":good});print("SOUL_LIGHT_CHECK ",label," -> ","ok" if good else "FAIL")
func redraw(s: Node) -> void:
    s._void.queue_redraw();s._ui.queue_redraw();await frames(3);await RenderingServer.frame_post_draw
func shot(tag: String) -> void:
    root.get_texture().get_image().save_png(W+"/"+phase+"/"+tag+".png")
func strength(c: Color) -> float:return (c.r+c.g+c.b)/3.0
func sample(im: Image, at: Vector2, x: int, y: int) -> Color:return im.get_pixel(int(at.x)+x,int(at.y)+y)
func corners(im: Image, flash:=false) -> bool:
    for p in [Vector2i(0,0),Vector2i(im.get_width()-1,0),Vector2i(0,im.get_height()-1),Vector2i(im.get_width()-1,im.get_height()-1)]:
        var c:=im.get_pixelv(p)
        if flash:
            if strength(c)<0.25 or strength(c)>0.65:return false
        elif strength(c)<0.015 or strength(c)>0.15:return false
    return true
func _run() -> void:
    if OS.get_cmdline_user_args().has("after"):phase="after"
    DirAccess.make_dir_recursive_absolute(W+"/"+phase)
    root.size=Vector2i(1152,648);root.content_scale_size=root.size
    Team.save_path="user://soul-light-private.save";Team.erase_save();Team.data={"party":[[0,0]],"levels":{0:{"lv":8}}};Team.save()
    var save_before:=FileAccess.get_sha256(Team.save_path)
    var original_aspect:=root.content_scale_aspect
    var s: Node=load("res://scenes/soul_prologue.tscn").instantiate();root.add_child(s);await frames(5)
    s.set_process(false);s._t=0.0;s._motes=[];s._jitter=0.0;s._question=0.0;s._river=0.0;s._flash=0.0;s._speak=0.0
    await redraw(s)
    var vp: SubViewport=s._void.get_parent();var base:=vp.get_texture().get_image()
    check("native backdrop starts at authored384x216",vp.size==Vector2i(384,216))
    check("base authored UI position unchanged",s._ui.position==Vector2.ZERO)
    shot("silent")
    s._speak=1.0;await redraw(s);var lit:=vp.get_texture().get_image();var offset: Vector2=s._void.position
    var bar: float=strength(sample(lit,offset,20,1))-strength(sample(base,offset,20,1))
    var middle: float=strength(sample(lit,offset,100,100))-strength(sample(base,offset,100,100))
    var end: float=strength(sample(lit,offset,100,149))-strength(sample(base,offset,100,149))
    metrics.append({"base_top_strip_added":bar,"shaft_middle_added":middle,"shaft_end_added":end})
    print("SOUL_LIGHT_METRIC ",JSON.stringify(metrics[-1]));shot("speaking")
    if phase=="after":
        check("no full-width speaking strip",absf(bar)<0.004)
        check("shaft still visible midway",middle>0.004)
        check("shaft alpha fades to zero at lower edge",end<0.004 and end<middle/3.0)
        check("base screen corners contain the indigo backdrop",corners(root.get_texture().get_image()))
    for item in [["wide",Vector2i(1536,648)],["tall",Vector2i(960,720)]]:
        root.size=item[1];await frames(6);await redraw(s)
        var visible:=root.get_visible_rect().size;var im:=root.get_texture().get_image()
        metrics.append({"case":item[0],"window":[root.size.x,root.size.y],"visible":[visible.x,visible.y],"native":[vp.size.x,vp.size.y],"void_offset":[s._void.position.x,s._void.position.y],"ui_offset":[s._ui.position.x,s._ui.position.y]})
        shot(item[0])
        if phase=="after":
            check(item[0]+" native backdrop covers expanded viewport",vp.size==Vector2i(ceili(visible.x/3.0),ceili(visible.y/3.0)))
            check(item[0]+" UI and world share whole-pixel centre",s._ui.position==s._void.position*3.0 and s._void.position==s._void.position.round() and Rect2(Vector2.ZERO,visible).encloses(s._ui.get_global_rect()))
            check(item[0]+" no clear or letterbox band at corners",corners(im))
            s._flash=0.4;await redraw(s);check(item[0]+" flash covers the expanded backdrop too",corners(root.get_texture().get_image(),true));s._flash=0.0
    if phase=="after":
        root.size=Vector2i(1536,648);await frames(6);s.stage="choose";s.line=s.LINES.size()-1;s.pick=0;s.shown=s._text().length();await redraw(s)
        var point: Vector2=s._ui.position+s._card_rect(2).get_center()
        for down in [true,false]:
            var e:=InputEventMouseButton.new();e.button_index=MOUSE_BUTTON_LEFT;e.position=point;e.global_position=point;e.pressed=down;Input.parse_input_event(e);await frames(2)
        check("centred wide UI keeps mouse card selection",s.pick==2 and s.chosen==-1)
        shot("wide-choice")
        root.size=Vector2i(1152,648);await frames(6);s.stage="talk";s.line=0;s._motes=[];s.set_process(true);await frames(45);await RenderingServer.frame_post_draw;shot("live-story")
    check("scene work leaves saved journey bytes exact",FileAccess.get_sha256(Team.save_path)==save_before)
    s.queue_free();await frames(5)
    if phase=="after":check("scene restores previous stretch policy",root.content_scale_aspect==original_aspect)
    if phase=="after":
        root.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_KEEP
        var again: Node=load("res://scenes/soul_prologue.tscn").instantiate();root.add_child(again);await frames(12)
        check("a letterboxed caller expands during soul scene",root.content_scale_aspect==Window.CONTENT_SCALE_ASPECT_EXPAND)
        again.queue_free();await frames(4)
        check("leaving restores the caller's letterbox policy",root.content_scale_aspect==Window.CONTENT_SCALE_ASPECT_KEEP)
        root.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_EXPAND
        var queued: Node=load("res://scenes/soul_prologue.tscn").instantiate();root.add_child(queued);await frames(12)
        root.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_KEEP
        queued.queue_free();await frames(4)
        check("queued exit preserves a destination's new stretch policy",root.content_scale_aspect==Window.CONTENT_SCALE_ASPECT_KEEP)
    Team.erase_save()
    if is_instance_valid(UI._blip):UI._blip.free()
    var music:=root.get_node_or_null("HollowtideMusic")
    if music!=null:music.queue_free()
    await frames(5)
    var result: Dictionary={"phase":phase,"total":total,"passed":total-failed,"failed":failed,"checks":facts,"metrics":metrics}
    var f:=FileAccess.open(W+"/"+phase+"-result.json",FileAccess.WRITE);f.store_string(JSON.stringify(result,"\t"));f.close()
    print("SOUL LIGHT RESULT ",JSON.stringify({"total":total,"passed":total-failed,"failed":failed}));quit(0 if failed==0 else 1)
