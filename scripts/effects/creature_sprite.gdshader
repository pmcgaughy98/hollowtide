shader_type canvas_item;

// Every battle creature sprite wears this. Two jobs, both in whole art pixels so
// the pixel grid never breaks:
//
// Breath: everything above breath_cut rises breath_lift art pixels while the
// rows below (legs, feet) stay planted; the last row above the cut stretches to
// fill the gap. Scaling the sprite by a fraction for breathing made some art
// pixels wider than others, which showed as a moving 9-box grid (Preston,
// 2026-09-28).
//
// Heat (Overheat): fire-coloured core pixels (a furnace window, a glowing seam)
// brighten toward white-gold, the heat bleeds orange into the pixels around
// them, and the body takes a faint warm cast. Rust and stone stay as drawn.
// heat 0 is the sprite as drawn, 1 is overheating, above 1 is a flare.

uniform float breath_lift = 0.0; // art pixels, whole numbers
uniform float breath_cut = 0.5;  // texture v at the row boundary where rising stops
uniform float heat : hint_range(0.0, 2.0) = 0.0;
// A gentle glow that breathes in and out while idle (Ironvent's vents,
// Preston 2026-09-28), added on top of heat and kept well below an attack's.
uniform float idle_glow : hint_range(0.0, 1.0) = 0.0;
// Heat that fills the body from the tail end toward the head (Furnace Roar's
// pressure climbing vent by vent, Preston 2026-09-28). 0 lights nothing yet,
// 1 lights everything; the sweep's leading edge flares like a vent catching.
// Measured across the art as drawn (tail on the left), so the foe's mirroring
// does not reverse it. At the default of 1 it changes nothing.
uniform float heat_sweep : hint_range(0.0, 1.0) = 1.0;

const vec3 BRIGHT = vec3(0.988, 0.612, 0.298); // #fc9c4c
const vec3 PALE = vec3(0.988, 0.863, 0.643);   // #fcdca4
const vec3 ORANGE = vec3(0.988, 0.455, 0.141); // #fc7424

varying vec4 tint; // modulate and self_modulate, which the hit flashes use

void vertex() {
	tint = COLOR;
}

// 1 for the saturated fire colours (#9c3414 up to #fcc870), 0 for rust and stone.
float core(vec4 c) {
	float fire = step(0.45, c.r - c.b) * step(0.5, c.r);
	float pale = step(0.95, c.r) * step(0.7, c.g) * step(c.b, 0.5);
	return max(fire, pale) * step(0.5, c.a);
}

void fragment() {
	vec2 uv = UV;
	if (breath_lift > 0.0 && UV.y < breath_cut) {
		float px = TEXTURE_PIXEL_SIZE.y;
		uv.y = min(UV.y + breath_lift * px, breath_cut - 0.5 * px);
	}
	vec4 raw = texture(TEXTURE, uv);
	float edge = heat_sweep * 1.1;
	float filled = smoothstep(uv.x - 0.05, uv.x + 0.05, edge);
	float front = heat_sweep < 1.0 ? max(0.0, 1.0 - abs(uv.x - edge) / 0.06) : 0.0;
	float h = heat * filled + heat * 0.6 * front + idle_glow;
	if (raw.a > 0.0 && h > 0.0) {
		// A slow, uneven flicker so the core breathes rather than blinks.
		float flicker = 0.85 + 0.15 * sin(TIME * 11.0 + uv.x * 40.0 + uv.y * 23.0);
		vec3 lit = raw.rgb;
		if (core(raw) > 0.5) {
			vec3 hot = mix(BRIGHT, PALE, clamp(h - 0.4, 0.0, 1.0));
			lit = mix(raw.rgb, hot, clamp(h * flicker, 0.0, 1.0));
		} else {
			// Heat bleeding out: how much fire sits within two pixels.
			float near = 0.0;
			for (int dx = -2; dx <= 2; dx++) {
				for (int dy = -2; dy <= 2; dy++) {
					near += core(texture(TEXTURE, uv + vec2(float(dx), float(dy)) * TEXTURE_PIXEL_SIZE));
				}
			}
			float bleed = clamp(near / 6.0, 0.0, 1.0) * clamp(h, 0.0, 1.3) * 0.55 * flicker;
			lit = mix(raw.rgb, ORANGE, bleed);
			lit += vec3(0.10, 0.03, 0.0) * h * h * flicker; // warm cast
		}
		raw.rgb = lit;
	}
	COLOR = raw * tint;
}
