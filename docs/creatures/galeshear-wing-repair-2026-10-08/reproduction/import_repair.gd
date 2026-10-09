extends SceneTree
## Production import of imagegen's repaired silhouettes. Original palette and arena
## scale are retained; padded cells prevent the completed wings being cropped again.
const ROOT := "D:/dev/hollowtide-galeshear-wings-20261008/"
const PROJECT := "D:/dev/hollowtide-world-refinement-20261008/project/"
const SOURCE := "docs/creatures/arena-starters-2026-10-07/"
const FACINGS := ["s","se","e","ne","n","nw","w","sw"]
const MIRRORS := {"nw":"ne","w":"e","sw":"se"}
const CELLS := {"e":Vector2i(0,0),"se":Vector2i(1,0),"s":Vector2i(2,0),"ne":Vector2i(0,1),"sw":Vector2i(2,1),"n":Vector2i(0,2),"nw":Vector2i(1,2),"w":Vector2i(2,2)}
var palette: Array[Color] = []

func _initialize() -> void:
    DirAccess.make_dir_recursive_absolute(PROJECT+SOURCE+"walk")
    DirAccess.make_dir_recursive_absolute(PROJECT+SOURCE+"forms")
    var records: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ROOT+"components.json"))
    for facing in FACINGS:
        var source := Image.load_from_file(ROOT+"originals/assets/sprites/arena/galeshear/"+facing+".png")
        for y in source.get_height():
            for x in source.get_width():
                var color := source.get_pixel(x,y)
                if color.a > 0.5 and not palette.has(color): palette.append(color)
    var stills := {}
    var reports: Array = []
    for facing in ["s","se","e","ne","n"]:
        var record: Dictionary = records[facing]
        assert(record.components.size() == 8)
        var generated := Image.load_from_file(record.path)
        var tallest := 0
        var widest := 0
        for component in record.components:
            assert(not component.touches_edge)
            tallest = maxi(tallest,component.bounds[3])
            widest = maxi(widest,component.bounds[2])
        var ratio := minf(128.0/tallest,168.0/widest)
        var sheet := Image.create(768,384,false,Image.FORMAT_RGBA8)
        for i in 8:
            var bounds: Array = record.components[i].bounds
            var crop := generated.get_region(Rect2i(bounds[0],bounds[1],bounds[2],bounds[3]))
            crop.resize(roundi(crop.get_width()*ratio),roundi(crop.get_height()*ratio),Image.INTERPOLATE_LANCZOS)
            var registered := Image.create(192,192,false,Image.FORMAT_RGBA8)
            var left := floori((192-crop.get_width())/2.0)
            var top := 176-crop.get_height()
            for y in crop.get_height():
                for x in crop.get_width():
                    var color := crop.get_pixel(x,y)
                    if color.a < 0.5: continue
                    var best := Color.TRANSPARENT
                    var distance := INF
                    for candidate in palette:
                        var r := color.r-candidate.r
                        var g := color.g-candidate.g
                        var b := color.b-candidate.b
                        var d := r*r*2+g*g*4+b*b*3
                        if d < distance: distance = d; best = candidate
                    registered.set_pixel(x+left,y+top,best)
            var used := registered.get_used_rect()
            assert(used.position.x >= 8 and used.end.x <= 184 and used.position.y >= 8 and used.end.y <= 184)
            sheet.blit_rect(registered,Rect2i(0,0,192,192),Vector2i((i%4)*192,(i/4)*192))
            reports.append({"facing":facing,"frame":i,"bounds":[used.position.x,used.position.y,used.size.x,used.size.y],"canvas":[192,192]})
            if i == 0: stills[facing] = registered
        var target: String = PROJECT+SOURCE+"walk/galeshear_"+facing+"_sheet.png"
        assert(sheet.save_png(target) == OK)
    # Preserve all eight original still-facing assignments. The established
    # walking pipeline continues to mirror the three un-authored reverse sides.
    var rotation_source := Image.load_from_file(records.rotation.path)
    var rotation_order := ["e","se","s","ne","sw","n","nw","w"]
    for i in rotation_order.size():
        var bounds: Array = records.rotation.components[i].bounds
        var crop := rotation_source.get_region(Rect2i(bounds[0],bounds[1],bounds[2],bounds[3]))
        var ratio := minf(128.0/crop.get_height(),168.0/crop.get_width())
        crop.resize(roundi(crop.get_width()*ratio),roundi(crop.get_height()*ratio),Image.INTERPOLATE_LANCZOS)
        var registered := Image.create(192,192,false,Image.FORMAT_RGBA8)
        var left := floori((192-crop.get_width())/2.0)
        var top := 176-crop.get_height()
        for y in crop.get_height():
            for x in crop.get_width():
                var color := crop.get_pixel(x,y)
                if color.a < 0.5: continue
                var best := Color.TRANSPARENT
                var distance := INF
                for candidate in palette:
                    var r := color.r-candidate.r
                    var g := color.g-candidate.g
                    var b := color.b-candidate.b
                    var d := r*r*2+g*g*4+b*b*3
                    if d < distance: distance = d; best = candidate
                registered.set_pixel(x+left,y+top,best)
        stills[rotation_order[i]] = registered
    var rotation := Image.create(576,576,false,Image.FORMAT_RGBA8)
    for facing in FACINGS:
        var still: Image = stills[facing]
        assert(still.save_png(PROJECT+"assets/sprites/arena/galeshear/"+facing+".png") == OK)
        rotation.blit_rect(still,Rect2i(0,0,192,192),CELLS[facing]*192)
    assert(rotation.save_png(PROJECT+SOURCE+"forms/galeshear_arena_rotation_3x3.png") == OK)
    FileAccess.open(ROOT+"import-report.json",FileAccess.WRITE).store_string(JSON.stringify({"palette_colors":palette.size(),"frames":reports,"cell_size":192,"feet_baseline":176,"source":"Imagegen repair; alpha components registered before palette-locked native import","still_rule":"Eight original facing assignments retained; reverse-side walking frames mirrored by the existing builder"},"  "))
    print("Imported repaired Galeshear: 8 stills, 5 eight-frame sheets, original palette, padded 192 px cells")
    quit()
