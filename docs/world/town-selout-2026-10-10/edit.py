from pathlib import Path
W=Path(__file__).parent; C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def put(r,s):
 q=W/'candidate'/r;q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(s.encode('utf-8') if isinstance(s,str) else s)
 p=C/r;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(q.read_bytes())
for name in ['building_exteriors','growth_shrine_painter','training_yard_painter','job_board_painter','hollow_mouth_painter']:
 r='scripts/town/'+name+'.gd'
 s=(W/'originals'/r).read_bytes()
 assert s.count(b'res://scripts/arena/creature_finish.gd')==1
 put(r,s.replace(b'res://scripts/arena/creature_finish.gd',b'res://scripts/town/exterior_finish.gd'))
r='scripts/arena/sel_out.gdshaderinc'
s=(W/'originals'/r).read_text(encoding='utf-8')
anchor='\t#ifdef SEL_OUT_MASKED_MAP\n\t// Map floors'
assert anchor in s
added=s.replace(anchor,'\t#ifdef SEL_OUT_SELECTIVE\n\t// Opt-in outer rim only; the original internal detail finish above stays exact.\n\tc.rgb = selective_rim(TEXTURE, UV, TEXTURE_PIXEL_SIZE, c);\n\t#endif\n'+anchor)
if b'\r\n' in (W/'originals'/r).read_bytes():added=added.replace('\n','\r\n')
put(r,added)
put('scripts/art/selout_rim.gdshaderinc', '''// Optional silhouette colours; no alpha, width, UV or internal-detail changes.
float rim_luma(vec3 c) { return dot(c, vec3(0.2126, 0.7152, 0.0722)); }
vec4 rim_sample(sampler2D tex, vec2 uv) {
	return texture(tex, uv) * step(0.0, uv.x) * step(0.0, uv.y) * (1.0-step(1.0, uv.x)) * (1.0-step(1.0, uv.y));
}
vec3 selective_rim(sampler2D tex, vec2 uv, vec2 texel, vec4 finished) {
	vec4 raw = rim_sample(tex, uv);
	vec4 n = rim_sample(tex, uv-vec2(0.0,texel.y));
	vec4 s = rim_sample(tex, uv+vec2(0.0,texel.y));
	vec4 w = rim_sample(tex, uv-vec2(texel.x,0.0));
	vec4 e = rim_sample(tex, uv+vec2(texel.x,0.0));
	float edge = min(min(n.a,s.a),min(w.a,e.a));
	if (finished.a<0.5 || (raw.a>0.5 && edge>0.5) || rim_luma(finished.rgb)>0.24) return finished.rgb;
	// Choose a real neighbouring swatch rather than averaging or adding grain.
	vec3 material = raw.rgb;
	float brightest = raw.a>0.5 ? rim_luma(material) : -1.0;
	for (int y=-2; y<=2; y++) {
		for (int x=-2; x<=2; x++) {
			vec4 candidate = rim_sample(tex,uv+vec2(float(x),float(y))*texel);
			float lum = rim_luma(candidate.rgb);
			if (candidate.a>0.5 && lum>brightest) { material=candidate.rgb; brightest=lum; }
		}
	}
	if (brightest<0.13) return finished.rgb;
	vec2 outward = raw.a>0.5 ? vec2(w.a-e.a,n.a-s.a) : vec2(e.a-w.a,s.a-n.a);
	float light = length(outward)>0.0 ? max(0.0,dot(normalize(outward),normalize(vec2(-1.0,-1.0)))) : 0.0;
	vec3 rim = material * mix(0.24,0.42,light);
	return rim * min(1.0,0.23/max(rim_luma(rim),0.001));
}
''')
put('scripts/town/exterior_finish.gdshader', '''shader_type canvas_item;
render_mode unshaded;
#define SEL_OUT_DETAIL_DEFAULT 0.0
#define SEL_OUT_SELECTIVE
#include "res://scripts/art/selout_rim.gdshaderinc"
#include "res://scripts/arena/sel_out.gdshaderinc"
''')
put('scripts/town/exterior_finish.gd', '''extends RefCounted
## Purposeful exteriors: palette-coloured outer rim, original black internal detail.
## Doors without the detail flag keep the exact existing shared creature finish.
const Finish := preload("res://scripts/arena/creature_finish.gd")
const SHADER := preload("res://scripts/town/exterior_finish.gdshader")
static func apply(sprite: Sprite2D, details: bool = false) -> void:
	Finish.apply(sprite, details)
	if details: sprite.material.shader = SHADER
''')
put('scripts/art/selout.gd', '''extends RefCounted
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
''')
print('Built optional town rim, shared painter helper and five isolated presentation integrations.')
