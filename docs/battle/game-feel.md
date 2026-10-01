# Why it looked AI-made, and what actually fixes it

Written 2026-09-11, after Grok research into firsthand indie developer accounts.

---

## The diagnosis

"Programmer art" is the long-standing term for functional but un-designed placeholder work.
Developers list consistent tells for it. Here is that list against the battle screen as it stood
this morning:

| Tell | Battle screen before today |
|---|---|
| Default engine fonts | Godot's default font throughout |
| Flat colours, perfect rectangles, no hierarchy | ColorRect backdrop, rectangular bars, rectangular buttons |
| No padding or intentional negative space | Absolute positions, no rhythm |
| Linear transitions, or none at all | None. Everything appeared and changed instantly |
| UI that never reacts to game events | Nothing reacted to anything |
| Generic engine widgets | Stock `Button`, stock `ProgressBar` |
| Information as a data dump | "60 / 60" and a damage sentence |

Seven out of seven.

**The mechanism worth naming, because it will happen again.** Every step of this project was
scoped to "does the logic work," and every step passed. Nothing in that loop ever asks whether the
thing feels like anything. Correct and dead is the default output of building feature by feature
with verification at each step, which is exactly how this project has been built. The sameness
across AI-assisted games is not a style. It is what you get when the only test is whether it runs.

---

## What the research actually said

Sources are firsthand developer accounts and two canonical talks, gathered via Grok's X search.
Events and claims are separated below, per the Grok protocol.

### The canonical references (events, checkable)

> **Correction, 2026-09-12.** The first version of this section put a quote in the wrong speaker's
> mouth. Grok attributed the "wobble, squirt" line to Nijman; it is not his. Caught by cross
> checking against Gemini and then resolved against independent sources. Corrected below.

- **"Juice It or Lose It"**, Martin Jonasson and Petri Purho, Nordic Game Jam 2012, repeated at
  GDC Europe 2013. This is where the juice vocabulary comes from. Jonasson describes juice as
  things that "wobble, squirt, bounce around, and make little cute noises", and frames it as
  "maximum output for minimum input". The older root is Gabler, Gray, Shodhan and Kucic, "How to
  Prototype a Game in Under 7 Days" (2005), which defines juice as "constant and bountiful user
  feedback".
- **"The Art of Screenshake"**, Jan Willem Nijman of Vlambeer, INDIGO Classes 2013. Nijman walks
  through thirty incremental changes to a dull shooter prototype, ending on the one he calls
  Meaning. He does not use the word juice. An independent step-by-step enumeration of all thirty
  exists at artificials.ch/juice-up-your-game if you want the full list.
- **Greg Lobanov** (Wandersong, Beastieball) on UI: deliberately chose a strong motif,
  parallelograms and looping patterns, plus simple reusable draw functions, so the whole UI reads
  as authored rather than assembled from defaults. Beastieball is a monster collector, which makes
  this the single most relevant reference on this list.

### The techniques developers repeatedly name

Hit stop on impact. Screen shake with trauma scaled non-linearly. Squash and stretch. Particles,
flashes and trails. Knockback on both attacker and target. Easing curves instead of linear motion.
Layered sound. Input generosity such as coyote time and buffering.

### Three things that matter more than the list

1. **Order.** Fix core responsiveness first. Juice amplifies what already works and cannot rescue
   something that feels wrong underneath.
2. **Restraint.** Constant shake and flash on everything becomes noise and reads as generic in its
   own way. Juice tied to the specific fantasy is what separates handcrafted from checklist polish.
3. **Juice compensates for simpler assets.** This one matters most here. High-quality static art
   with no interactive feedback still feels stiff, and responsiveness makes simpler art feel alive.
   This project has good sprites and no animation budget, so this is the highest-leverage lever
   available.

### The one number, flagged

Hit stop is commonly cited at roughly 40 to 80 milliseconds. **Unverified.** It is used as a
starting value of 60ms in `battle_screen.gd` and should be tuned by feel, not treated as correct.
No other figure from this research was used.

No paid promotion was detected in the results.

---

## What was built today

All of it lives in `battle_screen.gd` under the `impact` section. **None of it touches the rules.**
Damage, turn order and round count are byte-identical before and after, which was verified.

- **Strike animation.** Wind up, lunge, freeze on contact, recover, as one tween. Damage is applied
  at the moment of contact inside the animation rather than before it, so the number and the
  picture agree.
- **Hit stop.** A 60ms freeze at the point of contact.
- **Flash and squash.** The struck creature blows out bright and compresses, then springs back.
- **Screen shake, trauma squared.** A 20 damage hit shakes hard. A 5 damage hit barely moves. The
  squaring is the point: shaking every hit equally is what makes shake read as noise rather than
  weight.
- **Damage numbers** that lift off the target and fade, larger and gold on a strong matchup.
- **HP bars that slide** instead of snapping. A bar that jumps between values is the single
  clearest tell that nothing in a scene is animated.

### Measured at the impact frame

```
foe_hp        40          damage applied
modulate      (5.91, 5.91, 5.91)    flash mid-tween, overbright
scale         (3.3, 2.76)           squashed from (3.0, 3.0)
layer offset  (2.36, -5.89)         shake active
bar value     57.4                  still sliding toward 40
```

Rounds to win: 3, unchanged. Cleanup after the battle returns offset, scale and modulate to rest.

### A bug the shake exposed

Shaking the layer slid the backdrop off the viewport and showed the void behind it. The backdrop is
now grown past the screen by more than the strongest shake. Worth knowing generally: anything that
moves the whole screen needs everything behind it oversized.

---

## What is left, ranked, and deliberately short

Research of this kind produces thirty techniques. Most of them do not apply yet. These five do.

1. **The font.** Godot's default UI font in a pixel art game is the loudest remaining tell, and it
   is a single line to change once a pixel font exists. PixelLab has a `create_font` tool.
2. **Sound.** Developers say audio carries roughly half the weight of an impact. There is currently
   none. A punch without a sharp sound barely registers no matter how good the animation is.
3. **Transitions.** The battle still appears instantly rather than arriving. Creatures should slide
   in, the screen should wipe or flash.
4. **A UI motif.** Custom panels and bars that share the game's visual language, replacing stock
   widgets. This is the Lobanov point and it is the largest single change in perceived quality.
   **It needs a design decision that is not mine to make.**
5. **Overworld feedback.** Footstep rhythm, grass reaction, an encounter flash before the battle.

---

## The decision that is yours

Lobanov picked parallelograms and looping patterns and built everything from them. That choice is
authorship. A tool does not produce it, and an AI inventing one for you produces exactly the
generic result you are trying to avoid.

The question to answer before item 4 gets built: **what shape is this game?** Crystalline facets
and hard angular cuts. Soft rounded organic forms. Torn paper edges. Heavy black outlines like the
sprites themselves. Whatever it is, it then governs panels, bars, buttons, transitions and the
battle frame, and the UI stops looking like it came with the engine.
