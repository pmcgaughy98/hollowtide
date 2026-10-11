extends SceneTree
const U="D:/dev/hollowtide-world-tiles-20261010/"
const Art=preload("res://scripts/town/world_tile_art.gd")
const New=preload("res://scripts/town/highbank_painter.gd")
const Old=preload("D:/dev/hollowtide-world-tiles-20261010/originals/scripts/town/highbank_painter.gd")
const Layout=preload("res://scripts/town/town_layout.gd")
const Town=preload("res://scripts/town/hub_town.gd")
var passed:=0
var total:=0
func check(ok:bool,msg:String)->void:
	total+=1;passed+=int(ok);print("PASS " if ok else "FAIL ",msg)
func _initialize()->void:run.call_deferred()
func apron(p:Vector2i)->bool:
	for place in Layout.PLACES:
		if place.id not in ["home","shop","storage","scrolls"]:continue
		var d:Vector2i=place.door*24
		var north:bool=place.id=="scrolls"
		var start:int=d.y-24 if north else d.y+24
		var end:int=d.y if north else 216
		if p.y<start or p.y>=end:continue
		var half:int=11+(d.y-p.y)/5 if north else 11+(p.y-start)/4
		if p.x>=d.x+12-half and p.x<d.x+12+half:return true
	return false
func clearing(p:Vector2i)->bool:
	for place in Layout.PLACES:
		if place.id=="board" and Rect2i(place.door*24,Vector2i(24,24)).has_point(p):return true
		if place.id=="plaza":
			var at:Vector2i=p-place.rect.position*24
			if at.y<9 or at.y>=127:continue
			var left:int=load("res://scripts/town/crossroads_painter.gd")._edge(at.y)
			var right:int=288-left-(7 if at.y>72 else 0)
			if at.x>=left and at.x<right:return true
	return false
func run()->void:
	var source_hashes:Dictionary={}
	for id in Art.SIZES:
		var image:=Art.image(id);check(image!=null and image.get_size()==Art.SIZES[id],id+" native bounds")
		var opaque:=true
		for y in image.get_height():
			for x in image.get_width():
				if image.get_pixel(x,y).a!=1.0:opaque=false
		check(opaque,id+" fully opaque material")
		var combined:=Image.create(1152,768,false,Image.FORMAT_RGBA8)
		for tx in [7,8]:Art.tile(combined,id,tx,0)
		var continuous:=true
		for y in 24:
			for x in range(168,216):
				if combined.get_pixel(x,y)!=Art.sample(image,x,y):continuous=false
		check(continuous,id+" world phase is continuous across adjacent 24px tiles and source wrap")
	check(Art.image("absent")==null,"unknown material retains fallback")
	var block:Image=Town.paint_blockout()
	var base:Image=load("res://scripts/town/highbank_ground_painter.gd").paint(block)
	var before:Image=Old.paint(base)
	var after:Image=New.paint(base)
	check(before.get_size()==after.get_size() and after.get_size()==Vector2i(1152,768),"world canvas and native scale exact")
	var saved:Dictionary=Art.cache.duplicate()
	for id in Art.SIZES:Art.cache[id]=null
	var fallback:Image=New.paint(base)
	check(fallback.get_data()==before.get_data(),"all missing materials restore the entire original painter byte exact")
	Art.cache=saved
	var protected:=PackedByteArray();protected.resize(48*32)
	for place in Layout.PLACES:
		if place.id not in New.DRAWN:continue
		var rect:Rect2i=place.rect.grow(1).intersection(Rect2i(0,0,48,32))
		for y in range(rect.position.y,rect.end.y):
			for x in range(rect.position.x,rect.end.x):protected[y*48+x]=1
	var changed:=0;var forbidden:=0;var alpha:=0
	for y in 768:
		for x in 1152:
			var a:=before.get_pixel(x,y);var b:=after.get_pixel(x,y)
			if a.a!=b.a:alpha+=1
			if a==b:continue
			changed+=1
			var tx:int=x/24;var ty:int=y/24;var band:=Layout.band_of(ty)
			if protected[ty*48+tx]==1 and not New._path(tx,ty) and not New._plain(base.get_pixel(x,y),band) and not apron(Vector2i(x,y)) and not clearing(Vector2i(x,y)):forbidden+=1
	check(changed>100000,"substantial terrain detail installed: "+str(changed)+" changed pixels")
	check(forbidden==0,"service/foundation/door/contact pixels preserved: "+str(forbidden)+" outside ground masks")
	check(alpha==0,"full world opacity preserved")
	for place in Layout.PLACES:
		if place.id in ["lookout","landing","dock","gate"]:
			var rect:=Rect2i(place.rect.position*24,place.rect.size*24)
			check(before.get_region(rect).get_data()==after.get_region(rect).get_data(),place.id+" finished platform/entrance floor exact")
	var river:=Rect2i(0,720,1152,48)
	check(before.get_region(river).get_data()==after.get_region(river).get_data(),"approved river and dock extension exact")
	print("WORLD MATERIALS ",passed,"/",total," PASS" if passed==total else " FAILED")
	quit(0 if passed==total else 1)
