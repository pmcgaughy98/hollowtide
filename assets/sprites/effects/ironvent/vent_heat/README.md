# Ironvent Furnace Roar: spine-vent heat

Source: Preston's `C:/Users/pmcga/OneDrive/Documents/HollowTide Sprites/Effect Sheets/IronVent Effect/Ironvent Vent heat-flame.jfif`. The source stays untouched. `tools/cut_ironvent_vent_heat.py` cuts its nine irregularly placed drawings, removes JPEG magenta, snaps the colours to Ironvent's existing blowdown-fire ramp, and registers the vent root at pixel (54, 32) on a transparent 56×48 canvas.

| Frame | What the source drawing shows | Use |
| --- | --- | --- |
| `00_charge` | Small hot core and first sparks | Ignition at vent slit |
| `01_ignite` | Brighter branching spark | Pressure catches |
| `02_first_burst` | Compact flame and dark smoke | First release |
| `03_open` | Fan begins to spread toward tail | Expanding jet |
| `04_full` | Wide dense fan, pale-hot core | Peak |
| `05_sustain` | Another broad fan with a shifted contour | Moving hold |
| `06_turbulence` | Uneven tongues and smoky breakup | Late hold |
| `07_breakup` | Smaller pointed flame with separated fragments | Collapse |
| `08_cool` | Short ember and smoke | End |

All nine are distinct enough to keep. This order follows the material's growth and collapse, not a presumed 4×2 cell grid; the Opal image actually placed nine drawings irregularly. No source drawing was discarded. Each new frame has a binary alpha mask and is palette-matched; the raw JFIF remains the fallback.

`data/moves/ironvent_furnace_roar.tres` lists these frames in `vent_fan_frames`. `battle_screen.gd` plays the sequence for the three horizontal spine vents, still staggered by 0.08 seconds each. The fourth, upward vent keeps its existing static column. The existing `vent_jets` textures remain as fallbacks for moves without animated fan frames.

Visual review: `C:/Users/pmcga/Documents/Codex/2026-09-24/wh/Ironvent-Vent-Heat-Frames.png` shows all nine cuts; `Ironvent-Vent-Heat-Stagger.png` and `Ironvent-Vent-Heat-Overlay.png` show early and peak composites. At peak, the closely spaced vents merge into a broad flame. Preston should judge that look in the battle scene. No Godot play run was requested for this handoff.
