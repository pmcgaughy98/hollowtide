# Shared sel-out, Growth Shrine detail and Scroll Keeper, October 10

Preston asked to make the purposeful-building detail outlines part of sel-out, apply them to the shrine and continue the next task. Scroll Keeper is the next service in the town-finish brief. New Scroll Keeper architecture is an implemented visual proposal for his review.

## Play and result

F6 scenes/hub_town.tscn or F5 through the existing creature opening to Highbank. Scroll Keeper sits south of Market Street at (744,288), 144x120, unchanged north-facing activation tile (33,12). A scroll sign and worn north approach identify its porch. Three original source-masked door drawings open through the existing E/J/Enter service panel and door sound; Esc closes. Its leaf mask is confined to the actual original north door planks, preventing dark trim from joining the flood. No new teaching/relearning system or interior is claimed; the existing scroll service description remains.

Growth Shrine keeps its source art, footprint, fully walkable tiles, approach, inlay feedback and Claude's readiness/evolution flow. Pale stone seams and carved leaf details now receive stronger internal ink. No new creature art or palette changes.

## Shared recipe

scripts/arena/sel_out.gdshaderinc owns the shared silhouette repair, cluster cleanup and optional detail contours. Default creature application is unchanged. creature_finish.gd.apply(sprite, true) enables dark joints, material boundaries and narrow carved seams, including diagonals. Opposing brighter neighbours distinguish a fine seam from a broad shaded face. Purposeful town buildings and the shrine use this preset. The legacy building shader is a compatibility wrapper into the same source; no second copied finish to maintain. Documented in docs/art/art-direction.md for future integration. Quiet decorative scenery does not opt in.

Native comparison: all 33 current arena/dungeon south-facing creature forms render byte-exact to the old finish. Shrine's internal sample increases from 1,057 to 1,614 near-black pixels against its old building finish. Direct detailed preset and the legacy building entry point render byte-exact. Source art and all approved palette locks remain untouched.

## Provenance and scope

Scroll asset: assets/sprites/world/scroll_keeper_2026_10_10/scroll_native.png. Built-in imagegen, one call, zero Retro. Exact prompt: prompts/final-built-in.txt. Unmodified source: sources/scroll_original.png, with the generated_images original retained. Transparent safety-padding crop only (alpha>=8 content plus two source pixels), uniform nearest resize to 132x115, placement at (4,0) on transparent 144x120. Retained alpha is unchanged. No source painting, recolouring or architectural fragment compositing. Preparation metadata records source hash and dimensions.

Nine runtime files: shared shader include, creature shader wrapper / apply helper, legacy building shader wrapper, building_exteriors, growth_shrine_painter, highbank_ground_painter, new scroll_keeper_painter and new PNG. Art-direction and collaboration notes updated. Original scripts/shaders/docs archived. No hub controller/UI, layout, collision, camera, rules/state, title, creature texture or existing asset replacement. No commit/settings change.

## Verification

3 shared-render checks, 23 Scroll Keeper checks and 22 shrine checks pass. Native test captures are 1152x648. Exact ground outside bounded Scroll Keeper / north approach / contact band; all four previous foundation/sign textures and twelve door drawings exact; all thirty shrine tiles open; real walking/native E/cancel/from-approach; visible distinct door frames; source-door centre x59 on original tile centre60; actual rendered internal ink measured. Missing Scroll Keeper PNG or painter restores exact previous entire ground and retains the five prior exteriors and scroll interaction. Originals restored before installation. An initial too-wide trim-connected mask was rejected; its diagnostic capture/log are retained separately.

Review runs retain the existing root-certificate diagnostic. One final review Scroll Keeper fixture also reports two ObjectDB instances / one resource at shutdown; no production lifecycle fix is claimed. Editor import retains existing audio UID / empty-resource-save diagnostics. Live results and preservation audit added after installation.

Installed verification: all 3 shared-render, 23 Scroll Keeper and 22 shrine checks pass. Claude's full evolution check, town reachability/services and both Hall entrances pass against current live code. Final live native logs have no script/resource errors or shutdown warnings; live import exits 0 with the existing audio UID / empty-save diagnostics recorded.

Final preservation audit passes: 9,265 unowned files match their pre-install hashes, with one later inspected Claude dungeon edit retained separately by exact hash. All original art and creature assets match the task baseline; all 11 owned runtime/document files match their guarded installation hashes; initial archive copy is byte-exact. Claude's concurrent town walk cycles, Sparkwick palette-locked idle selection, boss/escort sizing and full-body shadow, builder options and trailer frame timing are preserved. Source snapshots and inspected dungeon diff are in concurrent/. The dungeon hash checked at final verification is dc062864b5ccf25efeea84a3c49a1221c3aa3ce277a160fc69ad7942e3cb87ce.

Snapshots / prompts / native checks / before-after proof / guarded manifest are included here. Fixture framing for whole exterior pictures does not change the production camera; service pictures use the actual camera. Isolated profiles and redirected capture paths preserve user settings and Claude's UI-tour captures. No organic dungeon clear or disk-save claim.

## Next

Remaining purposeful areas/services, then decorative scenery, using the shared detailed preset. Claude retains service rules/state, evolution and dungeon systems.
