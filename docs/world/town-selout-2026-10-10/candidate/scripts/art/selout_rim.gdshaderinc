// Optional silhouette colours; no alpha, width, UV or internal-detail changes.
float rim_luma(vec3 c) { return dot(c, vec3(0.2126, 0.7152, 0.0722)); }
vec4 rim_sample(sampler2D tex, vec2 uv) {
	return texture(tex, uv) * step(0.0, uv.x) * step(0.0, uv.y) * (1.0-step(1.0, uv.x)) * (1.0-step(1.0, uv.y));
}
vec3 selective_rim(sampler2D tex, vec2 uv, vec2 texel, vec4 finished) {
	vec4 raw = rim_sample(tex, uv);
	vec4 n = rim_sample(tex, uv-vec2(0.0,texel.y));
	vec4 s = rim_sample(tex, uv+vec2(0.0,texel.y));
	vec4 w = rim_sample(tex, uv-vec2(texel.x,0.0));
	vec4 e = rim_sample(tex, uv+vec2(texel.x,0.0));
	float edge = min(min(n.a,s.a),min(w.a,e.a));
	if (finished.a<0.5 || (raw.a>0.5 && edge>0.5) || rim_luma(finished.rgb)>0.24) return finished.rgb;
	// Choose a real neighbouring swatch rather than averaging or adding grain.
	vec3 material = raw.rgb;
	float brightest = raw.a>0.5 ? rim_luma(material) : -1.0;
	for (int y=-2; y<=2; y++) {
		for (int x=-2; x<=2; x++) {
			vec4 candidate = rim_sample(tex,uv+vec2(float(x),float(y))*texel);
			float lum = rim_luma(candidate.rgb);
			if (candidate.a>0.5 && lum>brightest) { material=candidate.rgb; brightest=lum; }
		}
	}
	if (brightest<0.13) return finished.rgb;
	vec2 outward = raw.a>0.5 ? vec2(w.a-e.a,n.a-s.a) : vec2(e.a-w.a,s.a-n.a);
	float light = length(outward)>0.0 ? max(0.0,dot(normalize(outward),normalize(vec2(-1.0,-1.0)))) : 0.0;
	vec3 rim = material * mix(0.24,0.42,light);
	return rim * min(1.0,0.23/max(rim_luma(rim),0.001));
}
