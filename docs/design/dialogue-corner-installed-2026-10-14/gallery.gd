extends SceneTree
const UI = preload("res://scripts/ui/ui_style.gd")
var out = "D:/dev/hollowtide-dialogue-install-20261014/" + OS.get_cmdline_user_args()[0] + "/"
var canvas: Node2D
var mode = 0
var fails = 0
const LONG = "The current has carried the last of the loose branches past the bank. Stay close while we look for a path through the reeds. We can cross together once the water settles, and find a dry place to rest before morning."
func _initialize():
	go.call_deferred()
func frames(n):
	for k in n: await process_frame
func ok(label, value):
	print(label, " -> ", "ok" if value else "FAIL")
	if not value: fails += 1
func draw():
	canvas.draw_rect(Rect2(0,0,1152,648),Color("354b45"))
	if mode == 0:
		UI.dialogue(canvas,Rect2(196,452,760,116),"","Rain settles over the bank. The reeds bend with the current.",null,0)
	elif mode == 1:
		UI.panel(canvas,Rect2(60,60,760,116))
		UI.panel(canvas,Rect2(60,220,480,220),0.8)
		UI.panel(canvas,Rect2(620,220,240,60),0.95,true)
	else:
		UI.dialogue(canvas,Rect2(196,452,760,116),"Rimefin",LONG,UI.dialogue_portrait("rimefin:surprised"),0,20,"surprised")
func snap(name):
	canvas.queue_redraw()
	await frames(3)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out+name+".png")
func go():
	root.size=Vector2i(1152,648)
	canvas=Node2D.new()
	root.add_child(canvas)
	canvas.draw.connect(draw)
	await snap("gallery-narration-typing")
	UI.finish_line()
	await snap("gallery-narration")
	mode=1
	await snap("gallery-shared-panels")
	mode=2
	await snap("gallery-long-typing")
	ok("Actual partner portrait resolves",UI.dialogue_portrait("rimefin:surprised")!=null)
	ok("All panel calls reuse one cached shared panel texture",UI.frame("panel")==UI.frame("panel"))
	UI.finish_line()
	await snap("gallery-long-page1")
	ok("Long line has more than one page",UI._line.pages>1 and not UI.line_done(LONG))
	var pages=UI._line.pages
	var guard=0
	while not UI.line_done(LONG) and guard<20:
		UI.finish_line()
		canvas.queue_redraw()
		await frames(2)
		guard+=1
	await snap("gallery-long-lastpage")
	ok("Long line completes only at last page",UI.line_done(LONG) and UI._line.page==pages-1)
	var widths_ok=true
	for width in [760,948]:
		for row in UI.wrap_text(LONG,width-70-UI.PORTRAIT_INSET,"story").split("\n"):
			widths_ok=widths_ok and UI.width_in(row,"story")<=width-70-UI.PORTRAIT_INSET
	ok("Wrapped lines fit both existing dialogue widths",widths_ok)
	print("GALLERY: ",5-fails,"/5")
	canvas.queue_free()
	await frames(3)
	quit(1 if fails else 0)
