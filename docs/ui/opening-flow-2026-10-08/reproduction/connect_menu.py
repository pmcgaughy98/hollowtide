from pathlib import Path
import hashlib, json

root = Path(__file__).parent
path = root/'project/scenes/main_menu_art_preview.tscn'
baseline = json.loads((root/'baseline.json').read_text())
content = path.read_bytes()
assert hashlib.sha256(content).hexdigest() == baseline['scenes/main_menu_art_preview.tscn'], 'Review scene changed; inspect first'
old = b'[ext_resource type="Script" uid="uid://4roryncbe6ib" path="res://scripts/main_menu_art_preview.gd" id="1"]'
new = b'[ext_resource type="Script" path="res://scripts/opening_flow.gd" id="1"]'
assert content.count(old) == 1
path.write_bytes(content.replace(old,new))
print('Existing approved menu scene now uses the opening wrapper; scene UID retained.')
