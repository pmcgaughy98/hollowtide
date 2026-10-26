extends RefCounted
## Same material finish as the bank, with a mask fitted to this close-up facade.
const BankFinish=preload("res://scripts/ui/waking_bank_finish.gd")
static func mask(img:Image)->Image:
	var result:=Image.create(384,216,false,Image.FORMAT_RGBA8)
	result.fill(Color.BLACK)
	for y in 216:
		for x in 384:
			var c:=img.get_pixel(x,y)
			var facade:=x>=60 and x<=323 and y<123
			var edges:=y>=112 and (x<125 or x>266)
			if (facade or edges) and not BankFinish.water(c) and c.get_luminance()<=0.68:
				result.set_pixel(x,y,Color.WHITE)
	return result
static func finished_image(img:Image)->Image:
	var material:=mask(img)
	var rim:=BankFinish.RIM.selout(img,material)
	var result:=img.duplicate() as Image
	for y in range(1,215):
		for x in range(1,383):
			if material.get_pixel(x,y).r<0.5:continue
			for d in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
				if BankFinish.water(img.get_pixelv(Vector2i(x,y)+d)):
					result.set_pixel(x,y,rim.get_pixel(x,y));break
	return result
static func apply(sprite:Sprite2D,img:Image)->void:
	BankFinish.apply_mask(sprite,_kept(img)[1])

## The finished facade and its mask, made once a session (Claude, 2026-10-26, pass 7 S5 / LF7-05): the walk up from
## town and the flood's arch each spent about 0.6 s finishing the same picture. Kept with the hash of the picture
## they came from; the finish math above is unchanged. finished_texture is shared, so nobody draws into it.
static var _kept_key:=0
static var _kept_pair:Array=[]
static func _kept(img:Image)->Array:
	var key:=hash(img.get_data())
	if _kept_pair.is_empty() or _kept_key!=key:
		_kept_pair=[ImageTexture.create_from_image(finished_image(img)),ImageTexture.create_from_image(mask(img))]
		_kept_key=key
	return _kept_pair
static func finished_texture(img:Image)->Texture2D:
	return _kept(img)[0]
