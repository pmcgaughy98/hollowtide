from pathlib import Path
import hashlib, importlib.util, json, shutil
from PIL import Image, ImageDraw

LIVE = Path('C:/Users/pmcga/dev/hollowtide')
WORK = Path(__file__).parent
FORMS = ('skimlet', 'ozbender', 'valvekin')

def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def paths():
    out = set()
    for folder in ('scripts', 'scenes', 'data', 'dialogue', 'tools'):
        out.update(p for p in (LIVE / folder).rglob('*') if p.is_file() and '__pycache__' not in p.parts)
    out.update((LIVE / 'assets/sprites/arena').glob('*/portrait.png'))
    for form in FORMS:
        out.update(p for p in (LIVE / 'assets/sprites/arena' / form).rglob('*') if p.is_file())
    out.update(LIVE / p for p in ('project.godot', 'docs/team/CODEX_TASKS_2026-10-22.md', 'docs/AI_COLLABORATION.md'))
    return sorted(out)

def main():
    assert not (WORK / 'protected-before.json').exists(), 'Do not replace the baseline'
    baseline = {p.relative_to(LIVE).as_posix(): sha(p) for p in paths()}
    (WORK / 'protected-before.json').write_text(json.dumps(baseline, indent=2), encoding='utf-8')
    for p in ('docs/team/CODEX_TASKS_2026-10-22.md', 'docs/AI_COLLABORATION.md', 'tools/arena/build_portraits.py'):
        dest = WORK / 'originals' / p
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(LIVE / p, dest)
    spec = importlib.util.spec_from_file_location('portrait_builder', LIVE / 'tools/arena/build_portraits.py')
    builder = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(builder)
    builder.ART = LIVE / 'assets/sprites/arena'
    canvas = Image.new('RGBA', (800, 3 * 244), '#242b25')
    draw = ImageDraw.Draw(canvas)
    facts = {}
    for row, form in enumerate(FORMS):
        base = builder.ART / form
        assert not (base / 'portrait.png').exists(), f'{form} already has a portrait; reassess'
        facts[form] = {}
        for col, facing in enumerate(('s', 'sw')):
            src = base / (facing + '.png')
            dest = WORK / 'originals' / src.relative_to(LIVE)
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dest)
            im = Image.open(src).convert('RGBA')
            tile = im.crop(im.getbbox())
            tile.thumbnail((200, 200), Image.Resampling.NEAREST)
            canvas.alpha_composite(tile, (col * 240 + 10, row * 244 + 26))
            draw.text((col * 240 + 10, row * 244 + 7), f'{form} {facing}', fill='white')
        pic = builder.portrait(form)
        dest = WORK / 'prepared/assets/sprites/arena' / form / 'portrait.png'
        dest.parent.mkdir(parents=True, exist_ok=True)
        pic.save(dest)
        canvas.alpha_composite(pic.resize((192, 192), Image.Resampling.NEAREST), (520, row * 244 + 26))
        draw.text((520, row * 244 + 7), 'default 48px crop, 4x', fill='white')
        facts[form] = {'size': list(pic.size), 'bbox': pic.getbbox(), 'colours': len(set(pic.getdata()) - {(0,0,0,0)}), 'source': 's.png', 'sha256': sha(dest)}
    canvas.convert('RGB').save(WORK / 'default-crops.png')
    (WORK / 'preparation.json').write_text(json.dumps(facts, indent=2), encoding='utf-8')
    print(json.dumps({'protected_files': len(baseline), 'portraits': facts}, indent=2))

if __name__ == '__main__':
    main()
