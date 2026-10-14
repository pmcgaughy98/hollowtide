extends RefCounted
## Non-destructive painter helper. Rect2i or an equally sized filled shape mask.
## The selected shape is the material, not its one-pixel rim. The helper finds the rim.
## Opaque masks use red (>0.5); transparent masks additionally gate with alpha.
## Null selects the image's opaque silhouette. Interior and unselected pixels stay exact.
const DIRS := [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]
static func _selected(img: Image, p: Vector2i, selection: Variant) -> bool:
	if p.x<0 or p.y<0 or p.x>=img.get_width() or p.y>=img.get_height(): return false
	if img.get_pixelv(p).a<0.5: return false
	if selection is Rect2i: return selection.has_point(p)
	if selection is Image:
		var mask: Color = selection.get_pixelv(p)
		return mask.a>0.5 and mask.r>0.5
	return true
static func selout(img: Image, mask_or_rect: Variant = null) -> Image:
	var result := img.duplicate() as Image
	if mask_or_rect != null and not (mask_or_rect is Rect2i or mask_or_rect is Image):
		push_error("Selout expects a Rect2i, Image mask or null")
		return result
	if mask_or_rect is Image and mask_or_rect.get_size()!=img.get_size():
		push_error("Selout mask must match the image dimensions")
		return result
	var bounds := Rect2i(Vector2i.ZERO,img.get_size())
	if mask_or_rect is Rect2i: bounds=bounds.intersection(mask_or_rect)
	for y in range(bounds.position.y,bounds.end.y):
		for x in range(bounds.position.x,bounds.end.x):
			var p := Vector2i(x,y)
			if not _selected(img,p,mask_or_rect): continue
			var outward := Vector2.ZERO
			var edge := false
			for d in DIRS:
				if not _selected(img,p+d,mask_or_rect):
					outward += Vector2(d)
					edge = true
			if not edge: continue
			var material := img.get_pixelv(p)
			for dy in range(-2,3):
				for dx in range(-2,3):
					var q := p+Vector2i(dx,dy)
					if _selected(img,q,mask_or_rect) and img.get_pixelv(q).get_luminance()>material.get_luminance(): material=img.get_pixelv(q)
			if material.get_luminance()<0.13: continue
			var light := maxf(0.0,outward.normalized().dot(Vector2(-1,-1).normalized()))
			var rim := Color(material.r,material.g,material.b)*lerpf(0.24,0.42,light)
			rim *= minf(1.0,0.23/maxf(rim.get_luminance(),0.001))
			rim.a = img.get_pixelv(p).a
			result.set_pixelv(p,rim)
	return result
