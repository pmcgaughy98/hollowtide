shader_type canvas_item;
render_mode unshaded;

// Local title composition only: leave the original village texture untouched.
void fragment() {
    float left = 1.0 - smoothstep(0.15, 0.58, UV.x);
    float lower = smoothstep(0.28, 0.62, UV.y);
    COLOR = vec4(0.055, 0.092, 0.068, left * lower * 0.88);
}
