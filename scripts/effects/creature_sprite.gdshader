shader_type canvas_item;

// Every battle creature sprite wears this. Two jobs, both in whole art pixels so
// the pixel grid never breaks:
//
// Breath and squash: the body above breath_cut (the legs or the feet line)
// stretches or squashes by whole art pixels, spread evenly over its height and
// width, while the rows below stay planted. Rows and columns repeat or drop at
// evenly spaced spots, so every art pixel stays one size. Scaling the sprite by
// a fraction made some art pixels wider than others, which showed as a moving
// 9-box grid (Preston, 2026-09-28); lifting only one row (the fix after that)
// lost the swell Preston liked (2026-09-29). This keeps the swell, on the grid.
//
// Heat (Overheat): fire-coloured core pixels (a furnace window, a glowing seam)
// brighten toward white-gold, the heat bleeds orange into the pixels around
// them, and the body takes a faint warm cast. Rust and stone stay as drawn.
// heat 0 is the sprite as drawn, 1 is overheating, above 1 is a flare.

uniform float breath_lift = 0.0;  // art pixels taller (+) or shorter (-), whole numbers
uniform float breath_widen = 0.0; // art pixels wider (+) or narrower (-) on each side
uniform float breath_cut = 0.5;   // texture v of the planted line: rows below stay put
uniform float breath_top = 0.0;   // texture v of the art's top row
uniform float breath_mid = 0.5;   // texture u of the body's middle column
uniform float breath_half = 0.5;  // texture u of half the art's width
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
// Which colours glow. 0 = fire (Ember: furnace windows, molten seams).
// 1 = jade (Oxbowarchon's green energy seams, Preston 2026-09-29): the bright
// greens light toward pale mint and bleed emerald; slate stone stays as drawn.
uniform int glow_kind = 0;
// Ironvent's head keeps the same soot-charcoal ramp in both views and attacks.
uniform bool charcoal_head = false;
uniform vec4 head_finish_bounds = vec4(0.76, 0.40, 1.0, 0.67);

// Registered Vitrecrag attack frames can omit the authored shell seams.
// Opt in only for that frame family; default materials remain unchanged.
uniform bool keep_authored_cracks = false;
uniform sampler2D authored_shell : filter_nearest, repeat_disable;


const vec3 BRIGHT = vec3(0.988, 0.612, 0.298); // #fc9c4c
const vec3 PALE = vec3(0.988, 0.863, 0.643);   // #fcdca4
const vec3 ORANGE = vec3(0.988, 0.455, 0.141); // #fc7424
const vec3 MINT = vec3(0.518, 0.957, 0.612);   // #84f49c, Oxbowarchon's own brightest jade
const vec3 PALE_MINT = vec3(0.847, 0.988, 0.878); // #d8fce0
const vec3 EMERALD = vec3(0.110, 0.737, 0.298); // #1cbc4c, Oxbowarchon's own

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

// 1 for the saturated jade greens (#0c6c34 up to #8cfcac) and the pale mint
// highlights, 0 for the grey-green slate (#446454) and the deep shadows.
float jade(vec4 c) {
	float green = step(0.18, c.g - max(c.r, c.b)) * step(0.4, c.g);
	float pale = step(0.75, c.g) * step(0.12, c.g - c.r) * step(0.08, c.g - c.b);
	return max(green, pale) * step(0.5, c.a);
}

float glows(vec4 c) {
	return glow_kind == 1 ? jade(c) : core(c);
}

// Glow amounts snap to quarter steps, so a glow is a few flat bands of colour
// like a drawn one, not a smooth blend that invents in-between colours.
float band4(float v) {
	return floor(v * 4.0 + 0.5) / 4.0;
}

void fragment() {
	vec2 uv = UV;
	vec2 size = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 p = floor(UV * size);  // this art pixel
	float cut = floor(breath_cut * size.y + 0.5);
	if (p.y < cut && (breath_lift != 0.0 || breath_widen != 0.0)) {
		vec2 src = p;
		if (breath_lift != 0.0) {
			// Rows above the cut spread out (or close up) from the cut upward.
			float h = max(1.0, cut - floor(breath_top * size.y + 0.5));
			src.y = cut - 1.0 - floor((cut - 1.0 - p.y) * h / max(1.0, h + breath_lift));
		}
		if (breath_widen != 0.0) {
			// Columns spread out (or close up) from the middle.
			float mid = breath_mid * size.x;
			float half_w = max(1.0, breath_half * size.x);
			src.x = floor(mid + (p.x + 0.5 - mid) * half_w / max(1.0, half_w + breath_widen));
		}
		uv = (src + 0.5) / size;
	}
	vec4 raw = texture(TEXTURE, uv);
	if (keep_authored_cracks && raw.a > 0.99) {
		vec2 shell_px = floor(uv * size);
		vec4 shell = texture(authored_shell, uv);
		bool plate = shell_px.x >= 22.0 && shell_px.x < 165.0
			&& shell_px.y >= 50.0 && shell_px.y < 119.0;
		bool window = shell_px.x >= 115.0 && shell_px.x < 137.0
			&& shell_px.y >= 76.0 && shell_px.y < 105.0;
		bool seam = shell.r > 0.45 && shell.r - shell.b > 0.20
			&& shell.g < shell.r * 0.85 && shell.a > 0.99;
		// Keep contours, the window and each pose's eruption as drawn.
		// The same snapped UV as breathing keeps seams on the body grid.
		if (plate && !window && seam && raw.r > 0.08 && core(raw) < 0.5) {
			raw.rgb = max(raw.rgb, shell.rgb);
		}
	}


	// Registered Ironvent art uses a 100px canvas. The head armor starts
	// below the horn bases; its finish leaves the horns and body rust intact.
	if (charcoal_head && raw.a > 0.0
		&& all(greaterThanEqual(uv, head_finish_bounds.xy))
		&& all(lessThan(uv, head_finish_bounds.zw))) {
		float brightest = max(raw.r, max(raw.g, raw.b));
		// Match the lineage's charcoal-grey armor, keeping the drawn planes,
		// black contour and molten highlights instead of flattening the head.
		if (core(raw) < 0.5 && brightest > 0.14) {
			float plane = dot(raw.rgb, vec3(0.28, 0.56, 0.16));
			raw.rgb = vec3(plane) * vec3(0.68, 0.72, 0.70);
		}
	}
	float edge = heat_sweep * 1.1;
	float filled = smoothstep(uv.x - 0.05, uv.x + 0.05, edge);
	float front = heat_sweep < 1.0 ? max(0.0, 1.0 - abs(uv.x - edge) / 0.06) : 0.0;
	float h = heat * filled + heat * 0.6 * front + idle_glow;
	if (raw.a > 0.0 && h > 0.0) {
		// A slow, uneven flicker so the core breathes rather than blinks. Time is
		// stepped to 12 updates a second so it moves like drawn frames, not a
		// smooth 60 fps fade (Gemini VFX research, 2026-09-29: animate on steps).
		float t = floor(TIME * 12.0) / 12.0;
		float flicker = 0.85 + 0.15 * sin(t * 11.0 + uv.x * 40.0 + uv.y * 23.0);
		vec3 lit = raw.rgb;
		vec3 bright = glow_kind == 1 ? MINT : BRIGHT;
		vec3 pale = glow_kind == 1 ? PALE_MINT : PALE;
		vec3 bleed_to = glow_kind == 1 ? EMERALD : ORANGE;
		vec3 cast = glow_kind == 1 ? vec3(0.0, 0.07, 0.04) : vec3(0.10, 0.03, 0.0);
		if (glows(raw) > 0.5) {
			vec3 hot = mix(bright, pale, clamp(h - 0.4, 0.0, 1.0));
			if (glow_kind == 1) {
				// Jade is drawn with its own light and dark greens (the sphere, the
				// rails). Brighten them by at most half the way and never darken, so
				// the drawn shading survives instead of going one flat mint.
				hot = mix(bright, pale, clamp(h - 0.8, 0.0, 1.0));
				lit = max(raw.rgb, mix(raw.rgb, hot, 0.5 * band4(clamp(h * flicker, 0.0, 1.0))));
			} else {
				lit = mix(raw.rgb, hot, band4(clamp(h * flicker, 0.0, 1.0)));
			}
		} else {
			// Heat bleeding out: how much fire sits within two pixels.
			float near = 0.0;
			for (int dx = -2; dx <= 2; dx++) {
				for (int dy = -2; dy <= 2; dy++) {
					near += glows(texture(TEXTURE, uv + vec2(float(dx), float(dy)) * TEXTURE_PIXEL_SIZE));
				}
			}
			float bleed = clamp(near / 6.0, 0.0, 1.0) * clamp(h, 0.0, 1.3) * 0.55 * flicker;
			lit = mix(raw.rgb, bleed_to, band4(bleed));
			lit += cast * band4(clamp(h * h * flicker, 0.0, 1.5)); // warm (or jade) cast
		}
		raw.rgb = lit;
	}
	COLOR = raw * tint;
}
