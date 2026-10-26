# Grok tasks, 2026-10-26

One clean list for today. It replaces the stacked "Pass 3" to "Pass 7" sections in
[GROK_TASKS_2026-10-22.md](GROK_TASKS_2026-10-22.md), which kept repeating the same questions. Every file and line below
was rechecked on 2026-10-26.
- Nobody changed your numbers in the seven factory passes (stats, EXP, learnsets, spawns, damage).
- Claude applies any table you hand over unchanged, then reruns `python tools/debug/run_checks.py pilot dungeon_chain lv1 move_table`.
- House rules: no em-dashes. Use the house words (Sense, nest, Second Wind, went down, Postmaster, Hollow).
- List any "source issues for Claude" in your result.

## Balance and rules (yours to decide)

**1. Hollow Mouth for a brand-new player.** This one first; it is the biggest open question.
- **Spawns:** `scripts/dungeon/dungeon.gd`, `DUNGEONS["mouth"]["spawns"]`. Today it reads
  `{1: [[7, 0], [103, 0]], 2: [[7, 0], [103, 0]], 3: [[7, 0], [10, 0], [103, 0]], 4: [[7, 0], [10, 0], [103, 0]]}`.
  That is Listener and Skimlet on every floor, plus Troughspine from B3F.
- **Monster-house roll:** the shared recipe at `dungeon.gd:297` (`"monster_house": 0.3`) also applies to B1F and B2F.
  Keep the roll there, drop it, or drop it until the Mouth has been cleared once.
- **Autopilot rest:** `REST_TO` at `dungeon.gd:51` (`0.7`).
- **What was measured:**
  - A level 1 leader that only bumps clears the Mouth about 1 time in 5 or 6. Over 30 seeds, the clears were 4 to 7 depending on the build.
  - In pass 6's live re-shoot, a level 1 team rolled 7 monster-house ambushes and went down 4 times before clearing.
  - Read `lv1_run` as a rate over many seeds, not seed by seed (see 9).

**2. The pilot story's two Hollow spawn rows.** In `docs/design/pilot-story-2026-10-10.md`, the table under "Who lives
where" still says:
- B1F: Listener, Troughspine, Skimlet.
- B2F: Listener, Troughspine, Ozbender, Valvekin.

The code (`DUNGEONS["hollow"]["spawns"]`) runs:
- B1F: Listener and Skimlet.
- B2F: Ozbender, Valvekin and Troughspine.

Rewrite the rows to match the code and put your 2026-10-12 reason under the table, replacing the "stale" line at 70. If
the code should change instead, say so.

**3. Status moves.** Say which of the 13 zero-damage moves in the learnsets belong in the dungeon. Each now has a
self-effect or the essence ring, so none is silent. The rest come out of the learnsets.

**4. `data/moves/fire_move.tres`.** It still exists. Delete it, or give it a real name.

**5. Three placeholder move names:** Lantern Tackle, Verdant Roar and Ember Feint.
- They are in `scripts/arena/arena_prototype.gd`: "Verdant Roar" at line 59, and `ember_feint` in Kithflare's and
  Sparkwick's kits at lines 116 and 119.
- Name them before the Training Yard opens. The Yard is shut for now.

**6. Body gate.** `move_table_check` now fails the suite if any kit move fails the body-part gate. Confirm that matches
`docs/creatures/DESIGN_RULES.md` (2026-10-02).

**7. Job Board clients.** Today a client can come from another floor's spawn list. For example, Preostmar, a B3F
creature, posts a B1F job.
- Should a client come from the job's own floor list, or only from creatures the team has met?
- Claude has a held line that keeps each client on its own floor. It goes in on your yes.

**8. The Guardian passive.** No creature carries it now (Starward's passive is the punch Chain). Does it come back? If
not, Claude drops its printed-only step from `arena_protector_check`.

**9. A separate random source for gameplay.** Fights and later floors share Godot's random generator with camera
shake and particles. Any change in frame counts reshuffles every roll, so `lv1_run`'s table moves between builds even
though no rule changed.
- The fix: Claude gives gameplay its own generator, so seeds replay the same way.
- That changes which rolls come up, so it needs your yes first.

**10. Later, no rush:**
- One in-world line per creature description, before any entry screen ships.
- Whether `dual_essence_check` stays as your print tool or retires.

**For your information (no answer needed):** the Warden's defeat branch used to grant its boss EXP once for every hit
that landed at 0 HP, up to three times a win. Pass 7 grants it once, as written.

## Art (new, coming later today)

Preston, 2026-10-26: Grok will generate **non-creature placeholder art**: HUD pieces, lamps, UI, character sprites,
props and similar. Creatures stay out.
- Claude is wiring every visual into the code first as a named art slot. Each slot gets an exact spec: pixel size,
  anchor, palette, light direction, outline rule and states. Each also gets a reference picture of its coded
  placeholder, so you see exactly what to make.
- Your art list will be `docs/team/GROK_ART_TASKS_2026-10-26.md`. It is generated from those slots once the design is
  done. Until then, please hold off on art, so nothing comes out at the wrong size the way the town buildings did.
- Tool: `tools/grok_image.py`. It runs one image per run, in a sealed folder holding only its style reference.
- Prompt rules: put the honesty line first, nothing from any existing franchise, and no text in images.
