// Hollowtide Sprite Forge finish at the arena's native pixel grid.
// Rendering only: original pixels, animation timing and foot anchors stay intact.
uniform vec4 outline : source_color = vec4(0.045, 0.055, 0.065, 1.0);
uniform float cluster_threshold = 0.12;
// Detail contour mode belongs to shared sel-out. Approved creature appearance stays the default.
uniform float detail_ink = SEL_OUT_DETAIL_DEFAULT;
// Skimlet-only pale pinpoints on thin leg edges; its eyes/body highlights stay intact.
uniform bool skimlet_leg_fix = false;
varying vec4 tint;
#include "res://scripts/arena/sparkwick_palette.gdshaderinc"

void vertex() {
	tint = COLOR;
	#ifndef SEL_OUT_MASKED_MAP
	// One texel of room for pale edge repairs, including art close to its canvas edge.
	VERTEX += (UV * 2.0 - 1.0);
	UV = (UV * (1.0 / TEXTURE_PIXEL_SIZE + 2.0) - 1.0) * TEXTURE_PIXEL_SIZE;
	#endif
}

// The art at uv, clear outside the texture. A macro that reads TEXTURE itself, not a function (Claude, 2026-10-24,
// pass 5 A5, LO5-25): handing TEXTURE, a built-in sampler, to a function printed the engine's 'custom_samplers'
// error every time one of these shaders loaded. The same sum as the old function's body.
#define sample_art(uv) (sparkwick_colour(texture(TEXTURE, (uv))) * step(0.0, (uv).x) * step(0.0, (uv).y) * (1.0-step(1.0, (uv).x)) * (1.0-step(1.0, (uv).y)))

float luma(vec3 c) { return dot(c, vec3(0.2126, 0.7152, 0.0722)); }

void fragment() {
	vec4 c = sample_art(UV);
	vec4 n = sample_art(UV + vec2(0.0, -TEXTURE_PIXEL_SIZE.y));
	vec4 s = sample_art(UV + vec2(0.0, TEXTURE_PIXEL_SIZE.y));
	vec4 e = sample_art(UV + vec2(TEXTURE_PIXEL_SIZE.x, 0.0));
	vec4 w = sample_art(UV + vec2(-TEXTURE_PIXEL_SIZE.x, 0.0));
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
			sample_art(UV + TEXTURE_PIXEL_SIZE),
			sample_art(UV - TEXTURE_PIXEL_SIZE),
			sample_art(UV + TEXTURE_PIXEL_SIZE * vec2(1.0,-1.0)),
			sample_art(UV + TEXTURE_PIXEL_SIZE * vec2(-1.0,1.0)));
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

	if (skimlet_leg_fix && c.a > 0.5) {
		vec3 rgb = floor(c.rgb * 255.0 + 0.5);
		bool pale_dot = all(equal(rgb, vec3(255.0))) || all(equal(rgb, vec3(225.0, 241.0, 247.0)));
		if (pale_dot) {
			float support = n.a+s.a+e.a+w.a;
			support += sample_art(UV+TEXTURE_PIXEL_SIZE).a + sample_art(UV-TEXTURE_PIXEL_SIZE).a;
			support += sample_art(UV+TEXTURE_PIXEL_SIZE*vec2(1.0,-1.0)).a + sample_art(UV+TEXTURE_PIXEL_SIZE*vec2(-1.0,1.0)).a;
			if (support < 6.5) c.rgb = vec3(72.0, 54.0, 37.0) / 255.0;
		}
	}

	// Internal selective outlines: existing dark joints plus narrow pale carved seams.
	// Opposing lighter neighbours distinguish a seam from a broad shaded material face.
	if (detail_ink > 0.0 && c.a > 0.5) {
		float lum = luma(c.rgb);
		float brightest = max(max(luma(n.rgb), luma(s.rgb)), max(luma(e.rgb), luma(w.rgb)));
		float boundary = smoothstep(0.12, 0.23, brightest-lum) * (1.0-smoothstep(0.36, 0.48, lum));
		float dark_joint = 1.0-smoothstep(0.13, 0.25, lum);
		float across = max(min(luma(n.rgb)*n.a, luma(s.rgb)*s.a), min(luma(e.rgb)*e.a, luma(w.rgb)*w.a));
		vec4 ne = sample_art(UV + TEXTURE_PIXEL_SIZE * vec2(1.0,-1.0));
		vec4 sw = sample_art(UV + TEXTURE_PIXEL_SIZE * vec2(-1.0,1.0));
		vec4 nw = sample_art(UV - TEXTURE_PIXEL_SIZE);
		vec4 se = sample_art(UV + TEXTURE_PIXEL_SIZE);
		across = max(across, max(min(luma(ne.rgb)*ne.a, luma(sw.rgb)*sw.a), min(luma(nw.rgb)*nw.a, luma(se.rgb)*se.a)));
		float carved_seam = smoothstep(0.055, 0.13, across-lum) * (1.0-smoothstep(0.72, 0.86, lum));
		c.rgb = mix(c.rgb, outline.rgb, detail_ink * max(max(boundary, dark_joint), carved_seam));
	}
	#ifdef SEL_OUT_SELECTIVE
	// Opt-in outer rim only; the original internal detail finish above stays exact.
	#ifdef SELOUT_RIM_MACRO
	// The rim as a macro that reads TEXTURE itself, once selout_rim.gdshaderinc defines it (Claude, 2026-10-24,
	// pass 5 A5); until then the old function, which prints the engine's 'custom_samplers' error.
	SELECTIVE_RIM(c.rgb, UV, TEXTURE_PIXEL_SIZE, c);
	#else
	c.rgb = selective_rim(TEXTURE, UV, TEXTURE_PIXEL_SIZE, c);
	#endif
	#endif
	#ifdef SEL_OUT_MASKED_MAP
	// Map floors retain the original painter exactly; ink only the supplied geometry mask.
	c = mix(sample_art(UV), c, texture(detail_mask, UV).r);
	#endif
	COLOR = c * tint;
}
