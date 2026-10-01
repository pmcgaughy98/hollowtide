shader_type canvas_item;

// Falling rain for a full-screen ColorRect (the main menu's Courier Lookout,
// Preston 2026-09-30). Drawn in whole art pixels on the same grid as the
// scene: each streak is a one-pixel-wide slanted line that steps down the
// grid, so it reads as drawn pixel rain, not a smooth blur. Time is stepped
// at 24 updates a second. `frozen` stops it for Reduce Motion.

uniform vec2 screen_size = vec2(1152.0, 648.0);
uniform float px = 2.0;              // screen pixels per art pixel
uniform float slant = 0.25;          // art pixels sideways per art pixel down (wind from the left)
uniform float density = 0.14;        // share of columns with a streak
uniform float speed = 260.0;         // art pixels per second
uniform vec4 tint : source_color = vec4(0.72, 0.8, 0.86, 0.32);
uniform float frozen = 0.0;

float hash(float n) {
	return fract(sin(n * 12.9898) * 43758.5453);
}

void fragment() {
	vec2 p = floor(UV * screen_size / px);             // this art pixel
	float t = frozen > 0.5 ? 3.0 : floor(TIME * 24.0) / 24.0;
	// Slanted columns: shifting x by the row makes each column a diagonal line.
	float col = floor(p.x - p.y * slant);
	vec4 c = vec4(0.0);
	if (hash(col) < density) {
		float length = 5.0 + floor(hash(col + 3.1) * 7.0);
		float gap = 70.0 + floor(hash(col + 5.7) * 90.0);
		float spd = speed * (0.75 + 0.5 * hash(col + 7.3));
		float y = mod(p.y - t * spd + hash(col + 1.7) * 400.0, length + gap);
		if (y < length) {
			c = tint;
			c.a *= 0.6 + 0.4 * (y / length);                // brighter at the leading end
		}
	}
	COLOR = c;
}
