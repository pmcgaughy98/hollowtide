# Claude's next Hollowtide work: battle framing and creature state

**2026-10-02.** This shift note is older than the creature rules. Read the top of `docs/AI_COLLABORATION.md` first. `PartyMember` now also keeps that run's known moves after an evolution. The win trigger is already the rule for any form with a link. HP between battles and saving are still the open job in section 2. Grok now owns future creature and move rules in `docs/creatures/DESIGN_RULES.md`. Grok still does not draw creature sprites. Codex still has Route 1.

**Prepared 2026-09-27 for Claude's next available session.** Preston asked which research-backed tasks should get attention when Claude's usage resets. This is a handoff proposal, not a change to the game or a command from Gemini. Preston's current direction and approved art remain authoritative.

## Decision

Prioritize **battle presentation architecture**, then **owned-creature state and saves**. Give the UI a targeted legibility pass within the existing HUD. Grok owns new environment and non-creature art; Codex can apply precise resource, script, and asset changes after the architecture is clear.

## 1. First task: battle-stage layout for giant and ordinary creatures

The approved Vitrecrag front is 128×128 in `assets/sprites/creatures/vitrecrag_official.png`; its approved matching rear is linked in `data/creatures/108_vitrecrag.tres`, and `battle_size` remains 1.75. A prior preview showed impressive mass but legs behind the lower dialogue HUD and shell near the upper HP area. The current `scripts/battle_screen.gd` builds the stage and HUD at hard-coded points in a 1152×648 view. It already has `FocusStage`, `BattleStage`, continuous HP fills, attack focus, effects, and shake. Preserve those behaviors and the player's preferred impact timing.

Claude: design a constrained layout model for the foe and partner that uses each sprite's *visible bounds and foot line*, reserves HUD-safe rectangles, and keeps the size difference legible without flattening all creatures to one height. Specify how the resting positions, temporary focus movement, and attack effects can stay inside those bounds. Account for integer or half-step nearest-filtered zoom and the actual 128×128 Vitrecrag art. Avoid replacing the existing focus rig with Camera2D or SubViewport merely because the research report mentions them. The report incorrectly describes the live battle stage as a separate world CanvasLayer; inspect the real `battle_screen.gd` tree before proposing draw-order changes.

Start with a concise design note and then implement the smallest clear refactor that fixes the observed clash. Keep the current Hollowtide slate and river-metal HUD, name headers, exact-percentage HP bars, Turbo Green `#1B8E78` at full health, yellow/orange medium and red low. The battle font pass now uses Alegreya Sans SC for names and commands, Vollkorn for narration, and Silkscreen for HP numbers; preserve this hierarchy unless a played review reveals a concrete issue. Design a visual review for one ordinary opponent and Vitrecrag, both sides of battle, including move impact. No new creature art should be inferred from this task; preserve the approved Vitrecrag front and rear.

Research inputs: `C:/Users/pmcga/Downloads/Large 2D Creature Battle Presentation.docx`, `Creature Scale Proposal Audit.docx`, and `docs/research/gemini-research-2026-09-27-adoption.md`. The reports' specific 100×100 Vitrecrag assumption and camera instructions are out of date.

## 2. Second task: individual party state and persistence design

The game currently stores each owned creature as a `PartyMember` containing only a `CreatureData species` reference. `PlayerParty` holds the run-local collection and active slot. `BattleScreen` holds HP inside the battle; `CreatureData` carries shared base stats, moves, evolution, and art. The opening-chapter plan calls for an owned creature to retain its HP and progression across encounters. This is a system-design job before adding more routes or dozens of species.

Claude: propose and implement an incremental `PartyMember` state model for current HP, level, experience, and selected move state; specify how battle entry/exit, capture, switching, fainting, and evolution update *one individual*. Keep `CreatureData` as immutable species data at runtime. Define a versioned save representation and migration/default behavior for the current unsaved prototype. Distinguish approved gameplay rules from placeholders rather than inventing a full level curve or economy. Preserve the existing six-slot party and the Cinderhide → Clinkerhide → Ironvent evolution path. River Listener's guard/interrupt kit is approved in principle, but it does not require a new creature resource or arbitrary balance values in this task.

Reference: `docs/world/opening-chapter-production-path.md`, `scripts/party_member.gd`, `scripts/player_party.gd`, `scripts/battle_screen.gd`, and `docs/battle/defensive-move-rules-draft.md`.

## 3. Later: reusable first-route state

After the battle and owned-creature state work, review `scenes/first_route_prototype.tscn` and `scripts/first_route_prototype.gd` as the first complete courier journey. Extract only interaction/report state that a second habitat will actually reuse. Keep the flood cause unresolved and the two-note river call ambiguous. The scene is still separate from the main start scene, and the full loop has not been reviewed end to end.

## Focus by collaborator

- **Claude:** scene and battle architecture, individual creature lifecycle, save format, serialized Godot trees, complex GDScript.
- **Codex:** exact guarded file edits, resource wiring, asset imports, API and data consistency.
- **Grok:** original non-creature environment and HUD art, firsthand-source leads, balance/economy research. The color report suggests a quieter soil/timber/river world palette; the route currently reads too much like a Game Boy-era monster game to Preston.
- **Preston:** visual decisions and final approvals, especially battle framing and new creature images.

## Research limits

The four latest Gemini reports are useful research and proposals, not game canon. `Hollowtide Color System Proposal.docx` supports reserving Turbo Green for full-health UI and testing contrast, but the current health gradient already does this. Its exact essence ramps are contact-sheet candidates, not mandatory recolors. `Creature Scale Proposal Audit.docx` supplies useful distinctions among height, body length, shell extent, and battle presentation but no binding mass values. `St. Joseph History And Lore.docx` offers Wayline and river-story leads; do not turn contested historical claims into dialogue without primary-source checks. See `docs/research/gemini-research-2026-09-27-adoption.md` for the accepted/deferred list.
