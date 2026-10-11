shader_type canvas_item;
render_mode unshaded;
// Starward only: material-coloured rim and bounded carved seams, preserving source highlights.
#define SEL_OUT_DETAIL_DEFAULT 0.55
#define SEL_OUT_SELECTIVE
#include "res://scripts/art/selout_rim.gdshaderinc"
#include "res://scripts/arena/sel_out.gdshaderinc"
