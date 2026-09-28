shader_type canvas_item;

// The source walk sheet is a JPEG with a painted magenta backdrop. Its source
// stays untouched; this removes that color only when the player is drawn.
void fragment() {
	float magenta = min(COLOR.r, COLOR.b) - COLOR.g;
	if (COLOR.r > 0.32 && COLOR.b > 0.30 && magenta > 0.12) {
		discard;
	}
}
