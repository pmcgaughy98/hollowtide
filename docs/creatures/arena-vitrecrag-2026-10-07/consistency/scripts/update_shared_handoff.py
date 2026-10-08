"""Prepend the completed Vitrecrag material handoff from verified installed evidence.

Run only after finalize_vitrecrag_evidence.py succeeds. The existing guide is read
at the time of writing and retained in full. A snapshot of that exact pre-write
guide is archived. No art, game code, settings or history is replaced.
"""
from pathlib import Path
import json

P = Path('C:/Users/pmcga/dev/hollowtide')
A = P / 'docs/creatures/arena-vitrecrag-2026-10-07/consistency'
guide = P / 'docs/AI_COLLABORATION.md'
proof = json.loads((A / 'final-verification.json').read_text(encoding='utf8'))
changes = json.loads((A / 'changed-files.json').read_text(encoding='utf8'))
assert proof['runtime']['fresh_capture_count'] == 8
assert not proof['runtime']['script_errors'] and not proof['import']['script_errors']
assert proof['installed_report_summary']['structural_and_palette_pass']
title = '## Codex: Vitrecrag line arena brick and crater consistency installed (October 7, 2026)'
before = guide.read_bytes()
text = before.decode('utf-8-sig').replace('\r\n', '\n')
assert title not in text, 'Completed entry already exists; inspect instead of duplicating it'
snapshot = A / 'AI_COLLABORATION-before-entry.md'
assert not snapshot.exists(), 'Guide snapshot exists; inspect instead of overwriting it'
snapshot.write_bytes(before)
entry = f'''{title}

Preston asked to fix the newly introduced Fusern/Slagglass/Vitrecrag arena line, especially Fusern's pale-orange shell views and lost brick texture. Fusern E/NE/N/NW now use the approved dark burnt-brick faces and mortar; E/NE/N walks receive the same material repair. Restored NW interior brick courses from the accepted dark W facing inside an audited 548-pixel island (349 RGB pixels changed); existing exterior courses, eyes, lower band and legs remain exact. Slagglass keeps its dark glass plates. Vitrecrag walks keep copper shell seams and a consistent approved rust-to-gold crater material, removing frame-to-frame white-hot seam and crater color drift. All output colors belong to each form's own approved base.

Installed {changes['active_png_count']} active PNG changes, rebuilt only these three forms through the unchanged named-form small-sprite pipeline. Canvases, poses, outer silhouettes, foot rows and facing assignments stay exact. Filled exactly 2,886 transparent crater pixels in 11 fully enclosed components in Vitrecrag's S/SE/E source walks; original alpha is exact everywhere else. The reporter explicitly validates that bounded exception and retains its previous artifact-removal behavior. Preserved {proof['original_pngs_preserved']} original art PNGs and {proof['initial_native_captures_preserved']} initial captures. All 72 derived walk mirrors and 216 exact game-pipeline checks pass; {proof['other_form_asset_guards']} previous-twelve arena assets and all reviewed code/settings guards except the explicitly extended reporter stay byte-identical. No paid calls, game-code edits or commit. Claude's concurrent ability/control updates were read and preserved; the current picker, keys 1–4 abilities and SPACE team switching remain current.

Godot 4.7.2 import and runtime checks exited 0 with zero script errors and eight fresh verified stills. Actual import/runtime diagnostics are retained in the report; this art pass does not resolve unrelated audio/import/shutdown issues. Whole-form brightness spread and fixed upper-dome texture measures are reported honestly, including Fusern's remaining spread above 8 because dark mortar contrast is preserved. Original generated pose/anatomy variations remain. [Exact changed files, originals, accepted masks/scripts, contacts/GIFs, material tables and native evidence](creatures/arena-vitrecrag-2026-10-07/consistency/README.md).

'''
heading, sep, remainder = text.partition('\n')
assert heading == '# Working Together on Hollowtide' and sep
guide.write_text(heading + '\n\n' + entry + remainder.lstrip('\n'), encoding='utf8')
assert guide.read_text(encoding='utf8').endswith(remainder.lstrip('\n'))
print('Added completed evidence-derived entry; entire previous guide retained.')
