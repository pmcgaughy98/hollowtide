"""Probe the base frames: sky rows, skylines and colours (read only, prints)."""
import importlib.util
from PIL import Image

ROOT = 'C:/Users/pmcga/dev/hollowtide'
spec = importlib.util.spec_from_file_location('fm', ROOT + '/docs/design/great-tree-2026-10-27/final/final_mocks.py')
fm = importlib.util.module_from_spec(spec)
spec.loader.exec_module(fm)
BUILD = fm.BUILD


def hexs(c):
    return '%02x%02x%02x' % c


t = Image.open(f'{BUILD}/title_highbank_1x.png').convert('RGB')
px = t.load()
print('TITLE column samples (x: y-runs)')
for x in (20, 80, 120, 150, 180, 210, 250, 290, 305):
    runs, last, start = [], None, 0
    for y in range(216):
        c = px[x, y]
        if c != last:
            if last is not None:
                runs.append((start, hexs(last)))
            last, start = c, y
    runs.append((start, hexs(last)))
    print(x, ' '.join(f'{a}:{b}' for a, b in runs[:40]))
cnt = {}
for c in t.getdata():
    cnt[c] = cnt.get(c, 0) + 1
print('title colours', len(cnt), ' '.join(hexs(c) for c in sorted(cnt, key=lambda c: -cnt[c])))

v = fm.load_3x(f'{BUILD}/round2/13_road_vista.png')
px = v.load()
print('VISTA column samples')
for x in (60, 100, 140, 180, 220, 240):
    runs, last, start = [], None, 0
    for y in range(216):
        c = px[x, y]
        if c != last:
            if last is not None:
                runs.append((start, hexs(last)))
            last, start = c, y
    runs.append((start, hexs(last)))
    print(x, ' '.join(f'{a}:{b}' for a, b in runs[:40]))
for name in ('06_street_wayline', '05c_rise_side_west_col2_row3', '07_ferry_ward_quiet_wayline'):
    im = fm.load_3x(f'{BUILD}/round2/{name}.png')
    cnt = {}
    for c in im.getdata():
        cnt[c] = cnt.get(c, 0) + 1
    print(name, len(cnt), ' '.join(hexs(c) for c in sorted(cnt, key=lambda c: -cnt[c])[:40]))
