# Godot runtime verification

## 2026-09-25: visible Cinderhide encounter

**Result:** the corrected main scene passes a headless encounter regression in Godot 4.7.2.stable.official.ed1daf0bf. Visual presentation still needs an editor or game-window review.

### Failure reproduced

The main scene and field_creature.gd used Label2D. The installed engine reported both "Could not find type Label2D" and "Cannot get class Label2D". This prevented the encounter script from loading. The import command returned exit code 0 despite the errors, so import exit status alone is insufficient evidence.

### Repair

- scripts/field_creature.gd now types Prompt as Label.
- scenes/main.tscn uses a Label with Control offsets, supported font/outline theme overrides, and mouse filtering set to Ignore.
- Existing creature resources, battle animations, and evolution links were not changed for this repair.

### What ran

A disposable copy of the current working tree was made without .git or .godot. Godot imported that copy, then ran tests/field_encounter_smoke.gd. The regression passed 18 assertions and exited 0 with FIELD_ENCOUNTER_SMOKE_OK.

The check exercises the real main scene and input/physics path:
- Scene/script load and hidden initial UI.
- E has no effect at a distance.
- Entering the interaction area shows the prompt.
- E opens Cinderhide versus Rimefin and freezes overworld movement.
- Strike completes its existing animation and both creatures take damage.
- Flee closes battle and restores movement.
- Leaving hides the prompt; distant E stays inactive.
- Re-entering starts a fresh encounter that can also be exited.

The test sends the physical E key through Godot's input system and activates the actual battle button signals. It does not call the field interaction handler directly.

### Repeating the check

Use an imported project or another disposable copy. From PowerShell:

```powershell
& 'C:\Users\pmcga\Games\Tools\Godot_v4.7.2\Godot_v4.7.2-stable_win64.exe' --headless --path 'C:\Users\pmcga\dev\hollowtide' --script res://tests/field_encounter_smoke.gd
```

The captured run is in C:/Users/pmcga/Documents/Codex/2026-09-24/wh/verification/hollowtide-700971a2/field-encounter.log.

### Limits of this evidence

This proves encounter behavior in the installed engine, not the appearance of the prompt or battle animation. Capture probability, completed evolution lines, the route quest, and the Opal converter were not exercised by this check.

The sandboxed engine reported an inability to read the Windows root certificate store. Editor import also could not save global editor settings. No security settings were changed; the offline encounter check completed successfully.

