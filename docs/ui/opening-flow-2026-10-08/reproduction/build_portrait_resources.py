from pathlib import Path
import re

root = Path(__file__).parent/'project'
portraits = root/'data/portraits'
portraits.mkdir(exist_ok=True)
profiles = [
    ('kithflare', '103_kithflare', (68, 8, 72, 72)),
    ('tallowroot', '1701_tallowroot', (64, 8, 104, 104)),
    ('rimefin', '001_rimefin', (78, 58, 104, 104)),
]
for name, species, region in profiles:
    source = (root/f'data/creatures/{species}.tres').read_text()
    textures = dict((identifier, path) for path, identifier in re.findall(r'\[ext_resource type="Texture2D" path="([^"]+)" id="([^"]+)"\]', source))
    idle = re.search(r'^idle_frames = .*$', source, re.M).group()
    paths = [textures[identifier] for identifier in re.findall(r'ExtResource\("([^"]+)"\)', idle)]
    lines = ['[gd_resource type="SpriteFrames" load_steps=17 format=3]', '']
    for i, path in enumerate(paths):
        lines += [f'[ext_resource type="Texture2D" path="{path}" id="{i+1}"]']
    lines += ['']
    for i in range(len(paths)):
        lines += [f'[sub_resource type="AtlasTexture" id="Face{i}"]', f'atlas = ExtResource("{i+1}")', f'region = Rect2({", ".join(map(str, region))})', 'filter_clip = true', '']
    frames = ', '.join(f'{{"duration": 1.0, "texture": SubResource("Face{i}")}}' for i in range(len(paths)))
    lines += ['[resource]', f'animations = [{{"frames": [{frames}], "loop": true, "name": &"idle", "speed": 8.0}}]', '']
    (portraits/f'{name}_front_idle.tres').write_text('\n'.join(lines))
    print(name, len(paths), 'front frames, crop', region)
