"""Install the Tallowroot and Rimefin evolution stages (Claude, 2026-10-05).

Usage (repo root):  python docs/creatures/starter-lines-rd-2026-10-05/install_evolutions.py <name>=<cell>[m] ...
  e.g. tallowroot2=3 tallowroot3=7m riftfin=3
<cell> is the 3x3 rotation cell (0-8) holding the back three-quarter view facing
up-right, picked by eye; a trailing m mirrors a cell that faces up-left.

Each stage keeps its line's pixel scale (1.5x zoom), so later stages stand taller.
Names approved by Preston 2026-10-05: Huskward, Rampartroot, Sparkwick, Stormwick.
"""
import sys
from pathlib import Path
from PIL import Image, ImageOps

E = Path("docs/creatures/starter-lines-rd-2026-10-05/evolutions")
SPEC = {
    # name: (id, display name, essence, battle_size, evolves into, asset folder)
    "tallowroot2": (1702, "Huskward", 4, 1.3, "1703_tallowroot3", "tallowroot_2026_10_05"),
    "tallowroot3": (1703, "Rampartroot", 4, 1.45, None, "tallowroot_2026_10_05"),
    "riftfin": (502, "Riftfin", 1, 1.3, "503_scourmaw", "rimefin_catfish_2026_10_05"),
    "scourmaw": (503, "Scourmaw", 1, 1.45, None, "rimefin_catfish_2026_10_05"),
    "kithflare2": (109, "Sparkwick", 0, 1.7, "110_kithflare3", "kithflare_line_2026_10_05"),
    "kithflare3": (110, "Stormwick", 0, 1.45, None, "kithflare_line_2026_10_05"),
}

# Second essences (Preston 2026-10-05): Tallowroot line Bloom/Stone, Rimefin line Tide/Hollow, Kithflare line Ember/Electric.
SECOND = {n: "has_second_essence = true\nsecond_essence = %d\n" % e for n, e in
          [("tallowroot2", 2), ("tallowroot3", 2), ("riftfin", 5), ("scourmaw", 5), ("kithflare2", 6), ("kithflare3", 6)]}

TRES = """[gd_resource type="Resource" script_class="CreatureData" load_steps={steps} format=3]

[ext_resource type="Script" path="res://scripts/creature_data.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/sprites/creatures/{folder}/{name}_front.png" id="2_sprite"]
[ext_resource type="Texture2D" path="res://assets/sprites/creatures/{folder}/{name}_back.png" id="3_back"]
{evo_ext}
[resource]
script = ExtResource("1_script")
id = {id}
creature_name = "{display}"
essence = {essence}
{second}sprite = ExtResource("2_sprite")
back_sprite = ExtResource("3_back")
description = "Provisional entry (Claude, 2026-10-05, on Preston's request): Retro Diffusion art from docs/creatures/starter-lines-rd-2026-10-05/evolutions. Default stats and no moves (Strike) until Grok sets the kit and numbers."
{evo_line}battle_size = {size}
"""


def install(name, cell, mirror):
    cid, display, essence, size, evo, folder = SPEC[name]
    dest = Path("assets/sprites/creatures") / folder
    dest.mkdir(parents=True, exist_ok=True)
    pad = Image.open(E / f"{name}_pad.png").convert("RGBA")
    sheet = Image.open(E / f"{name}_rotation_3x3.png").convert("RGBA")
    cw = sheet.width // 3
    back = sheet.crop(((cell % 3) * cw, (cell // 3) * cw, (cell % 3 + 1) * cw, (cell // 3 + 1) * cw))
    if mirror:
        back = ImageOps.mirror(back)
    if back.size != pad.size:
        back = back.resize(pad.size, Image.NEAREST)
    pad.save(dest / f"{name}_front.png")
    back.save(dest / f"{name}_back.png")
    evo_ext = evo_line = ""
    if evo and not Path(f"data/creatures/{evo}.tres").exists():
        print("  link to", evo, "skipped until that stage is installed")
        evo = None
    if evo:
        evo_ext = f'[ext_resource type="Resource" path="res://data/creatures/{evo}.tres" id="4_evolution"]\n'
        evo_line = 'evolves_into = ExtResource("4_evolution")\n'
    Path(f"data/creatures/{cid}_{name}.tres").write_text(TRES.format(
        steps=5 if evo else 4, folder=folder, name=name, evo_ext=evo_ext, id=cid, display=display,
        essence=essence, second=SECOND.get(name, ""), evo_line=evo_line, size=size), encoding="utf-8")
    print("installed", name, "back cell", cell, "mirrored" if mirror else "", "bbox", back.getbbox())


if __name__ == "__main__":
    for arg in sys.argv[1:]:
        name, cell = arg.split("=")
        install(name, int(cell.rstrip("m")), cell.endswith("m"))
