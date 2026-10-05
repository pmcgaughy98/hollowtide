shader_type canvas_item;
render_mode unshaded;
uniform float scene_clock = 0.0;
varying float phase;
varying vec4 tint;
void vertex() {
	phase = MODEL_MATRIX[3].x * 0.043 + MODEL_MATRIX[3].y * 0.019;
	tint = COLOR;
}
void fragment() {
	vec2 size = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 pixel = floor(UV * size);
	float height = clamp((0.78 * size.y - pixel.y) / (0.6 * size.y), 0.0, 1.0);
	float shift = round(sin(scene_clock * 0.75 + phase) * height);
	vec2 sample_uv = (pixel + vec2(shift, 0.0) + vec2(0.5)) / size;
	COLOR = texture(TEXTURE, sample_uv) * tint;
}
