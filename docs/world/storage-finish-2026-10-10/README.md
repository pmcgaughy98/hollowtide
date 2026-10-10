# Storage exterior and finish, October 10

Next town-finish slice after Home / Item Shop / Wayline Hall. One original low timber storehouse with root beams, moss roofing, cross-braced panels, warm windows/lantern and crates. Strong internal near-black contours mark it as purposeful at Preston's direction. Architecture is an implemented visual proposal, awaiting his review.

## Play / art

F6 scenes/hub_town.tscn, or the existing F5 story to Highbank. Storage is right of Item Shop, with a crate pictogram beside its door. E/J/Enter uses the existing service response; Esc closes it. One source-masked wooden door has closed / ajar / open frames in `buildings["storage"]["frames"][0..2]`; no hookup remains. Existing storage inventory functionality is not claimed; the panel remains Claude's description.

Asset: `assets/sprites/world/storage_2026_10_10/storage_native.png`. Exact world footprint (912,72), canvas144x120, one unchanged door tile(40,7), 24px grid. Uniformly fitted source remains a low broad storehouse; transparent canvas retains the complete source shape and original doorway alignment. No collision/path/camera changes.

## Provenance

Built-in imagegen, one generation, zero Retro. Unmodified output in `sources/storage_original.png`, exact tool prompt in [prompts/final-built-in.txt](prompts/final-built-in.txt). Original descriptive brief also retained. Preparation details in asset-preparation.json: crop transparent safety padding (excluding sub-8-alpha empty-canvas wisps, with two source pixels of room), uniform nearest scaling to134x81, offset(8,38) on144x120. Alpha within the crop is preserved. No architectural compositing, painting, colour replacement or source-image overwrite. Original built-in output remains at its generated_images path too.

Grounding/sign/animated door are original code-native Image textures. Sprite uses the unchanged installed building detail shader; foundations, grass overlap, contact shadow, threshold and worn approach follow the existing terrain colours. The existing optional view hook suppresses the Storage floating plaque only.

## Scope and checks

Runtime: new nativePNG and storage_painter.gd, Storage-only extension in building_exteriors.gd, capture/optional-painter hook in highbank_ground_painter.gd. Collaboration note prepended. Existing Home/shop/Hall, original PNGs/backups, creature finishes/palette locks, title, UI/controllers and Claude rules/state are preserved.

21 native checks pass: exact all ground outside Storage/shadow/apron, exact Home/shop/Hall foundations/signs and all nine door drawings, original footprint, actual near-black interior render, source doorway on existing tile (centre within2pixels), visible distinct door masks, transparent corners, actual walking/native E/sound/open/close/from-approach. Source PNG and optional painter were physically removed one at a time in the review checkout: exact old entire ground/blockout returns, the finished trio stays, service remains usable; restored before install. One fallback fixture left a small shutdown resource warning; the final primary native check was clean except the review certificate diagnostic. No production cleanup change claimed.

Native1152x648 captures in review/: storage_exterior uses fixture framing for the complete building, storage_service uses the actual camera. No production camera change, new interior/storage economy, natural dungeon clear or disk-save claim. Guarded hashes and original snapshots preserve concurrent work. No commit/settings edit or borrowed game assets/code.

## Installed verification

Installed project: 21 Storage native checks pass, plus the existing town and paired Hall-door checks. Final verbose Storage run has no error or shutdown resource warning. The initial live fixture reported two ObjectDB instances / one resource at shutdown; this was not reproduced in the verbose rerun, and no production lifecycle fix is claimed. Live editor import retains the existing stale audio UID / empty-resource-save diagnostics.

Preservation audit passes: 9,257 unowned files match their pre-install hashes; all original art and creature assets match the task baseline. Claude's concurrent essence expansion, creature resource assignments, slower idle animation, UI capture and icon work are retained. Four new unowned files are also retained. Installation and archive verification records are saved beside this note.

## Next

Scroll Keeper, then remaining services and decoration. Keep purposeful buildings outlined through their details; decorative buildings get quieter treatment. Claude owns service inventory/state and dungeon rules.
