from pathlib import Path
import shutil, re
ROOT=Path('C:/Users/pmcga/dev/hollowtide')
STAGE=Path('D:/dev/hollowtide-world-refinement-20261008/project')
WORK=Path(__file__).parent
def copy(p):
    dest=STAGE/p.relative_to(ROOT)
    dest.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(p,dest)
    if p.suffix=='.import':
        for rel in re.findall(r'res://\.godot/imported/[^"\s]+',p.read_text(encoding='utf-8')):
            src=ROOT/rel.removeprefix('res://')
            if src.exists(): copy(src)
for folder in ['scripts','scenes','data','dialogue']:
    for p in (ROOT/folder).rglob('*'):
        if p.is_file(): copy(p)
for folder in ['assets/sprites/ui','assets/fonts','assets/sprites/menu','assets/sprites/world/waking_bank_2026_10_10']:
    for p in (ROOT/folder).rglob('*'):
        if p.is_file(): copy(p)
idle=(ROOT/'scripts/ui/creature_idle.gd').read_text(encoding='utf-8')
for rel in re.findall(r'"res://([^"\n]+/)"',idle):
    for p in (ROOT/rel).glob('*'):
        if p.is_file(): copy(p)
for rel in ['project.godot','default_bus_layout.tres','.godot/global_script_class_cache.cfg','.godot/uid_cache.bin']:
    if (ROOT/rel).exists(): copy(ROOT/rel)
for name in ['first_morning_check.gd','opening_flow_check.gd']:
    shutil.copy2(WORK/name,STAGE/'tools/debug'/name)
print('Candidate checks and current opening dependencies staged; original F5 setting retained.')
