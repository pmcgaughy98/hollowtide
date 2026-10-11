extends SceneTree
const RAW := "C:/Users/pmcga/.codex/generated_images/01a11b73-6d5a-78a3-819c-fd3b9ced7188/exec-15ef5037-970b-4026-afb8-b4d2f81ed407.png"
const W := "D:/dev/hollowtide-waking-art-20261010/"
const DEST := "res://assets/sprites/world/waking_bank_2026_10_10/waking_native.png"
func _initialize() -> void:
	var img := Image.load_from_file(RAW)
	if img==null or img.is_empty():quit(1);return
	print("Generated source ",img.get_size(),"; native preparation uses nearest 384x216, no repaint or palette conversion.")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DEST.get_base_dir()))
	img.resize(384,216,Image.INTERPOLATE_NEAREST)
	img.convert(Image.FORMAT_RGBA8)
	var err:=img.save_png(ProjectSettings.globalize_path(DEST))
	print("Prepared waking asset ",img.get_size()," -> ",err)
	quit(0 if err==OK else 1)
