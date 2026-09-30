shader_type canvas_item;

// The molten-glass sheet of Vitrecrag's meltdown: a flattened spill lying on the
// ground along the line from the pour to the target, widest in a pool around the
// target and running past it. Every cell is one art pixel, snapped to the same
// grid as the lava river, with the river's layers (outline, cooling edge, orange
// body, pale core), hot bands flowing outward and ripple rings from the pool.
// It cools from the source end into crust with glowing cracks, then fades.

uniform vec2 origin;          // stage position of this rect's top-left corner
uniform vec2 rect_size;
uniform float px = 3.0;       // screen size of one art pixel
uniform vec2 a;               // stage position of the pour
uniform vec2 b;               // stage position of the target's feet
uniform float spread = 0.0;   // half-width in art pixels at the target end
uniform float reach = 0.0;    // art pixels the sheet runs past the target
uniform float cool = 0.0;     // 0 molten, 1 fully crusted
uniform float fade = 1.0;
uniform float glow = 0.0;     // white-hot flash as the spill lands

const vec3 OUTLINE = vec3(0.227, 0.078, 0.063); // #3a1410
const vec3 EDGE = vec3(0.863, 0.361, 0.141);    // #dc5c24
const vec3 BODY = vec3(0.988, 0.455, 0.141);    // #fc7424
const vec3 CORE = vec3(0.988, 0.612, 0.298);    // #fc9c4c
const vec3 HOT = vec3(0.988, 0.784, 0.439);     // #fcc870
const vec3 PALE = vec3(0.988, 0.863, 0.643);    // #fcdca4
const vec3 CRUST = vec3(0.290, 0.141, 0.125);   // #4a2420
const vec3 CRACK = vec3(0.612, 0.204, 0.078);   // #9c3414

// Time stepped to 12 updates a second, so the flood moves like drawn frames
// rather than a smooth 60 fps slide (Gemini VFX research, 2026-09-29).
float stepped_time() {
	return floor(TIME * 12.0) / 12.0;
}

void fragment() {
	vec2 cell = floor((origin + UV * rect_size) / px);
	vec2 c = cell + 0.5;
	// (E is taken: the shader language reserves it for Euler's number.)
	vec2 src = a / px;
	vec2 dst = b / px;
	vec2 dir = normalize(dst - src);
	vec2 run = dst + dir * reach - src;
	float s = clamp(dot(c - src, run) / dot(run, run), 0.0, 1.0);
	// Distances with the vertical doubled, so the spill lies flat on the ground.
	vec2 d = c - (src + run * s);
	d.y *= 2.0;
	float at_target = clamp(s * length(run) / max(1.0, length(dst - src)), 0.0, 1.0);
	float w = spread * mix(0.35, 1.0, at_target);
	float n = length(d) / max(w, 0.001);
	vec2 dp = c - dst;
	dp.y *= 2.0;
	float np = length(dp) / max(spread * 1.5, 0.001);
	float m = min(n, np);
	// A ragged, slowly heaving edge.
	m += 0.10 * sin(c.x * 0.37 + stepped_time() * 2.3) * sin(c.y * 0.61 - stepped_time() * 1.7);
	if (spread <= 0.0 || m > 1.0) {
		COLOR = vec4(0.0);
	} else {
		vec3 col = CORE;
		if (m > 0.9) {
			col = OUTLINE;
		} else if (m > 0.7) {
			col = EDGE;
		} else if (m > 0.38) {
			col = BODY;
		}
		float band = fract(s * 7.0 - stepped_time() * 1.6);
		float ring = fract(length(dp) * 0.08 - stepped_time() * 0.9);
		if (m <= 0.7 && (band < 0.14 || ring < 0.08)) {
			col = HOT;
		}
		col = mix(col, PALE, glow * step(m, 0.7));
		if (cool > 0.0 && s < cool * 1.3) {
			bool crack = mod(cell.x + cell.y * 3.0, 7.0) < 1.0 && m < 0.7;
			col = m > 0.9 ? OUTLINE : (crack ? CRACK : CRUST);
		}
		COLOR = vec4(col, fade);
	}
}
