// Sparkwick's display palette: approved arena-front gold/tan/copper, not muddy grey-brown.
// Exact swatches only. Flame, pale belly, alpha and source art remain unchanged.
uniform bool sparkwick_palette = false;
vec4 sparkwick_colour(vec4 c) {
    if (!sparkwick_palette || c.a == 0.0) return c;
    vec3 rgb = floor(c.rgb * 255.0 + 0.5);
    vec3 out_rgb = rgb;
    // Older large idle -> the same warm material ramps as the approved arena take.
    if (all(equal(rgb, vec3(206,157,92))) || all(equal(rgb, vec3(207,157,92))) || all(equal(rgb, vec3(185,129,64))) || all(equal(rgb, vec3(186,129,64)))) out_rgb = vec3(215,156,76);
    else if (all(equal(rgb, vec3(174,141,96))) || all(equal(rgb, vec3(175,141,96))) || all(equal(rgb, vec3(171,125,84))) || all(equal(rgb, vec3(172,125,84)))) out_rgb = vec3(202,152,89);
    else if (all(equal(rgb, vec3(156,98,57))) || all(equal(rgb, vec3(157,98,57))) || all(equal(rgb, vec3(160,112,71))) || all(equal(rgb, vec3(161,112,71)))) out_rgb = vec3(156,103,58);
    else if (all(equal(rgb, vec3(121,94,73))) || all(equal(rgb, vec3(122,94,73))) || all(equal(rgb, vec3(123,81,51))) || all(equal(rgb, vec3(124,81,51)))) out_rgb = vec3(143,92,54);
    else if (all(equal(rgb, vec3(109,67,44))) || all(equal(rgb, vec3(110,67,44)))) out_rgb = vec3(105,64,39);
    // Turned/walking generations contain desaturated body paint, already locked to the
    // source palette. Remove those dull material swatches without repainting markings.
    else if (all(equal(rgb, vec3(180,139,91))) || all(equal(rgb, vec3(166,137,105))) || all(equal(rgb, vec3(166,121,85)))) out_rgb = vec3(202,152,89);
    return vec4(out_rgb / 255.0, c.a);
}
