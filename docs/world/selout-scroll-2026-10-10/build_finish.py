from pathlib import Path
W=Path(__file__).parent
orig=W/'originals/scripts/arena/creature_finish.gdshader'
s=orig.read_text();s=s.replace('shader_type canvas_item;\nrender_mode unshaded;\n','')
s=s.replace('uniform float cluster_threshold = 0.12;','uniform float cluster_threshold = 0.12;\n// Detail contour mode belongs to shared sel-out. Approved creature appearance stays the default.\nuniform float detail_ink = SEL_OUT_DETAIL_DEFAULT;')
ink='''
	// Internal selective outlines: existing dark joints plus narrow pale carved seams.
	// Opposing lighter neighbours distinguish a seam from a broad shaded material face.
	if (detail_ink > 0.0 && c.a > 0.5) {
		float lum = luma(c.rgb);
		float brightest = max(max(luma(n.rgb), luma(s.rgb)), max(luma(e.rgb), luma(w.rgb)));
		float boundary = smoothstep(0.12, 0.23, brightest-lum) * (1.0-smoothstep(0.36, 0.48, lum));
		float dark_joint = 1.0-smoothstep(0.13, 0.25, lum);
		float across = max(min(luma(n.rgb)*n.a, luma(s.rgb)*s.a), min(luma(e.rgb)*e.a, luma(w.rgb)*w.a));
		vec4 ne = sample_art(TEXTURE, UV + TEXTURE_PIXEL_SIZE * vec2(1.0,-1.0));
		vec4 sw = sample_art(TEXTURE, UV + TEXTURE_PIXEL_SIZE * vec2(-1.0,1.0));
		vec4 nw = sample_art(TEXTURE, UV - TEXTURE_PIXEL_SIZE);
		vec4 se = sample_art(TEXTURE, UV + TEXTURE_PIXEL_SIZE);
		across = max(across, max(min(luma(ne.rgb)*ne.a, luma(sw.rgb)*sw.a), min(luma(nw.rgb)*nw.a, luma(se.rgb)*se.a)));
		float carved_seam = smoothstep(0.055, 0.13, across-lum) * (1.0-smoothstep(0.72, 0.86, lum));
		c.rgb = mix(c.rgb, outline.rgb, detail_ink * max(max(boundary, dark_joint), carved_seam));
	}
'''
s=s.replace('\tCOLOR = c * tint;',ink+'\tCOLOR = c * tint;')
d=W/'candidate/scripts/arena';d.mkdir(parents=True,exist_ok=True)
(d/'sel_out.gdshaderinc').write_text(s)
(d/'creature_finish.gdshader').write_text('shader_type canvas_item;\nrender_mode unshaded;\n#define SEL_OUT_DETAIL_DEFAULT 0.0\n#include "res://scripts/arena/sel_out.gdshaderinc"\n')
(W/'candidate/scripts/town/building_detail_finish.gdshader').write_text('shader_type canvas_item;\nrender_mode unshaded;\n// Compatibility entry point: same shared sel-out, purposeful detail preset.\n#define SEL_OUT_DETAIL_DEFAULT 1.0\n#include "res://scripts/arena/sel_out.gdshaderinc"\n')
s=(W/'originals/scripts/arena/creature_finish.gd').read_text()
s=s.replace('static func apply(sprite: Sprite2D) -> void:', 'static func apply(sprite: Sprite2D, details: bool = false) -> void:')
s=s.replace('\tfinish.shader = SHADER','\tfinish.shader = SHADER\n\tfinish.set_shader_parameter("detail_ink", 1.0 if details else 0.0)')
(d/'creature_finish.gd').write_text(s)
print('Shared sel-out core with optional detail mode; legacy entry points retained.')
