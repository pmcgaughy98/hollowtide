shader_type canvas_item;

// The original HUD study is a JPEG with magenta cutouts. Keep its source file
// unchanged and reveal the live controls through those cutouts at draw time.
void fragment() {
	float magenta = min(COLOR.r, COLOR.b) - COLOR.g;
	if (COLOR.r > 0.32 && COLOR.b > 0.30 && magenta > 0.12) {
		discard;
	}
}
