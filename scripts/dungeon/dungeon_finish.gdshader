shader_type canvas_item;
render_mode unshaded;
#define SEL_OUT_DETAIL_DEFAULT 0.75
#define SEL_OUT_MASKED_MAP
uniform sampler2D detail_mask : filter_nearest, repeat_disable;
#include "res://scripts/arena/sel_out.gdshaderinc"
