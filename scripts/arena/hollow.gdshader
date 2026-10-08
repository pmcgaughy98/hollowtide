shader_type canvas_item;
// Hollow essence as absence (Preston, 2026-10-07: Scourmaw is "void/absence", not ghost).
// Holes drift through the body so the arena shows through it; a thin cyan rim marks where
// the body has been worn away, and stray pixels crumble off. Everything is worked out on
// whole art pixels and moves in steps, so it stays crisp pixel art rather than a smooth fade.

uniform float time_s = 0.0;
// Share of the body that is missing: about 0.3 at rest, more while moving, most while phasing.
uniform float absence : hint_range(0.0, 1.0) = 0.3;
uniform vec4 rim : source_color = vec4(0.55, 0.9, 1.0, 1.0);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void fragment() {
	vec4 c = texture(TEXTURE, UV) * COLOR;
	if (c.a < 0.01) {
		discard;
	}
	vec2 px = floor(UV / TEXTURE_PIXEL_SIZE);   // this art pixel
	float t = floor(time_s * 6.0) / 6.0;          // six steps a second
	float n = noise(px / 6.0 + vec2(t * 0.6, -t * 0.45));
	float hole = n - (1.0 - absence);             // above 0 means inside a hole
	if (hole > 0.05) {
		discard;
	}
	if (hole > 0.0) {
		COLOR = vec4(rim.rgb, c.a);
	} else if (hash(px + vec2(t * 13.0, t * 7.0)) < absence * 0.07) {
		discard;                                  // a crumbling pixel
	} else {
		COLOR = c;
	}
}
