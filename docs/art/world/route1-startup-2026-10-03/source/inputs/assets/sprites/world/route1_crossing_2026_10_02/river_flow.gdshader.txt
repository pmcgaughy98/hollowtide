shader_type canvas_item;
render_mode unshaded;

// The sprite's fixed alpha mask preserves the existing bank silhouette.
uniform sampler2D river_texture : filter_nearest, repeat_enable;
uniform vec2 flow_offset = vec2(0.0);
uniform vec2 surface_size = vec2(224.0, 640.0);

void fragment() {
	vec2 pixel = floor(UV * surface_size) + vec2(0.5);
	vec3 water = texture(river_texture, (pixel - flow_offset) / 32.0).rgb;
	COLOR = vec4(water, texture(TEXTURE, UV).a);
}
