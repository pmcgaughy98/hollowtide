# Render a creature model as a sprite source (Claude, 2026-10-12, the sprites-in-3D workshop; the method is the
# mech session's render_sprite_views.py, written again for Hollowtide): eight views from one fixed camera, an
# orthographic lens pitched down like the dungeon's drawn view, transparent background, Workbench flat colour so
# the pixel textures stay as painted, one key light. tools/art/pixelize_views.py then turns the renders into
# sprites at the dungeon's size and measures them.
#   blender -b --factory-startup -P tools/blender/render_creature_views.py -- <model.glb> <out_dir> [elev_deg] [px] [face]
# `face` is the Blender axis the model's front points along: -y (the default; the mech session's ape, and glTF
# files that face +Z before import), +y, +x or -x. Check the contact sheet: "s" must show the face.
import bpy, math, os, sys
from mathutils import Vector

argv = sys.argv[sys.argv.index("--") + 1:]
MODEL, OUT = argv[0], argv[1]
ELEV = float(argv[2]) if len(argv) > 2 else 30.0     # camera pitch below level: the dungeon's three-quarter view
PX = int(argv[3]) if len(argv) > 3 else 256           # render size; the pixelizer scales down from here
FACE = argv[4] if len(argv) > 4 else "-y"
FACE_DEG = {"+x": 0.0, "+y": 90.0, "-x": 180.0, "-y": 270.0}[FACE]
# Where the camera stands, as an offset from the direction the creature faces: "s" is straight in front of it
# (the face toward the camera); "e" is 90 degrees to its left so it faces screen right; "n" is behind.
VIEWS = {"s": 0, "se": -45, "e": -90, "ne": -135, "n": 180, "nw": 135, "w": 90, "sw": 45}
os.makedirs(OUT, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
ext = os.path.splitext(MODEL)[1].lower()
if ext == ".glb" or ext == ".gltf":
    bpy.ops.import_scene.gltf(filepath=MODEL)
elif ext == ".obj":
    bpy.ops.wm.obj_import(filepath=MODEL)
else:
    raise SystemExit("unknown model type " + ext)
meshes = [o for o in scene.objects if o.type == "MESH"]
if not meshes:
    raise SystemExit("no mesh in " + MODEL)

# Stand the model on the ground at the origin, and measure it.
lo = Vector((1e9, 1e9, 1e9))
hi = Vector((-1e9, -1e9, -1e9))
for o in meshes:
    for c in o.bound_box:
        w = o.matrix_world @ Vector(c)
        lo = Vector(min(a, b) for a, b in zip(lo, w))
        hi = Vector(max(a, b) for a, b in zip(hi, w))
centre = (lo + hi) * 0.5
root = bpy.data.objects.new("creature_root", None)
scene.collection.objects.link(root)
for o in meshes:
    if o.parent is None:
        o.parent = root
root.location = Vector((-centre.x, -centre.y, -lo.z))
bpy.context.view_layer.update()
size = hi - lo
radius = max(size.x, size.y, size.z) * 0.5
height = size.z

# Camera: orthographic, pitched down ELEV degrees, framed on the model's bounding sphere so every view shares one scale.
cam_data = bpy.data.cameras.new("cam")
cam_data.type = "ORTHO"
cam_data.ortho_scale = radius * 2.6
cam = bpy.data.objects.new("cam", cam_data)
scene.collection.objects.link(cam)
scene.camera = cam
target = Vector((0, 0, height * 0.5))

# Light: one key from above-left of the camera, plus the Workbench's flat shading so colours stay as painted.
sun_data = bpy.data.lights.new("key", "SUN")
sun_data.energy = 3.0
sun = bpy.data.objects.new("key", sun_data)
scene.collection.objects.link(sun)

scene.render.engine = "BLENDER_WORKBENCH"
scene.display.shading.light = "FLAT"
scene.display.shading.color_type = "TEXTURE"
scene.display.shading.show_object_outline = False
scene.render.film_transparent = True
scene.render.resolution_x = PX
scene.render.resolution_y = PX
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = "PNG"
scene.render.image_settings.color_mode = "RGBA"
scene.view_settings.view_transform = "Standard"
scene.display.render_aa = "OFF"   # crisp edges for the pixelizer

dist = radius * 4.0
# Animation (optional): FRAMES="0,6,12,18" renders those frames of the file's first action for every view, as
# <dir>_f<k>.png, so one rig gives the same walk in all eight directions; without it, the rest pose as <dir>.png.
frames = [int(f) for f in os.environ.get("FRAMES", "").split(",") if f.strip() != ""]
if frames:
    actions = list(bpy.data.actions)
    print("actions:", [(a.name, tuple(a.frame_range)) for a in actions])
for name, offset in VIEWS.items():
    a = math.radians(FACE_DEG + offset)
    pos = Vector((math.cos(a) * dist * math.cos(math.radians(ELEV)),
                  math.sin(a) * dist * math.cos(math.radians(ELEV)),
                  target.z + dist * math.sin(math.radians(ELEV))))
    cam.location = pos
    direction = target - pos
    cam.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    sun.rotation_euler = (math.radians(50), 0, cam.rotation_euler.z - math.radians(30))
    bpy.context.view_layer.update()
    if frames:
        for k, f in enumerate(frames):
            scene.frame_set(f)
            scene.render.filepath = os.path.join(OUT, "%s_f%d.png" % (name, k))
            bpy.ops.render.render(write_still=True)
        print("rendered", name, "frames", frames)
    else:
        scene.render.filepath = os.path.join(OUT, name + ".png")
        bpy.ops.render.render(write_still=True)
        print("rendered", name, "camera at", round(FACE_DEG + offset) % 360, "degrees")
print("model size x %.3f y %.3f z %.3f, radius %.3f, ortho scale %.3f" % (size.x, size.y, size.z, radius, cam_data.ortho_scale))
