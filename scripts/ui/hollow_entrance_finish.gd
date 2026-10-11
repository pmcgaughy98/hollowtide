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
	var material:=ShaderMaterial.new()
	material.shader=BankFinish.SHADER
	material.set_shader_parameter("detail_mask",ImageTexture.create_from_image(mask(img)))
	material.set_shader_parameter("detail_ink",0.55)
	sprite.material=material
