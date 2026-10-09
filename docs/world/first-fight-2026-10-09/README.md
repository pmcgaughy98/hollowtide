# The first fight on the levee (Claude, 2026-10-09)

**Preston, 2026-10-09:** refine the opening through the first story. The references (Coromon's lab battle right after the starter, Nexomon's woods) all test the partner choice at once; Codex's first morning ended on the levee with the September turn-based battle behind the Cinderhide and no reaction to its result. Now the Cinderhide is the first fight, in the arena, with the partner you chose and you at the controls.

## Play it
F5 now launches the opening flow (`project.godot` main scene is `scenes/opening_flow.tscn`). New Game, pick a courier, meet the dispatcher, work beside the three partners, invite one, collect the pouch, walk east onto the levee and press E at the Cinderhide. The arena opens on the grass floor: your partner (stage 1 of its line) against a wild Cinderhide, with today's controls (WASD, mouse aim, click or J, Space, 1 to 3, C). Lose and you are back on the levee with the Cinderhide still watching and a hint; win and it drops into the reeds, the road east is open.

## What changed
- `scripts/first_fight.gd` (new, Claude's): attached by the world journey in a new game. On the levee it replaces the field creature's battle screen with itself; `start(creature)` opens the arena in its own canvas layer (like Codex's relay practice), with the player's active party creature and the wild one mapped to arena lines by name; `match_over` returns to the levee, hides the beaten Cinderhide (not freed: the route's map polish looks it up), and shows a message. The world's map button hides during the fight. Prose is a proposal.
- `scripts/world_journey.gd` (Codex's; three lines): a `first_fight` var, its creation beside `partner_story`, and an `enter_area` call.
- `scripts/arena/arena_prototype.gd`: `story_mode` (debug keys F, G, T, N, B, M, R off; a plain hint line) and `signal match_over(winner)` fired 2.2 s after the result.
- `project.godot`: `run/main_scene` is the opening flow. Codex's note said the launch belongs to the opening slice; a concurrent edit had put the arena back.

## Check (`tools/debug/first_fight_check.gd`)
- Launch scene: `res://scenes/opening_flow.tscn`.
- A new game with Kithflare chosen: the first-fight script is attached; on the levee the Cinderhide's battle screen is the bridge.
- Meeting it: the arena opens with you:Kithflare against wild:Cinderhide, you steer Kithflare, story mode on, the journey paused.
- A loss: back on the levee after 2.2 s with the Cinderhide still there and the message.
- A win: back after 2.2 s, the Cinderhide gone, the won flag set, the message.
- Picker and press checks still pass (story mode is off by default).
- Stills: `fight.png`, `after_loss.png`, `after_win.png`.

## Known
- Run-local like the rest of the first morning; no save.
- The arena floor is the grass arena, not a levee; a levee floor is art work for later.
- The wild Cinderhide is stage 1 of the Ironvent line; Grok may want a weaker first opponent or a wild with a basic only.
- The old turn-based battle screen still exists on the route for direct previews; only the first-morning game uses the bridge.
