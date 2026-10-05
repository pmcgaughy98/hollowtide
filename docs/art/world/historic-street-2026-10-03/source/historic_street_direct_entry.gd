extends SceneTree
const OUT:="C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/historic-street-review/direct-entry/"
var results:Array=[]
var failed:=false
func _initialize() -> void:call_deferred("_run")
func frames(n:int) -> void:
    for i in n:await process_frame
func _run() -> void:
    for id in ["historic_street","riverfront","hometown"]:
        var scene:String="city_riverfront" if id=="riverfront" else id
        change_scene_to_file("res://scenes/"+scene+".tscn")
        await frames(75)
        var journey:Node2D=current_scene
        var okay:bool=journey!=null and journey.get_script().resource_path=="res://scripts/world_journey.gd" and journey.active_id==id and not journey.transitioning
        if okay:
            okay=journey.active_area.has_node("AreaEntrances") and journey.route.get("player")==journey.active_area.get_node("Player")
            var loaded:int=journey.get_children().filter(func(n:Node)->bool:return n is Node2D).size()
            okay=okay and loaded==1
        failed=failed or not okay
        results.append({"direct_scene":scene,"connected_area":journey.active_id,"one_live_area_and_original_controller":okay})
        await RenderingServer.frame_post_draw
        root.get_texture().get_image().save_png(OUT+id+"-direct.png")
        journey.queue_free();current_scene=null
        await frames(10)
    var f:=FileAccess.open(OUT+"checks.json",FileAccess.WRITE)
    f.store_string(JSON.stringify({"checks":results,"passed":not failed},"\t"));f.close()
    print("HISTORIC_DIRECT_ENTRY ",not failed);quit(1 if failed else 0)
