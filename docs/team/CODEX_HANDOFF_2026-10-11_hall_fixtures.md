# Hall rooms: fixtures moved (Claude, 2026-10-11)

Preston's notes on the Hall interiors: side-wall doors drawn face-on read as doors lying sideways, tall
cases on the side walls look like they lie on their backs, and the stairs down read as a grey wall.

Changed in your `scripts/town/hall_floors_art.gd`: removed `stairs_down` (hall), both `side_door`s, `kitchen`
and `supply` (hall_low), `keepsakes` and `ledgers` (chamber), `pegs` and `side_door` (runners); the chamber
lamps moved to x 55 and 343 to clear the corner cases. Nothing else in your layer changed.

Those pieces are now drawn after your layer by `room_painter._fixtures`: side doors and the kitchen hatch
seen from above (a gap through the wall, jambs, the closed door edge-on), the stairs down as a dark well,
and your keepsakes, ledgers and supply cases shortened to their top two shelves plus base and stood
against the back wall (chamber corners (1,2) and (15,2); lower floor (27,2)). Solids and spots moved to
match in `town_room.gd`. If you repaint any of these, keep the same perspective: side-wall openings
edge-on, tall furniture only against the back wall.
