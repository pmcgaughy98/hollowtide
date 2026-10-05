shader_type canvas_item;

// A material finish for the existing female RD atlas, in native art pixels.
// Alpha, frame geometry, pose registration and gait remain as authored.
uniform float finish_strength : hint_range(0.0, 1.0) = 1.0;
varying vec4 sprite_tint;

void vertex() {
	sprite_tint = COLOR;
}

float luminance(vec3 c) {
	return dot(c, vec3(0.28, 0.56, 0.16));
}

bool rose(vec3 c) {
	return c.r > 0.48 && c.g / max(c.r, 0.001) > 0.34
		&& c.g / max(c.r, 0.001) < 0.65 && c.b > c.g * 0.82;
}

void fragment() {
	vec4 raw = texture(TEXTURE, UV);
	vec3 c = raw.rgb;
	if (raw.a > 0.0) {
		vec4 above = texture(TEXTURE, UV - vec2(0.0, TEXTURE_PIXEL_SIZE.y));
		vec4 left = texture(TEXTURE, UV - vec2(TEXTURE_PIXEL_SIZE.x, 0.0));
		vec4 below = texture(TEXTURE, UV + vec2(0.0, TEXTURE_PIXEL_SIZE.y));
		vec4 right = texture(TEXTURE, UV + vec2(TEXTURE_PIXEL_SIZE.x, 0.0));
		bool inside = above.a > 0.99 && left.a > 0.99 && below.a > 0.99 && right.a > 0.99;
		bool upper_plane = inside && (luminance(above.rgb) + 0.04 < luminance(c)
			|| luminance(left.rgb) + 0.04 < luminance(c));
		bool lower_plane = inside && !upper_plane && (luminance(below.rgb) + 0.04 < luminance(c)
			|| luminance(right.rgb) + 0.04 < luminance(c));
		if (max(c.r, max(c.g, c.b)) < 0.15 || (c.g < 0.04 && c.r < 0.25)) {
			// Match the male courier's warm dark ink, clearing the red fringe.
			c = vec3(0.051, 0.039, 0.016);
		} else if (c.r > 0.7 && c.g / c.r > 0.62 && c.b < c.g * 0.9) {
			// Keep facial highlights warm, with the same light as the male.
			c = min(vec3(1.0), c + vec3(0.008, 0.028, 0.025));
		} else if (rose(c)) {
			// Pink stays pink. Narrow folds add a material plane, not random grain.
			c = clamp(vec3(0.28) + (c - vec3(0.28)) * 1.10, vec3(0.0), vec3(1.0));
			if (upper_plane) {
				c += vec3(0.043, 0.027, 0.023);
			} else if (lower_plane) {
				c *= vec3(0.94, 0.92, 0.92);
			}
		} else if (c.g > c.r * 1.4 && c.b > c.r * 1.6) {
			c *= vec3(0.96, 1.06, 1.01);
			if (upper_plane) {
				c += vec3(0.016, 0.039, 0.032);
			} else if (lower_plane) {
				c *= 0.91;
			}
		} else {
			// Brown hair, leather and the satchel keep separate existing ramps.
			c *= vec3(1.02, 1.0, 0.96);
			if (upper_plane && c.r > 0.25) {
				c += vec3(0.025, 0.021, 0.010);
			} else if (lower_plane) {
				c *= 0.94;
			}
		}
	}
	COLOR = vec4(mix(raw.rgb, clamp(c, vec3(0.0), vec3(1.0)), finish_strength), raw.a) * sprite_tint;
}
