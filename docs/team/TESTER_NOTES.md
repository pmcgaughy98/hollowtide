# Tester notes: the Hollowtide alpha (2026-10-22)

Hollowtide is a turn-based dungeon crawler. You arrive as a creature in a flood, a partner finds you, and the two of
you run routes for the Wayline out of the river town of Highbank. The dungeons are Hollows: every step is a turn, and
the wilds move when you do.

## Where the build ends
The build ends after the first growth at the Growth Shrine. You see an end card ('The first stretch of Hollowtide',
three lines of what comes next, 'Thanks for running it.', then 'E  Keep running routes'), and the game drops you back
in Highbank with every Hollow open and the objective line "That's the first stretch. Run the Hollows again or rest at
home." Nothing new comes after that; you can keep running Hollows.

The path, in order: the storm and the soul's arrival; waking on the riverbank mid-flood; the Hollow Mouth (four floors,
no boss); the road to Highbank; the Job Board and the theft; the Wayline Tower and the trial; Rootbank Warren and the
crew; runners named; The Hollow and the Warden; the stone; the Growth Shrine and the first growth; the end card. The
automated run of that path, with the autopilot playing, took about 12 minutes on 2026-10-12; a person who reads every
line will take longer.

## Keyboard or controller
Both work everywhere (2026-10-23). On a controller: D-pad or left stick walks, A attacks and chooses, B goes back,
Y opens the bag, X uses a place or the stairs, hold RB with A, X or Y for moves 1 to 3, Start pauses. Every key and
button can be changed under Options, Rebind keys. The keyboard keys below are the defaults.

In Highbank: WASD / arrows move. E / J / Enter use a place.

In a Hollow: WASD / arrows step. Shift turns in place. J attacks. 1-3 fire moves. I opens the bag.
Z rests a turn. E takes the stairs. Ctrl + direction runs. L shows the recent messages again. T gives team orders.
Y / N answer a recruit's offer.

Menus: P (Start on a controller) pauses: Objective, Team, Bag, Options and Controls, plus Floor and Message log in a Hollow. Arrows move the
focus, Enter chooses, Esc goes back. F11 toggles full screen anywhere, and the same switch is in Options. The Controls
page in the pause menu lists all of this.

## Tab plays the game itself
In a Hollow, Tab switches the autopilot on and off. With it on, the team walks, fights and rests on its own; it is the
driver our automated checks use. Leave it off if you want to test the game. If you switch it on, say so in anything you
report, because the autopilot's choices are not a player's choices. Whether it stays in the build under a name is
Preston's call.

## Not in this build
- The Item Shop, the Scroll Keeper and the Training Yard are shut (a sign at each door). Scrolls found in a Hollow still
  teach moves.
- Mouse play in the field. The mouse works in menus only.
- Anything past the end card: the deeper Hollow, more routes and the crew come later.
- Final names. Hollow Mouth, the pond stone, the traps and several skills carry working names.
- Credits. They come with a later title-screen pass.

## Saves and starting over
The game saves itself whenever the team arrives in Highbank (home from a run, out of a room) and when it sets out for
a Hollow, and when the team sleeps in a bed at home. Leaving through the pause menu (Return to title or Quit Game) saves too; left in a Hollow, Continue on the
title resumes that run at the top of its floor, once. The file is `%APPDATA%\Godot\app_userdata\Hollowtide\team.save`,
with a `.bak` beside it; `menu_preferences.cfg` in the same folder holds your settings. To start over, pick New Game on
the title.

Going down in a Hollow loses the bag (a fresh run starts with one berry), any parcel in it, and the creatures recruited
on that run, then sends the team home. The first time through the Hollow Mouth there is no home yet, so the team tries
again from its first floor. Levels, moves, the partners you set out with, Storage and everything the story gave you
are kept. The screen after a fall lists what went and what stayed.

## What to send
- What you did, in order, and what you expected to happen instead.
- Where you were: the Hollow and the floor (each floor opens on a card with both, and the floor, B1F or B2F, sits
  top left) or the place in Highbank.
- In a Hollow, press L and copy the recent messages.
- A screenshot if something looks wrong, and whether you were windowed or full screen.
- Whether Tab autopilot was on.
- If the game crashes, the newest file in the `logs` folder beside the save file, if there is one.

## Where to send findings
Not set yet. Preston picks the address, and this line changes when he does.
