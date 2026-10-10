# Growth Shrine, October 10

Preston prioritized the place where creatures evolve. Finished original open-air shrine art and presentation around Claude's already working readiness, confirmation, evolution scene and carried record. Visual architecture is an implemented proposal for Preston's review.

## Play

F6 scenes/hub_town.tscn, or reach Highbank from F5. South of Market Street near Home: moss/root-framed low limestone dais, purple mineral leaf inlays, north stepping stones. The existing activation tile is (7,12). E/J/Enter opens the existing shrine response; if ready, E confirms evolution and Esc cancels. Fixed the misleading confirmation footer that previously said E close. No change to which creature is eligible, which moves it keeps or how it evolves.

The 144x120 clearing remains at (96,288). All thirty tiles are open. A low-relief separate sprite stays beneath creatures; no new doorway or collision. Source art uses the unchanged building detail shader for near-black contours throughout stone/root detail. Contact shadow and a small worn approach join the north entrance to the existing street. An original small three-leaf inlay on the activation tile settles to active with growth/evolve_ask/growth_done/evolving_now, then to dormant after closing. Reads existing services rather than an absent panel ID. Existing finished-exterior hook suppresses only the shrine's floating plaque.

## Source and scope

Built-in imagegen, one generation, zero Retro. Final project asset: assets/sprites/world/growth_shrine_2026_10_10/shrine_native.png. Exact tool prompt: prompts/final-built-in.txt. Unmodified source: sources/shrine_original.png; original generated_images output also retained. Preparation only crops transparent safety padding (alpha>=8 content plus two source pixels), uniformly nearest-resizes to 136x113, then places at (4,3) on transparent 144x120. Alpha in the crop is preserved; no painting, recolouring or architectural fragment compositing. asset-preparation.json records hashes/dimensions. Contact grounding and small entrance-inlay frames are original code-native textures.

Runtime: new shrine PNG and growth_shrine_painter.gd; shrine-only branches in building_exteriors.gd and highbank_ground_painter.gd; one HUD footer conditional in hub_town.gd. Collaboration note prepended. Archived original scripts and current pre-install notes. Layout, paths, camera, evolution.gd / evolution_scene.gd / team_state.gd, dungeon rules, title, UI style, all creature sprites/palette locks and older archives retained. No commit/settings change.

## Verification

22 native shrine checks pass: all ground outside Rect2i(96,264,144,144) exact, all four prior service signs/foundations and twelve door textures exact, dimensions/position/finish, all thirty tiles open, transparent corners, actual walking and native E from tile and approach, not-ready/ready/cancel and inlay state. Missing art and missing painter physically tested separately: exact previous entire ground returns, prior four exteriors and evolution service work. One missing-painter fixture reports two ObjectDB instances / one resource at shutdown; no production lifecycle fix claimed.

Claude's evolution check passes confirmation, intro/whiten/trade/reveal/done stages, new form on carried record and street, moves preserved, and a waiting move offered on the next run. Existing town and paired Hall entrance checks pass. Isolated test profiles and redirected screenshots protect user saves and Claude's UI-tour captures. Review native runs retain the existing certificate diagnostic; import retains existing stale audio UID / empty-resource-save diagnostics. No organic dungeon clear or disk-save claim.

Native 1152x648 captures in review/: shrine_exterior uses fixture framing for the whole clearing; shrine_ready and shrine_not_ready use actual camera. Evolution captures are from Claude's unchanged scene, not newly authored.

Installed verification: all 22 shrine checks pass, Claude's complete evolution check passes, and existing town / paired Hall entrance checks pass. These final live native logs have no script/resource errors or shutdown warnings. Live import exits 0 with the pre-existing audio UID / empty-resource-save diagnostics retained.

Preservation audit: 9,265 unowned pre-install files match exactly; all original art and creature assets match the task baseline. Five runtime files and the collaboration note match their guarded installation hashes. Archive copy is byte-exact. Claude's concurrent dungeon VFX pass (new essence feedback, hit-stop, rings/sparks, healing/level/ready motes and outlined damage numbers) is retained and the live evolution check runs against that version. See installation.json and the retained concurrent source snapshot.

## Next

Scroll Keeper resumes the town-finish order. Claude owns the shrine eligibility/state, rules and evolution scene. Keep purposeful internal contours stronger than decorative scenery.
