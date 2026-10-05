shader_type canvas_item;
render_mode unshaded;
uniform vec2 surface_size = vec2(1024.0,768.0);

float hash(vec2 p) {
    // Integer lattice corners remain identical on both sides of each noise cell.
    uvec2 cell = uvec2(ivec2(p) + ivec2(4096));
    uint value = cell.x * 1597334677u ^ cell.y * 3812015801u;
    value ^= value >> 16u;
    value *= 2246822519u;
    value ^= value >> 13u;
    return float(value & 65535u) / 65535.0;
}
float patch(vec2 p) {
	vec2 cell = floor(p);
	vec2 blend = fract(p);
	blend = blend * blend * (3.0 - 2.0 * blend);
	return mix(mix(hash(cell), hash(cell + vec2(1.0, 0.0)), blend.x),
		mix(hash(cell + vec2(0.0, 1.0)), hash(cell + vec2(1.0)), blend.x), blend.y);
}
void fragment() {
	vec4 base = texture(TEXTURE, UV);
	// Grass changes gently in broad patches; soil and water retain their colors.
	if (base.g - base.r > 0.055 && base.g - base.b > 0.065) {
		vec2 pixel = floor(UV * surface_size);
		float broad = patch(pixel / 83.0);
		float small = patch(pixel / 27.0);
		float shade = (broad + 0.35 * small - 0.675) * 0.28;
		float dry = smoothstep(0.52, 0.82, patch(pixel / 139.0 + vec2(7.0, 3.0)));
		base.rgb *= 1.0 + shade;
		base.rgb = mix(base.rgb, base.rgb * vec3(1.08, 0.99, 0.89), dry * 0.75);
	}
	COLOR = base;
}
