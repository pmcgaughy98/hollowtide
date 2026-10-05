# Continuous grass shading, October 4, 2026

Fresh native hometown inspection exposed rectangular color jumps at the grass noise lattice. Identical native grass tiles in a single surface retained the jumps with the old shader, UV coordinates and explicit texture sampling; removing the shader removed them. Replacing only the sine/fract corner hash with stable integer lattice values removed the visible seams while retaining the original broad/narrow/dry-grass blending.

Only assets/sprites/world/route1_landscape_2026_10_03/ground_variation.gdshader changed. 2184 of 2185 recorded existing runtime files remain exact. No new runtime texture, art generation, cost, gameplay, collision, state or launch edit. Native outdoor captures from the actual hometown, riverfront, historic street and Route 1 were inspected. Final stderr empty and owned process exited; user editor left untouched. Comparisons and unchanged tile surface are diagnostic fixtures, not installed artwork.

The observed correction is verified in this renderer; the exact compiler/driver mechanism is not proven. [Official CanvasItem texture/COLOR reference](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html) informed the sampling comparison; it does not prove the seam diagnosis.

The full world goal remains active. Hometown resident/garden work remains planned and ungenerated: no new paid request or upload. Preston's latest full Kithflare-line recheck takes priority. Originals, candidate diagnostics, baseline and corrected native captures remain in review/.
