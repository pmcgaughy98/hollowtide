from pathlib import Path
import hashlib, json, re, shutil, subprocess, sys

W = Path(__file__).parent
L = Path('C:/Users/pmcga/dev/hollowtide')
E = L / 'docs/art/arena-fronts-2026-10-26'
TEAM = L / 'docs/team/CODEX_HANDOFF_2026-10-26_arena_fronts.md'
QUEUE = L / 'docs/team/CODEX_TASKS_2026-10-26.md'
COLLAB = L / 'docs/AI_COLLABORATION.md'
MARK = '## Codex result, October 26: C22 arena fronts in assets'

def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

subprocess.run([sys.executable, str(W / 'verify.py')], check=True)
assert MARK not in QUEUE.read_text(encoding='utf-8-sig'), 'Already published'
assert not E.exists(), 'Evidence destination already exists'
assert not TEAM.exists(), 'Handoff already exists'

# Fresh notes snapshots preserve any other agent's updates before our addition.
for p in (QUEUE, COLLAB):
    d = W / 'docs-before-publication' / p.relative_to(L)
    d.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(p, d)

# Only evidence and disposable fixture sources, never profiles or real saves.
E.mkdir(parents=True)
for p in W.iterdir():
    if p.is_file():
        shutil.copy2(p, E / p.name)
for name in ('originals', 'prepared', 'runner', 'asset-pack-per-form-probe', 'docs-before-publication'):
    shutil.copytree(W / name, E / name, ignore=shutil.ignore_patterns('.godot', '__pycache__'))

handoff = (W / 'HANDOFF.md').read_text(encoding='utf-8')
TEAM.write_text(handoff, encoding='utf-8')
(E / 'HANDOFF.md').write_text(handoff.replace('../art/arena-fronts-2026-10-26/README.md', 'README.md'), encoding='utf-8')

result = '''

## Codex result, October 26: C22 arena fronts in assets

COMPLETE/INSTALLED. Sixteen existing chosen fronts (121,988 PNG bytes) now have byte-identical runtime copies at `res://assets/sprites/arena/<form>/front_chosen.png`. Per-form folders keep palette/cleanup tools compatible. All 486 original docs form files remain hash-exact. Board fallback already repointed; its only edits are the path/comment, preserving Claude's dirty Tower dialogue, Layout.way_to routing, directional-set preference and 66px sizing. No further repoint needed. Export preset now excludes docs/*; no literal runtime res://docs/ reference remains in scripts/scenes/data/dialogue. [Native comparison, manifest, sources, hashes and logs](../art/arena-fronts-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_arena_fronts.md).

Native 52/52 and asset-only PCK 49/49 clean for final per-form paths: source/fallback pixels identical, imported textures work through exact UI.res_image without raw PNGs, docs sentinel excluded. Maintained board_scene PASS; known raw 4 ObjectDB/2-resource exit warnings retained, no clean-teardown claim. Source issue for Claude: mirekit/whinet had no chosen front filename in original docs; current directional sets verified usable, no alias or art selection invented. Full Windows game export/painted street/Home desk/board/Hollow/cache/EXE-icon QA still pending templates under C11; asset-only PCK does not close it or enable exported town_room worker art. Next FX-01 empty Sail Slash/Mark Glyph frames. C6 OFF, town/exterior HOLD. No generation/paid art/real save/rules/Route1/message/commit; Codex review, Preston approval not claimed.
'''
old_queue = QUEUE.read_bytes()
QUEUE.write_bytes(old_queue + result.encode('utf-8'))
old_collab = COLLAB.read_text(encoding='utf-8-sig')
heading = '# Working Together on Hollowtide'
assert old_collab.startswith(heading)
note = '''

## Codex: C22 arena fronts relocated and wired (October 26, 2026)

C22 COMPLETE/INSTALLED. 16 chosen fronts, 121,988 bytes, unchanged file/RGBA data at res://assets/sprites/arena/<form>/front_chosen.png; board fallback already repointed, only path/comment changed, Claude's dirty edits preserved. All 486 docs originals retained/hash-exact, per-form maintenance compatible. Export preset excludes docs/*, no literal runtime res://docs/ references remain in scripts/scenes/data/dialogue. Native 52/52 and asset-only imported-texture PCK 49/49 clean; maintained board_scene PASS with known raw 4 ObjectDB/2-resource exit warnings retained. [Gallery, manifests, source diff and logs](art/arena-fronts-2026-10-26/README.md); [handoff](team/CODEX_HANDOFF_2026-10-26_arena_fronts.md). Mirekit/Whinet had no chosen front filename originally; their current directional sets work, no alias invented. C11 full Windows export/painted-art/cache/EXE-icon QA still pending templates; exported town_room worker-art gate stays. Next FX-01 empty attack frames. C6 OFF, town/exterior HOLD. No paid/generative art/real save/rules/Route1/message/commit; Codex review only.
'''
COLLAB.write_text(heading + note + old_collab[len(heading):], encoding='utf-8')

# Verify copied evidence and local documentation links, then guard owned sources again.
for name in ('README.md', 'HANDOFF.md'):
    p = E / name
    for target in re.findall(r'\]\(([^)]+)\)', p.read_text(encoding='utf-8')):
        if '://' not in target:
            assert (p.parent / target).exists(), (name, target)
for rel, expected in json.loads((W / 'installed-files.json').read_text()).items():
    assert sha(L / rel) == expected, rel
for name in ('manifest.json', 'verification.json', 'source.diff', 'native-fallback-comparison.png', 'arena-fronts-probe.pck'):
    assert sha(E / name) == sha(W / name), name
assert QUEUE.read_bytes().startswith(old_queue)
assert COLLAB.read_text(encoding='utf-8').endswith(old_collab[len(heading):])
receipt = {'evidence': str(E), 'handoff': str(TEAM), 'queue_appended': True, 'collaboration_prepended': True, 'owned_hashes_match': True, 'links_exist': True}
(W / 'publication.json').write_text(json.dumps(receipt, indent=2), encoding='utf-8')
shutil.copy2(W / 'publication.json', E / 'publication.json')
print(json.dumps(receipt, indent=2))
