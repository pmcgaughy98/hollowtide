extends SceneTree
## Actual evolution scene, process-only art and preference caches, no save or asset writes.
const E := preload("res://scripts/ui/evolution_scene.gd")
const C := preload("res://scripts/ui/creature_idle.gd")
const U := preload("res://scripts/ui/ui_style.gd")
const M := preload("res://scripts/audio/music.gd")
const B := "res://docs/art/slot-candidates/riftfin-growth-2026-10-28/"
func _initialize() -> void:
 _run.call_deferred()
func _snap(name: String) -> void:
 await RenderingServer.frame_post_draw
 var err := root.get_texture().get_image().save_png(ProjectSettings.globalize_path(B+name+".png"))
 assert(err == OK)
func _run() -> void:
 # Avoid even preference migration writes; all settings are local to this preview process.
 U._prefs = ConfigFile.new()
 U._game_prefs = ConfigFile.new()
 U._prefs.set_value("menu","reduce_motion",false)
 var probe := E.new()
 var baseline := probe._pick("rimefin","riftfin")
 assert(String(baseline[0]).contains("/small/"))
 var baseline_old: Rect2i = baseline[2]
 var baseline_new: Rect2i = baseline[4]
 var report := {"baseline_family":baseline[0],"baseline_old_height":baseline_old.size.y,"baseline_new_height":baseline_new.size.y,"baseline_scale":3}
 print("BASELINE: ",baseline[0]," heights ",baseline_old.size.y," -> ",baseline_new.size.y," at 3x")
 root.add_child(probe)
 probe.family=baseline[0]
 probe.scale_k=3
 probe._text="Current fallback: small Riftfin still at 3x"
 probe._new=probe._sprite("riftfin",baseline[3],baseline[4])
 for i in 4:
  await process_frame
 await _snap("current-fallback")
 probe.queue_free()
 await process_frame
 var pic := Image.load_from_file(ProjectSettings.globalize_path(B+"prepared.png"))
 var candidate := ImageTexture.create_from_image(pic)
 C._cache["riftfin"]=[candidate]
 var scene := E.new()
 var picked := scene._pick("rimefin","riftfin")
 assert(picked[0]=="idle")
 assert((picked[4] as Rect2i).size.y >= (picked[2] as Rect2i).size.y)
 assert(picked[3].size()==1 and picked[3][0]==candidate)
 root.add_child(scene)
 scene.run("rimefin","riftfin","Rimefin","Riftfin",true)
 var seen := {}
 var intro=false
 var reveal=false
 var reveal_at := 0
 var start := Time.get_ticks_msec()
 while scene.stage!="done" and Time.get_ticks_msec()-start<16000:
  await process_frame
  seen[scene.stage]=true
  if scene.stage=="intro" and not intro and Time.get_ticks_msec()-start>500:
   await _snap("candidate-intro")
   intro=true
  if scene.stage=="reveal":
   if reveal_at==0:
    reveal_at=Time.get_ticks_msec()
   if not reveal and Time.get_ticks_msec()-reveal_at>850:
    await _snap("candidate-reveal")
    reveal=true
 assert(scene.stage=="done")
 for phase in ["intro","whiten","trade","reveal"]:
  assert(seen.has(phase),"Missing phase "+phase)
 assert(scene.family=="idle" and scene.scale_k==2)
 assert(scene._new.texture==candidate)
 var b1: Rect2i = picked[2]
 var b2: Rect2i = picked[4]
 report.merge({"candidate_family":scene.family,"candidate_scale":scene.scale_k,"old_height":b1.size.y,"new_height":b2.size.y,"on_screen_heights":[b1.size.y*2,b2.size.y*2],"phases":seen.keys(),"one_held_frame":true,"prepared_texture_verified":true,"pass":intro and reveal})
 var file := FileAccess.open(B+"runtime-check.json",FileAccess.WRITE)
 file.store_string(JSON.stringify(report," ")+"\n")
 file.close()
 print("CANDIDATE_PASS: idle family, 2x, ",b1.size.y*2," -> ",b2.size.y*2,"px, all growth phases, one held still verified")
 M.release(self)
 var earliest := Time.get_ticks_msec()+120
 var stop := Time.get_ticks_msec()+5000
 while Time.get_ticks_msec()<earliest or (M.working() and Time.get_ticks_msec()<stop):
  await process_frame
 M.finish_work()
 scene.queue_free()
 for i in 3:
  await process_frame
 C._cache.erase("riftfin")
 quit(0)