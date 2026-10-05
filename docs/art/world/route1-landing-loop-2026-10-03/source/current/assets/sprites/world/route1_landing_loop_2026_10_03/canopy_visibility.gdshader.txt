shader_type canvas_item;
uniform float canopy_opacity : hint_range(0.0, 1.0) = 1.0;
void fragment() {
	vec4 ink = COLOR;
	float crown = 1.0 - smoothstep(0.67, 0.73, UV.y);
	ink.a *= mix(1.0, canopy_opacity, crown);
	COLOR = ink;
}
