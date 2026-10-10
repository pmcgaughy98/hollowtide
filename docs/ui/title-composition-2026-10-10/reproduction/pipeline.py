from pathlib import Path
W=Path(__file__).parent;prior=Path('D:/dev/hollowtide-title-refinement-20261010')
entry='''## Codex: authored title composition pass (October 10, 2026)

Preston asked for a further visual upgrade so the title looks like an authored game menu. Replaced the large main frame/header/copy card with four serif text choices, stationary pixel pointer, warm focus underline and small control footer. Existing Vollkorn/Silkscreen/regular body fonts establish typography hierarchy. A code-only lower-left forest wash provides contrast over the original village; bitmap and wordmark pixels are untouched. Options/Help have restrained frames, serif headings/actions and lighter text. Kept 16:9 window composition, raised Help to fit the type, footer hidden on subpages. No new generated art or imagegen/Retro calls.

29 actual-input native title checks and 51 full launch/menu checks pass, including wide-window rendered aspect, guide/footer/Back behavior, both New Game routes, selected team arrival and existing preferences/pause flow. Real title Quit closes its engine. Runtime scope: creature_opening.gd and title_legibility.gdshader; original script archived. Claude state/levels/learnsets/combat/audio, field pages, maps/Hall, all creature art/finishes/palettes and previous backups preserved. Isolated test profiles; no save/Continue or natural dungeon-clear claim; no commit. [Native previews, original snapshots, checks and preservation audit](ui/title-composition-2026-10-10/README.md).

Visual direction remains a proposal for Preston's review. Preserve all title routes during further art work. Field pages/Growth Shrine remain later handoff work, rules/state with Claude.

'''
for name in ['package.py','install.ps1','check_live.py','audit.py','finalize.ps1']:
    t=(prior/name).read_text().replace('hollowtide-title-refinement-20261010','hollowtide-title-composition-20261010').replace('title-refinement-2026-10-10','title-composition-2026-10-10')
    t=t.replace('passes=26','passes=29').replace("'passed':26","'passed':29").replace('77 installed','80 installed')
    if name=='package.py':
        start=t.index("entry='''")
        end=t.index("'''\nnotes=",start)+3
        t=t[:start]+"entry="+repr(entry)+t[end:]
    if name=='audit.py':t=t.replace("'village_wordmark_creatures_audio_originals'","'village_wordmark_creatures_audio_fonts_originals'")
    (W/name).write_text(t)
print('Prepared guarded composition install and reproducible verification pipeline')
