from pathlib import Path
import hashlib,json,shutil,re
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');F=R/'docs/design/opening-scene-font-fix-2026-10-17';owned='scripts/main_menu_art_preview.gd'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,s):p.write_bytes(s.replace('\r\n','\n').replace('\n','\r\n').encode('utf-8'))
baseline=json.loads((W/'protected-before.json').read_text());changes=[p for p,h in baseline.items() if sha(R/p)!=h];assert changes==[owned],changes
original=(W/'original-main_menu_art_preview.gd').read_bytes();expected=original.replace(b'(TITLE_FONT as FontFile).duplicate()',b'(load(UI.TYPE["display"]["file"]) as FontFile).duplicate()',1);assert (R/owned).read_bytes()==expected
native=(W/'summer-scenes.log').read_text();assert 'OPENING FIX: 10/10' in native and not any(s in native for s in ['ERROR','WARNING','FAIL'])
ui=(W/'ui-fit.log').read_text();assert 'ui fit: all ok (0 failed)' in ui
assert not F.exists();F.mkdir(parents=True);write(F/'.gdignore','')
for name in ['original-main_menu_art_preview.gd','fix.diff','protected-before.json','commands.json','boot-commands.json','verification-commands.json','opening_flow-godot-parse.log','creature_opening-godot-parse.log','opening_flow-boot.log','creature_opening-boot.log','main_menu-parse.log','main_menu_art_preview-parse.log','summer-scenes.log','ui-fit.log','first-attempt-summer-scenes.log','fixture-button-count-attempt.log','check.py','boot.py','base_parse.py','fix.py','refine_fix.py','verify_scenes.gd','verify.py','document.py']:
    shutil.copy2(W/name,F/name)
shutil.copytree(W/'captures',F/'captures')
shutil.copy2(R/owned,F/'installed-main_menu_art_preview.gd')
ui_count=len(re.findall(r'^ok    ',ui,re.M))
receipt={'date':'2026-10-17','existing_changed':[owned],'protected_total':len(baseline),'other_files_exact':len(baseline)-1,'exact_single_replacement':True,'summer_native_checks':'10/10','summer_native_log_clean':True,'ui_fit_assertions_passed':ui_count,'ui_fit_headless_diagnostics':'Dungeon custom-sampler shader and exit resource diagnostics are retained in ui-fit.log; not used as render proof.','private_profiles':True,'real_player_save_untouched':True,'generations_commits':False}
(F/'receipt.json').write_text(json.dumps(receipt,indent=2),encoding='utf-8')
summary=f'Fixed both opening scenes failing to load after the October16 menu font update: main_menu_art_preview.gd still referenced removed TITLE_FONT. One line now reads the shared display role\'s source FontFile (UI.TYPE["display"]["file"]); the wordmark retains its existing pixel renderer. Both scenes loaded, built wordmarks/buttons and passed their preludes into menus in installed Summer Engine: native10/10, clean log and reviewed screenshots. UI-fit{ui_count} assertions pass; its headless dungeon shader/exit-resource diagnostics are archived separately. All{len(baseline)-1} other protected current source/scene/data/dialogue/project files exact; Grok and Claude changes preserved, private saves/profiles only. Evidence and original source: docs/design/opening-scene-font-fix-2026-10-17/README.md. Current campaign entry remains creature_opening.tscn; opening_flow.tscn is the legacy courier opening. No new art, game rules, settings or commit.'
readme=f'''# Opening scenes load again, October 17, 2026

The recent font change removed `TITLE_FONT` from `scripts/main_menu.gd`. Its subclass `main_menu_art_preview.gd` still referenced it in `_build_wordmark`, so that script could not parse. `opening_flow.gd` inherits it, and `creature_opening.gd` inherits `opening_flow.gd`; both scenes therefore reported an unresolved base class.

Exactly one source line changed in `scripts/main_menu_art_preview.gd`:

```gdscript
var font: FontFile = (load(UI.TYPE["display"]["file"]) as FontFile).duplicate()
```

This takes the source font from the current shared display role. `UI.font()` returns a `FontVariation`, so casting that helper result to `FontFile` was not valid; the first native test exposed it and the final fix uses the source path. The existing wordmark shader, sizes, smoothing options and scene inheritance remain intact. Original bytes, final one-line diff and installed source are archived here.

## Verification

- Installed **Summer Engine** native OpenGL run: **10/10**, no script errors/warnings. Both PackedScenes load, attach their scripts, build wordmarks/buttons and pass their preludes to the actual menus. The legacy scene correctly has three buttons without a save; the campaign title has four. The fixture's initial four-button assumption for the legacy scene was corrected, without changing the game.
- Reviewed screenshots: [legacy courier menu](captures/opening_flow-menu.png), [current creature campaign menu](captures/creature_opening-menu.png). Prelude captures are beside them. No headless rendering is offered as visual proof.
- Existing `tools/debug/ui_fit_check.gd`: **{ui_count} assertions pass, 0 failed**. Its headless run also emitted dungeon custom-sampler shader and exit-resource diagnostics; these are retained in [ui-fit.log](ui-fit.log). The native Summer title verification is clean.
- [Receipt](receipt.json): one changed source line; **{len(baseline)-1} other protected files exact**, including current Grok/Claude source changes and `project.godot`. All runs used D-work APPDATA/LOCALAPPDATA and a private save path. No real save, art, rules, scene composition or setting changes.

The first standalone `--check-only` diagnostic also complained about `DialogueManager` because that route did not supply the project singleton. Full project boot was used to reproduce the actual inherited-class error. The direct base-script parse identified the missing `TITLE_FONT`. Diagnostic attempts are preserved rather than labelled successful.

## Open in Summer

Open the live project at `C:/Users/pmcga/dev/hollowtide/project.godot` and reopen `res://scenes/creature_opening.tscn` for the current campaign title. `res://scenes/opening_flow.tscn` is the older human-courier launch. Both build much of their interface in code when played, so the static editor tree contains only the root node; play the selected scene to see the complete menu.

[Exact successful Summer/UI-fit commands](verification-commands.json), [native driver](verify_scenes.gd), [original source](original-main_menu_art_preview.gd), [final diff](fix.diff). No changes were committed.
'''
write(F/'README.md',readme)
for rel in ['docs/AI_COLLABORATION.md','docs/team/CODEX_START_HERE_2026-10-14.md']:
    p=R/rel;backup=F/'before-docs'/p.name;backup.parent.mkdir(exist_ok=True);shutil.copy2(p,backup);t=p.read_text(encoding='utf-8')
    if 'AI_COLLABORATION' in rel:
        first=t.index('\n')+1;t=t[:first]+'\n## Codex: opening scenes repaired after font update (October17,2026)\n\n'+summary+'\n'+t[first:]
    else:t=t.replace('## Current status\n\n','## Current status\n\nOctober17 opening repair: '+summary+'\n\n',1)
    assert p.read_bytes()==backup.read_bytes();write(p,t)
write(R/'docs/team/CODEX_HANDOFF_2026-10-17_opening_fix.md','# Opening scene repair, October17,2026\n\n'+summary+'\n\nUser\'s scene-opening issue takes priority over the creature-view queue; no creature task is marked complete by this fix. October14 facing-audit work remains in D:/dev/hollowtide-creature-facing-audit-20261014 and has not been published. The prepared feedback pack was also set aside before browser verification; it is not a completed delivery.\n')
print(json.dumps(receipt,indent=2))
