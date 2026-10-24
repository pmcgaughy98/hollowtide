// Optional silhouette colours; no alpha, width, UV or internal-detail changes.
float rim_luma(vec3 c) { return dot(c, vec3(0.2126, 0.7152, 0.0722)); }
// rim_sample and SELECTIVE_RIM are macros that read TEXTURE themselves (Claude, 2026-10-24, pass 5 A5): a function
// handed TEXTURE, a built-in sampler, printed the engine's 'custom_samplers' error each time a rimmed shader loaded.
// SELECTIVE_RIM(result, uv, texel, finished) sets the vec3 `result` to what the old selective_rim() returned.
#define SELOUT_RIM_MACRO
#define rim_sample(uv) (texture(TEXTURE, (uv)) * step(0.0, (uv).x) * step(0.0, (uv).y) * (1.0-step(1.0, (uv).x)) * (1.0-step(1.0, (uv).y)))
#define SELECTIVE_RIM(result, uv, texel, finished) { \
	vec4 rim_fin = finished; \
	vec3 rim_out = rim_fin.rgb; \
	vec4 rim_raw = rim_sample(uv); \
	vec4 rim_n = rim_sample((uv)-vec2(0.0,(texel).y)); \
	vec4 rim_s = rim_sample((uv)+vec2(0.0,(texel).y)); \
	vec4 rim_w = rim_sample((uv)-vec2((texel).x,0.0)); \
	vec4 rim_e = rim_sample((uv)+vec2((texel).x,0.0)); \
	float rim_edge = min(min(rim_n.a,rim_s.a),min(rim_w.a,rim_e.a)); \
	if (!(rim_fin.a<0.5 || (rim_raw.a>0.5 && rim_edge>0.5) || rim_luma(rim_fin.rgb)>0.24)) { \
		/* Choose a real neighbouring swatch rather than averaging or adding grain. */ \
		vec3 rim_material = rim_raw.rgb; \
		float rim_brightest = rim_raw.a>0.5 ? rim_luma(rim_material) : -1.0; \
		for (int rim_y=-2; rim_y<=2; rim_y++) { \
			for (int rim_x=-2; rim_x<=2; rim_x++) { \
				vec4 rim_candidate = rim_sample((uv)+vec2(float(rim_x),float(rim_y))*(texel)); \
				float rim_lum = rim_luma(rim_candidate.rgb); \
				if (rim_candidate.a>0.5 && rim_lum>rim_brightest) { rim_material=rim_candidate.rgb; rim_brightest=rim_lum; } \
			} \
		} \
		if (rim_brightest>=0.13) { \
			vec2 rim_outward = rim_raw.a>0.5 ? vec2(rim_w.a-rim_e.a,rim_n.a-rim_s.a) : vec2(rim_e.a-rim_w.a,rim_s.a-rim_n.a); \
			float rim_light = length(rim_outward)>0.0 ? max(0.0,dot(normalize(rim_outward),normalize(vec2(-1.0,-1.0)))) : 0.0; \
			vec3 rim_rgb = rim_material * mix(0.24,0.42,rim_light); \
			rim_out = rim_rgb * min(1.0,0.23/max(rim_luma(rim_rgb),0.001)); \
		} \
	} \
	result = rim_out; \
}
