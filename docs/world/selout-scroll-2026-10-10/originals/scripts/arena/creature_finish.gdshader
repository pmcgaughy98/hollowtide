shader_type canvas_item;
render_mode unshaded;
// Hollowtide Sprite Forge finish at the arena's native pixel grid.
// Rendering only: original pixels, animation timing and foot anchors stay intact.
uniform vec4 outline : source_color = vec4(0.045, 0.055, 0.065, 1.0);
uniform float cluster_threshold = 0.12;
varying vec4 tint;

void vertex() {
	tint = COLOR;
	// One texel of room for pale edge repairs, including art close to its canvas edge.
	VERTEX += (UV * 2.0 - 1.0);
	UV = (UV * (1.0 / TEXTURE_PIXEL_SIZE + 2.0) - 1.0) * TEXTURE_PIXEL_SIZE;
}

vec4 sample_art(sampler2D tex, vec2 uv) {
	vec4 c = texture(tex, uv);
	return c * step(0.0, uv.x) * step(0.0, uv.y) * (1.0-step(1.0, uv.x)) * (1.0-step(1.0, uv.y));
}

float luma(vec3 c) { return dot(c, vec3(0.2126, 0.7152, 0.0722)); }

void fragment() {
	vec4 c = sample_art(TEXTURE, UV);
	vec4 n = sample_art(TEXTURE, UV + vec2(0.0, -TEXTURE_PIXEL_SIZE.y));
	vec4 s = sample_art(TEXTURE, UV + vec2(0.0, TEXTURE_PIXEL_SIZE.y));
	vec4 e = sample_art(TEXTURE, UV + vec2(TEXTURE_PIXEL_SIZE.x, 0.0));
	vec4 w = sample_art(TEXTURE, UV + vec2(-TEXTURE_PIXEL_SIZE.x, 0.0));
	float edge = min(min(n.a, s.a), min(e.a, w.a));
	if (c.a < 0.5) {
		// Existing dark contours need no extra thickness. Add a texel only where
		// the source silhouette ends in a light/material colour.
		float repair = max(max(n.a * step(0.23, luma(n.rgb)), s.a * step(0.23, luma(s.rgb))), max(e.a * step(0.23, luma(e.rgb)), w.a * step(0.23, luma(w.rgb))));
		c = vec4(outline.rgb, step(0.5, repair));
	} else if (edge < 0.5 && luma(c.rgb) < 0.23) {
		c.rgb = min(c.rgb, outline.rgb);
	} else if (edge > 0.5 && luma(c.rgb) > 0.16) {
		// Remove only weak isolated shade specks surrounded by a repeated colour.
		// Never average colours, blur edges, erase high-contrast eyes, or flatten glow.
		vec4 around[8] = vec4[8](n,s,e,w,
			sample_art(TEXTURE, UV + TEXTURE_PIXEL_SIZE),
			sample_art(TEXTURE, UV - TEXTURE_PIXEL_SIZE),
			sample_art(TEXTURE, UV + TEXTURE_PIXEL_SIZE * vec2(1.0,-1.0)),
			sample_art(TEXTURE, UV + TEXTURE_PIXEL_SIZE * vec2(-1.0,1.0)));
		float strongest = 4.0;
		vec3 chosen = c.rgb;
		for (int i=0; i<8; i++) {
			float count = 0.0;
			for (int j=0; j<8; j++) {
				count += around[j].a * (1.0-step(0.015, distance(around[i].rgb,around[j].rgb)));
			}
			float dist = distance(c.rgb,around[i].rgb);
			if (around[i].a > 0.5 && count > strongest && dist < cluster_threshold) {
				strongest = count;
				chosen = around[i].rgb;
			}
		}
		c.rgb = chosen;
	}
	COLOR = c * tint;
}
