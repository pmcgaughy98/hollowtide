# Scroll Keeper cellar entrance

Preston requested a trapdoor because the former upright door appeared to lead nowhere above a mostly-roof building. The entrance is now a recessed limestone stairwell descending south beneath the moss roof. A wooden lid closes over it, lifts, then folds back toward the roof when the existing Scroll Keeper service opens.

The north approach, tile (33,12), 144x120 footprint at (744,288), scrolling sign and shared sel-out remain. This is exterior presentation; the existing description panel still serves the interaction, with no basement scene or new teaching rules.

Two built-in imagegen edits, zero Retro calls. First stair direction rejected; final treads darken toward the south/roof. Generated sources are preserved unmodified in sources/. Exact prompts: prompts/exact-built-in-prompts.json. Preparation: transparent-padding crop and uniform nearest resize only, recorded in preparation.json. Original installed Scroll Keeper sprite and all earlier archives remain unchanged.

Native checks exercise walking, E, service sound, lifting/open/closing states, actual visible stair reveal, footprint, near-black detail ink, unchanged other four services and all twelve prior door textures, plus all ground outside bounded Scroll Keeper. Native captures in review/ show closed, lifting, folded-back and the existing service. Checks/logs and guarded install manifest are archived here; installation.json records preservation verification after live checks.

Runtime scope: building_exteriors.gd plus assets/sprites/world/scroll_cellar_2026_10_10/scroll_native.png. No controller, layout, shader, shrine, title, state, creature or palette changes. Concurrent Claude changes preserved. No commit.

Review fixture reports the pre-existing root-certificate diagnostic. One repeated capture run also reported two ObjectDB instances and one resource in use at shutdown; other runs completed without those shutdown messages. No production lifecycle fix is claimed.

Installed result: live Godot import completed (existing stale audio UID / empty-resource-path editor diagnostics retained); native live run passed all 25 checks with no errors or warnings. Preservation audit: 9,559 unowned protected files exact, all original asset and creature hashes exact, no archive mismatches and all three scoped installed files match the manifest.
