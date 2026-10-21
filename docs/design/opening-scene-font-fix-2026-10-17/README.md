# Opening scenes load again, October 17, 2026

The recent font change removed `TITLE_FONT` from `scripts/main_menu.gd`. Its subclass `main_menu_art_preview.gd` still referenced it in `_build_wordmark`, so that script could not parse. `opening_flow.gd` inherits it, and `creature_opening.gd` inherits `opening_flow.gd`; both scenes therefore reported an unresolved base class.

Exactly one source line changed in `scripts/main_menu_art_preview.gd`:

```gdscript
var font: FontFile = (load(UI.TYPE["display"]["file"]) as FontFile).duplicate()
```

This takes the source font from the current shared display role. `UI.font()` returns a `FontVariation`, so casting that helper result to `FontFile` was not valid; the first native test exposed it and the final fix uses the source path. The existing wordmark shader, sizes, smoothing options and scene inheritance remain intact. Original bytes, final one-line diff and installed source are archived here.

## Verification

- Installed **Summer Engine** native OpenGL run: **10/10**, no script errors/warnings. Both PackedScenes load, attach their scripts, build wordmarks/buttons and pass their preludes to the actual menus. The legacy scene correctly has three buttons without a save; the campaign title has four. The fixture's initial four-button assumption for the legacy scene was corrected, without changing the game.
- Reviewed screenshots: [legacy courier menu](captures/opening_flow-menu.png), [current creature campaign menu](captures/creature_opening-menu.png). Prelude captures are beside them. No headless rendering is offered as visual proof.
- Existing `tools/debug/ui_fit_check.gd`: **30 assertions pass, 0 failed**. Its headless run also emitted dungeon custom-sampler shader and exit-resource diagnostics; these are retained in [ui-fit.log](ui-fit.log). The native Summer title verification is clean.
- [Receipt](receipt.json): one changed source line; **540 other protected files exact**, including current Grok/Claude source changes and `project.godot`. All runs used D-work APPDATA/LOCALAPPDATA and a private save path. No real save, art, rules, scene composition or setting changes.

The first standalone `--check-only` diagnostic also complained about `DialogueManager` because that route did not supply the project singleton. Full project boot was used to reproduce the actual inherited-class error. The direct base-script parse identified the missing `TITLE_FONT`. Diagnostic attempts are preserved rather than labelled successful.

## Open in Summer

Open the live project at `C:/Users/pmcga/dev/hollowtide/project.godot` and reopen `res://scenes/creature_opening.tscn` for the current campaign title. `res://scenes/opening_flow.tscn` is the older human-courier launch. Both build much of their interface in code when played, so the static editor tree contains only the root node; play the selected scene to see the complete menu.

[Exact successful Summer/UI-fit commands](verification-commands.json), [native driver](verify_scenes.gd), [original source](original-main_menu_art_preview.gd), [final diff](fix.diff). No changes were committed.
