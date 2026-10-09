# Recruiting (Claude, 2026-10-09)

**Preston, 2026-10-09:** "Do recruiting next." This is slice 5 of the pivot. The structure comes from Red Rescue Team and Explorers of Sky; nothing is copied. The rates are drafts for Grok.

## How it works (`scripts/dungeon/dungeon.gd`)
- When your team beats a wild creature, it may get back up and ask to come along. The chance is 30% for a stage 1 creature, 15% for stage 2 and 6% for stage 3. It works the same after a turn fight or a real-time battle.
- A panel asks the question. **Y** welcomes it, **N** lets it go. Answering costs no turn, and nothing else happens until you answer.
- **Welcomed** with room on the team (four at most), it joins at half health, follows in the chain, and goes down the stairs with you.
- **Welcomed** with a full team, it waits at the courier hall's roster.
- **The run's recruits are only kept if you clear the run.** Fainting loses them and the roster entries, the same way it loses the bag.
- The autopilot always says yes.

## Check (`tools/debug/dungeon_recruit_check.gd`)
- A beaten Rimefin asked to join, and a rest while it asked did nothing.
- After Y it joined at 14 of 29 HP without spending a turn. After six steps it was 2 tiles behind the leader.
- After N, the next one left and the team stayed the same.
- With four on the team, the next recruit went to the hall roster.
- Down the stairs, the team kept its recruits.
- A faint returned the team and the roster to how the run began.
- A cleared run kept a new recruit.
- Stills: `asking.png`, `joined.png`.

## Known
- The courier hall's roster lives only within the dungeon session. Taking it into the world and the save comes with the job board (slice 6).
- There is no swap at the hall yet to choose who comes on the next run.
