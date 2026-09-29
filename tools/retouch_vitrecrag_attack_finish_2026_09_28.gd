@tool
extends EditorScript

# Final-pixel pass for the approved whole-body attack poses.
# Keeps every source frame's alpha, canvas, pose and pixel coordinates.
const ROOT = "res://assets/sprites/creatures/attacks/"
const SPECS = [
    ["vitrecrag_plate_lunge/built/", "vitrecrag_plate_lunge/style_matched/", ["load", "brace", "launch", "contact", "recover"]],
    ["vitrecrag_lava_pour/v2/", "vitrecrag_lava_pour/style_matched/", ["load", "hole", "flood", "breakout", "pour_a", "pour_b", "recover"]],
]
const HOT = ["fc7424", "fc9c4c", "dc5c24", "9c3414"]

func _run() -> void:
    for spec in SPECS:
        var source_folder: String = spec[0]
        var dest_folder: String = spec[1]
        var names: Array = spec[2]
        for name in names:
            var source_path: String = ROOT + source_folder + name + ".png"
            var img: Image = Image.load_from_file(ProjectSettings.globalize_path(source_path))
            if img == null:
                push_error("Missing " + source_path)
                continue
            var out: Image = _retouch(img)
            var dest: String = ROOT + dest_folder + name + ".png"
            var abs_dest: String = ProjectSettings.globalize_path(dest)
            DirAccess.make_dir_recursive_absolute(abs_dest.get_base_dir())
            var err: Error = out.save_png(abs_dest)
            if err != OK:
                push_error("Could not save " + dest + ": " + str(err))
            else:
                print(dest + " " + str(out.get_size()))

func _retouch(img: Image) -> Image:
    var out: Image = img.duplicate()
    for y in range(img.get_height()):
        for x in range(img.get_width()):
            var c: Color = img.get_pixel(x, y)
            if c.a < 0.5:
                continue
            var h: String = c.to_html(false)
            if _edge(img, x, y):
                if h not in HOT:
                    out.set_pixel(x, y, Color("#040404") if h in ["040404", "1c1c1c"] else Color("#140c14"))
            elif h == "040404":
                out.set_pixel(x, y, Color("#140c14"))
            elif h == "1c1c1c":
                out.set_pixel(x, y, Color("#342c24"))
            elif h == "441c1c" and _near_bright(img, x, y, c):
                out.set_pixel(x, y, Color("#542424"))
    return out

func _edge(img: Image, x: int, y: int) -> bool:
    for delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
        var p: Vector2i = Vector2i(x, y) + delta
        if p.x < 0 or p.y < 0 or p.x >= img.get_width() or p.y >= img.get_height():
            return true
        if img.get_pixelv(p).a < 0.5:
            return true
    return false

func _near_bright(img: Image, x: int, y: int, c: Color) -> bool:
    var own: float = c.r * 0.2126 + c.g * 0.7152 + c.b * 0.0722
    for yy in range(max(0, y - 2), min(img.get_height(), y + 3)):
        for xx in range(max(0, x - 2), min(img.get_width(), x + 3)):
            var n: Color = img.get_pixel(xx, yy)
            if n.a > 0.5 and n.r * 0.2126 + n.g * 0.7152 + n.b * 0.0722 > own + 0.06:
                return true
    return false
