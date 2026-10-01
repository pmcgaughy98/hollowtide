# River Listener move identity

**Design draft, 26 September 2026.** Preston selected this three-stage nonstarter line for development and chose guards and interruptions for its eventual four-move kits. The stage names, move names, and exact effects here are working proposals, not approved canon. This kit follows the [line brief](../creatures/river-listener-line.md), [roster art prompts](../creatures/creature-roster-draft.md), and [defensive move rules](defensive-move-rules-draft.md); it does not add creature or move resources to Godot.

## What the line learns

The split brow and gill fans make sensing a river visible in every stage. Stage I **reads and braces**. Stage II **sends and bends a call**. Stage III **distinguishes a live answer from an empty echo and guides danger away**. Its battle role is a defensive scout with a way to win, not a raw-damage predator. Keep one reliable attack in each four-slot kit so a long fight never strands it without a move.

The names describe actions the creature performs. Visual effects should be water pressure, disturbed silt, brief reflected ripples, and a measurable pause in motion. Avoid generic bubbles, musical-note icons, blue lightning, ghost costumes, or a shark-like water bite.

## Stage I — Cutbank Listener

| Move | Battle intention | Creature action and readable effect |
| --- | --- | --- |
| **Stoneclick** | Reliable Tide attack; unlimited use. | One bracing fin taps a submerged stone. A tight ring runs along the ground to the target; the split brow settles immediately afterward. |
| **Silt Veer** | Evasion or damage reduction against the next incoming hit. | The creature folds low, sweeps a narrow fan of silt aside, and shifts one body-width rather than teleporting. |
| **Brow Pulse** | Focused Tide hit with a modest interruption opportunity. | Both brow paddles open asymmetrically; one compact pressure front crosses the screen. It should be forceful but smaller than a starter's heavy attack. |
| **Bank Brace** | Stronger short guard at a clear opportunity cost. | The fins plant, gill fans close, and a shallow V-shaped wake divides around the body. Its next attack is delayed or forfeited according to the eventual guard rule. |

**Field behavior:** small repeated taps reveal where it is listening. Do not let a Stage I encounter solve the missing return mark or identify the source of the two-note river call.

## Stage II — Bend Caller

| Move | Battle intention | Creature action and readable effect |
| --- | --- | --- |
| **Bendclick** | Reliable Tide attack; unlimited use. | A lower, louder tap carries through the second brow ridge. The narrow wave turns once around a visible bend before reaching the target. |
| **Borrowed Call** | Misdirect the foe's next attack or reduce its force. | The widened gill plates send one call forward and a fainter copy to the side. The visual shows where the false answer came from without declaring it magical. |
| **Ridge Pulse** | Heavy Tide pressure hit with an interruption window. | Three gill plates fan back in sequence and release a stepped wave. The attack reads as trained control, not an explosion. |
| **Counterbend** | Guard, then return a smaller pressure wave when struck. | The body turns broadside, routes the impact past its flank, and sends a short wake back. This is a response, so its timing must be obvious to the player. |

**Stage change:** the extra ridge and broad gill plates make the same sensing anatomy capable of projecting a signal. It can bend a call but cannot yet tell whether the answer came from a living source.

## Stage III — Quietwater Warden

| Move | Battle intention | Creature action and readable effect |
| --- | --- | --- |
| **Deepclick** | Reliable Tide attack; unlimited use. | The broad asymmetric vanes press toward the ground, producing one low ripple with a clear dark center. |
| **Empty Answer** | Proposed Hollow move: read and weaken a misleading incoming action. | The near-black gill chambers briefly lose their reflection. Sound falls away for a beat; a thin outline marks the path the next attack would have taken. No ghost or death imagery. |
| **Channel Seal** | Tide control hit that interrupts or delays one committed enemy action. | The stepped dorsal ridges flex in order while two currents close a narrow channel around the target. Use a restrained impact instead of a giant water blast. |
| **Sheltering Bend** | High-cost guard and measured return of force. | The Warden plants its fins, parts the incoming current around itself, then sends a small return wake. In a later multi-creature design, this could protect a partner; the current battle has only one active creature per side. |

**Stage change:** its sensitivity now separates a live call from an empty echo. That is a protective skill, not proof of the fictional flood's cause.

## Implementation boundary

The current `MoveData` resource stores name, one essence, power, uses, and an effect scene. `BattleScreen` resolves a damaging action in speed order. It cannot yet represent guard, evasion, interruption, a reactive counter, or the proposed Tide/Hollow secondary essence. Those behaviors need explicit rules and feedback before any of the support moves above become playable resources.

The first engine slice could use **Stoneclick, Bendclick, and Deepclick** as unlimited damaging moves once sprites and effect art are approved. Keep the other nine in design until Claude has specified the action/result state model and Grok has balanced costs and counterplay. Do not disguise them as four different damage numbers just to fill the current buttons. Grok can use the action descriptions as non-creature effect and sound briefs; Preston's Forge remains the source of creature sprites.

## Decisions before implementation

1. Does a guard apply to one incoming action, one full round, or until the user's next action?
2. What does an interruption stop: all moves, only a declared heavy move, or a specific visible wind-up?
3. Can a foe read and respond to a reactive counter, so the move creates a choice instead of automatic free damage?
4. Is Hollow secondary essence a property of Stage III, of **Empty Answer** only, or both?

Resolve these with the overall combat rules before assigning final power, uses, learn order, or evolution trigger. The line's current art briefs and one-to-one three-stage evolution remain the visual foundation.
